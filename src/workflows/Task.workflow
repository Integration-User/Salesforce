<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Email_Task_Type</fullName>
        <field>Type</field>
        <literalValue>Outgoing Email</literalValue>
        <name>Update Email Task Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Subject_field_with_Type</fullName>
        <description>Adds Task Type to Subject field</description>
        <field>Subject</field>
        <formula>TEXT(Type) + &quot; - &quot; + Subject</formula>
        <name>Update Subject field with Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Email Type update</fullName>
        <actions>
            <name>Update_Email_Task_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task.Subject</field>
            <operation>contains</operation>
            <value>Email:</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Task Subject with Type</fullName>
        <actions>
            <name>Update_Subject_field_with_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>On save, will add Task Type to Subject line</description>
        <formula>AND(
NOT(ISNULL(TEXT(Type ))),
NOT(CONTAINS(Subject , TEXT(Type))) 
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
