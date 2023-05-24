<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Advisory_CAF_Approved</fullName>
        <description>Advisory CAF Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Compliance_Workflow_Email_Templates/CAF_Approved</template>
    </alerts>
    <alerts>
        <fullName>CAF_Final_Approval</fullName>
        <description>CAF Final Approval</description>
        <protected>false</protected>
        <recipients>
            <recipient>jwaller@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>rfrancis@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Process_Notifications/CAF_Final_Approval</template>
    </alerts>
    <alerts>
        <fullName>Deactivation_for_Lost_Renewal</fullName>
        <description>Deactivation for Lost Renewal</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>alvin.mapilisan@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>keiji.ampil@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>pcuzon@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Compliance_Workflow_Email_Templates/Deactivation_CAF_Needed</template>
    </alerts>
    <alerts>
        <fullName>New_Client_Initial_Compliance_Checks</fullName>
        <description>New Client - Initial Compliance Checks</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Compliance_Workflow_Email_Templates/Prospect_SS5_Call_to_action</template>
    </alerts>
    <alerts>
        <fullName>New_Client_Onboard_Request_to_Enablement</fullName>
        <description>New Client - Onboard Request to Enablement</description>
        <protected>false</protected>
        <recipients>
            <field>Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Compliance_Workflow_Email_Templates/Final_On_boarding_Request_to_Enablement</template>
    </alerts>
    <alerts>
        <fullName>Request_for_ID_for_Name_Change_CAF</fullName>
        <description>Request for ID for Name Change CAF</description>
        <protected>false</protected>
        <recipients>
            <field>Change_Info_Provided_by__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Compliance_Workflow_Email_Templates/External_Name_Change_ID_Request</template>
    </alerts>
    <alerts>
        <fullName>Sales_Opportunity_Stage5</fullName>
        <description>Sales Opportunity (Stage5)</description>
        <protected>false</protected>
        <recipients>
            <recipient>System_Administrator</recipient>
            <type>role</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Process_Notifications/New_Client_Onboarding_Request</template>
    </alerts>
    <alerts>
        <fullName>Transitioned_CAF</fullName>
        <description>Transitioned CAF</description>
        <protected>false</protected>
        <recipients>
            <recipient>sworsham@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Compliance_Workflow_Email_Templates/Transitioned_CAF</template>
    </alerts>
</Workflow>
