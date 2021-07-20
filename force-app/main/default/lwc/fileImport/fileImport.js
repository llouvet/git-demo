import { LightningElement } from 'lwc';
import readRecords from '@salesforce/apex/FileImportController.readRecords';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class FileImport extends LightningElement {

    get acceptedFormats() {
        return ['.csv'];
    }

    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        var fileIDs = [];
        uploadedFiles.forEach(file => {
            fileIDs.push(file.documentId);
        })
        readRecords({fileIDs: fileIDs, objectApiName: 'Account'})
        .then(result => {
            console.log(result);
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
            this.dispatchEvent(new CloseActionScreenEvent());
        })
        console.log(fileIDs);
    }
}