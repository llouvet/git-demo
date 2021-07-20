public with sharing class FileImportController {

    @AuraEnabled(cacheable=true)
    public static Integer readRecords(List<Object> fileIDs, String objectApiName){
        try {
            //params too?
            List<String> ids = (List<String>)fileIDs;
            Map<String, String> columns = new Map<String, String>{'COL1'=>'Name','COL2'=>'Type','COL3'=>'Phone'};
            Integer recordNumber = 0;

            List<ContentVersion> files = [SELECT VersionData FROM ContentVersion WHERE ContentDocumentID IN :ids];
            List<SObject> recordsUploaded = new List<SObject>();
            for(Contentversion fileData: files){
                String content = fileData.VersionData.toString();
                List<String> lines = content.split('\n');
                List<String> cols = lines[0].trim().split(',');
                lines.remove(0);
                for(String line: lines){
                    line = line.trim();
                    List<String> values = line.split(',');
                    SObject obj = Schema.getGlobalDescribe().get(objectApiName).newSObject();
                    for(Integer i=0; i<values.size();i++){
                        obj.put(columns.get(cols[i]), values[i]);
                    }
                    recordsUploaded.add(obj);
                    System.debug(obj);
                }    
            }
            
            recordNumber = recordsUploaded.size();
            return recordNumber;
        } catch (Exception e) {
            System.debug(e.getMessage());
            //throw new AuraHandledException(e.getMessage());
            return -1;
        }
    }
}
