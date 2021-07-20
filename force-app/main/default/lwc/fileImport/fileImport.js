import { LightningElement } from 'lwc';
import readRecords from '@salesforce/apex/FileImportController.readRecords';

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
            alert("No. of records uploaded : " + result);
        })
        console.log(uploadedFiles);
    }
}