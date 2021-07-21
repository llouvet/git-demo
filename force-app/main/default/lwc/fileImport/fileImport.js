import { LightningElement, api } from 'lwc';
import readRecords from '@salesforce/apex/FileImportController.readRecords';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class FileImport extends LightningElement {

    @api objApiName;
    @api columnsMap;

    get acceptedFormats() {
        return ['.csv'];
    }

    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        console.log(this.objApiName)
        var fileIDs = [];
        uploadedFiles.forEach(file => {
            fileIDs.push(file.documentId);
        })
        var obj = (this.objApiName)?this.objApiName:'Account';
        readRecords({fileIDs: fileIDs, objectApiName: this.objApiName, columnsMap: this.columnsMap})
        .then(result => {
            if(result.success == 'true'){
                this.dispatchEvent(new ShowToastEvent({
                    'title': 'Success',
                    'message': result.message,
                    'variant': 'success'
                }));
            }
            else{
                this.dispatchEvent(new ShowToastEvent({
                    'title': 'There was a problem...',
                    'message': result.message,
                    'variant': 'warning'
                }));
            }
            this.dispatchEvent(new CustomEvent('close', {
                detail: result.records
            }));
            this.dispatchEvent(new CloseActionScreenEvent());
        })
        console.log(fileIDs);
    }
}