public with sharing class FileImportController {

    @AuraEnabled(cacheable=true)
    public static Map<String,String> readRecords(List<Object> fileIDs, String objectApiName, Object columnsMap){
        try {
            List<String> ids = new List<String>();
            for(Object fileID: fileIDs){
                ids.add((String)fileID);
            }
            Map<String,String> columns = new Map<String,String>();

            Map<Object,Object> colMap = (Map<Object,Object>)columnsMap;
            for(Object column: colMap.keySet()){
                String key = (String)column;
                String value = (String)colMap.get(column);
                columns.put(key,value);
            }

            Map<String,String> result = new Map<String,String>();

            List<ContentVersion> files = [SELECT VersionData FROM ContentVersion WHERE ContentDocumentID IN :ids];
            List<SObject> recordsUploaded = new List<SObject>();
            for(Contentversion fileData: files){
                String content = fileData.VersionData.toString();
                List<String> lines = content.split('\n');
                List<String> cols = lines[0].trim().split(',');
                if(cols.size()>columns.size()){
                    result.put('success','false');
                    result.put('message','The number of columns doesn\'t match.');
                    //todo
                    return result;
                }
                lines.remove(0);
                for(String line: lines){
                    line = line.trim();
                    List<String> values = line.split(',');
                    SObject obj = Schema.getGlobalDescribe().get(objectApiName).newSObject();
                    for(Integer i=0; i<values.size();i++){
                        if(columns.get(cols[i])!=null){
                            obj.put(columns.get(cols[i]), values[i]);
                        }
                        else{
                            result.put('success','false');
                            result.put('message','The column "'+cols[i]+'" doesn\'t exist.');
                            return result;
                        }
                    }
                    recordsUploaded.add(obj);
                }    
            }
            result.put('success','true');
            result.put('message',recordsUploaded.size()+' records were uploaded.');
            result.put('records',JSON.serialize(recordsUploaded));
            return result;
        } catch (Exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
}
