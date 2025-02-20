/**
 * utility class for handling of @see Zephr_Company_Type_Value__c records
 * @author Zoran Zunko
 * @date 5/18/22
 */
public without sharing class ZephrCompanyTypeValuesManager {

    @TestVisible static Map<String, Set<String>> zephrCompanyTypeValues;

    public static Map<String, Set<String>> getZephrCompanyTypeValues() {
        if (zephrCompanyTypeValues == null) {
            List<Zephr_Company_Type_Value__c> zephrCompanyTypeValueRecords = [SELECT Company_Type_JSON_Values__c, Zephr_Tenant__c, Restricted__c FROM Zephr_Company_Type_Value__c];
            zephrCompanyTypeValues = new Map<String, Set<String>>();
            for (Zephr_Company_Type_Value__c zephrCompanyTypeValueRecord : zephrCompanyTypeValueRecords) {
                if (String.isBlank(zephrCompanyTypeValueRecord.Company_Type_JSON_Values__c) && !zephrCompanyTypeValueRecord.Restricted__c) {
                    zephrCompanyTypeValues.put(
                            zephrCompanyTypeValueRecord.Zephr_Tenant__c.toLowerCase(),
                            new Set<String>()
                    );
                } else {
                    zephrCompanyTypeValues.put(
                            zephrCompanyTypeValueRecord.Zephr_Tenant__c.toLowerCase(),
                            (Set<String>) JSON.deserialize(zephrCompanyTypeValueRecord.Company_Type_JSON_Values__c, Set<String>.class)
                    );
                }

            }
        }
        return zephrCompanyTypeValues;
    }
}