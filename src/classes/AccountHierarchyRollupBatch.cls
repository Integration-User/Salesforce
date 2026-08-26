/** SF-2296 - Recalculates Account hierarchy rollups for recently modified Accounts. 
* SF-2247 : Rollup Number of Clients in Hierarchy
*/
@SuppressWarnings('PMD')
public without sharing class AccountHierarchyRollupBatch implements Database.Batchable<AggregateResult>, Database.Stateful, Schedulable {
    private static final Integer DEFAULT_LOOKBACK_DAYS = 2;
    private static final Set<String> CLIENT_RELATIONSHIPS = new Set<String>{'Client', 'Client + Trial'};
    private static final String REPORT_EMAIL = 'mgupta@greenstreet.com';
    private Integer lookbackDays;
    private List<RollupReportRow> reportRows = new List<RollupReportRow>();

    /** Uses the default seven-day processing window. */
    public AccountHierarchyRollupBatch() {
        this(DEFAULT_LOOKBACK_DAYS);
    }

    /**
     * Uses a configurable Account modification lookback window.
     * @param lookbackDays Number of days to include.
     */
    public AccountHierarchyRollupBatch(Integer lookbackDays) {
        this.lookbackDays = lookbackDays == null || lookbackDays < 0 ? DEFAULT_LOOKBACK_DAYS : lookbackDays;
    }

    /**
    * Selects each Organization Account that is a parent of another Account.
     * @param context Batch execution context.
     * @return Unique parent Account groups.
     */
    public Iterable<AggregateResult> start(Database.BatchableContext context) {
        Date modifiedSince = Date.today().addDays(-lookbackDays);
        return [
            SELECT ParentId parentId, COUNT(Id) childCount
            FROM Account
            WHERE ParentId != null
            AND Parent.RecordType.DeveloperName = 'Organization_Account'
            AND LastModifiedDate >= :modifiedSince
            GROUP BY ParentId
        ];
    }

    /**
     * Recalculates affected Organization Accounts in one bulk operation.
     * @param context Batch execution context.
    * @param scope Unique parent Account groups.
     */
    public void execute(Database.BatchableContext context, List<AggregateResult> scope) {
        if (scope == null || scope.isEmpty()) {
            return;
        }

        Set<Id> parentIds = new Set<Id>();
        for (AggregateResult result : scope) {
            parentIds.add((Id) result.get('parentId'));
        }
        Map<Id, Account> parentById = loadParentAccounts(parentIds);
        List<Account> children = loadChildren(parentIds);
        Map<Id, List<Account>> childrenByParentId = groupChildrenByParent(children);

        List<Account> updates = new List<Account>();
        for (Id rootId : parentIds) {
            Account rootAccount = parentById.get(rootId);
            if (rootAccount == null || rootAccount.RecordType == null
                || rootAccount.RecordType.DeveloperName != 'Organization_Account') {
                continue;
            }
            List<Account> parentChildren = childrenByParentId.get(rootId);
            RollupValues values = calculateRollup(parentChildren);
            Account updateAccount = new Account(Id = rootId);
            updateAccount.Clients_In_Hierarchy__c = values.clientCount;
            updateAccount.put('Number_of_Accounts_in_Hierarchy__c', values.accountCount);
            updateAccount.put('Total_ARR_in_Client_Hierarchy__c', values.totalArr);
            updates.add(updateAccount);
            for (Account child : parentChildren) {
                if (CLIENT_RELATIONSHIPS.contains(child.Type)) {
                    Account childUpdate = new Account(Id = child.Id);
                    childUpdate.put('Number_of_Accounts_in_Hierarchy__c', values.accountCount);
                    updates.add(childUpdate);
                }
            }
            RollupReportRow reportRow = new RollupReportRow();
            reportRow.accountName = rootAccount.Name;
            reportRow.accountId = rootId;
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
        Database.executeBatch(new AccountHierarchyRollupBatch(DEFAULT_LOOKBACK_DAYS), 1);
    }

    @SuppressWarnings('PMD')
    private static Map<Id, Account> loadParentAccounts(Set<Id> parentIds) {
        return new Map<Id, Account>([
            SELECT Id, Name, ParentId, Type, Annual_Recurring_Revenue__c, RecordType.DeveloperName
            FROM Account
            WHERE Id IN :parentIds
        ]);
    }

    @SuppressWarnings('PMD')
    private static List<Account> loadChildren(Set<Id> parentIds) {
        return [
            SELECT Id, Name, ParentId, Type, Annual_Recurring_Revenue__c
            FROM Account
            WHERE ParentId IN :parentIds
        ];
    }

    private static Map<Id, List<Account>> groupChildrenByParent(List<Account> children) {
        Map<Id, List<Account>> childrenByParentId = new Map<Id, List<Account>>();
        for (Account child : children) {
            if (!childrenByParentId.containsKey(child.ParentId)) {
                childrenByParentId.put(child.ParentId, new List<Account>());
            }
            childrenByParentId.get(child.ParentId).add(child);
        }
        return childrenByParentId;
    }

    private static RollupValues calculateRollup(List<Account> children) {
        RollupValues values = new RollupValues();
        values.accountCount = children == null ? 0 : children.size();
        if (children == null) {
            return values;
        }
        for (Account child : children) {
            if (CLIENT_RELATIONSHIPS.contains(child.Type)) {
                values.clientCount++;
                if (child.Annual_Recurring_Revenue__c != null) {
                    values.totalArr += child.Annual_Recurring_Revenue__c;
                }
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
