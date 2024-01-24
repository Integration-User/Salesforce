<?xml version="1.0" encoding="UTF-8"?>
<Profile xmlns="http://soap.sforce.com/2006/04/metadata">
    <custom>true</custom>
    <fieldPermissions>
        <editable>true</editable>
        <field>Contact.Lead_Channel__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Contact.Lead_Type__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Opportunity.Campaign_Name__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Opportunity.Close_Reason__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Opportunity.Create_New_Sales_Opportunity__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Opportunity.Digital_Medium__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Opportunity.Digital_Source__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Opportunity.Inbound__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Opportunity.LeadSource</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Opportunity.Lead_Channel__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Opportunity.Lead_Contact__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Opportunity.Lead_Type__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Opportunity.Marketing_Identified_Country__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Opportunity.New_Sales_Opportunity__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Opportunity.Revisit_Date__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Opportunity.Sales_Owner__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Opportunity.Sales_Reviewed__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Opportunity.Sales_Type__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>false</editable>
        <field>Opportunity.Sectors_Sold__c</field>
        <readable>false</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Opportunity.Submission_Notes_New__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Opportunity.Submission_Notes__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Opportunity.Submission_URL__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Opportunity.Top_Attribution_Driver__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Opportunity.Type_Details__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>Opportunity.UTM_Content__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <layoutAssignments>
        <layout>Contact-Contact Layout</layout>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Opportunity-New Business</layout>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Opportunity-Sales Development</layout>
        <recordType>Opportunity.Sales_Development</recordType>
    </layoutAssignments>
    <recordTypeVisibilities>
        <default>true</default>
        <personAccountDefault>true</personAccountDefault>
        <recordType>Account.Organization_Account</recordType>
        <visible>true</visible>
    </recordTypeVisibilities>
    <recordTypeVisibilities>
        <default>false</default>
        <recordType>Account.Subsidiary_Account</recordType>
        <visible>true</visible>
    </recordTypeVisibilities>
    <recordTypeVisibilities>
        <default>false</default>
        <recordType>Opportunity.Existing_Business</recordType>
        <visible>true</visible>
    </recordTypeVisibilities>
    <recordTypeVisibilities>
        <default>false</default>
        <recordType>Opportunity.Renewal_Closed</recordType>
        <visible>true</visible>
    </recordTypeVisibilities>
    <recordTypeVisibilities>
        <default>false</default>
        <recordType>Opportunity.Sales_Development</recordType>
        <visible>true</visible>
    </recordTypeVisibilities>
    <recordTypeVisibilities>
        <default>true</default>
        <personAccountDefault>true</personAccountDefault>
        <recordType>Opportunity.Sales_Opportunity</recordType>
        <visible>true</visible>
    </recordTypeVisibilities>
    <recordTypeVisibilities>
        <default>false</default>
        <recordType>Opportunity.Sales_Opportunity_Closed</recordType>
        <visible>true</visible>
    </recordTypeVisibilities>
    <userLicense>Salesforce</userLicense>
    <userPermissions>
        <enabled>true</enabled>
        <name>ActivitiesAccess</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>AllowUniversalSearch</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>AllowViewKnowledge</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ApexRestServices</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ApiEnabled</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>AssignTopics</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>CanAccessCE</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ChatterEditOwnPost</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ChatterFileLink</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ChatterInternalUser</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ChatterInviteExternalUsers</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ChatterOwnGroups</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ContentWorkspaces</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>CreateCustomizeFilters</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>CreateCustomizeReports</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>CreateTopics</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>EditOppLineItemUnitPrice</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>EditTopics</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>EnableNotifications</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ExportReport</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>LightningConsoleAllowedForUser</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>LightningExperienceUser</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>RunReports</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>SelectFilesFromSalesforce</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>SendSitRequests</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ShowCompanyNameAsUserBadge</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>SubmitMacrosAllowed</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>SubscribeToLightningReports</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>UseWebLink</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ViewHelpLink</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ViewRoles</name>
    </userPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ViewSetup</name>
    </userPermissions>
</Profile>