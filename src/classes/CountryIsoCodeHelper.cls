/*
* To get the country ISO code:
* Map<String,String> countryISOCodes = CountryIsoCodeHelper.CountryIsoCodeHelper('United Kingdom');
* String x2Fig = countryToIsoCodes.get('2Fig');
* String x3Fig = countryToIsoCodes.get('3Fig');
* String numeric = countryToIsoCodes.get('Numeric');
*
* 211007 - Zoran Zunko - bulkified the method to avoid multiple SOQLs
*/
public with sharing class CountryIsoCodeHelper {
    public static Map<String, Map<String, String>> isoCodeMap;
    public static Map<String, Map<String, String>> reverseIsoCodeMap;

    public static Map<String, String> CountryIsoCodeHelper(String country) {

        if (isoCodeMap == null) {
            List<ISO_Map__mdt> isoCodeMappings = [
                    SELECT MasterLabel,
                            X2_Fig_ISO_Code__c,
                            X3_Fig_ISO_Code__c,
                            Numeric_ISO_Code__c
                    FROM ISO_Map__mdt
            ];
            isoCodeMap = new Map<String, Map<String, String>>();
            for (ISO_Map__mdt isoCodeMapping : isoCodeMappings) {
                isoCodeMap.put(isoCodeMapping.MasterLabel, new Map<String, String>{
                        '2Fig' => isoCodeMapping.X2_Fig_ISO_Code__c,
                        '3Fig' => isoCodeMapping.X3_Fig_ISO_Code__c,
                        'Numeric' => isoCodeMapping.Numeric_ISO_Code__c
                });
            }
        }

        if (isoCodeMap.containsKey(country)) {
            return isoCodeMap.get(country);
        } else {
            return new Map<String, String>{
                    '2Fig' => null,
                    '3Fig' => null,
                    'Numeric' => null
            };
        }

    }

    public static Map<String, String> ReverseCountryIsoCodeHelper(String twoLetterISO) {

        if (reverseIsoCodeMap == null) {
            List<ISO_Map__mdt> isoCodeMappings = [
                    SELECT MasterLabel,
                            X2_Fig_ISO_Code__c,
                            X3_Fig_ISO_Code__c,
                            Numeric_ISO_Code__c
                    FROM ISO_Map__mdt
            ];
            reverseIsoCodeMap = new Map<String, Map<String, String>>();
            for (ISO_Map__mdt isoCodeMapping : isoCodeMappings) {
                reverseIsoCodeMap.put(isoCodeMapping.X2_Fig_ISO_Code__c, new Map<String, String>{
                        'Name' => isoCodeMapping.MasterLabel,
                        '3Fig' => isoCodeMapping.X3_Fig_ISO_Code__c,
                        'Numeric' => isoCodeMapping.Numeric_ISO_Code__c
                });
            }
        }

        if (reverseIsoCodeMap.containsKey(twoLetterISO)) {
            return reverseIsoCodeMap.get(twoLetterISO);
        } else {
            return new Map<String, String>{
                    'Name' => null,
                    '3Fig' => null,
                    'Numeric' => null
            };
        }

    }
}