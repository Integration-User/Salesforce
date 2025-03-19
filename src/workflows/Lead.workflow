<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>AM_Referral_Alert_Email</fullName>
        <description>AM Referral Alert Email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>adillard@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>bmarenholz@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>carora@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>llesce@greenstreet.com</recipient>
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
            <recipient>nhigdem@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>olivia.houlder@reactnews.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>osawkins@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>peager@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Referral_Templates/New_Referral</template>
    </alerts>
    <alerts>
        <fullName>CAM_Referral</fullName>
        <description>CAM Referral</description>
        <protected>false</protected>
        <recipients>
            <recipient>cmccrory@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>esteiner@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>kangle@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Process_Notifications/Referral</template>
    </alerts>
    <alerts>
        <fullName>EAM_Referral</fullName>
        <description>EAM Referral</description>
        <protected>false</protected>
        <recipients>
            <recipient>cmccrory@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>esteiner@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ksantos@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>slaughlin@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Process_Notifications/Referral</template>
    </alerts>
    <alerts>
        <fullName>IJGlobal_Referral_Email_Alert</fullName>
        <description>IJGlobal Referral Email Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Referral_Templates/New_Referral</template>
    </alerts>
    <alerts>
        <fullName>New_Advisory_Referral_Alert_Email</fullName>
        <description>New Advisory Referral Alert Email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Referral_Templates/New_Referral</template>
    </alerts>
    <alerts>
        <fullName>New_Referral_Alert_Email</fullName>
        <description>New Referral Alert Email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>CAM_Manager</recipient>
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
            <recipient>US_Platform_Sales_Manager_B</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>US_Sales_Manager_C</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>VP_Sales_West</recipient>
            <type>role</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Referral_Templates/New_Referral</template>
    </alerts>
    <alerts>
        <fullName>New_Referral_Commercial_and_Advisory_Alert_Email</fullName>
        <description>New Referral Commercial and Advisory Alert Email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Referred_By_Lead__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Referral_Templates/Commercial_Advisory_ARR_Template_Email</template>
    </alerts>
    <alerts>
        <fullName>Referral_Assigned_to_User</fullName>
        <description>Referral Assigned to User</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Referred_By_Lead__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Referred_By__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Referral_Templates/New_Referral_Reassignment</template>
    </alerts>
    <alerts>
        <fullName>Referral_Assignment</fullName>
        <description>Referral Assignment</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>aling@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>lhewett@greenstreet.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Referral_Templates/Referral_Assignment</template>
    </alerts>
    <alerts>
        <fullName>Referral_Lead_Converted</fullName>
        <description>Referral Lead Converted</description>
        <protected>false</protected>
        <recipients>
            <field>Referred_By_Lead__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Referral_Templates/Referral_Converted</template>
    </alerts>
    <alerts>
        <fullName>Referral_Lead_Rejecte</fullName>
        <description>Referral Lead Rejected</description>
        <protected>false</protected>
        <recipients>
            <field>Referred_By_Lead__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Referral_Templates/Referral_Lead_Disqualified</template>
    </alerts>
</Workflow>