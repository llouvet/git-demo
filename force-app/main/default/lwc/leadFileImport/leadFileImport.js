import { LightningElement } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class LeadFileImport extends LightningElement {
    objApiName = 'Account';
    columnsMap = {
        'COL1':'Name',
        'COL2':'Type',
        'COL3':'Phone'
    };

    closeQuickAction(event){
        var detail = event.detail;
        var obj = JSON.parse(detail);
        console.log(obj);
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}