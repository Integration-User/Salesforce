/**
* Company     : Plative
* Description : Test Data Factory
* [21.Jun.2020] Anisa - Code Creation 
*/
@isTest
public class Plative_TestDataFactory  {

    // Create Trigger custom settings
    public static void createCustomSettings(){
        
        Trigger_Control_Setting__c tcs = new Trigger_Control_Setting__c();
        tcs.Account__c = true;
        tcs.Contact__c = true;
        tcs.Opportunity__c = true;
        tcs.Task__c = true;
        tcs.Event__c = true;
        tcs.Project__c = true;
        tcs.User__c = true;
        insert tcs;
    }

    // Create Integration user custom settings
    public static void createIntegrationSettings(){
        
        Netsuite_Integration_User__c settings = new Netsuite_Integration_User__c();
        settings.SetupOwnerId = UserInfo.getUserId();
        settings.Is_Integration_User__c = true;
        insert settings;
    }
    // Create Accounts
    public static List<Account> creatAccounts(Integer num, Boolean doInsert){   
        List<Account> accounts = new List<Account>();
        Account acc;
        for(Integer i=1; i<=num; i++){
            acc = new Account();
            acc.Name = 'Test Account '+i;
            accounts.add(acc);
        }
        if(doInsert){
            insert accounts;
        }
        return accounts;
    }

    // Create Account
    public static Account createAccount(Boolean doInsert){  
        Account accnt = new Account();
        accnt.Name = 'Test Account '+System.today();
        accnt.Phone = '1111111111';
        accnt.Website = 'http://www.google.com';
        accnt.BillingCity = 'New York';
        accnt.BillingCountry = 'United States';
        accnt.BillingPostalCode = '4123123';
        accnt.BillingState = 'New York';
        accnt.BillingStreet = 'Madison Avenue';
        accnt.ShippingCity = 'New York';
        accnt.ShippingCountry = 'United States';
        accnt.ShippingPostalCode = '4123123';
        accnt.ShippingState = 'New York';
        accnt.ShippingStreet = 'Madison Avenue';
        accnt.Company_Type__c = 'Accountant';
        accnt.Description = 'Test Account';
        accnt.CRE_Exposure__c = '$1-3B';
        accnt.Subsidiary__c = '10 GSA LLC';
        if(doInsert){
            insert accnt;
        }
        return accnt;
    }

    // Create Contact
    public static Contact createContact(Account acc,Boolean doInsert){  
        Contact cont = new Contact();
        cont.AccountId = acc.Id;
        cont.FirstName = 'FName';
        cont.LastName = 'LName';
        cont.Email = 'test@email.com';
        cont.Phone = '123123123';
        cont.Billing_Contact__c = true;
        if(doInsert){
            insert cont;
        }
        return cont;
    }

    // Create Opportyunity
    public static Opportunity createOpportunity(Account acc,Boolean doInsert){  
        Opportunity oppty = new Opportunity();
        oppty.Name = 'Test Oppty';
        oppty.StageName = '2 - Conducting Needs Analysis';
        oppty.CloseDate = System.today()+10;
        oppty.AccountId = acc.Id;
        oppty.LeadSource = 'Inquiry';
        oppty.Pricebook2Id = Test.getStandardPricebookId();
        oppty.Terms__c = 'Net 30';
        oppty.Billing_Schedule__c = 'Other';
        oppty.ADV_PPD_Sent__c = System.today()-10;
        oppty.CRS_Sent__c = 'Yes';
        oppty.Contract_Start_Date__c = System.today();
        oppty.Contract_End_Date__c = System.today().addYears(5);
        oppty.Other_Invoice_Frequency__c = 'TEst';
        oppty.Advisory_Only_Notes__c = 'Test Advisory Notes';
        oppty.Description = 'Test Description';
        if(doInsert){
            insert oppty;
        }
        return oppty;
    }

    // Create Product
    public static Product2 createProduct(Boolean doInsert){ 
        Product2 product = new Product2();
        product.Name = Label.TestClass_ProductName;
        product.Family = 'REIT';
        product.IsActive = true;
        
        if(doInsert){
            insert product;
        }
        return product;
    }

    // Create PBE
    public static PricebookEntry createPricebookEntry(Product2 prod, Boolean doInsert){ 

        PricebookEntry pricebookEntry = new PricebookEntry();
        pricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
        pricebookEntry.Product2Id = prod.Id;
        pricebookEntry.UnitPrice = 100;
        pricebookEntry.IsActive = true;
        
        if(doInsert){
            insert pricebookEntry;
        }
        return pricebookEntry;
    }

    // Create Opportunity Products
    public static OpportunityLineItem createOLI(Opportunity oppty, Product2 prod, Boolean doInsert){    

        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = oppty.Id;
        oli.Product2Id = prod.Id;
        oli.UnitPrice = 10000;
        if(doInsert){
            insert oli;
        }
        return oli;
    }

    // Create Project
    public static Project__c createProject(Opportunity oppty, Boolean doInsert){    
        
        Project__c proj = new Project__c();
        proj.Opportunity__c = oppty.Id;
        proj.Rev_Rec_Override_Percent_Complete__c = 70; 
        
        if(doInsert){
            insert proj;
        }
        return proj;
    }


}