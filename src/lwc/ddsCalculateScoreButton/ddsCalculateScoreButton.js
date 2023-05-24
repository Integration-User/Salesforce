import { LightningElement, api } from 'lwc';
import { FlowNavigationNextEvent, FlowAttributeChangeEvent } from 'lightning/flowSupport';
import getDDSScoreResult from '@salesforce/apex/DDSScoreCalculationController.getDDSScoreResult';

export default class DdsCalculateScoreButton extends LightningElement {

    //-----Input variables---
    @api recordId;
    @api label;
    @api approvalLabel = 'Send for approval';

    //-----Output flow variables---
    @api scoreLetter;
    @api residualPercent;
    @api resultMessage;
    @api buttonPressed;
    @api absoluteARR;
    @api absoluteARR2;
    @api totalARR;
    @api dmlError;

    //Logic variables to control button visibility
    @api showSpinner = false;
    @api hiddenApprovalButton = false;

    //Call to the Score Calculation class.
    handleClick(){
        this.showSpinner = true;
        this.hiddeApprovalButton = true;

        //Call the logic class and return wrapper to the flow
        getDDSScoreResult({recordId: this.recordId})
        .then((data) =>{
            this.scoreLetter = data.letterGrade;
            this.absoluteARR = data.absoluteARR;
            this.totalARR = data.totalARR;
            this.dmlError = data.dmlError;
            this.buttonPressed = true;

            //Indicate to flow that the variables have been changed
            this.dispatchEvent(new FlowAttributeChangeEvent('scoreLetter', data.letterGrade));
            this.dispatchEvent(new FlowAttributeChangeEvent('dmlError', data.dmlError));
            this.dispatchEvent(new FlowAttributeChangeEvent('absoluteARR', data.absoluteARR));
            this.dispatchEvent(new FlowAttributeChangeEvent('totalARR', data.totalARR));
            this.dispatchEvent(new FlowAttributeChangeEvent('buttonPressed', true));

            //Logic to hide different buttons
            this.showSpinner = false;
            this.hiddenApprovalButton = false; 
            this.handleGoNext();
        }).catch(error => {
            console.log(error);
            this.showSpinner = false; 
            this.hiddenApprovalButton = false;   
        });
    }

    //Pass to the next screen flow when approval button is pressed
    handleClickApprovalButton(){
        this.handleGoNext();
    }

    //Send event to flow to navigate to the next screen
    handleGoNext() {
        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);
    }
    
   
}