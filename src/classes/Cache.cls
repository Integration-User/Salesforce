/**
* @author Zoran Zunko
* @date 7/9/21
*
*/
public class Cache {
    public static String recordTypeId(String recordTypeName) {
        String result = '';
        try {
            List<String> recordTypeParts = recordTypeName.split('\\.');
            String sobjectName = recordTypeParts[0];
            String recordTypeDevName = recordTypeParts[1];

            result = Schema.getGlobalDescribe().get(sobjectName).getDescribe().getRecordTypeInfosByDeveloperName().get(recordTypeDevName).recordTypeId;
        } catch(Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage() + ' - ' + ex.getStackTraceString());
        }
        return result;
    }
}