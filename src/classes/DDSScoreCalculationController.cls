/**
 * @description       : controller to execute the scoring logic of a deal and communicate with the corresponding LWC.
 * @author            : Raúl Iglesias
 * @group             : Mckinsey
 * @last modified on  : 01-05-2023
 * @last modified by  : Raúl Iglesias
**/
public without sharing class DDSScoreCalculationController {
    /**
     * ********************
     * IMPLEMENTATON LOGIC
     * ********************
     */

    /**
    * @description : method to obtain DDS Score result calling to DDS Score Calculation logic.
    * @author Raúl Iglesias | 11-28-2022 
    * @param recordId 
    * @return DDSResultWrapper  
    **/
    @AuraEnabled
    public static DDSResultWrapper getDDSScoreResult(String recordId){
        DDSScoreCalculationHandler ddsScore = new DDSScoreCalculationHandler(recordId);                               
        return ddsScore.calculateDDSScore();
    }
}