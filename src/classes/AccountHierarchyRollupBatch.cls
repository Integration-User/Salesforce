/** SF-2296 - Recalculates Account hierarchy rollups for recently modified Accounts. 
* SF-2247 : Rollup Number of Clients in Hierarchy
*/
public without sharing class AccountHierarchyRollupBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
    private static final String ORGANIZATION_RECORD_TYPE = 'Organization_Account';
    private static final Set<String> CLIENT_TYPES = new Set<String>{'Client', 'Client + Trial'};
    private static final String REPORT_EMAIL = 'mgupta@greenstreet.com';
    private List<RollupReportRow> reportRows = new List<RollupReportRow>();

    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator([SELECT Id FROM Account WHERE LastModifiedDate = LAST_N_DAYS:1]);
    }

    /**
     * Recalculates affected Organization Accounts in one bulk operation.
     * @param context Batch execution context.
     * @param scope Accounts modified during the daily processing window.
     */
    public void execute(Database.BatchableContext context, List<SObject> scope) {
        if (scope == null || scope.isEmpty()) {
            return;
        }

        Set<Id> changedAccountIds = new Set<Id>();
        for (SObject record : scope) {
            changedAccountIds.add((Id) record.get('Id'));
        }
        List<Account> allAccounts = loadAccounts();
        Map<Id, Account> accountById = new Map<Id, Account>(allAccounts);
        Map<Id, List<Id>> childrenByParentId = buildChildrenByParent(allAccounts);
        Set<Id> organizationIds = findAffectedOrganizations(changedAccountIds, accountById);

        List<Account> updates = new List<Account>();
        for (Id organizationId : organizationIds) {
            RollupValues values = calculateRollup(organizationId, accountById, childrenByParentId);
            Account updateAccount = new Account(Id = organizationId);
            updateAccount.Clients_In_Hierarchy__c = values.clientCount;
            updateAccount.put('Number_of_Accounts_in_Hierarchy__c', values.accountCount);
            updateAccount.put('Total_ARR_in_Client_Hierarchy__c', values.totalArr);
            updates.add(updateAccount);
            reportRows.add(new RollupReportRow(
                accountById.get(organizationId).Name,
                organizationId,
                values.clientCount,
                values.accountCount,
                values.totalArr
            ));
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
        Database.executeBatch(new AccountHierarchyRollupBatch(), 200);
    }

    private static List<Account> loadAccounts() {
        return [
            SELECT Id, Name, ParentId, Type, Annual_Recurring_Revenue__c, RecordType.DeveloperName
            FROM Account
        ];
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

    private static Set<Id> findAffectedOrganizations(Set<Id> changedAccountIds, Map<Id, Account> accountById) {
        Set<Id> organizationIds = new Set<Id>();
        for (Id changedAccountId : changedAccountIds) {
            Id currentId = changedAccountId;
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
        while (!pendingIds.isEmpty()) {
            Id currentId = pendingIds.remove(0);
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

        RollupReportRow(String accountName, Id accountId, Integer clientCount, Integer accountCount, Decimal totalArr) {
            this.accountName = accountName;
            this.accountId = accountId;
            this.clientCount = clientCount;
            this.accountCount = accountCount;
            this.totalArr = totalArr;
        }
    }

    private static String escapeHtml(String value) {
        if (value == null) {
            return '';
        }
        return value.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')
            .replace('"', '&quot;').replace('\'', '&#39;');
    }
}