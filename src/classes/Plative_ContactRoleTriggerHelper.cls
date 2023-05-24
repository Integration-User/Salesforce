/**
* Company     : Plative
* Description : Helper for Opportunity Contact Role trigger
* History     : 
* [17.Jun.2020] Kunal - Code Creation 
*/
public class Plative_ContactRoleTriggerHelper {
    
    public static void addCustomInfluence(List<OpportunityContactRole> triggerNew){
        Set<Id> contactIdSet = new Set<Id>();
        Set<Id> opportunityIdSet = new Set<Id>();
        
        //Take Opportunity Id
        for(OpportunityContactRole ocr: triggerNew){
            opportunityIdSet.add(ocr.OpportunityId);
        }
        
        //Get All Contact Roles related to Opportunity Ids
        List<OpportunityContactRole> ocrList = [Select Id,OpportunityId,ContactId from OpportunityContactRole where OpportunityId IN :opportunityIdSet];
        for(OpportunityContactRole ocr: ocrList){
            contactIdSet.add(ocr.ContactId);
        }
        
        //Get Custom Model Id
        List<CampaignInfluenceModel> influenceModelList = [Select Id,MasterLabel,DeveloperName,ModelType from CampaignInfluenceModel where IsActive=true AND DeveloperName = 'Even_Touch' LIMIT 1];
        
        if(!influenceModelList.isEmpty()){
            Id customModelId = influenceModelList[0].Id;
            
            //Get Campaign Members list
            List<CampaignMember> campaignMemberList = [Select ContactId, CampaignId from CampaignMember where ContactId != null AND ContactId IN: contactIdSet];
            
            //Map of Contact Id Vs All Campaign Ids against it
            Map<Id,Set<Id>> contactIdVsCampaignIds = new Map<Id,Set<Id>>();
            if(!campaignMemberList.isEmpty()){
                for(CampaignMember member: campaignMemberList){
                    if(!contactIdVsCampaignIds.containsKey(member.ContactId)){
                        contactIdVsCampaignIds.put(member.ContactId, new Set<Id>());
                    }
                    contactIdVsCampaignIds.get(member.ContactId).add(member.CampaignId);
                }
            }
            
            //Get existing Campaign Influence Members against the Opportunities
            List<CampaignInfluence> campaignInfluenceList = [Select CampaignId,OpportunityId,ContactId from CampaignInfluence where ModelId = :customModelId AND OpportunityId IN :opportunityIdSet];
            
            Map<Id,Map<String,Id>> opportunityIdVsKeyVsInfluenceId = new Map<Id,Map<String,Id>>();
            for(CampaignInfluence influence: campaignInfluenceList){
                String key = influence.CampaignId + '-' + influence.ContactId;
                if(opportunityIdVsKeyVsInfluenceId.containsKey(influence.OpportunityId)){
					Map<String,Id> tempMap = opportunityIdVsKeyVsInfluenceId.get(influence.OpportunityId);
                    tempMap.put(key,influence.Id);
                    opportunityIdVsKeyVsInfluenceId.put(influence.OpportunityId,tempMap);
                } else {
                    Map<String,Id> tempMap = new Map<String,Id>{key => influence.Id};
                    opportunityIdVsKeyVsInfluenceId.put(influence.OpportunityId,tempMap);
                }
            }
            
            
            //Map of Opportunity Id Vs Total Campaign Ids(determine on the basis of OCR & contactIdVsCampaignIds)
            Map<Id,Set<Id>> opptyIdVsCampaignIds = new Map<Id,Set<Id>>();
            for(OpportunityContactRole ocr: ocrList){
                if(contactIdVsCampaignIds.containsKey(ocr.ContactId)){
                    if(!opptyIdVsCampaignIds.containsKey(ocr.OpportunityId)){
                        opptyIdVsCampaignIds.put(ocr.OpportunityId, new Set<Id>());
                    } 
                    opptyIdVsCampaignIds.get(ocr.OpportunityId).addAll(contactIdVsCampaignIds.get(ocr.ContactId));
                }                
            }
            
            List<CampaignInfluence> campaignInfluenceUpsertList = new List<CampaignInfluence>(); 
            Map<Id,CampaignInfluence> campaignInfluenceUpdateMap = new Map<Id,CampaignInfluence>();
            Set<String> contactOpportunityUniqueString = new Set<String>();
            for(OpportunityContactRole ocr: ocrList){
                String key = ocr.OpportunityId + '-' + ocr.ContactId;
                if(!contactOpportunityUniqueString.contains(key)){
                    contactOpportunityUniqueString.add(key);
                    try{
                        //Check if current contact has any campaigns 
                        if(contactIdVsCampaignIds.containsKey(ocr.ContactId) && opptyIdVsCampaignIds.containsKey(ocr.OpportunityId)){
                            //Check if current Opportunity has existing Campaign Influence associated with currenct contact
                            if(opportunityIdVsKeyVsInfluenceId.containsKey(ocr.OpportunityId)){
                                //Check if there's an existing Influence against the current Contact
                                for(Id campaignId: contactIdVsCampaignIds.get(ocr.ContactId)){
                                    String tempKey = campaignId + '-' + ocr.ContactId;
                                    CampaignInfluence customInfluence = createCustomInfluence(customModelId,ocr.OpportunityId, ocr.ContactId, campaignId);
                                    Decimal decimalNumber = 100;
                                    Decimal influencePercent = decimalNumber.divide(opptyIdVsCampaignIds.get(ocr.OpportunityId).size(),2);
                                    customInfluence.Influence = influencePercent;
                                    if(opportunityIdVsKeyVsInfluenceId.containsKey(ocr.OpportunityId) && opportunityIdVsKeyVsInfluenceId.get(ocr.OpportunityId).containsKey(tempKey)){
                                        Id influenceId = opportunityIdVsKeyVsInfluenceId.get(ocr.OpportunityId).get(tempKey);
                                        customInfluence.Id = influenceId;
                                        campaignInfluenceUpdateMap.put(influenceId,customInfluence);
                                    } else {
                                        campaignInfluenceUpsertList.add(customInfluence);
                                    }
                                }  
                            }
                            
                            //If no influence found for Opportunity then create one
                            else {
                                //Create Influence
                                for(Id campaignId: contactIdVsCampaignIds.get(ocr.ContactId)){
                                    CampaignInfluence customInfluence = createCustomInfluence(customModelId,ocr.OpportunityId, ocr.ContactId, campaignId);
                                    Decimal decimalNumber = 100;
                                    Decimal influencePercent = decimalNumber.divide(opptyIdVsCampaignIds.get(ocr.OpportunityId).size(),2);
                                    customInfluence.Influence = influencePercent;
                                    campaignInfluenceUpsertList.add(customInfluence);
                                } 
                            }
                        }
                    } catch(Exception ex){
                        System.debug('In Apex class Plative_ContactRoleTriggerHelper. ' + 'At line number: ' + ex.getLineNumber() + '. Cause: ' + ex.getCause() + '. Message: ' + ex.getMessage());
                    }
                }                
            }
            
            if(!campaignInfluenceUpdateMap.isEmpty()){
                campaignInfluenceUpsertList.addAll(campaignInfluenceUpdateMap.values());
            }
            
            //Upsert Custom Influence records
            List<Database.UpsertResult> results = Database.upsert(campaignInfluenceUpsertList,false);
            system.debug('results: ' + results);
        }
    }
    
    
    //This method creates Campaign Influence
    public static CampaignInfluence createCustomInfluence(Id modelId, Id opptyId, Id contactId, Id campaignId){
        CampaignInfluence customInfluence = new CampaignInfluence();
        customInfluence.ModelId = modelId;
        customInfluence.OpportunityId = opptyId;
        customInfluence.ContactId = contactId;
        customInfluence.CampaignId = campaignId;
        return customInfluence;
    }
    
    
    //This method deletes any existing Campaign Influence records if Opportunity Contact Roles are deleted
    public static void reCalculateCustomInfluence(List<OpportunityContactRole> triggerOld){
        Set<Id> opportunityIdSet = new Set<Id>();
        Set<String> toDeleteKeySet = new Set<String>();
        for(OpportunityContactRole ocr: triggerOld){
            //Create Key of OpptyId + ContactId to identify which Influence records to delete
            String key = String.valueOf(ocr.OpportunityId) + String.valueOf(ocr.ContactId);
            toDeleteKeySet.add(key);
            opportunityIdSet.add(ocr.OpportunityId);
        }
        
        //Get Campaign Influence records based on Opportunity Ids to delete
        List<CampaignInfluence> campaignInfluenceList = [Select Id,OpportunityId,ContactId from CampaignInfluence where OpportunityId IN :opportunityIdSet];
        
        List<CampaignInfluence> campaignInfluenceDeleteList = new List<CampaignInfluence>();
        for(CampaignInfluence influence: campaignInfluenceList){
            //Based on the key check if influence records needs to be deleted or not
            String key = String.valueOf(influence.OpportunityId) + String.valueOf(influence.ContactId);
            if(toDeleteKeySet.contains(key)){
                campaignInfluenceDeleteList.add(influence);
            }
        }
        Database.delete(campaignInfluenceDeleteList,false);
        
        //Fetch all Contact roles again to recalculate Campaign Influence Records
        List<OpportunityContactRole> ocrList = [Select Id,OpportunityId,ContactId from OpportunityContactRole where OpportunityId IN :opportunityIdSet];
        //Call method that calculates Campaign Influence records.
        Plative_ContactRoleTriggerHelper.addCustomInfluence(ocrList);
    }
    
    
}