import { LightningElement, wire } from 'lwc';
import { subscribe, MessageContext, unsubscribe } from 'lightning/messageService';
import queryMessage from '@salesforce/messageChannel/QueryMessage__c';
import getRecords from '@salesforce/apex/SampleResultController.getRecords';

export default class SampleResult extends LightningElement {
    messageRecievedQuery;
    readyToRender = false;
    columns;
    data;
    title = "Sample Data with appear here."

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
        this.readyToRender = false;
        this.messageRecievedQuery = message.query;
        console.log(message);
        this.generateTable(message.query, message.fields);
        //this.readyToRender = true;
    }

    connectedCallback(){
        this.subscribeToMessageChannel();
    }
    
    disconnectedCallback(){
        this.unsubscribeToMessageChannel();
    }

    generateTable(query, fields){
        var mapFields = [];
        if(fields.length > 1){
            fields.forEach(field => {
                if(field.value!=='Id'){
                    let mapping = {label: field.name, fieldName: field.value};
                    mapFields.push(mapping);    
                }
            });
            this.columns = mapFields;
            getRecords({query: query})
            .then(result => {
                this.data = result;
                this.title = "Sample Data (limited to 10 records)"
                this.readyToRender = true;
            });
        }
        else{
            this.title = "Sample Data will appear here.";
            this.readyToRender = false;
        }
    }
}