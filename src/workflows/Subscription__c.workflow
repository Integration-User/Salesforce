<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>NextGen_Seats_Decrease_1_day_Subscription</fullName>
        <description>NextGen - Seats Decrease 1 day Subscription</description>
        <protected>false</protected>
        <recipients>
            <recipient>Sales_Ops</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <field>Opportunity_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>NextGen_Renewal_Emails/Renewal_Subscribers_Decrease_1_Day</template>
    </alerts>
    <alerts>
        <fullName>NextGen_Seats_Decrease_5_days_Subscription</fullName>
        <description>NextGen - Seats Decrease 5 days	Subscription</description>
        <protected>false</protected>
        <recipients>
            <recipient>Sales_Ops</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <field>Opportunity_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>NextGen_Renewal_Emails/Renewal_Subscribers_Decrease_5_Days</template>
    </alerts>
    <alerts>
        <fullName>NextGen_Seats_Decrease_Subscription</fullName>
        <description>NextGen - Seats Decrease Subscription</description>
        <protected>false</protected>
        <recipients>
            <recipient>Sales_Ops</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <field>Opportunity_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>NextGen_Renewal_Emails/Renewal_Subscribers_Decrease</template>
    </alerts>
    <alerts>
        <fullName>NextGen_Seats_Decrease_Subscription_Unable_to_Decrease</fullName>
        <description>NextGen - Seats Decrease Subscription - Unable to Decrease</description>
        <protected>false</protected>
        <recipients>
            <recipient>Sales_Ops</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <field>Opportunity_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>NextGen_Renewal_Emails/Renewal_Subscribers_Decrease</template>
    </alerts>
</Workflow>
