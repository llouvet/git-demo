import { LightningElement, wire } from 'lwc';
import { subscribe, MessageContext, unsubscribe } from 'lightning/messageService';
import QUERY_NAME from '@salesforce/schema/Query__c.Name';
import QUERY_STRING from '@salesforce/schema/Query__c.Query_String__c';
import QUERY_OBJECT from '@salesforce/schema/Query__c';
import queryMessage from '@salesforce/messageChannel/QueryMessage__c';
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class QuerySaver extends LightningElement {
    disabled = true;
    queryName;
    queryString;
    subscription = null;
    @wire(MessageContext)messageContext;

    subscribeToMessageChannel(){
        if(!this.subscription){
            this.subscription = subscribe(
                this.messageContext,
                queryMessage,
                (message) => this.handleMessage(message)
            );
        }
    }

    unsubscribeToMessageChannel(){
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    handleMessage(message){
        this.disabled = true;
        if(message.query){
            this.disabled = false;
            this.queryString = message.query;
        }
    }

    setName(event){
        this.queryName = event.detail.value;
    }

    connectedCallback(){
        this.subscribeToMessageChannel();
    }
    
    disconnectedCallback(){
        this.unsubscribeToMessageChannel();
    }

    createQueryRecord(){
        const fields = {};
        fields[QUERY_NAME.fieldApiName] = this.queryName;
        fields[QUERY_STRING.fieldApiName] = this.queryString;
        const recordInput = { apiName: QUERY_OBJECT.objectApiName, fields};
        createRecord(recordInput)
        .then(queryRecord => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Query saved successfully.',
                    variant: 'success'
                })
            )
        })
    }
}