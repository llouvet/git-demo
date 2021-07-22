import { LightningElement, api } from 'lwc';
import readRecords from '@salesforce/apex/FileImportController.readRecords';
import deleteRecords from '@salesforce/apex/FileImportController.deleteRecords';
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
        readRecords({fileIDs: fileIDs, objectApiName: this.objApiName, columnsMap: this.columnsMap})
        .then(result => {
            if(result.success == 'true'){
                this.dispatchEvent(new ShowToastEvent({
                    'title': result.title,
                    'message': result.message,
                    'variant': 'success'
                }));
            }
            else{
                this.dispatchEvent(new ShowToastEvent({
                    'title': result.title,
                    'message': result.message,
                    'variant': 'warning'
                }));
                deleteRecords({recordIds: fileIDs});
            }
            this.dispatchEvent(new CustomEvent('finished', {
                detail: result.records
            }));
        })
    }
}