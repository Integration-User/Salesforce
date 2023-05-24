public with sharing class AddOrRemoveBillingContact {
    
    public static void  AddBillingContact(Set<ID> setContactIds, Set<ID> setOppoItemIds){
        Map<Id,Map<String, List<Contact>>> mapAccnNContacts = new Map<Id,Map<String, List<Contact>>>();
        //Map<String, List<Contact>> mapBillCons = new Map<String, List<Contact>>();   
        Set<ID> setOppoIds = new  Set<ID>();      
        Set<Id> setAccountIds = new Set<ID>();
        Map<Id, Set<ID>> mapOppoContactRole = new Map<Id, Set<ID>>();
        Map<Id,Map<Id,OpportunityContactRole>> mapContactRoleRecords = new Map<Id,Map<Id,OpportunityContactRole>>();
        Set<ID> toDeleteRecords = new Set<ID>();
        Map<String,OpportunityContactRole> toCreateRoleList = new Map<String,OpportunityContactRole>();
        List<OpportunityContactRole> toDeleteRoleList = new List<OpportunityContactRole>();
        List<Opportunity> listOppo;
        List<Contact> listContact;
        Set<String> setCategories = new Set<String>();
        Set<String> uniqueCombo = new Set<String>();

        // Get Opportunities for Contact IDs
        if(setContactIds != null && setContactIds.size() > 0){
            listContact = [Select id, Accountid,Billing_Contact_Multi__c from Contact where id in: setContactIds];
            setAccountIDs = new Set<Id>();

            for(Contact con : listContact){
                setAccountIDs.add(con.AccountId);
            }
            listOppo = [Select id, Accountid from Opportunity where Accountid in: setAccountIDs  AND (NOT StageName like '%Closed%') 
                        AND StageName !='Consolidated'];
            system.debug('>>>> listOppo : '+listOppo);
            system.debug('>>>> listContact : '+listContact);
        }

        // Get Contacts for Opportunity IDs
        else{
            for(OpportunityLineItem item : [Select id,OpportunityId from OpportunityLineItem where id in: setOppoItemIds])
                setOppoIds.add(item.OpportunityId);
            
            listOppo = [Select AccountId from Opportunity where id in: setOppoIds AND (NOT StageName like '%Closed%') 
                        AND StageName !='Consolidated'];
                        
            setAccountIDs = new Set<Id>();

            for(Opportunity oppo : listOppo){
                setAccountIDs.add(oppo.AccountId);
            }
            listContact = [Select id, Accountid,Billing_Contact_Multi__c from Contact where Accountid in: setAccountIDs];
        }
        List<OpportunityContactRole> listRoles = [Select ID, OpportunityID, ContactID,Hidden_Billing_Contact_Category_Txt__c from OpportunityContactRole where OpportunityID in: listOppo
                                                AND (NOT Opportunity.StageName like '%Closed%') AND Opportunity.StageName !='Consolidated'];
        List<OpportunityContactRole> remainingRoles = new List<OpportunityContactRole>();
        
        if(setContactIds != null){
            List<OpportunityContactRole> roles = new List<OpportunityContactRole>();
            for(OpportunityContactRole oppoRole : listRoles){
                if(setContactIds.contains(oppoRole.ContactID)){
                    roles.add(oppoRole);
                }
                else{
                    remainingRoles.add(oppoRole);
                }
            }
            delete roles;
        }
        //else{
                // Prepare maps of Opportunity Contact Role records to check and delete required records
            for(OpportunityContactRole role : remainingRoles){
                if(!mapOppoContactRole.containsKey(role.OpportunityID)){
                    mapOppoContactRole.put(role.OpportunityID, new Set<Id>());
                    mapContactRoleRecords.put(role.OpportunityID, new Map<Id,OpportunityContactRole>());
                }
                mapOppoContactRole.get(role.OpportunityID).add(role.ContactID);
                mapContactRoleRecords.get(role.OpportunityID).put(role.ContactID,role);
                toDeleteRecords.add(role.Id);
                uniqueCombo.add(''+role.OpportunityID+' '+role.ContactID);
            }
        //}
        system.debug('>>>> mapOppoContactRole : '+mapOppoContactRole);
        system.debug('>>>> mapContactRoleRecords : '+mapContactRoleRecords);
        // Prepare Contact against Account and Product Category so that it will be easy to check the Opportunity Contactc Role records
        for(Contact con : listContact){
            if(!mapAccnNContacts.containskey(con.AccountId)){
                mapAccnNContacts.put(con.Accountid, new Map<String, List<Contact>>());
            }
            if(con.Billing_Contact_Multi__c != null){
                for(String str : con.Billing_Contact_Multi__c.split(';')){
                    setCategories.add(str);
                    if(!mapAccnNContacts.get(con.AccountId).containskey(str)){
                        mapAccnNContacts.get(con.AccountId).put(str, new List<Contact>());
                    }
                    mapAccnNContacts.get(con.AccountId).get(str).add(con);
                }
            }
        }  
        system.debug('>>>> mapAccnNContacts : '+mapAccnNContacts);

        // Get All Opportunity Item records to check and match Contact Role to Opprotunity based on PRoduct Category
        List<OpportunityLineItem> listOpposItems = [SELECT id, OpportunityId, Product2.Billing_Contact_Category__c,Opportunity.AccountId 
                                        FROM OpportunityLineItem 
                                        WHERE OpportunityId in: listOppo 
                                        AND (NOT Opportunity.StageName like '%Closed%') AND Opportunity.StageName !='Consolidated' AND Product2.Billing_Contact_Category__c in: setCategories]; // addd non closed opp filter 
        
        system.debug('>>>> listOpposItems : '+listOpposItems);
        
        for(OpportunityLineItem lineItem : listOpposItems){
            system.debug('>>>> In loop');
            if(setOppoItemIds != null && !setOppoItemIds.contains(lineItem.id)){
                continue;
            }
            if(mapAccnNContacts != null && mapAccnNContacts.get(lineItem.Opportunity.AccountId) != null && 
               mapAccnNContacts.get(lineItem.Opportunity.AccountId).get(lineItem.Product2.Billing_Contact_Category__c) != null){
                
                system.debug('>>>> After If');
                        
                for(Contact con :  mapAccnNContacts.get(lineItem.Opportunity.AccountId).get(lineItem.Product2.Billing_Contact_Category__c)){
                    if(!uniqueCombo.contains(''+lineItem.OpportunityId+' '+con.ID)){
                        
                        if(mapOppoContactRole.size() ==0 || mapOppoContactRole.get(lineItem.OpportunityId) == null || !mapOppoContactRole.get(lineItem.OpportunityId).contains(con.Id)){
                            toCreateRoleList.put(''+lineItem.OpportunityId+' '+con.ID, new OpportunityContactRole(ContactID = con.ID, OpportunityId = lineItem.OpportunityId,   
                                Role = 'Billing Contact',Hidden_Billing_Contact_Category_Txt__c=''));
                            uniqueCombo.add(''+lineItem.OpportunityId+' '+con.ID);
                        }
                        else if(!mapOppoContactRole.get(lineItem.OpportunityId).contains(con.Id)){
                            toCreateRoleList.put(''+lineItem.OpportunityId+' '+con.ID, new OpportunityContactRole(ContactID = con.ID, OpportunityId = lineItem.OpportunityId,   
                            Role = 'Billing Contact',Hidden_Billing_Contact_Category_Txt__c=''));
                            uniqueCombo.add(''+lineItem.OpportunityId+' '+con.ID);
                        }
                        /*else{
                            toDeleteRecords.remove(mapContactRoleRecords.get(lineItem.OpportunityId).get(con.Id));
                        }*/
                        String category = toCreateRoleList.get(''+lineItem.OpportunityId+' '+con.ID).Hidden_Billing_Contact_Category_Txt__c;
                        if( lineItem.Product2.Billing_Contact_Category__c != null){
                            if(category != '')
                                category += ';'; 
                            category += lineItem.Product2.Billing_Contact_Category__c;
                            toCreateRoleList.get(''+lineItem.OpportunityId+' '+con.ID).Hidden_Billing_Contact_Category_Txt__c = category;
                        }
                    }
                    else{
                        if(lineItem.Product2.Billing_Contact_Category__c != null){
                            OpportunityContactRole role;
                            if(toCreateRoleList.containskey(''+lineItem.OpportunityId+' '+con.ID))
                                role = toCreateRoleList.get(''+lineItem.OpportunityId+' '+con.ID);
                            else
                                role = mapContactRoleRecords.get(lineItem.OpportunityId).get(con.Id);
                            if(role.Hidden_Billing_Contact_Category_Txt__c == null){
                                role.Hidden_Billing_Contact_Category_Txt__c = ''+lineItem.Product2.Billing_Contact_Category__c;
                                role.Role = 'Billing Contact';
                            } 
                            else{
                                role.Hidden_Billing_Contact_Category_Txt__c += ';'+lineItem.Product2.Billing_Contact_Category__c;
                            }
                            toCreateRoleList.put(''+lineItem.OpportunityId+' '+con.ID,role);
                        }
                    }
                }
            }
        }
        for(Id roleId : toDeleteRecords){
            toDeleteRoleList.add(new OpportunityContactRole(Id = roleId));
        }

        system.debug('>>>> toDeleteRecords : '+toDeleteRecords);
        system.debug('>>>> toCreateRoleList : '+toCreateRoleList);
        if(toCreateRoleList.size() > 0)
            upsert toCreateRoleList.values();
    }

    public static void DeleteBillingContact(List<OpportunityLineItem> listItems){

        Set<Id> setOppoIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();
        Set<String> categorySet = new Set<String>();
        Map<String,Id> mapCatItem = new Map<String,Id>();
        List<OpportunityContactRole> toDeleteRoleRecords = new List<OpportunityContactRole>();

        for(OpportunityLineItem item : listItems){
            productIds.add(item.Product2Id);
            categorySet.add(item.Product2.Billing_Contact_Category__c);
            setOppoIds.add(item.OpportunityId);
        }
        Map<Id,Product2> mapProducts = new Map<Id,Product2>([SELECT id,Billing_Contact_Category__c FROM Product2 where id in: productIds ]);
        List<OpportunityContactRole> listRoles = new List<OpportunityContactRole>([Select id,Hidden_Billing_Contact_Category_Txt__c 
                                    from OpportunityContactRole where OpportunityId in: setOppoIds AND (NOT Opportunity.StageName like '%Closed%') AND Opportunity.StageName !='Consolidated']); // and Hidden_Billing_Contact_Category__c includes (:categorySet)
        system.debug('>>>> listItems : '+listItems);
        for(OpportunityLineItem item : listItems){
            system.debug('>>>> item : '+item);
            String category = mapProducts.get(item.Product2Id).Billing_Contact_Category__c;
            if( category != null){
                for(OpportunityContactRole role : listRoles){
                    if(role.Hidden_Billing_Contact_Category_Txt__c != null && role.Hidden_Billing_Contact_Category_Txt__c.contains(category)){
                        role.Hidden_Billing_Contact_Category_Txt__c = role.Hidden_Billing_Contact_Category_Txt__c.replacefirst(category,'');
                        role.Hidden_Billing_Contact_Category_Txt__c = role.Hidden_Billing_Contact_Category_Txt__c.replace(';;',';');
                    }
                    system.debug('>>>>>>>role : '+role);
                }
            }
        }   
        update listRoles;
        for(OpportunityContactRole role : listRoles){
            if(role.Hidden_Billing_Contact_Category_Txt__c != null && role.Hidden_Billing_Contact_Category_Txt__c.length() < 2)
                toDeleteRoleRecords.add(role);
        }   
        system.debug('>>>> toDeleteRoleRecords : '+toDeleteRoleRecords);     
        delete toDeleteRoleRecords;
    }
}