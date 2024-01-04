<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>BBFTD_Activation_Email</fullName>
        <description>BBFTD Activation Email</description>
        <protected>false</protected>
        <recipients>
            <recipient>astover@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>enget@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ksantos@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Process_Notifications/BBFTD_to_clops</template>
    </alerts>
    <alerts>
        <fullName>Begin_Onboarding_Process</fullName>
        <description>Begin Onboarding Process</description>
        <protected>false</protected>
        <recipients>
            <recipient>ksantos@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Compliance_Workflow_Email_Templates/Prospect_SS5_Call_to_action</template>
    </alerts>
    <alerts>
        <fullName>Closed_Won_Renewal_Alert</fullName>
        <description>Closed Won Renewal Alert</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <recipient>Account Owner Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Sales</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Process_Notifications/Closed_Won_Renewal_Alert</template>
    </alerts>
    <alerts>
        <fullName>DDS_ScoreApprovalApproved</fullName>
        <description>Score approval - approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Approval_Email_Templates/DDS_ScoreApproved</template>
    </alerts>
    <alerts>
        <fullName>DDS_ScoreApprovalRejected</fullName>
        <description>Score approval - rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Approval_Email_Templates/DDS_ScoreRejected</template>
    </alerts>
    <alerts>
        <fullName>Deactivate_Client</fullName>
        <description>Deactivate Client</description>
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
        <fullName>Discount_Approved</fullName>
        <description>Discount Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Approval_Email_Templates/Discount_Approved</template>
    </alerts>
    <alerts>
        <fullName>Discount_Rejected</fullName>
        <description>Discount Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Approval_Email_Templates/Discount_Rejected</template>
    </alerts>
    <alerts>
        <fullName>Lost_Client_Transition_Alert</fullName>
        <description>Lost Client Transition Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>esteiner@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ksantos@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Process_Notifications/Lost_Client_Transition</template>
    </alerts>
    <alerts>
        <fullName>New_Advisory_Referral</fullName>
        <ccEmails>ksantos@greenstreet.com</ccEmails>
        <description>New Advisory Referral</description>
        <protected>false</protected>
        <recipients>
            <recipient>aspindler@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>sjensen@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Process_Notifications/Advisory_Referral_Notification</template>
    </alerts>
    <alerts>
        <fullName>New_Equity_Client_Onboarding_Request</fullName>
        <description>New Equity Client - Onboarding Request</description>
        <protected>false</protected>
        <recipients>
            <recipient>ksantos@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Process_Notifications/New_Client_Onboarding_Request</template>
    </alerts>
    <alerts>
        <fullName>New_Subscription_Client_Onboarding_Request</fullName>
        <description>New Subscription Client - Onboarding Request</description>
        <protected>false</protected>
        <recipients>
            <recipient>cmccrory@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>dcruickshanks@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>hparkinson@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>kbenning@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>mfernandez@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>mkerbs@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>msheahan@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>olivia.houlder@reactnews.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>peager@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Process_Notifications/New_Client_Onboarding_Request</template>
    </alerts>
    <alerts>
        <fullName>One_time_client_on_boarding_request</fullName>
        <description>One time client on-boarding request</description>
        <protected>false</protected>
        <recipients>
            <recipient>ksantos@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Process_Notifications/One_Time_Client_Onboarding_Request</template>
    </alerts>
    <alerts>
        <fullName>Online_Order_Closed_Won</fullName>
        <description>Online Order Closed Won</description>
        <protected>false</protected>
        <recipients>
            <recipient>cmccrory@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>dcruickshanks@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>esteiner@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jblanden@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jschulz@greenstreetnews.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>khoffman@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>krapadas@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>mrichardson@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Process_Notifications/Online_Order_Closed_Won</template>
    </alerts>
    <alerts>
        <fullName>Pending_Pricing_Discount_Request</fullName>
        <description>Pending Pricing Discount Request</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>khoffman@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Approval_Email_Templates/Discount_Request_Email</template>
    </alerts>
    <alerts>
        <fullName>Referral_Status_Update</fullName>
        <description>Referral Status Update</description>
        <protected>false</protected>
        <recipients>
            <field>BDR_Referred_By__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Referred_By__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Referral_Templates/Referral_Status_Update</template>
    </alerts>
    <alerts>
        <fullName>SDO_Sales_Owner_for_Review_Email_Alert</fullName>
        <description>SDO Sales Owner for Review Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Sales_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/SDO_New_Opportunity_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>Send_Email_About_Expiring_Trial</fullName>
        <description>Send Email About Expiring Trial</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Manager</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Opportunity Owner</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Process_Notifications/Trial_Expiring_Opt_Out_tomorrow</template>
    </alerts>
    <alerts>
        <fullName>Terms_Request_Approved</fullName>
        <description>Terms Request Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Approval_Email_Templates/Terms_Approved</template>
    </alerts>
    <alerts>
        <fullName>Terms_Request_Rejected</fullName>
        <description>Terms Request Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Approval_Email_Templates/Terms_Rejected</template>
    </alerts>
    <alerts>
        <fullName>Trial_Deactivation_Email_Alert</fullName>
        <description>Trial Deactivation Email Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>Opportunity Owner</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Trial_Deactivation_Access_Template</template>
    </alerts>
    <alerts>
        <fullName>Trial_Ending_Tomorrow</fullName>
        <description>Trial Ending Tomorrow</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Process_Notifications/Trial_Expiring_Opt_Out_tomorrow</template>
    </alerts>
    <alerts>
        <fullName>Trial_Expiring_Opt_Out_Coming_due</fullName>
        <description>Trial Expiring/Opt-Out Coming due</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>greenstreet-newbusinesssales@greenstreetadvisors.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Process_Notifications/Trial_Expiring_Opt_Out_tomorrow</template>
    </alerts>
    <alerts>
        <fullName>Trial_Expiring_Today</fullName>
        <description>Trial Expiring Today</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Process_Notifications/Trial_Expiring_Opt_Out_today</template>
    </alerts>
    <alerts>
        <fullName>Trial_Expiring_Today_2</fullName>
        <description>Trial Expiring Today</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Process_Notifications/Trial_Expiring_Opt_Out_today</template>
    </alerts>
    <alerts>
        <fullName>Trial_Expiring_Tomorrow_2</fullName>
        <description>Trial Expiring Tomorrow</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Process_Notifications/Trial_Expiring_Opt_Out_tomorrow</template>
    </alerts>
    <alerts>
        <fullName>Trial_Expiring_in_1_Week_2</fullName>
        <description>Trial Expiring in 1 Week</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Process_Notifications/Trial_Expiring_Opt_Out_1weeks</template>
    </alerts>
    <alerts>
        <fullName>Trial_Expiring_in_1_week</fullName>
        <description>Trial Expiring in 1 week</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Process_Notifications/Trial_Expiring_Opt_Out_1weeks</template>
    </alerts>
    <alerts>
        <fullName>Trial_Lost_Deactivate</fullName>
        <description>Trial Lost - Deactivate</description>
        <protected>false</protected>
        <recipients>
            <recipient>alvin.mapilisan@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>keiji.ampil@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ksantos@greenstreet.com</recipient>
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
        <fullName>Usage_Drop_Alert</fullName>
        <description>Usage Drop Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Process_Notifications/Usage_Drop_Email</template>
    </alerts>
    <alerts>
        <fullName>Won_Opp_alert</fullName>
        <description>Won Opp alert to New Sales</description>
        <protected>false</protected>
        <recipients>
            <recipient>Associate_Sales_Manager</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>BDR</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>BDR_Manager</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>Sales</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>Sales_Manager</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>UK_Associate_Sales_Manager</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>UK_News_Manager</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>UK_News_Sales</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>UK_Sales</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>bsaks@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>cmccrory@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>dfigenshu@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>dperson@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>esteiner@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jblanden@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jcohen@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jguilfoy@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>khoffman@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ksantos@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>lhewett@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>mfernandez@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>msheahan@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>rramos@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>greenstreet-newbusinesssales@greenstreetadvisors.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Process_Notifications/Closed_Won_Alert</template>
    </alerts>
    <alerts>
        <fullName>Won_Opp_from_Referral</fullName>
        <description>Won Opp from Referral</description>
        <protected>false</protected>
        <recipients>
            <recipient>New_Sales</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>cmccrory@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>greenstreet-newbusinesssales@greenstreetadvisors.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Process_Notifications/Closed_Won_Alert_BDR</template>
    </alerts>
    <alerts>
        <fullName>X60_Day_Referral_Check_In</fullName>
        <description>60 Day Referral Check In</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Referred_By__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Referral_Templates/X60_Day_Referral_Check_In</template>
    </alerts>
    <fieldUpdates>
        <fullName>Approval_Status_Pending</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Pending</literalValue>
        <name>Approval Status Pending</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Status_to_Approved</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Approval Status to Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Status_to_Approved_Terms</fullName>
        <description>Approved</description>
        <field>Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Approval Status to Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Status_to_Not_Approved</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Not Approved</literalValue>
        <name>Approval Status to Not Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Status_to_Rejected_Terms</fullName>
        <description>Terms Rejected</description>
        <field>Approval_Status__c</field>
        <literalValue>Not Approved</literalValue>
        <name>Approval Status to Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DDS_ApprovedARR</fullName>
        <description>Stamp the opportunity total ARR that was approved</description>
        <field>DDS_ApprovedARR__c</field>
        <formula>AverageTotalARR__c</formula>
        <name>Approved ARR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DDS_ApprovedScore</fullName>
        <description>Stamp the score that was approved</description>
        <field>DDS_ApprovedScore__c</field>
        <formula>TEXT( DDS_ScoreAssignment__c )</formula>
        <name>Approved Score</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DDS_ScoreAPApproved</fullName>
        <field>DDS_ApprovalProcessStatus__c</field>
        <literalValue>Approved</literalValue>
        <name>Score AP - Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DDS_ScoreAPInProgress</fullName>
        <field>DDS_ApprovalProcessStatus__c</field>
        <literalValue>In Progress</literalValue>
        <name>Score AP - In Progress</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DDS_ScoreAPRecall</fullName>
        <field>DDS_ApprovalProcessStatus__c</field>
        <name>Score AP - Recall</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DDS_ScoreAPRejected</fullName>
        <field>DDS_ApprovalProcessStatus__c</field>
        <literalValue>Rejected</literalValue>
        <name>Score AP - Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Research_Products_Stamp</fullName>
        <field>Research_Products2__c</field>
        <formula>EUR_REIT__c &amp; BR() &amp; EUR_REA__c  &amp; BR () &amp; US_REA__c &amp; BR () &amp; US_REIT__c</formula>
        <name>Research Products Stamp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Class_ID</fullName>
        <field>Class_ID__c</field>
        <formula>9</formula>
        <name>Update Class ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Close_Date</fullName>
        <description>Changes the Close Date to be Today + 90 days</description>
        <field>CloseDate</field>
        <formula>TODAY()+90</formula>
        <name>Update Close Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Close_Date_Pushes</fullName>
        <field>Close_Date_Pushes__c</field>
        <formula>NULLVALUE(Close_Date_Pushes__c,0)+1</formula>
        <name>Update Close Date Pushes</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Close_Date_based_off_Days_Stalled</fullName>
        <field>CloseDate</field>
        <formula>IF(Days_Stalled__c &gt; 120, TODAY()+180, PRIORVALUE( CloseDate))</formula>
        <name>Update Close Date based off Days Stalled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Close_Date_to_Today</fullName>
        <field>CloseDate</field>
        <formula>TODAY()</formula>
        <name>Update Close Date to Today</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Department_ID</fullName>
        <field>Department_Id__c</field>
        <formula>8</formula>
        <name>Update Department ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Last_Stage_Change</fullName>
        <field>Last_Stage_Change__c</field>
        <formula>IF(ISCHANGED(StageName), TODAY(), (Last_Stage_Change__c))</formula>
        <name>Update Last Stage Change</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Made_Active_By_field</fullName>
        <description>Updates Made Active By field if it&apos;s blank. This can be deleted as well.</description>
        <field>Made_Active_By__c</field>
        <formula>CreatedBy.FirstName + &quot; &quot; +  CreatedBy.LastName</formula>
        <name>Update Made Active By field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_News_Products</fullName>
        <field>News_Products2__c</field>
        <formula>News_ABAlert__c &amp;  BR() &amp; News_CMAlert__c &amp; BR() &amp; News_HFAlert__c</formula>
        <name>Update News Products</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Opp_Name</fullName>
        <field>Name</field>
        <formula>Text(Sales_Type__c)&amp;&quot; - &quot;&amp;Account.Name&amp;&quot; &quot;&amp;Renewal_Month__c&amp;&quot; &quot;&amp; Renewal_Year__c</formula>
        <name>Update Opp Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Prospect_Since_field</fullName>
        <description>Updates Prospect Since field with Opportunity Created date. ( I think this can be deleted now. - KS 7/2021)</description>
        <field>Prospect_Since__c</field>
        <formula>DATEVALUE(CreatedDate)</formula>
        <name>Update Prospect Since field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Automated Opp Names</fullName>
        <actions>
            <name>Update_Opp_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.LastModifiedById</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Calculate Average to Close</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.IsClosed</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>When Opportunity is marked closed, calculates the average to close days</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>News Products</fullName>
        <actions>
            <name>Update_News_Products</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>(Ischanged(News_ABAlert__c) || ischanged(News_CMAlert__c) || ischanged(News_HFAlert__c)||ischanged( News_Product_Description__c )) || isnew()</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Populate Department %26 Class ID</fullName>
        <actions>
            <name>Update_Class_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Department_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Opportunity.Class__c</field>
            <operation>equals</operation>
            <value>Corporate</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Department__c</field>
            <operation>equals</operation>
            <value>Corporate</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Populate Discount Percentage Field</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Discounts_over_10_Count__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Approval_Status__c</field>
            <operation>notEqual</operation>
            <value>Approved,Not Approved</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Research Products</fullName>
        <actions>
            <name>Research_Products_Stamp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>(Ischanged(EUR_REIT__c) || ischanged(EUR_REA__c) || ischanged(US_REA__c) ||ischanged( US_REIT__c)) || isnew()</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Sent Email about trial</fullName>
        <actions>
            <name>Send_Email_About_Expiring_Trial</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.Trial_End_Date__c</field>
            <operation>equals</operation>
            <value>TOMORROW</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.IsClosed</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Send Email alert that trial is expiring in 1 day</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Close Date to 3 months</fullName>
        <actions>
            <name>Update_Close_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>When a SALES Opportunity is first created, set the Close Date to 3 months from today (90 days)</description>
        <formula>AND(    (ISNEW()),    ( RecordType.DeveloperName = &quot;Sales_Opportunity&quot;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Opp Closed Lost Date to TODAY</fullName>
        <actions>
            <name>Update_Close_Date_to_Today</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.Last_Stage_Change__c</field>
            <operation>equals</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Won,Closed Lost</value>
        </criteriaItems>
        <description>If Opp Stage is changed and Stage is Closed Lost/Won, on save set Close Date to TODAY</description>
        <failedMigrationToolVersion>246.16.8</failedMigrationToolVersion>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Trial Expiring</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.IsClosed</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Email alert about trial/opt-out coming due in 1 week and today.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Trial_Expiring_in_1_Week_2</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Opportunity.Trial_End_Date__c</offsetFromField>
            <timeLength>-7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <offsetFromField>Opportunity.Trial_End_Date__c</offsetFromField>
            <timeLength>-1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Trial_Expiring_Today_2</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Opportunity.Trial_End_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Update Close Date Pushes</fullName>
        <actions>
            <name>Update_Close_Date_Pushes</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Close Date Pushes tracks the number of times an opportunity’s close date has been updated to a date in the future.</description>
        <formula>AND(ISCHANGED(CloseDate),CloseDate&gt;PRIORVALUE(CloseDate))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Last Stage Change</fullName>
        <actions>
            <name>Update_Last_Stage_Change</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Made Active By if Blank</fullName>
        <actions>
            <name>Update_Made_Active_By_field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.Made_Active_By__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>If Made Active By field is blank, populates with the Opportunity CreatedBy. Created this because we needed to import legacy Made Active By data, but for future need this to be Opportunity CreatedBy.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Prospect Since if Blank</fullName>
        <actions>
            <name>Update_Prospect_Since_field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.Prospect_Since__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>If Prospect Since field is blank, populates with the Opportunity Created Date. Created this because we needed to import legacy Prospect Since data, but for future need this to be the Opportunity CreatedDate.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>