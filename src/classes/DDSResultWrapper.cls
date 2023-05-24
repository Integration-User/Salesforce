/**
 * @description       : wrapper class to get the detail result of DDS Calculation Score.
 * @author            : Raúl Iglesias
 * @group             : Mckinsey
 * @last modified on  : 01-09-2023
 * @last modified by  : Raúl Iglesias
**/
public with sharing class DDSResultWrapper {
    
     /**
     * ********************
     * VARIABLES DEFINITION
     * ********************
    **/

    //Letter associated to the score obtained according to the residual percentage.
    @AuraEnabled
    public String letterGrade;

    //Opportunity ARR required to exceed the Residual cut-off % max value of the current pre/post record set identified.
    @AuraEnabled
    public Decimal absoluteARR;

    //Custom result message depending on the different casuistics : error in calculation, missing main variables, success...
    @AuraEnabled
    public String resultMessage;

    //Current opportunity total ARR
    @AuraEnabled
    public Decimal totalARR;

    //Residual amount to get the next xcore
    @AuraEnabled
    public Decimal residualAmount;

    //Error message to store a DML error from Salesforce.
    @AuraEnabled
    public String dmlError;

    
    /**
     * ********************
     * CONSTRUCTORS DEFINITION
     * ********************
    **/
    
    /**
    * @description : class constructor method.
    * @author Raúl Iglesias | 12-14-2022 
    **/
    public DDSResultWrapper() {
        this.letterGrade = null;
        this.absoluteARR = null;
        this.resultMessage = null;
        this.totalARR = null;
        this.residualAmount = null;
        this.dmlError = null;
    }
}