<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>New_Integration_Error</fullName>
        <description>New Integration Error</description>
        <protected>false</protected>
        <recipients>
            <recipient>ksantos@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>webmaster@greenst.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Process_Notifications/New_Integration_Error</template>
    </alerts>
</Workflow>
