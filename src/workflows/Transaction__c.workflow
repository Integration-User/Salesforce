<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Invoice_Overdue_past_30_days_Alert</fullName>
        <description>Invoice Overdue past 30 days Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Billing_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Process_Notifications/Invoice_Overdue_past_30_days</template>
    </alerts>
</Workflow>
