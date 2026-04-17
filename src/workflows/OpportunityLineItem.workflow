<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>React_News_Notification_Lost_Product</fullName>
        <ccEmails>requests@reactnews.com</ccEmails>
        <description>React News Notification Lost Product</description>
        <protected>false</protected>
        <recipients>
            <recipient>Opportunity Owner</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>cespina@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ksantos@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/React_News_Lost_Product</template>
    </alerts>
    <rules>
        <fullName>Opportunity Product Name</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Won,Closed Lost,Suspended</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
