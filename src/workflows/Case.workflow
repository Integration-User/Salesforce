<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>AskNicely_Closed_Case</fullName>
        <ccEmails>greenstreet_45d975f@trigger.asknice.ly</ccEmails>
        <description>AskNicely Closed Case</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/AskNicely_Closed_Case</template>
    </alerts>
    <alerts>
        <fullName>Case_Closed_Internal</fullName>
        <description>Case Closed - Internal</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Cases/Case_Closed</template>
    </alerts>
    <alerts>
        <fullName>Case_Stale_For_4_days</fullName>
        <description>3 Business Days Since Modified</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>carora@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Cases/Case_Stale_4_days</template>
    </alerts>
    <alerts>
        <fullName>Data_Support_Inside_Office_Hours_Email_Alert</fullName>
        <description>Data Support Inside Office Hours Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>noreply@greenstreet.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Data_Support_Inside_Office_Hours_Template</template>
    </alerts>
    <alerts>
        <fullName>Data_Support_Outside_Office_Hours_Email_Alert</fullName>
        <description>Data Support Outside Office Hours Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>noreply@greenstreet.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Data_Support_Outside_Office_Hours_Template</template>
    </alerts>
    <alerts>
        <fullName>Data_Support_Weekend_Email_Alert</fullName>
        <description>Data Support Weekend Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>noreply@greenstreet.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Data_Support_Weekend_Template</template>
    </alerts>
    <alerts>
        <fullName>Deal_scoring_error_email_alerts</fullName>
        <description>Deal scoring error email alerts</description>
        <protected>false</protected>
        <recipients>
            <recipient>cespina@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jblanden@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ksantos@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Cases/Deal_scoring_error_email_template</template>
    </alerts>
    <alerts>
        <fullName>Escalated_React_News_Case</fullName>
        <description>Escalated React News Case</description>
        <protected>false</protected>
        <recipients>
            <recipient>dbetusova@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Escalated_React_News_Case</template>
    </alerts>
    <alerts>
        <fullName>Help_Desk_Weekend_Email_Alert</fullName>
        <description>Help Desk Weekend Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>noreply@greenstreet.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Help_Desk_Template_HTML</template>
    </alerts>
    <alerts>
        <fullName>New_Salesforce_Request_Case_Alert</fullName>
        <description>New Salesforce Request Case Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Process_Notifications/New_Salesforce_Request_Case_Alert_ET</template>
    </alerts>
    <alerts>
        <fullName>New_Salesforce_Request_Internal_Comment</fullName>
        <description>New Salesforce Request Internal Comment</description>
        <protected>false</protected>
        <recipients>
            <field>Requested_By__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/New_Salesforce_Request_Internal_Comment</template>
    </alerts>
    <alerts>
        <fullName>Salesforce</fullName>
        <description>Salesforce Request Status Update</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Cases/Case_Status_Update</template>
    </alerts>
    <alerts>
        <fullName>Salesforce_Request_Case_Closed</fullName>
        <description>Salesforce Request Case Closed</description>
        <protected>false</protected>
        <recipients>
            <field>Requested_By__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Salesforce_Request_Case_Closed</template>
    </alerts>
    <alerts>
        <fullName>Trial_Activation_Email_Alert</fullName>
        <description>Trial Activation Email Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>Opportunity Owner</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Trial_Activation_Access_Template</template>
    </alerts>
    <alerts>
        <fullName>Untouched_Data_Support_Cases</fullName>
        <description>Untouched Data Support Cases</description>
        <protected>false</protected>
        <recipients>
            <recipient>crastogi@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Untouched_Data_Support_Cases</template>
    </alerts>
    <alerts>
        <fullName>Untouched_Help_Desk_Cases</fullName>
        <description>Untouched Help Desk Cases</description>
        <protected>false</protected>
        <recipients>
            <recipient>Help_Desk_untouched_cases</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>noreply@greenstreet.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Untouched_Help_Desk_Cases</template>
    </alerts>
    <fieldUpdates>
        <fullName>Set_Client_Support_Type</fullName>
        <field>Support_Type__c</field>
        <literalValue>Client Support</literalValue>
        <name>Set Client Support Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Data_Support_External_Type</fullName>
        <field>Type</field>
        <literalValue>External</literalValue>
        <name>Set Data Support External Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Data_Support_Internal_Type</fullName>
        <field>Type</field>
        <literalValue>Internal</literalValue>
        <name>Set Data Support Internal Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_EU_Data_Support_Type</fullName>
        <field>Support_Type__c</field>
        <literalValue>EU Data Support</literalValue>
        <name>Set EU Data Support Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_React_News_Support_Type</fullName>
        <field>Support_Type__c</field>
        <literalValue>React News</literalValue>
        <name>Set React News Support Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_US_Data_Support_Type</fullName>
        <field>Support_Type__c</field>
        <literalValue>US Data Support</literalValue>
        <name>Set US Data Support Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_User_List_Request_Support_Type</fullName>
        <field>Support_Type__c</field>
        <literalValue>Green Street</literalValue>
        <name>Set User List Request Support Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_Owner</fullName>
        <field>OwnerId</field>
        <lookupValue>Deal_Score_Error</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Update Case Owner</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_to_Bounce_Back_Queue</fullName>
        <field>OwnerId</field>
        <lookupValue>Bounce_Back_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Update to Bounce Back Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <outboundMessages>
        <fullName>asknicely__CaseClosedOutbound</fullName>
        <apiVersion>34.0</apiVersion>
        <description>case closed</description>
        <endpointUrl>https://salesforce.asknice.ly/salesforce/caseclosed</endpointUrl>
        <fields>Id</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>ksantos@greenstreet.com</integrationUser>
        <name>CaseClosedOutbound</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>Case Closed Notification</fullName>
        <actions>
            <name>Salesforce_Request_Case_Closed</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Salesforce Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Deal Scoring WF</fullName>
        <actions>
            <name>Deal_scoring_error_email_alerts</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Case_Owner</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Deal Score Error</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Escalated React News Case</fullName>
        <actions>
            <name>Escalated_React_News_Case</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Escalated</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Support_Type__c</field>
            <operation>equals</operation>
            <value>React News</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>New Salesforce Request Internal Comment</fullName>
        <actions>
            <name>New_Salesforce_Request_Internal_Comment</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED( Comments__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>React News Routing</fullName>
        <actions>
            <name>Set_React_News_Support_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>React News</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>User List Requests</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Route to Bounce Back Queue</fullName>
        <actions>
            <name>Update_to_Bounce_Back_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>contains</operation>
            <value>Undeliverable</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>contains</operation>
            <value>Delivery Status Notification (Failure)</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Untouched EU Data Support %28External%29 Cases</fullName>
        <actions>
            <name>Set_Data_Support_External_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_EU_Data_Support_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6</booleanFilter>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>EU Data Support</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Help Desk</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Submitted_Day__c</field>
            <operation>notEqual</operation>
            <value>Saturday</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Submitted_Day__c</field>
            <operation>notEqual</operation>
            <value>Sunday</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>External Data Support</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Untouched_Data_Support_Cases</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.CreatedDate</offsetFromField>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Untouched EU Data Support %28Internal%29 Cases</fullName>
        <actions>
            <name>Set_Data_Support_Internal_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_EU_Data_Support_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6</booleanFilter>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>EU Data Support</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Help Desk</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Submitted_Day__c</field>
            <operation>notEqual</operation>
            <value>Saturday</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Submitted_Day__c</field>
            <operation>notEqual</operation>
            <value>Sunday</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Internal Data Support</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Untouched_Data_Support_Cases</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.CreatedDate</offsetFromField>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Untouched Help Desk Cases</fullName>
        <actions>
            <name>Set_Client_Support_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Help Desk</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Help Desk</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Submitted_Day__c</field>
            <operation>notEqual</operation>
            <value>Saturday</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Submitted_Day__c</field>
            <operation>notEqual</operation>
            <value>Sunday</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Untouched_Help_Desk_Cases</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.CreatedDate</offsetFromField>
            <timeLength>3</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Untouched US Data Support %28External%29 Cases</fullName>
        <actions>
            <name>Set_Data_Support_External_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_US_Data_Support_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6</booleanFilter>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>US Data Support</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Help Desk</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Submitted_Day__c</field>
            <operation>notEqual</operation>
            <value>Saturday</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Submitted_Day__c</field>
            <operation>notEqual</operation>
            <value>Sunday</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>External Data Support</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Untouched_Data_Support_Cases</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.CreatedDate</offsetFromField>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Untouched US Data Support %28Internal%29 Cases</fullName>
        <actions>
            <name>Set_Data_Support_Internal_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_US_Data_Support_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6</booleanFilter>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>US Data Support</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Help Desk</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Submitted_Day__c</field>
            <operation>notEqual</operation>
            <value>Saturday</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Submitted_Day__c</field>
            <operation>notEqual</operation>
            <value>Sunday</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Internal Data Support</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Untouched_Data_Support_Cases</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.CreatedDate</offsetFromField>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>User List Request Routing</fullName>
        <actions>
            <name>Set_User_List_Request_Support_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>User List Requests</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>User List Requests</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>asknicely__AskNicelyCaseClosedWebhook</fullName>
        <actions>
            <name>asknicely__CaseClosedOutbound</name>
            <type>OutboundMessage</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <description>Trigger an AskNicely survey when a case is closed.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>