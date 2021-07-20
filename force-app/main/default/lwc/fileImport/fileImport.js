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
            this.dispatchEvent(new CloseActionScreenEvent());
            const event = new ShowToastEvent();
            if(result.success = 'true'){
                event.title = 'Success';
                event.message = result.message;
                event.variant = 'success';
            }
            else{
                event.title = 'There was a problem...';
                event.message = result.message;
                event.variant = 'warning';
            }
            this.dispatchEvent;
            //alert("No. of records uploaded : " + result);
        })
        console.log(uploadedFiles);
    }
}