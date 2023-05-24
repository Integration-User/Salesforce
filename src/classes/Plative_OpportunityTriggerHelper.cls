/**
* Company     : Plative
* Description : Helper class for Plative_OpportunityTriggerHandler
* History     :
* [26.Feb.2020] Kunal - Code Creation
* [01.Mar.2020] Anisa - Added methods for integration
* [28.May.2020] Anisa - Changed logic to get Contact from Billing contact and not OCR
* [21.Mar.2021] Anisa - Added method getBillingContactIds (GS-306)
*/

public without sharing class Plative_OpportunityTriggerHelper {

    /**
    * Description : Checks if opportunity is closed won, 
    *               if yes then marks for sync to netsuite
    **/
    public static Id salesOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Sales_Opportunity').getRecordTypeId(); 
    public static Id salesOppCloseRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Sales_Opportunity_Closed').getRecordTypeId(); 
    public static Id advisoryRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Advisory').getRecordTypeId(); 
    public static Id advisoryCloseRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Advisory_Closed').getRecordTypeId(); 
    public static Id renewalRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Existing_Business').getRecordTypeId(); 
    public static Id renewalClosedRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Renewal_Closed').getRecordTypeId(); 


    public static void syncToNSOnClosedWon(Map<Id, Opportunity> mapNewOppty,
                                              Map<Id, Opportunity> mapOldOppty){
        Id advisoryRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(
                        System.label.Advisory_RT).getRecordTypeId();
        Id salesOpptyRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(
                             System.label.Sales_Opportunity).getRecordTypeId();
        Id existingBusinessRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(
                                System.label.Existing_Business_RT).getRecordTypeId();
        
        //check if status is set to closed won
        for (Opportunity oppty : mapNewOppty.values()) {
            //Checks if Opportunity is Closed Won
            if (oppty.IsWon && !mapOldOppty.get(oppty.Id).IsWon &&
               (oppty.RecordTypeId == advisoryRT ||
                oppty.RecordTypeId == salesOpptyRT || 
                oppty.RecordTypeId == existingBusinessRT )) {
                oppty.Trigger_Real_time_Sync__c = true;
            } 
        }
    }


    /**
    * Description : If Department and class is updated on opportunity,
    *               query their NS internal id from custom mdt and update on record
    **/
    public static void checkIfDeptOrClassUpdated(List<Opportunity> lstOppty,
                                                    Map<Id, Opportunity> mapOldOppty){
        
        Set<String> setDepartments = new Set<String>();
        Set<String> setClasses = new Set<String>();

        //check if department or class is changed/updated
        for(Opportunity oppty : lstOppty){
            if(!String.isBlank(oppty.Department__c) && 
                ( mapOldOppty == null ||
                (oppty.Department__c != mapOldOppty.get(oppty.Id).Department__c))){
                setDepartments.add(oppty.Department__c);            
            }
            if(!String.isBlank(oppty.Class__c) && 
                ( mapOldOppty == null ||
                oppty.Class__c != mapOldOppty.get(oppty.Id).Class__c)){
                setClasses.add(oppty.Class__c);         
            }
        }
        //Neither of the fields updated then return
        if(setClasses.isEmpty()  && setDepartments.isEmpty()){
            return;
        }
        
        if(!setClasses.isEmpty()){
            updateClassId(lstOppty, setClasses);
        }
        if(!setDepartments.isEmpty()){
            updateDepartmentId(lstOppty, setDepartments);
        }
    }


    /**
    * Description : Update Class NS internal Id
    **/
    public static void updateClassId(List<Opportunity> lstOppty,
                                        Set<String> setClasses){
        List<NS_Picklist_Internal_Id__mdt> lstClasses;
        //query custom mdt
        try{
            lstClasses = [SELECT SF_Picklist_Field_Value__c, NS_Internal_ID__c,
                                 SF_Picklist_Field_Name__c
                          FROM NS_Picklist_Internal_Id__mdt
                          WHERE SF_Picklist_Field_Value__c IN :setClasses
                          AND SF_Picklist_Field_Name__c='Class'];
        }
        catch(Exception e){
            System.debug('EXCEPTION '+e.getMessage()+e.getStackTraceString());
        }

        for(Opportunity oppty : lstOppty){
            for(NS_Picklist_Internal_Id__mdt metadata: lstClasses){
                if(metadata.SF_Picklist_Field_Value__c == oppty.Class__c){
                    oppty.Class_Id__C = metadata.NS_Internal_Id__c;
                }
            }
        }
    }

    /**
    * Description : Update Department NS internal Id
    **/

    public static void updateDepartmentId(List<Opportunity> lstOppty,
                                          Set<String> setDepartments){
        List<NS_Picklist_Internal_Id__mdt> lstDepartments;
        //query custom mdt
        try{
            lstDepartments = [SELECT SF_Picklist_Field_Value__c, NS_Internal_ID__c,
                                 SF_Picklist_Field_Name__c
                          FROM NS_Picklist_Internal_Id__mdt
                          WHERE SF_Picklist_Field_Value__c IN :setDepartments
                          AND SF_Picklist_Field_Name__c = 'Department'];
        }
        catch(Exception e){
            System.debug('EXCEPTION '+e.getMessage()+e.getStackTraceString());
        }

        for(Opportunity oppty : lstOppty){
            for(NS_Picklist_Internal_Id__mdt metadata: lstDepartments){
                if(metadata.SF_Picklist_Field_Value__c == oppty.Department__c){
                    oppty.Department_Id__C = metadata.NS_Internal_Id__c;
                }
            }
        }
    }

    /**
    * Description : Trigger real-time sync of accounts on opportunity closed won
    **/
    public static Boolean triggerSyncOnAccount(Set<Id> setAccountIds){
        try{
            Set<Id> setParentIds = new Set<Id>();           
            List<Account> lstAccounts = [SELECT Id, ParentId, Trigger_Real_time_Sync__c 
                                         FROM Account
                                         WHERE Id IN :setAccountIds];
            for(Account acc: lstAccounts){
                acc.Trigger_Real_time_Sync__c =true;
                if(!String.isBlank(acc.ParentId)){
                    setParentIds.add(acc.ParentId);
                }
            }

            //Update parent accounts first
            List<Account> lstParentAccounts = [SELECT Id, Trigger_Real_time_Sync__c 
                                               FROM Account
                                               WHERE Id IN :setParentIds];
            if(lstParentAccounts != null && !lstParentAccounts.isEmpty()){
                for(Account acc: lstParentAccounts){
                    acc.Trigger_Real_time_Sync__c =true;
                }

                lstParentAccounts.addAll(lstAccounts);
                update lstParentAccounts;
            }
            update lstAccounts;
        }
        catch(Exception e){
            System.debug('EXCEPTION '+e.getMessage()+e.getStackTraceString());
            return false;
        }
        return true;
    }
    /**
    * Description : Trigger sync for associated contacts with billing contact role
    **/ 
    public static Boolean triggerContactSync(Set<Id> setContactIds){
        
        //Query contacts 
        try{            
            //Get contacts with assistant
            List<Contact> lstCon = [SELECT Id,Assistant__c
                                         FROM Contact
                                         WHERE Id IN :setContactIds];
            if(lstCon==null || lstCon.isEmpty()){
                return false;
            }
            //Set the trigger checkbox to true for all these contacts
            Contact cntct;
            List<Contact> lstContacts = new List<Contact>();
            for(Contact con : lstCon){
                //also sync assistant contact information           
                if(!String.isBlank(con.Assistant__c)){
                    cntct = new Contact();
                    cntct.Id = con.Assistant__c;
                    cntct.Trigger_Real_time_Sync__c = true;
                    lstContacts.add(cntct);
                }
                cntct = new Contact();
                cntct.Id = con.Id;
                cntct.Trigger_Real_time_Sync__c = true;
                lstContacts.add(cntct);
            }
            update lstContacts;
        }
        catch(Exception e){
            System.debug('EXCEPTION '+e.getMessage()+e.getStackTraceString());
        }
        return true;
    }

    /**
    * Description : Check if customer id to be stamped on project
    *               after advisory opportunities are synced
    **/
    public static void syncProjectForAdvOppty(Map<Id, Opportunity> mapNewOppty,
                                              Map<Id, Opportunity> mapOldOppty){
        
        Id advisoryRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(
                        System.label.Advisory_RT).getRecordTypeId();
        Set<Id> setAdvisoryOppty = new Set<Id>();
        //check if real time sync is to be initiated
        for (Opportunity oppty : mapNewOppty.values()) {
            //Checks if trigger real time sync field is updated
            if (oppty.Synced__c == 'Yes' &&
                oppty.Synced__c != mapOldOppty.get(oppty.Id).Synced__c) {
                if(oppty.RecordTypeId == advisoryRT){
                    setAdvisoryOppty.add(oppty.Id);
                }
            }
        }   
        if(setAdvisoryOppty != null && !setAdvisoryOppty.isEmpty()){
            markProjectsForSyncing(setAdvisoryOppty);
        }
    }

    /**
    * Description : Check if billing contact added at Stage 6
    **/
    public static void checkBillingContact(Map<Id, Opportunity> mapNewOppty,
                                           Map<Id, Opportunity> mapOldOppty){
        Set<Id> setOpptyIds = new Set<Id>();
        Set<Id> setContactIds = new Set<Id>();

        Boolean hasOpptyinVerbalWin= false;
        //check if real time sync is to be initiated
        for (Opportunity oppty : mapNewOppty.values()) {
            //Checks if trigger real time sync field is true
            if (  oppty.StageName == 'Verbal Win (6)' && 
                 (oppty.StageName != mapOldOppty.get(oppty.Id).StageName)){
                setOpptyIds.add(oppty.Id);
                hasOpptyinVerbalWin = true;
            }
        }

        if(!setOpptyIds.isEmpty()){
            setContactIds = getBillingContactIds(setOpptyIds);
        }

        if(hasOpptyinVerbalWin && setContactIds.isEmpty()){
            mapNewOppty.values()[0].addError('Please make sure Billing Contact is added before moving Opportunity to Verbal Win');
            return;
        }
    }
        /**
    * Description : Check if OpportunityLine Start date, End Date and Product ExternalId added at Stage 6
    **/
    public static void checkOpportunityLineFieldsNull(Map<Id, Opportunity> mapNewOppty,
                                           Map<Id, Opportunity> mapOldOppty){
                                               
        Id salesOpptyRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(
                             System.label.Sales_Opportunity).getRecordTypeId();
        Id existingBusinessRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(
                                System.label.Existing_Business_RT).getRecordTypeId();

        Set<Id> setOpptyIds = new Set<Id>();
        Set<Id> setOpptyLineIds = new Set<Id>();

        Boolean hasOpptyinVerbalWin= false;
        //check if real time sync is to be initiated
        for (Opportunity oppty : mapNewOppty.values()) {
            //Checks if trigger real time sync field is true
            if (oppty.StageName == 'Verbal Win (6)' && 
               (oppty.StageName != mapOldOppty.get(oppty.Id).StageName) &&
               (oppty.RecordTypeId == salesOpptyRT || 
                oppty.RecordTypeId == existingBusinessRT)){
                  setOpptyIds.add(oppty.Id);
                  hasOpptyinVerbalWin = true;
            }
        }

        if(!setOpptyIds.isEmpty()){
            setOpptyLineIds = getOppLineIteamsIds(setOpptyIds);
        }

        if(hasOpptyinVerbalWin && !setOpptyLineIds.isEmpty()){
            mapNewOppty.values()[0].addError('Please ensure all related Opportunity Line Items Start Date, End Date and Product ID are filled out before moving Opportunity to Stage 6 Verbal Win');
            return;
        }
    }

    /**
    * Description : Check if records to be synced
    **/
    public static void syncRecordsToNS(Map<Id, Opportunity> mapNewOppty,
                                       Map<Id, Opportunity> mapOldOppty){
    
        Set<Id> accountIdSet = new Set<Id>();
        List<Opportunity> lstSalesOrderToSync = new List<Opportunity>();
        Set<Id> setOpptyIds = new Set<Id>();
        Set<Id> setContactIds = new Set<Id>();
        Set<Id> setOwnerIds = new Set<Id>();

        //check if real time sync is to be initiated
        for (Opportunity oppty : mapNewOppty.values()) {
            //Checks if trigger real time sync field is true
            if (oppty.Trigger_Real_time_Sync__c && !mapOldOppty.get(oppty.Id).Trigger_Real_time_Sync__c) {
                lstSalesOrderToSync.add(oppty);
                accountIdSet.add(oppty.AccountId);
                setOpptyIds.add(oppty.Id);
                setOwnerIds.add(oppty.OwnerId);
            }
        }
            
        if(setOpptyIds.isEmpty()){
            return;
        }

        setContactIds = getBillingContactIds(setOpptyIds);
            
        //check account set 
        if(accountIdSet == null || accountIdSet.isEmpty()){
            return; 
        }
        //If error then return from method
        if(!triggerSyncOnAccount(accountIdSet)){
            return;
        }

        //Trigger sync on contact
        if(!triggerContactSync(setContactIds)){     
            return;
        }

        //Check if sync settings exist
        Sync_Settings__mdt syncSetting = Plative_SFToNSSyncUtility.checkSyncSettings(
                                                                    'Opportunity');
        if(syncSetting == null){
            return;
        }
        List<SObject> lstChildSobjects;
        // Check if child records are to be sent in payload
        if(syncSetting.Sync_Child_Records__c){
            lstChildSobjects = Plative_SFToNSSyncUtility.getChildRecordsToSync(syncSetting,
                                                                               setOpptyIds,
                                                                               'Opportunity'); 
        }
        //Get API settings
        List<API_Settings__mdt> apiSettings = [SELECT Account__c, Consumer_Key__c,
                                                      Consumer_Secret__c, Endpoint__c,
                                                      Signature_Method__c, Token_Id__c,
                                                      Token_Secret__c, Version__c
                                               FROM API_Settings__mdt
                                               WHERE DeveloperName = 'Netsuite'];

        Map<Decimal, Plative_UpsertRecordQueueable> currentQ = new Map<Decimal, 
                                                               Plative_UpsertRecordQueueable>();
        currentQ.putAll(Plative_SyncQueue.getInstance());
        currentQ.put(syncSetting.Sync_Order__c, 
                                             new Plative_UpsertRecordQueueable(
                                             lstSalesOrderToSync,
                                             lstChildSobjects, apiSettings,
                                             syncSetting.Sync_Order__c));

        Plative_SyncQueue.getInstance().clear();
        Plative_SyncQueue.getInstance().putAll(currentQ);
        Plative_SFToNSSyncUtility.triggerJobsInQueue();

    }

    /**
    * Description : Get Billing Contact Ids
    **/
    public static Set<Id> getBillingContactIds(Set<Id> setOpptyIds){
        Set<Id> setContactIds = new Set<Id>();
        try{
            List<OpportunityContactRole> lstOCR = [SELECT   Id,ContactId 
                                                   FROM     OpportunityContactRole
                                                   WHERE    OpportunityId IN :setOpptyIds
                                                   AND      Role = 'Billing Contact'];
            for(OpportunityContactRole ocr : lstOCR){
                setContactIds.add(ocr.ContactId);
            }
        }
        catch(Exception e){
            System.debug('EXCEPTION '+e.getMessage()+e.getStackTraceString());
        }
        return setContactIds;
    }
    /**
    * Description : Get OpportunityLineItem Ids where Start Date / End Date / Product External Ids is Null
    **/
    public static Set<Id> getOppLineIteamsIds(Set<Id> setOpptyIds){
        Set<Id> setOpptyLineIds = new Set<Id>();
        try{
            List<OpportunityLineItem> lstOLI = [SELECT      Id,Start_Date__c,End_Date__c ,Product_External_Id__c,Name
                                                   FROM     OpportunityLineItem
                                                   WHERE    OpportunityId IN :setOpptyIds];
            for(OpportunityLineItem oli : lstOLI){
                   system.debug('--------------'+oli.Start_Date__c+oli.End_Date__c+oli.Product_External_Id__c);
                if(oli.Start_Date__c == null || oli.End_Date__c == null ||oli.Product_External_Id__c == null){
                   system.debug('Inside'+oli.Start_Date__c+oli.End_Date__c+oli.Product_External_Id__c);
                   setOpptyLineIds.add(oli.Id);
                }
            }
        }
        catch(Exception e){
            System.debug('EXCEPTION '+e.getMessage()+e.getStackTraceString());
        }
        return setOpptyLineIds;
    }
    
    /**
    * Description : Mark projects for sync
    **/
    public static void markProjectsForSyncing(Set<Id> setAdvisoryOppty) {
        
        //Query projects for the account
        try{
            List<Project__c> lstProjects = [SELECT Id, Sync_To_Netsuite__c
                                            FROM Project__c
                                            WHERE Opportunity__c IN :setAdvisoryOppty];
            if(lstProjects != null && !lstProjects.isEmpty()){
                for(Project__c proj : lstProjects){
                    proj.Sync_To_Netsuite__c = true;
                    proj.Synced__c = 'Yes';
                }
                update lstProjects;
            }
        }
        catch(Exception e){
            System.debug('EXCEPTION '+e.getMessage()+e.getStackTraceString());
        }
    }
    /*SF-358*/
    public static void updateHvtAndYoyFlag(Map<Id, Opportunity> triggerNewMap, Map<Id, Opportunity> triggerOldMap) {
        /*Get Account DDS_Segment__c info which will be used to get Meatadata from DDS_YoYSegmentation__mdt*/
        Set<Id> accountIds = new Set<Id>();
        boolean isAmountUpdated = false;
        for (Opportunity opp : triggerNewMap.values()) {
            Opportunity oldOpp = triggerOldMap.get(opp.Id);
            if ((opp.Amount != oldOpp.Amount || opp.Starting_Price_Opp__c != oldOpp.Starting_Price_Opp__c
                || opp.High_Value_Target__c != oldOpp.High_Value_Target__c || opp.X2nd_Year_Amount_in_USD__c != oldOpp.X2nd_Year_Amount_in_USD__c
                || opp.X3rd_Year_Amount_in_USD__c != oldOpp.X3rd_Year_Amount_in_USD__c || opp.Year_4_Amount__c != oldOpp.Year_4_Amount__c
                || opp.Year_5_Amount__c != oldOpp.Year_5_Amount__c) && opp.Current_Contract_Year__c < 2) {
                isAmountUpdated = true;
            }
            if (opp.accountId != null) accountIds.add(opp.accountId);
        }
        // no need to exectue below logic if fields are not updated - (Year 2-5 fields, Amount, high value target %)
        if (!isAmountUpdated) return;
        Map<Id, Account> accountMap = new Map<Id, Account>([Select DDS_Segment__c From Account where ID IN : accountIds]);
        
        /*Get All OpportunityLineItem based on new Opportunity to get ProductCodes that will be used to get SKU_Obtained*/
        Map<Id, List<String>> oppProductCodes = new Map<Id, List<String>>();
        for (OpportunityLineItem lineItem: [SELECT Id, Product2.ProductCode, OpportunityId FROM OpportunityLineItem WHERE Lost_Product__c = false AND OpportunityId IN : triggerNewMap.keySet()]) {
            if (lineItem.Product2.ProductCode != null) {
                if (oppProductCodes.containsKey(lineItem.OpportunityId)) {
                    oppProductCodes.get(lineItem.OpportunityId).add(lineItem.Product2.ProductCode);
                } else {
                    oppProductCodes.put(lineItem.OpportunityId, new list<String>{lineItem.Product2.ProductCode});
                } 
            } 
        }
        system.debug('oppProductCodes-->'+oppProductCodes);
        /* Get SKU value by products codes combinations from DDS_SKUCombination__mdt
         * Third is neccesary get all the deal SKU Combination Metadata records
		*/
        Map<String, String> skuByProductCodes = new Map<String, String>();
        for(DDS_SKUCombination__mdt ddsSKURecord : [SELECT SKU__c, ProductCombination__c FROM DDS_SKUCombination__mdt WHERE IsForTesting__c = false]) {
            List<String> sortProductCombinationList = (ddsSKURecord.ProductCombination__c).split(';');
            sortProductCombinationList.sort();
            String keyMap = String.join(sortProductCombinationList, ''); //---> i.e :'DDS1DDS2;'                                                
            if(!skuByProductCodes.containsKey(keyMap)){
                skuByProductCodes.put(keyMap, ddsSKURecord.SKU__c);
            }	                                                
        }
        system.debug('skuByProductCodes-->'+skuByProductCodes);
        
        for (Opportunity opp : triggerNewMap.values()) {
            if (oppProductCodes.containsKey(opp.Id) && String.isNotBlank(opp.Renewal_Year__c) && opp.Current_Contract_Year__c < 2) {
                // Variable to store the different product codes from LineItems for the opportunity
                List<String> ddsProductCodes = oppProductCodes.get(opp.Id);
                ddsProductCodes.sort();
                String inputKeyProductCombination = String.join(ddsProductCodes,''); //---> i.e :'DDS1DDS2;'
                /*Checking ProductCombination should be present into DDS_SKUCombination__mdt*/
                if(skuByProductCodes.containsKey(inputKeyProductCombination)) {
                    String SKU_Obtained = skuByProductCodes.get(inputKeyProductCombination);
                    system.debug('SKU_Obtained-->'+SKU_Obtained);
                    Decimal yoySegmentRate = [SELECT YoY_Rate__c FROM DDS_YoYSegmentation__mdt 
                                              WHERE Segment__c =: accountMap.get(opp.AccountId).DDS_Segment__c 
                                              AND IsForTesting__c = false AND SKU__c = : SKU_Obtained 
                                              AND SalesType__c = : opp.Sales_Type__c == 'New' || opp.Sales_Type__c == 'Upsell' ? 'New' : opp.Sales_Type__c 
                                              AND EffectiveYear__c =: Decimal.valueOf(opp.Renewal_Year__c) LIMIT 1]?.YoY_Rate__c;
                    system.debug('yoySegmentRate-->'+yoySegmentRate);
                    
                    /*YOY and HVT Increase Unmet Condition*/
                    String yoyTargetUnmet = '';
                    Decimal firstYearHVT = opp.High_Value_Target__c > 0 ?  opp.High_Value_Target__c : yoySegmentRate;
                    Decimal totalHVTGrowth = 0;
                    Decimal totalHVTGrowthTarget = 0;
                    opp.Required_Increase__c = yoySegmentRate;
                    
                    if (yoySegmentRate > 0) {
                        if (opp.Starting_Price_Opp__c > 0 && opp.Same_Store_ARR__c > 0) {
                            Decimal yoyGrowth = ((opp.Same_Store_ARR__c - opp.Starting_Price_Opp__c)/opp.Starting_Price_Opp__c)*100;
                            totalHVTGrowth += yoyGrowth;
                            totalHVTGrowthTarget += firstYearHVT;
                            if (yoyGrowth < yoySegmentRate) {
                                yoyTargetUnmet = 'Year 1';
                            }
                        }
                        if (opp.X2nd_Year_Amount_in_USD__c != null && opp.X2nd_Year_Amount_in_USD__c > 0 && opp.Total_ARR__c > 0) {
                            Decimal year2Growth = ((opp.X2nd_Year_Amount_in_USD__c - opp.Total_ARR__c)/opp.Total_ARR__c)*100;
                            if (year2Growth < yoySegmentRate) {
                                if (String.isNotBlank(yoyTargetUnmet)) yoyTargetUnmet += ', Year 2';
                                else yoyTargetUnmet = 'Year 2';
                            }
                            totalHVTGrowth += year2Growth;
                            totalHVTGrowthTarget += yoySegmentRate;
                        }
                        if (opp.X3rd_Year_Amount_in_USD__c != null && opp.X3rd_Year_Amount_in_USD__c > 0 && opp.X2nd_Year_Amount_in_USD__c > 0) { 
                            Decimal year3Growth = ((opp.X3rd_Year_Amount_in_USD__c - opp.X2nd_Year_Amount_in_USD__c)/opp.X2nd_Year_Amount_in_USD__c)*100;
                              if (year3Growth < yoySegmentRate) {
                                if (String.isNotBlank(yoyTargetUnmet)) yoyTargetUnmet += ', Year 3';
                                else yoyTargetUnmet = 'Year 3';
                            }
                            totalHVTGrowth += year3Growth;
                            totalHVTGrowthTarget += yoySegmentRate;
                        }
                        if (opp.Year_4_Amount__c != null && opp.Year_4_Amount__c > 0 && opp.X3rd_Year_Amount_in_USD__c > 0) {
                            Decimal year4Growth = ((opp.Year_4_Amount__c - opp.X3rd_Year_Amount_in_USD__c)/opp.X3rd_Year_Amount_in_USD__c)*100;
                              if (year4Growth < yoySegmentRate) {
                                if (String.isNotBlank(yoyTargetUnmet)) yoyTargetUnmet += ', Year 4';
                                else yoyTargetUnmet = 'Year 4';
                            }
                            totalHVTGrowth += year4Growth;
                            totalHVTGrowthTarget += yoySegmentRate;
                        }
                        if (opp.Year_5_Amount__c != null && opp.Year_5_Amount__c > 0 && opp.Year_4_Amount__c > 0) {
                            Decimal year5Growth = ((opp.Year_5_Amount__c - opp.Year_4_Amount__c)/opp.Year_4_Amount__c)*100;
                            if (year5Growth < yoySegmentRate) {
                                if (String.isNotBlank(yoyTargetUnmet)) yoyTargetUnmet += ', Year 5';
                                else yoyTargetUnmet = 'Year 5';
                            }
                            totalHVTGrowth += year5Growth;
                            totalHVTGrowthTarget += yoySegmentRate;
                        }
                        system.debug('yoyTargetUnmet-->'+yoyTargetUnmet);
                        if(String.isNotBlank(yoyTargetUnmet)) opp.YoY_Target_Unmet__c = true;
                        else opp.YoY_Target_Unmet__c = false;
                        opp.Unmet_Deal_Insights__c = yoyTargetUnmet;
                        
                        system.debug('totalHVTGrowth-->'+totalHVTGrowth);
                        system.debug('totalHVTGrowthTarget-->'+totalHVTGrowthTarget);
                        
                        if (opp.High_Value_Target__c > 0 && totalHVTGrowth < totalHVTGrowthTarget) {
                            opp.HVT_Increase_Unmet__c = true;
                        } else {
                            opp.HVT_Increase_Unmet__c = false;
                        }
                    }
                }
            }
        }
    }
    /* public static void updateOpportunityProcessesBeforeAction(List<Opportunity> lstOppty, Map<Id, Opportunity> mapOldOppty) {
        for (Opportunity oppty : lstOppty) {
            // Update Forecasting Category
            Opportunity oldOpp = (mapOldOppty != null && !mapOldOppty.isEmpty()) ? mapOldOppty.get(oppty.id) : null;
            if((oppty.RecordTypeId == salesOppRecordTypeId || oppty.RecordTypeId == salesOppCloseRecordTypeId) && !oppty.IsClosed) {
                oppty.ForecastCategoryName = oppty.Rep_Forecast_Category__c;
            }
            // Advisory Recurring?
            if(oppty.Recurring_Revenue_Advisory__c == 'Yes' && oppty.RecordTypeId == advisoryRecordTypeId) {
                oppty.Sales_Type__c = 'Recurring';
            }
            // Criteria - Mirror Rep Forecast, Action - Update Standard Forecast
            if(oldOpp != null && oppty.Rep_Forecast_Category__c != oldOpp.Rep_Forecast_Category__c) {
                oppty.ForecastCategoryName = oppty.Rep_Forecast_Category__c;
            }
            // Criteria - Lost Record Type Update, Action - Update Record Type
            if(oppty.StageName == 'Closed Lost' && oppty.RecordTypeId == renewalRecordTypeId) {
                // oppty.RecordTypeId = renewalClosedRecordTypeId;
                oppty.Update_RecordType_Id__c = renewalClosedRecordTypeId;
            }
            // Criteria - BBFTD, Action - Update RT
            if(oppty.StageName == 'Closed Won' && oppty.RecordTypeId == renewalRecordTypeId) {
                //oppty.RecordTypeId = renewalClosedRecordTypeId;
                oppty.Update_RecordType_Id__c = renewalClosedRecordTypeId;
            }
            // Criteria - Sales Opp Closed Won, Action - Update Opp RT
            if(oppty.StageName == 'Closed Won' && oppty.RecordTypeId == salesOppRecordTypeId && oppty.Close_Reason__c != 'Online Order' && oppty.Amount > 0) {
                //oppty.RecordTypeId = salesOppCloseRecordTypeId;
                oppty.Update_RecordType_Id__c = salesOppCloseRecordTypeId;
            }
            // Criteria - Closed Won Advisory, Action - Opp RT Update
            if(oppty.StageName == 'Closed Won' && oppty.RecordTypeId == advisoryRecordTypeId) {
                // oppty.RecordTypeId = advisoryCloseRecordTypeId;
                oppty.Update_RecordType_Id__c = advisoryCloseRecordTypeId;
            }
        }
    }*/
}