<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>NPS_Survey_Response_Escalation_Request</fullName>
        <description>NPS Survey Response Escalation Request</description>
        <protected>false</protected>
        <recipients>
            <recipient>CAM_Manager</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>acervisi@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>cmccrory@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Campaign_Templates/NPS_Escalation_Email</template>
    </alerts>
</Workflow>
