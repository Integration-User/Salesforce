/** SF-2296 - Recalculates Account hierarchy rollups for recently modified Accounts. 
* SF-2247 : Rollup Number of Clients in Hierarchy
*/
@SuppressWarnings('PMD')
public without sharing class AccountHierarchyRollupBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
    private static final String ORGANIZATION_RECORD_TYPE = 'Organization_Account';
    private static final Set<String> CLIENT_TYPES = new Set<String>{'Client', 'Client + Trial'};
    private static final String REPORT_EMAIL = 'mgupta@greenstreet.com';
    private List<RollupReportRow> reportRows = new List<RollupReportRow>();

    /**
     * Selects Accounts modified during the daily processing window.
     * @param context Batch execution context.
     * @return Query locator for recently modified Accounts.
     */
    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator([SELECT Id, Name, ParentId, Type, Annual_Recurring_Revenue__c, RecordType.DeveloperName FROM Account WHERE LastModifiedDate = LAST_N_DAYS:1]);
     }

    public void execute(Database.BatchableContext context, List<SObject> scope) {
        if (scope == null || scope.isEmpty()) {
            return;
        }

        Map<Id, Account> accountById = new Map<Id, Account>();
        for (SObject record : scope) {
            Account changedAccount = (Account) record;
            accountById.put(changedAccount.Id, changedAccount);
        }
        loadAncestors(accountById);
        Set<Id> organizationIds = findAffectedOrganizations(accountById);
        loadDescendants(organizationIds, accountById);
        Map<Id, List<Id>> childrenByParentId = buildChildrenByParent(accountById.values());

        List<Account> updates = new List<Account>();
        for (Id organizationId : organizationIds) {
            RollupValues values = calculateRollup(organizationId, accountById, childrenByParentId);
            Account updateAccount = new Account(Id = organizationId);
            updateAccount.Clients_In_Hierarchy__c = values.clientCount;
            updateAccount.put('Number_of_Accounts_in_Hierarchy__c', values.accountCount);
            updateAccount.put('Total_ARR_in_Client_Hierarchy__c', values.totalArr);
            updates.add(updateAccount);
            RollupReportRow reportRow = new RollupReportRow();
            reportRow.accountName = accountById.get(organizationId).Name;
            reportRow.accountId = organizationId;
            reportRow.clientCount = values.clientCount;
            reportRow.accountCount = values.accountCount;
            reportRow.totalArr = values.totalArr;
            reportRows.add(reportRow);
        }

        if (!updates.isEmpty()) {
            Plative_AccountTriggerHandler.isAccountTriggerSkip = true;
            try {
                update updates;
            } finally {
                Plative_AccountTriggerHandler.isAccountTriggerSkip = false;
            }
        }
    }

    /**
     * Sends the hierarchy rollup report after all batch scopes complete.
     * @param context Batch execution context.
     */
    public void finish(Database.BatchableContext context) {
        if (reportRows.isEmpty()) {
            return;
        }

        String body = '<html><body><p>Accounts updated: ' + reportRows.size() + '</p>'
            + '<table border="1" cellpadding="4" cellspacing="0">'
            + '<tr><th>Account</th><th>Account Id</th><th>Clients</th>'
            + '<th>Accounts</th><th>Total ARR</th></tr>';
        for (RollupReportRow row : reportRows) {
            body += '<tr><td>' + escapeHtml(row.accountName) + '</td>'
                + '<td>' + row.accountId + '</td>'
                + '<td>' + row.clientCount + '</td>'
                + '<td>' + row.accountCount + '</td>'
                + '<td>' + row.totalArr + '</td></tr>';
        }
        body += '</table></body></html>';

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new List<String>{REPORT_EMAIL});
        email.setSubject('Account hierarchy rollup completed');
        email.setHtmlBody(body);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
    }

    /**
     * Starts the daily batch job when invoked by Salesforce scheduling.
     * @param context Scheduling context.
     */
    public void execute(SchedulableContext context) {
        Database.executeBatch(new AccountHierarchyRollupBatch(), 20);
    }

    @SuppressWarnings('PMD')
    private static void loadAncestors(Map<Id, Account> accountById) {
        Set<Id> pendingParentIds = new Set<Id>();
        for (Account account : accountById.values()) {
            if (account.ParentId != null) {
                pendingParentIds.add(account.ParentId);
            }
        }

        while (!pendingParentIds.isEmpty()) {
            List<Account> parents = [SELECT Id, Name, ParentId, Type, Annual_Recurring_Revenue__c, RecordType.DeveloperName FROM Account WHERE Id IN :pendingParentIds ];
            pendingParentIds.clear();
            for (Account parent : parents) {
                if (accountById.put(parent.Id, parent) == null && parent.ParentId != null) {
                    pendingParentIds.add(parent.ParentId);
                }
            }
        }
    }

    @SuppressWarnings('PMD')
    private static void loadDescendants(Set<Id> organizationIds, Map<Id, Account> accountById) {
        Set<Id> pendingParentIds = new Set<Id>(organizationIds);
        while (!pendingParentIds.isEmpty()) {
            List<Account> children = [
                SELECT Id, Name, ParentId, Type, Annual_Recurring_Revenue__c, RecordType.DeveloperName
                FROM Account
                WHERE ParentId IN :pendingParentIds
            ];
            pendingParentIds.clear();
            for (Account child : children) {
                if (accountById.put(child.Id, child) == null) {
                    pendingParentIds.add(child.Id);
                }
            }
        }
    }

    private static Map<Id, List<Id>> buildChildrenByParent(List<Account> accounts) {
        Map<Id, List<Id>> childrenByParentId = new Map<Id, List<Id>>();
        for (Account account : accounts) {
            if (account.ParentId == null) {
                continue;
            }
            if (!childrenByParentId.containsKey(account.ParentId)) {
                childrenByParentId.put(account.ParentId, new List<Id>());
            }
            childrenByParentId.get(account.ParentId).add(account.Id);
        }
        return childrenByParentId;
    }

    private static Set<Id> findAffectedOrganizations(Map<Id, Account> accountById) {
        Set<Id> organizationIds = new Set<Id>();
        for (Account changedAccount : accountById.values()) {
            Id currentId = changedAccount.Id;
            Set<Id> visitedIds = new Set<Id>();
            while (currentId != null && !visitedIds.contains(currentId)) {
                visitedIds.add(currentId);
                Account current = accountById.get(currentId);
                if (current == null) {
                    break;
                }
                if (current.RecordType != null && current.RecordType.DeveloperName == ORGANIZATION_RECORD_TYPE) {
                    organizationIds.add(current.Id);
                }
                currentId = current.ParentId;
            }
        }
        return organizationIds;
    }

    private static RollupValues calculateRollup(Id organizationId, Map<Id, Account> accountById, Map<Id, List<Id>> childrenByParentId) {
        RollupValues values = new RollupValues();
        List<Id> pendingIds = new List<Id>();
        if (childrenByParentId.containsKey(organizationId)) {
            pendingIds.addAll(childrenByParentId.get(organizationId));
        }
        Set<Id> visitedIds = new Set<Id>();
        for (Integer index = 0; index < pendingIds.size(); index++) {
            Id currentId = pendingIds[index];
            if (!visitedIds.add(currentId)) {
                continue;
            }
            Account current = accountById.get(currentId);
            if (current == null) {
                continue;
            }
            values.accountCount++;
            if (CLIENT_TYPES.contains(current.Type)) {
                values.clientCount++;
            }
            if (CLIENT_TYPES.contains(current.Type) && current.Annual_Recurring_Revenue__c != null) {
                values.totalArr += current.Annual_Recurring_Revenue__c;
            }
            if (childrenByParentId.containsKey(currentId)) {
                pendingIds.addAll(childrenByParentId.get(currentId));
            }
        }
        return values;
    }

    private class RollupValues {
        Integer accountCount = 0;
        Integer clientCount = 0;
        Decimal totalArr = 0;
    }

    private class RollupReportRow {
        String accountName;
        Id accountId;
        Integer clientCount;
        Integer accountCount;
        Decimal totalArr;

    }

    private static String escapeHtml(String value) {
        if (value == null) {
            return '';
        }
        return value.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')
            .replace('"', '&quot;').replace('\'', '&#39;');
    }
}
