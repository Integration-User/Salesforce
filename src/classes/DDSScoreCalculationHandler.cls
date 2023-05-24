/**
 * @description       : class with all the logic to calculate DDS Score in a deal record.
 * @author            : Raúl Iglesias
 * @group             : Mckinsey
 * @last modified on  : 01-24-2023
 * @last modified by  : Raúl Iglesias
**/
//CRUD Permissions
@SuppressWarnings('PMD')
public without sharing class DDSScoreCalculationHandler {

    /**
     * ********************
     * CONSTANTS DEFINITION
     * ********************
    **/

    private final String NEW_SALES_TYPE = 'New';
    private final String RENEWAL_SALES_TYPE = 'Renewal';
    private final Integer MULTIYEARS_NUMBER = 2;

    /**
     * ********************
     * VARIABLES DEFINITION
     * ********************
    **/
    
    //Current Opportunity record Id. 
    private String recordId;

    //Current Opportunity record.
    private Opportunity currentOpp;

    //Salesforce data preparation with their current values.
    public Map<String, String> dynamicSFValuesByName;

    //SKU value by products codes combinations
    private Map<String, String> skuByProductCodes;

    //Formula predictors coefficients by predictor value
    public Map<String, Decimal> coefficientByPredictorValue;

    //YoY Segment rate for renewal deal.
    private Decimal yoySegmentRate;

    //Original Score metadata record.
    private DDS_ModelScores__mdt originalScoreRate;

    //Model scores letters ranges.
    private List<DDS_ModelScores__mdt> scoreByResidualRange;

    //Predictive ARR calculated throug corresponding formula.
    private Decimal estimatedARR;

    //Original Score without post processing.
    private String originalScore;

    //Opportunity ARR required to exceed the Residual cut-off % max value of the current pre/post record set identified.
    private Decimal absoluteIncrementalARR;

    //In case of error is neccesary indicate if was an admin error or user input error.
    private Boolean isAdminError;

    //Save the current status of the different phases in the calculate of scoring to compose with a custom label a Score Debug message.
    private List<String> adminErrorsController;

    //Combination of DDS products codes
    private List<String> ddsProductCodes;

    //Result of the final calculate.
    public DDSResultWrapper resultWrapper;

    //Variable to get only test metadata records from Salesforce.
    public Boolean isTest;
    
    private Decimal essentialIncrementalARR;

    /**
     * ********************
     * CONSTRUCTORS DEFINITION
     * ********************
    **/

    //Custom exception class
    public virtual class DDSCustomException extends Exception {}

    /**
    * @description : basic constructor to calculate the DDS Score with real Salesforce data looking for into related deal records.
    * @author Raúl Iglesias | 11-28-2022 
    * @param recordId 
    **/
    public DDSScoreCalculationHandler(String recordId) {
        this.dynamicSFValuesByName = new Map<String,String> {
            'SKU' => null,
            'SalesType' => null,
            'AUM' => null,
            'UserCounts' => null,
            'Segment' => null,
            'Priority' => null,
            'Customer_Tenure' => null,
            'Analyst_Hours' => null,
            'TotalARR' => null,
            'RenewalYear' => null,
            'ContractLength' => null
        };
        this.recordId = recordId;
        this.currentOpp = null;
        this.skuByProductCodes = new Map<String, String>();
        this.coefficientByPredictorValue = new Map<String, Decimal>();
        this.scoreByResidualRange = new List<DDS_ModelScores__mdt>();
        this.ddsProductCodes = new List<String>();
        this.estimatedARR = null;
        this.originalScore = null;
        this.yoySegmentRate = null;
        this.originalScoreRate = null;
        //(0 = Pre processing data, 1 = SKU bundle calculated , 2 = Model Identified, 3 = Formula constructed, 4 = Calculated Estimated ARR , 5 =Calculate Score, 6 = Reasons)
        this.adminErrorsController = new List<String>{'N', 'N', 'N', 'N', 'N', 'N', 'N'};
        this.isAdminError = true;
        this.resultWrapper = new DDSResultWrapper();
        this.isTest = false;
    }

    /**
    * @description focused on quick testing of a score calculation by entering the necessary data for validation. 
    * @author Raúl Iglesias | 11-28-2022 
    * @param sku 
    * @param salesType 
    * @param aum 
    * @param usersCount 
    * @param segment 
    * @param priority 
    * @param tenure 
    * @param analystHours
    * @param totalARR
    * @param YoY
    * @param contractLength
    **/
    public DDSScoreCalculationHandler(  String sku, 
                                        String salesType, 
                                        String aum, 
                                        String usersCount, 
                                        String segment, 
                                        String priority, 
                                        String tenure, 
                                        String analystHours, 
                                        String totalARR, 
                                        Decimal YoY, 
                                        String contractLength) {

        this.dynamicSFValuesByName = new Map<String,String> {
            'SKU' => sku,
            'SalesType' => salesType,
            'AUM' => aum,
            'UserCounts' => usersCount,
            'Segment' => segment,
            'Priority' => salesType.equals(this.NEW_SALES_TYPE) ? '' : priority,
            'Customer_Tenure' => tenure,
            'Analyst_Hours' => String.isBlank(analystHours) ? '0' : analystHours,
            'TotalARR' => totalARR,
            'ContractLength' => String.isBlank(contractLength) ? '0' : contractLength
        };
        this.currentOpp = null;
        this.skuByProductCodes = new Map<String, String>();
        this.coefficientByPredictorValue = new Map<String, Decimal>();
        this.scoreByResidualRange = new List<DDS_ModelScores__mdt>();
        this.ddsProductCodes = new List<String>();
        this.estimatedARR = null;
        this.originalScore = null;
        this.yoySegmentRate = YoY;
        this.originalScoreRate = null;
        this.adminErrorsController = new List<String>{'N', 'N', 'N', 'N', 'N', 'N', 'NA'};
        this.isAdminError = true;
        this.resultWrapper = new DDSResultWrapper();
        this.isTest = false;
    }

    /**
     * ********************
     * IMPLEMENTATON LOGIC
     * ********************
     */

    //MAIN METHOD
    /**
    * @description : main method to group all the phases in the calculation returning a detail result.
    * @author Raúl Iglesias | 12-02-2022 
    * @return DDSResultWrapper 
    **/
    public DDSResultWrapper calculateDDSScore(){
        try{
            this.prepareDDSData();
            this.formulaConstructionAndCalculationEstimatedARR();
            this.calculateOriginalScore();
            this.applyPostProcessingValidations();
            this.updateOpportunity(this.originalScore);
            return this.resultWrapper;
        }catch(Exception e){
            this.adminErrorsController[6] = e.getMessage();
            this.originalScore = this.isAdminError ? 'ErrorAdmin' : 'ErrorInput';
            this.updateOpportunity(this.originalScore);
            return this.resultWrapper;
        } 
    }

     //DATA PREPARATION PHASE//

     /**
     * @description : data preparation phase.
     * @author Raúl Iglesias | 11-29-2022 
     **/
     private void prepareDDSData(){
        this.getRelatedOpportunityData();
        this.getDDSStaticData();
     }

    /**
    * @description : get all the different information from current deal and related rexords.
    * @author Raúl Iglesias | 11-29-2022 
    **/
    private void getRelatedOpportunityData(){

        //Add product code filters.
        if(!String.isBlank(this.recordId)){
            try{
                this.currentOpp = [SELECT Id, AccountId, format(DDS_AverageTotalArr__c) formatTotalARR, Total_ARR__c, Renewal_Year__c,CurrencyIsoCode,
                                   DDS_StartingPriceUSD__c, Sales_Type__c, Length_of_Contract__c, AverageTotalARR__c,
                                   (SELECT Id, Product2.ProductCode FROM OpportunityLineItems WHERE Lost_Product__c = false)
                                        FROM Opportunity 
                                            WHERE Id = : this.recordId];
                //Necessary this second query by limitation in alias functionality.
                this.currentOpp.Account = [SELECT Id, Priority__c, Years_as_Client__c , DDS_Segment__c, format(DDS_AUMValue__c) formatAUM, 
                                           User_Count__c, DDS_AUMValue__c, Analyst_Hours__c, Client_Segment_New__c, Company_Type__c
                                            FROM Account 
                                                WHERE Id = : this.currentOpp.AccountId];
            }catch(Exception e){
                throw new DDSCustomException(Label.DDS_NoDeal);
            }
            this.getDDSProductCodes();
        }

        this.fillDynamicSFValuesMap();
        this.prepareSKUData();

        if(this.currentOpp != null){this.calculateSKUbyProductCombinations();}
    }

    /**
    * @description : dynamicSFValues map fill with values obtained from the current opp and related records.
    * @author Raúl Iglesias | 11-29-2022 
    **/
    private void fillDynamicSFValuesMap(){

        if(!String.isBlank(this.recordId) && this.currentOpp != null){
            this.dynamicSFValuesByName.put('SalesType', this.currentOpp.Sales_Type__c == this.NEW_SALES_TYPE || this.currentOpp.Sales_Type__c == 'Upsell' ? this.NEW_SALES_TYPE : this.currentOpp.Sales_Type__c );
            this.dynamicSFValuesByName.put('AUM', String.valueOf(this.currentOpp.Account?.DDS_AUMValue__c));
            this.dynamicSFValuesByName.put('UserCounts', String.valueOf(this.currentOpp.Account?.User_Count__c));
            this.dynamicSFValuesByName.put('Segment', this.currentOpp.Account?.DDS_Segment__c);
            this.dynamicSFValuesByName.put('Priority', this.currentOpp.Sales_Type__c == this.NEW_SALES_TYPE || this.currentOpp.Sales_Type__c == 'Upsell' ? null : this.currentOpp.Account?.Priority__c);
            this.dynamicSFValuesByName.put('Customer_Tenure', String.valueOf(this.currentOpp.Account?.Years_as_Client__c));
            this.dynamicSFValuesByName.put('Analyst_Hours', this.currentOpp.Account?.Analyst_Hours__c != null ? String.valueOf(this.currentOpp.Account?.Analyst_Hours__c) : '0');
            this.dynamicSFValuesByName.put('TotalARR', String.valueOf(this.currentOpp.AverageTotalARR__c));
            this.dynamicSFValuesByName.put('RenewalYear', this.currentOpp.Renewal_Year__c);
            this.dynamicSFValuesByName.put('ContractLength', this.currentOpp.Length_of_Contract__c == null ? '0' : String.valueOf(Math.floor(this.currentOpp.Length_of_Contract__c)));
        }

        if(!this.areTheRequiredDataCompleteAccordingToTheModel()){
            this.isAdminError = !((String.isBlank(this.dynamicSFValuesByName.get('Segment')) && String.isBlank(this.currentOpp.Account.Company_Type__c)) 
                                || String.isBlank(this.dynamicSFValuesByName.get('TotalARR')) 
                                || (this.currentOpp != null && this.currentOpp.AverageTotalARR__c == null)
                                || (String.isBlank(this.dynamicSFValuesByName.get('Priority')) && this.dynamicSFValuesByName.get('SalesType')?.equals(this.RENEWAL_SALES_TYPE)));
                                    
            throw new DDSCustomException(String.format(Label.DDS_AdminFieldErrors, new List<String>{this.indicateMissingField(this.dynamicSFValuesByName.get('Analyst_Hours')), 
                                                                                                    this.indicateMissingField(this.dynamicSFValuesByName.get('UserCounts')), 
                                                                                                    this.indicateMissingField(this.dynamicSFValuesByName.get('SalesType')),
                                                                                                    this.indicateMissingField(this.dynamicSFValuesByName.get('Customer_Tenure'))})
                                        + ((String.isBlank(this.dynamicSFValuesByName.get('Segment')) && !String.isBlank(this.currentOpp.Account.Company_Type__c))
                                           ? '\n' + Label.DDS_MissingSegmentMapping + ' ' + this.currentOpp.Account.Company_Type__c 
                                           : ''));
        } 
    }        
    /**
    * @description : prepare differents data estructures for the different metadata types tables.
    * @author Raúl Iglesias | 11-29-2022 
    **/
    private void getDDSStaticData(){
        this.prepareScoreData();
        this.prepareConstructorFormulaData();
    }

    //CONSTRUCTED FORMULA AND CALCULATE PREDICTIVE ARR

    /**s
    * @description : method to calculate estimated ARR depending of the model type.
    * @author Raúl Iglesias | 12-01-2022 
    **/
    private void formulaConstructionAndCalculationEstimatedARR(){
        //New Logo model formula
        if(this.dynamicSFValuesByName.get('SalesType').equals(this.NEW_SALES_TYPE)){
           this.calculateEstimatedArrNewModel();
        //Renewal with AUM model formula
        }else if(this.dynamicSFValuesByName.get('SalesType').equals(this.RENEWAL_SALES_TYPE) 
                && (String.isNotBlank(this.dynamicSFValuesByName.get('AUM')) && Decimal.ValueOf(this.dynamicSFValuesByName.get('AUM')) > 0)){
           this.calculateEstimatedArrRenewalModel();
        //Renewal without AUM model formula
        }else{
            this.calculateEstimatedArrRenewalWithoutAumModel();
        }
        this.adminErrorsController[3] = 'Y';
        this.adminErrorsController[4] = 'Y';
    }

    //CALCULATE ORIGINAL SCORE

    /**
    * @description : different steps to calculate origin letter score without post processing steps.
    * @author Raúl Iglesias | 12-02-2022 
    **/
    private void calculateOriginalScore(){

        if(!this.scoreByResidualRange.isEmpty()){
            this.translateModelScoreCutOffsAndGetScoreLetter();
        }else{
            throw new DDSCustomException(Label.DDS_ModelScoreRecords);
        }
    }

    //POST PROCESSING VALIDATIONS//

    /**
    * @description : apply necessary post processing steps and calculate absolute incremental ARR to get the next best letter.
    * @author Raúl Iglesias | 12-09-2022 
    **/
    public void applyPostProcessingValidations(){
        if(!this.originalScore.equals('A')){//TO DO Check
            this.absoluteIncrementalARR = (this.originalScoreRate.ResidualCutOffMax__c - Decimal.valueOf(this.dynamicSFValuesByName.get('TotalARR'))).setScale(2, RoundingMode.CEILING);
        }else{
            this.absoluteIncrementalARR = 0;
        }
        if (!this.originalScore.equals('F')) {
            this.essentialIncrementalARR = (Decimal.valueOf(this.dynamicSFValuesByName.get('TotalARR')) - this.originalScoreRate.ResidualCutOffMin__c).setScale(2, RoundingMode.CEILING);
        } else {
            this.essentialIncrementalARR = 0;
        }
        this.adminErrorsController[5] = 'Y';
    }
    

    /**
     * ********************
     *    UTILS METHODS
     * ********************
     *
    /**
     
    * @description : function to determine if a decimal Number is into a specified range.
    * @author Raúl Iglesias | 11-30-2022 
    * @param decimalNumber 
    * @param minRange 
    * @param maxRange 
    * @return Boolean 
    **/
    private Boolean numberIsInRange(Decimal decimalNumber, Decimal minRange, Decimal maxRange){
        return (minRange == null || decimalNumber >= minRange) 
                && (maxRange == null || decimalNumber <= maxRange);
    }

    /**
    * @description : indicate if a value is blank to return label word.
    * @author Raúl Iglesias | 12-14-2022 
    * @param stringToCheck 
    * @return string 
    **/
    private string indicateMissingField(String stringToCheck){
        return String.isBlank(stringToCheck) || stringToCheck.equals('None') ? Label.DDS_MissingField : stringToCheck;
    }

    /**
    * @description : calulate SKU with the current DDS product combination codes in the opportunity for a specific client.
    * @author Raúl Iglesias | 11-30-2022 
    **/
    private void calculateSKUbyProductCombinations(){

        this.adminErrorsController[0] = 'Y';
        this.adminErrorsController[2] = 'Y';

        //Sort products codes to obtain the exact possibles keys.
        if(this.ddsProductCodes != null && !this.ddsProductCodes.isEmpty()){
            this.ddsProductCodes.sort();
            //SF-431
            Set<String> uniqueProductCodes =  new Set<String>();
            uniqueProductCodes.addAll(this.ddsProductCodes);
            // String inputKeyProductCombination = String.join(this.ddsProductCodes,'');
            String inputKeyProductCombination = String.join(new List<String>(uniqueProductCodes),'');

            if(this.skuByProductCodes.containsKey(inputKeyProductCombination)){
                this.dynamicSFValuesByName.put('SKU', this.skuByProductCodes.get(inputKeyProductCombination));
                this.adminErrorsController[1] = 'Y';
            }else{
                throw new DDSCustomException(Label.DDS_SKUNotFound + this.ddsProductCodes);
            } 
        }else{
            throw new DDSCustomException(Label.DDS_ProductsNotValid);
        }
    }

    /**
    * @description : conditions that the salesforce data has to meet to continue with the process.
    * @author Raúl Iglesias | 11-30-2022 TO DO : Add Customer Total ARR
    * @return Boolean 
    **/
    private Boolean areTheRequiredDataCompleteAccordingToTheModel(){
      return !((String.isBlank(this.dynamicSFValuesByName.get('SalesType')) || String.isBlank(this.dynamicSFValuesByName.get('Segment')))
                || (this.currentOpp != null && this.currentOpp?.AverageTotalARR__c == null)
                || String.isBlank(this.dynamicSFValuesByName.get('TotalARR'))
                || (this.dynamicSFValuesByName.get('SalesType') == this.RENEWAL_SALES_TYPE 
                    && (String.isBlank(this.dynamicSFValuesByName.get('Customer_Tenure')) 
                    || String.isBlank(this.dynamicSFValuesByName.get('UserCounts')) 
                    || String.isBlank(this.dynamicSFValuesByName.get('Priority')))));
    }

    /**
    * @description : conditions that the New Logo Model has to meet to execute the calculation
    * @author Raúl Iglesias | 12-01-2022 
    * @return Boolean 
    **/
    private Boolean notMeetConditionsToNewLogoModel(){
        return !this.coefficientByPredictorValue.containsKey(this.dynamicSFValuesByName.get('SKU'))
                || !this.coefficientByPredictorValue.containsKey(this.dynamicSFValuesByName.get('Segment'));
    }

    /**
    * @description : conditions that the Renewal with AUM Model has to meet to execute the calculation
    * @author Raúl Iglesias | 12-01-2022 
    * @return Boolean 
    **/
    private Boolean notMeetConditionsToRenewalWithAUMModel(){
        return !this.coefficientByPredictorValue.containsKey('Log_AUM')
                || !this.coefficientByPredictorValue.containsKey('Log_Users')
                || !this.coefficientByPredictorValue.containsKey(this.dynamicSFValuesByName.get('SKU'))
                || !this.coefficientByPredictorValue.containsKey(this.dynamicSFValuesByName.get('Segment'))
                || !this.coefficientByPredictorValue.containsKey('Customer_Tenure')
                || !this.coefficientByPredictorValue.containsKey('Analyst_Hours');
    }

    /**
    * @description : conditions that the Renewal without AUM Model has to meet to execute the calculation
    * @author Raúl Iglesias | 12-01-2022 
    * @return Boolean 
    **/
    private Boolean notMeetConditionsToRenewalWithoutAUMModel(){
        return  !this.coefficientByPredictorValue.containsKey('Log_Users')
                || !this.coefficientByPredictorValue.containsKey(this.dynamicSFValuesByName.get('SKU'))
                || !this.coefficientByPredictorValue.containsKey(this.dynamicSFValuesByName.get('Segment'))
                || !this.coefficientByPredictorValue.containsKey('Customer_Tenure')
                || !this.coefficientByPredictorValue.containsKey('Analyst_Hours');
    }

    /**
    * @description : translate the residual cutt off ranges to dollars and get corresponding score letter .
    * @author Raúl Iglesias | 12-07-2022 
    **/
    private void translateModelScoreCutOffsAndGetScoreLetter(){

        Boolean isIntoThisRange = false;

        for(Integer i = 0; i < this.scoreByResidualRange.size(); i++ ){

            this.scoreByResidualRange[i].ResidualCutOffMax__c = this.getTranslatedRange(this.scoreByResidualRange[i].ResidualCutOffMax__c);
            this.scoreByResidualRange[i].ResidualCutOffMin__c = this.getTranslatedRange(this.scoreByResidualRange[i].ResidualCutOffMin__c);

            //Second is compare if the customer ARR is into this range
            isIntoThisRange = this.numberIsInRange(Decimal.valueOf(this.dynamicSFValuesByName.get('TotalARR')), 
                                                   this.scoreByResidualRange[i].ResidualCutOffMin__c, 
                                                   this.scoreByResidualRange[i].ResidualCutOffMax__c);
            if(isIntoThisRange){
                this.originalScore = this.scoreByResidualRange[i].Score__c;
                this.originalScoreRate =this.scoreByResidualRange[i];
                break;
            }
        }

        if(!isIntoThisRange){
            throw new DDSCustomException(Label.DDS_NoModelScoreRange + this.dynamicSFValuesByName.get('TotalARR'));
        } 
    }

    /**
    * @description 
    * @author Raúl Iglesias | 01-03-2023 
    * @param range 
    * @return Decimal 
    **/
    private Decimal getTranslatedRange(Decimal range){
        //First is transalted the cutt off range
        //For contracts without multi year or without year over year percent found.
        if(Decimal.valueOf(this.dynamicSFValuesByName.get('ContractLength')) < this.MULTIYEARS_NUMBER || this.yoySegmentRate == 0){
            return range != null ? ((range/100 +1) * this.estimatedARR) * (this.yoySegmentRate/100 +1) : null;
        //For multi year contracts
        }else{
            return range != null 
                ? ((((range/100 +1) * this.estimatedARR) 
                    * (this.dynamicSFValuesByName.get('SalesType').equals(this.NEW_SALES_TYPE) ? 1 : (this.yoySegmentRate/100 +1)))
                    * (1-(Math.pow(Double.valueOf((this.yoySegmentRate/100 +1)), Double.valueOf(this.dynamicSFValuesByName.get('ContractLength')))))
                        / (1 - (this.yoySegmentRate/100 +1)))
                            / Decimal.valueOf(this.dynamicSFValuesByName.get('ContractLength'))
                : null;
        }
    }

    /**
    * @description : formula to calculate estimated ARR in Renewal with AUM Model.
    * @author Raúl Iglesias | 12-09-2022 
    **/
    private void calculateEstimatedArrRenewalModel(){
         //Required Renewal with AUM parameters, in case some one missing, throw error
         if(this.notMeetConditionsToRenewalWithAUMModel()){

            throw new DDSCustomException(String.format(Label.DDS_ValuesRenewalAUM,
                                         new List<String>{String.valueOf(this.coefficientByPredictorValue.containsKey('Log_AUM')), 
                                                          String.valueOf(this.coefficientByPredictorValue.containsKey('Log_Users')), 
                                                          String.valueOf(this.coefficientByPredictorValue.containsKey(this.dynamicSFValuesByName.get('SKU'))),
                                                          String.valueOf(this.coefficientByPredictorValue.containsKey(this.dynamicSFValuesByName.get('Segment'))),
                                                          String.valueOf(this.coefficientByPredictorValue.containsKey('Customer_Tenure')),
                                                          String.valueOf(this.coefficientByPredictorValue.containsKey('Analyst_Hours'))}));

        //Math expression : Predictive ARR = exp(Log_User coefficient * log(UserCount Value) + Log_AUM coefficient * log(AUM Value) 
        //                                  + CustomerTenure Coefficient * Customer Tenure value +  SKU Coefficient + Segment Coeficcient);
        }else{
            this.estimatedARR = Math.exp(this.coefficientByPredictorValue.get('Log_Users') * Decimal.valueOf(this.dynamicSFValuesByName.get('UserCounts'))
                                            + this.coefficientByPredictorValue.get('Log_AUM') * Math.log(Decimal.valueOf(this.dynamicSFValuesByName.get('AUM')))
                                            + this.coefficientByPredictorValue.get('Customer_Tenure') * Decimal.valueOf(this.dynamicSFValuesByName.get('Customer_Tenure'))
                                            + this.coefficientByPredictorValue.get('Analyst_Hours') * Decimal.valueOf(this.dynamicSFValuesByName.get('Analyst_Hours'))
                                            + this.coefficientByPredictorValue.get(this.dynamicSFValuesByName.get('SKU')) 
                                            + this.coefficientByPredictorValue.get(this.dynamicSFValuesByName.get('Segment')));
        }
    }

    /**
    * @description :formula to calculate estimated ARR in Renewal without AUM Model. TO DO : review formulas , where include analyst hours
    * @author Raúl Iglesias | 12-09-2022 
    **/
    private void calculateEstimatedArrRenewalWithoutAumModel(){
        //Required Renewal without AUM parameters, in case some one missing, throw error
        if(this.notMeetConditionsToRenewalWithoutAUMModel()){
            throw new DDSCustomException(String.format(Label.DDS_ValuesRenewal,
                                         new List<String>{String.valueOf(this.coefficientByPredictorValue.containsKey('Log_Users')), 
                                                          String.valueOf(this.coefficientByPredictorValue.containsKey(this.dynamicSFValuesByName.get('SKU'))),
                                                          String.valueOf(this.coefficientByPredictorValue.containsKey(this.dynamicSFValuesByName.get('Segment'))),
                                                          String.valueOf(this.coefficientByPredictorValue.containsKey('Customer_Tenure')),
                                                          String.valueOf(this.coefficientByPredictorValue.containsKey('Analyst_Hours'))}));

         //Math expression : Predictive ARR = exp(Log_User coefficient * log(UserCount Value) + CustomerTenure Coefficient * Customer Tenure value
        //                                   +  SKU Coefficient + Segment Coeficcient);
        }else{
            this.estimatedARR = Math.exp(this.coefficientByPredictorValue.get('Log_Users') * Decimal.valueOf(this.dynamicSFValuesByName.get('UserCounts'))
                                        + this.coefficientByPredictorValue.get('Customer_Tenure') * Decimal.valueOf(this.dynamicSFValuesByName.get('Customer_Tenure'))
                                        + this.coefficientByPredictorValue.get('Analyst_Hours') * Decimal.valueOf(this.dynamicSFValuesByName.get('Analyst_Hours'))
                                        + this.coefficientByPredictorValue.get(this.dynamicSFValuesByName.get('SKU')) 
                                        + this.coefficientByPredictorValue.get(this.dynamicSFValuesByName.get('Segment')));
        }
    }

    /**
    * @description : formula to calculate estimated ARR in New logo Model.
    * @author Raúl Iglesias | 12-09-2022 
    **/
    private void calculateEstimatedArrNewModel(){
         //Required new logo parameters, in case some one missing, throw error
         if(this.notMeetConditionsToNewLogoModel()){

            throw new DDSCustomException(String.format(Label.DDS_ValuesNewLogo,
                                         new List<String>{String.valueOf(this.coefficientByPredictorValue.containsKey(this.dynamicSFValuesByName.get('SKU'))),
                                                          String.valueOf(this.coefficientByPredictorValue.containsKey(this.dynamicSFValuesByName.get('Segment')))}));
        //Math expression : Predictive ARR = exp(SKU Coefficient + Segment Coeficcient);
        }else{
            this.estimatedARR = Math.exp(this.coefficientByPredictorValue.get(this.dynamicSFValuesByName.get('SKU')) 
                                + this.coefficientByPredictorValue.get(this.dynamicSFValuesByName.get('Segment')));
        }
    }

    /**
    * @description : Prepare Formula Predictors metadata table.
    * @author Raúl Iglesias | 12-09-2022 
    **/
    private void prepareConstructorFormulaData(){

        String keyMap = '';
        for(DDS_FormulaPredictor__mdt ddsFormulaPredictorRecord : [SELECT PredictorName__c, PredictorValue__c, Coefficient__c 
                                                                    FROM DDS_FormulaPredictor__mdt
                                                                        WHERE SalesType__c = : this.dynamicSFValuesByName.get('SalesType')
                                                                            AND IsForTesting__c = : this.isTest
                                                                                AND WithAUM__c = : (this.dynamicSFValuesByName.get('SalesType').equals(this.NEW_SALES_TYPE) 
                                                                                                    ? false 
                                                                                                    : String.isNotBlank(this.dynamicSFValuesByName.get('AUM'))) ]){
            //Te key map will be generated with the predictor value in case of predictor name was SKU or Segment, else will be the predictor name like Log_Users or Customer_Tenure.
            keyMap = String.isBlank(ddsFormulaPredictorRecord.PredictorValue__c) ? ddsFormulaPredictorRecord.PredictorName__c : ddsFormulaPredictorRecord.PredictorValue__c;
            if(!this.coefficientByPredictorValue.containsKey(keyMap)){
                this.coefficientByPredictorValue.put(keyMap, ddsFormulaPredictorRecord.Coefficient__c);
            }
        }

        this.adminErrorsController[0] = 'Y';
        this.adminErrorsController[1] = 'Y';
        this.adminErrorsController[2] = 'Y';
    }

    /**
    * @description : Prepare Model Scores and YoY segment rate metadata table helper.prepareScoreData(this.scoreByResidualRange);
    * @author Raúl Iglesias | 12-09-2022 
    **/
    private void prepareScoreData(){

        //Get YoY segment rate for renewals deals and new logo model with multi year.
        if((this.dynamicSFValuesByName.get('SalesType').equals(this.RENEWAL_SALES_TYPE) 
                || (this.dynamicSFValuesByName.get('SalesType').equals(this.NEW_SALES_TYPE) && Decimal.valueOf(this.dynamicSFValuesByName.get('ContractLength')) >= this.MULTIYEARS_NUMBER))
            && this.yoySegmentRate == null){

            this.yoySegmentRate = [SELECT YoY_Rate__c 
                                    FROM DDS_YoYSegmentation__mdt	
                                        WHERE Segment__c =: this.dynamicSFValuesByName.get('Segment')
                                            AND IsForTesting__c = : this.isTest
                                                AND SKU__c = : this.dynamicSFValuesByName.get('SKU')
                                                    AND SalesType__c = : this.dynamicSFValuesByName.get('SalesType')
                                                        AND EffectiveYear__c =: (String.isBlank(this.dynamicSFValuesByName.get('RenewalYear')) 
                                                                                ? null
                                                                                : Decimal.valueOf(this.dynamicSFValuesByName.get('RenewalYear'))) LIMIT 1]?.YoY_Rate__c;
           
        }

        if(this.yoySegmentRate == null){
            this.yoySegmentRate = 0;
        }

        this.scoreByResidualRange = [SELECT ResidualCutOffMax__c, ResidualCutOffMin__c, Score__c ,IsForTesting__c
                                        FROM DDS_ModelScores__mdt
                                            WHERE SalesType__c = : this.dynamicSFValuesByName.get('SalesType')
                                                AND IsForTesting__c = : this.isTest
                                                    AND AccountPriority__c = : this.dynamicSFValuesByName.get('Priority')
                                                        ORDER BY Score__c ASC];
    }

    /**
    * @description : Prepare SKU metadata table.
    * @author Raúl Iglesias | 12-09-2022 
    **/
    private void prepareSKUData(){

        String keyMap = '';
        List<String> sortProductCombinationList = new List<String>();

        for(DDS_SKUCombination__mdt ddsSKURecord : [SELECT SKU__c, ProductCombination__c 
                                                        FROM DDS_SKUCombination__mdt 
                                                            WHERE IsForTesting__c = : this.isTest]){

            //The key is generated with the product codes joined in a single string sorted in alphabetical order.
            sortProductCombinationList = (ddsSKURecord.ProductCombination__c).split(';');
            sortProductCombinationList.sort();

            keyMap = String.join(sortProductCombinationList, '');

            if(!this.skuByProductCodes.containsKey(keyMap)){
                this.skuByProductCodes.put(keyMap, ddsSKURecord.SKU__c);
            }
        }
    }

    /**
    * @description : format to AUM value to currency with correspond IsoCode
    * @author Raúl Iglesias | 12-14-2022 
    * @return String 
    **/
    private String formatAUMToCurrency(){
        return ( this.currentOpp?.Account != null 
                ? String.valueOf(this.currentOpp.Account.DDS_AUMValue__c == null ? '' : '•AUM: ' + this.currentOpp.Account.get('formatAUM') + '\n')
                : this.dynamicSFValuesByName.get('AUM'))  ; 
    }

    /**
    * @description build with the different parameters the score insight message.
    * @author Raúl Iglesias | 12-14-2022 
    * @return String 
    **/
    private String buildScoreInsightMessage(){
        return (this.dynamicSFValuesByName.get('SalesType').equals(this.NEW_SALES_TYPE) 
                    ? + '' 
                    : + Label.DDS_Priority + ' '+ this.indicateMissingField(this.dynamicSFValuesByName.get('Priority')) + '\n' )  
                    + (this.currentOpp != null && Decimal.valueOf(this.dynamicSFValuesByName.get('ContractLength')) < this.MULTIYEARS_NUMBER 
                        ? Label.DDS_OpportunityARR + ' ' + this.indicateMissingField(String.valueOf(this.currentOpp.get('formatTotalARR'))) + '\n' 
                        : '')
                    + Label.DDS_Segment + ' ' + (this.currentOpp != null ? ((String.isBlank(this.dynamicSFValuesByName.get('Segment')) 
                                                                                && String.isBlank(this.currentOpp.Account.Company_Type__c)
                                                                            ? Label.DDS_MissingCompany_Type
                                                                            : this.indicateMissingField(this.currentOpp.Account.Client_Segment_New__c)))
                                                                         : this.indicateMissingField(this.dynamicSFValuesByName.get('Segment'))) + '\n'
                    + (this.dynamicSFValuesByName.get('SalesType').equals(this.NEW_SALES_TYPE) 
                                ? '' 
                                : + this.formatAUMToCurrency())
                    + Label.DDS_Model + ' ' + this.indicateMissingField(this.dynamicSFValuesByName.get('SalesType')) 
                    + (Decimal.valueOf(this.dynamicSFValuesByName.get('ContractLength')) >= this.MULTIYEARS_NUMBER 
                        ? ' ' + Label.DDS_WithMultiyear 
                        : '')+ '\n';
    }


    /**
    * @description : calculate what is the combination of products codes including react product logic and lost products.
    * @author Raúl Iglesias | 12-16-2022 
    **/
    private void getDDSProductCodes(){

        Set<String> lostProductsCodes = new Set<String>();

        if(this.currentOpp?.OpportunityLineItems.isEmpty()){
            this.isAdminError = false;
            throw new DDSCustomException(Label.DDS_AddProducts);
        }
       
        //Get all the different opportunity product codes to calculate the SKU
        for(OpportunityLineItem oliRecord : this.currentOpp?.OpportunityLineItems){
            if(oliRecord.Product2.ProductCode != null){
                this.ddsProductCodes.add(oliRecord.Product2.ProductCode);
            }
        }
    }


    /**
    * @description : update opportunity and prepare result wrapper.
    * @author Raúl Iglesias | 12-12-2022 
    * @param score 
    **/
    private void updateOpportunity(String score){

        Opportunity oppToUpdate = new Opportunity(
            Id = this.recordId,
            DDS_ScoreDebug__c = String.format(Label.DDS_AdminError, this.adminErrorsController),
            DDS_ScoreInsight__c =  this.dynamicSFValuesByName.get('SalesType') != null ? this.buildScoreInsightMessage() : this.adminErrorsController[6],
            DDS_ScoreAssignment__c = score,
            DDS_ScoreARRResidual__c = this.absoluteIncrementalARR,
            DDS_ScoreARREssential__c = this.essentialIncrementalARR,
            DDS_ScoreInsightARRpercentage__c = this.absoluteIncrementalARR != null 
                                                && score != 'A'
                                                && this.currentOpp.DDS_StartingPriceUSD__c != null
                                                && this.dynamicSFValuesByName.get('SalesType') == this.RENEWAL_SALES_TYPE
                                                && this.recordId != null 
                                                    ? (((( this.originalScoreRate.ResidualCutOffMax__c - this.currentOpp.DDS_StartingPriceUSD__c) 
                                                        / this.currentOpp.DDS_StartingPriceUSD__c ))
                                                        *100).setScale(2, RoundingMode.CEILING)
                                                    : null
                                                
        );                                                 
        //Return variables to flow.
        this.resultWrapper.letterGrade = score;
        this.resultWrapper.absoluteARR = this.absoluteIncrementalARR;
        this.resultWrapper.totalARR = this.currentOpp != null ? this.currentOpp.AverageTotalARR__c : null;

        if(this.currentOpp != null){
            try{
                update oppToUpdate;
            }catch(Exception e){
                this.resultWrapper.dmlError = e.getMessage();
            }
        }
    }
}