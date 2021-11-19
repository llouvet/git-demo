import { LightningElement, wire } from 'lwc';
import getAllObjects from '@salesforce/apex/QueryBuilderController.getAllObjects';
import getAllFields from '@salesforce/apex/QueryBuilderController.getAllFields';
import getAllOperators from '@salesforce/apex/QueryBuilderController.getAllOperators';
import getAllPicklistValues from '@salesforce/apex/QueryBuilderController.getAllPicklistValues';
import { publish, MessageContext } from 'lightning/messageService';
import queryMessage from '@salesforce/messageChannel/QueryMessage__c';

export default class QueryBuilder extends LightningElement {

    objOptions = [];
    objValue;
    objIsSelected = false;
    isDisabled = true;
    fieldOptions = [];
    requiredFields = ['Id'];
    selectedFields = ['Id'];
    selectedFieldsWithLabel = [];
    query;

    filterFieldName;
    filterFieldValue;
    filterFieldType;
    isFilterFieldPicklist = false;
    filterFieldOptions;
    operatorOptions = [];
    filterOperatorName;
    filterOperatorValue;
    filterInputName;
    filterInputValue;
    inputType;
    notAllFieldsFilled = true;

    filters = [];
    filtersToString = '';
    render = false;

    customLogic = false;
    customLogicValue;

    @wire(MessageContext)messageContext;

    @wire(getAllObjects)wiredObjects(result){
        console.log(result);
        if(result.data){
            let unsorted = JSON.parse(JSON.stringify(result.data));
            this.objOptions = unsorted.sort((a, b) => a.label.localeCompare(b.label));
        }
        if(result.error){
            console.log(result.error);
        }
    }

    saveObject(event){
        this.objValue = event.detail.value;
        this.objIsSelected = true;
        this.query = 'SELECT \nFROM '+this.objValue;
        getAllFields({objApiName: this.objValue})
        .then(result => {
            this.fieldOptions = result;
            this.selectedFields = ['Id'];
            this.generateQuery();
            this.isDisabled = false;
        });
    }

    saveFields(event){
        this.selectedFields = event.detail.value;
        if(!this.selectedFields.includes('Id'))this.selectedFields.unshift('Id');
        let selectedFieldData = [];
        this.selectedFields.forEach(field => {
            var selectedFieldName = this.fieldOptions.find(({value}) => value === field).label;
            var selectedFieldWithLabel = {name: selectedFieldName, value: field};
            selectedFieldData.push(selectedFieldWithLabel);
        });
        this.selectedFieldsWithLabel = selectedFieldData;
        this.generateQuery();
        console.log(this.query);

    }

    displayOperators(event){
        this.filterFieldValue = event.detail.value;
        this.filterFieldName = this.fieldOptions.find(({value}) => value === this.filterFieldValue).label;
        this.filterFieldType = this.fieldOptions.find(({value}) => value === this.filterFieldValue).type;
        getAllOperators({fieldType: this.filterFieldType})
        .then(result => {
            console.log(result);
            this.operatorOptions = result;
            this.inputType = result[0].type;
        })
        if(this.filterFieldType==='PICKLIST'){
            getAllPicklistValues({objectName: this.objValue, fieldName: this.filterFieldName})
            .then(result => {
                this.filterFieldOptions = result;
                this.isFilterFieldPicklist = true;
            })
        }
    }

    setOperator(event){
        this.filterOperatorValue = event.detail.value;
        this.filterOperatorName = this.operatorOptions.find(({value}) => value === this.filterOperatorValue).label;
    }

    isAllFieldsFilled(event){
        this.filterInputValue = event.detail.value;
        this.filterInputName = event.detail.value;
        if(this.filterOperatorValue!==undefined && this.filterFieldValue!==undefined && this.filterInputValue!==undefined
            && this.filterInputValue!==''){
            this.notAllFieldsFilled = false;
        }
        else{
            this.notAllFieldsFilled = true;
        }
    }

    addFilter(){
        this.render = false;
        if((this.filterOperatorValue==='isEmpty'||this.filterOperatorValue==='isNull')&&(this.filterInputValue!=='TRUE'&&this.filterInputValue!=='FALSE')){
            console.log('error!');
        }
        else{
            console.log(this.filterOperatorValue);
            let operator = this.convertOperator()[this.filterOperatorValue];
            if(operator.includes('###')){
                operator = operator.replace('###',this.filterInputValue);
            }
            if(this.filterOperatorValue==='isEmpty'||this.filterOperatorValue==='isNull'){
                if(this.filterInputValue==='TRUE'){
                    operator = '= '+operator;
                }
                else if(this.filterInputValue==='FALSE'){
                    operator = '!= '+operator;
                }
            }
            else{
                operator += ' ';
                if(this.inputType!=='number' && !operator.includes('%')){
                    operator += '\''+this.filterInputValue+'\'';
                }
                else if(!operator.includes('%')){
                    operator += this.filterInputValue;
                }
            }
            operator = this.filterFieldValue + ' ' + operator;
            console.log(operator);
            let opValue = {label: this.filterFieldName+' '+this.filterOperatorName+' '+this.filterInputName, value:operator};
            console.log(this.filters);
            console.log(this.filters.includes(opValue));
            let test = this.filters.find(({label}) => label === opValue.label);
            console.log(test);
            if(!this.filters.find(({label}) => label === opValue.label)){
                this.filters.push(opValue);
            }
            this.render = true;
            this.isFilterFieldPicklist = false;
            this.generateFilterString();
            this.generateQuery();
        }
    }

    convertOperator(){
        const operatorMapping = {
            'equals':'=',
            'startsWith':'LIKE \'###%\'',
            'notStartWith':'NOT LIKE \'###%\'',
            'endsWith':'LIKE \'%###\'',
            'notEndWith':'NOT LIKE \'%###\'',
            'contains':'LIKE \'%###%\'',
            'notContain':'NOT LIKE \'%###%\'',
            'isEmpty':'\'\'',
            'isNull':'null',
            'greaterThan':'>',
            'greaterOrEqual':'>=',
            'lowerThan':'<',
            'lowerOrEqual':'<='
        };
        return operatorMapping;
    }

    displayCustomLogicPanel(){
        this.customLogic = (this.customLogic)?false:true;
    }

    handleCustomLogic(event){
        this.customLogicValue = event.detail.value;
    }

    generateFilterString(){
        if(this.filters.length > 0){
            if(this.customLogic && this.customLogicValue !== undefined){
                let finalString = this.customLogicValue;
                for(let i=0; i<this.filters.length; i++){
                    finalString = finalString.replace(i+1,this.filters[i].value);
                }
                this.filtersToString = finalString;
            }
            else{
                let finalString = this.filters.map(filter => {return filter.value}).join(' AND ');
                console.log(finalString);
                this.filtersToString = finalString;
            }
        }
        else{
            this.filtersToString = '';
        }
    }

    generateQuery(){
        this.query = 'SELECT '+this.selectedFields.join(', ')+' FROM '+this.objValue;
        if(this.filtersToString!==''){
            this.query += ' WHERE '+this.filtersToString;
        }
        console.log(this.query);
        const queryData = {
            query: this.query,
            fields: this.selectedFieldsWithLabel};
        publish(this.messageContext, queryMessage, queryData);
    }

    removeFilter(event){
        this.render = false;
        let result = event.detail.name;
        this.filters = this.filters.filter(({label}) => label !== result);
        this.generateFilterString();
        this.generateQuery();
        this.render = true;
    }
}