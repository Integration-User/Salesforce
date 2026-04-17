<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Lost_Client_Transition_Alert_to_Leadership</fullName>
        <description>Lost Client Transition Alert to Leadership</description>
        <protected>false</protected>
        <recipients>
            <recipient>cmccrory@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jamie.hamer@reactnews.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>kangle@greenstreet.com</recipient>
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
            <recipient>mrichardson@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>olivia.houlder@reactnews.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>slaughlin@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Process_Notifications/Lost_Client_Transition</template>
    </alerts>
    <alerts>
        <fullName>New_Advisory_Referral</fullName>
        <ccEmails>ksantos@greenst.com</ccEmails>
        <description>New Advisory Referral</description>
        <protected>false</protected>
        <recipients>
            <recipient>ksantos@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Process_Notifications/Advisory_Referral_Notification</template>
    </alerts>
    <alerts>
        <fullName>Send_Subsidiary_Change_Approval_Escalation</fullName>
        <description>Send Subsidiary Change Approval Escalation</description>
        <protected>false</protected>
        <recipients>
            <recipient>jwiggins@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>rramos@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@greenstreet.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Subsidiary_Change_Approval</template>
    </alerts>
    <fieldUpdates>
        <fullName>Approve_Subsidiary_Change</fullName>
        <field>Subsidiary_Change_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Approve Subsidiary Change</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Lock_Opportunities</fullName>
        <field>Lock_Opportunities__c</field>
        <literalValue>1</literalValue>
        <name>Lock Opportunities</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Recall_Subsidiary_Change</fullName>
        <field>Subsidiary_Change_Status__c</field>
        <literalValue>Recalled</literalValue>
        <name>Recall Subsidiary Change</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reject_Subsidiary_Change</fullName>
        <field>Subsidiary_Change_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Reject Subsidiary Change</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Unlock_Opportunities</fullName>
        <field>Lock_Opportunities__c</field>
        <literalValue>0</literalValue>
        <name>Unlock Opportunities</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Customer_Channel_NS_Internal_ID</fullName>
        <description>Updates the NS internal ID on Customer Channel</description>
        <field>Customer_Channel_NS_Internal_Id__c</field>
        <formula>CASE(Customer_Channel__c ,&apos;Contracted - PSI&apos;,2,&apos;Non-Contracted - PSI&apos;, 2, &apos;Subscription - PMP&apos;,1,1)</formula>
        <name>Update Customer Channel NS Internal ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Send Escalation Email for Subsidiary Change</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Account.Lock_Opportunities__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Send_Subsidiary_Change_Approval_Escalation</name>
                <type>Alert</type>
            </actions>
            <timeLength>48</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Update Customer Channel NS Internal ID</fullName>
        <actions>
            <name>Update_Customer_Channel_NS_Internal_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the NS internal ID of the customer channel on creation and change of company type</description>
        <formula>ISCHANGED( Company_Type__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
