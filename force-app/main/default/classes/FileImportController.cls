/**
 * @author Lucille Louvet
 * @description Controller for the LWC fileImport
 */
public with sharing class FileImportController {

    /**
     * @description returns a map with a success indicator and a message to be displayed in a toast. If the operation results in a success, returns the records created.
     * @param fileIDs
     * @param objectApiName
     * @param columnsMap 
     * @return  `Map<String,String>`
     * @exception 
     */
    @AuraEnabled(cacheable=true)
    public static Map<String,String> readRecords(List<Object> fileIDs, String objectApiName, Object columnsMap){
        try {
            List<ID> ids = new List<ID>();
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
            if(ContentVersion.sObjectType.getDescribe().isAccessible()){
                List<ContentVersion> files = [SELECT VersionData FROM ContentVersion WHERE ContentDocumentID IN :ids];
                List<SObject> recordsUploaded = new List<SObject>();
                for(Contentversion fileData: files){
                    String content = fileData.VersionData.toString();
                    List<String> lines = content.split('\n');
                    String separator = (lines[0].contains(';'))?';':',';
                    separator = (lines[0].contains('"'))?'"'+separator+'"':separator;

                    lines[0] = cleanUpLine(lines[0]);
                    List<String> cols = lines[0].split(separator);
                    lines.remove(0);

                    for(String line: lines){
                        line = cleanUpLine(line);
                        List<String> values = line.split(separator);
                        SObject obj = Schema.getGlobalDescribe().get(objectApiName).newSObject(); 
                        Integer columnsMatched = 0;
                        for(Integer i=0; i<values.size();i++){
                            if(columns.get(cols[i])!=null){
                                obj.put(columns.get(cols[i]), values[i]);
                                columnsMatched++;
                            }
                        }
                        if(columnsMatched<columns.size()){
                            result.put('success','false');
                            result.put('title','Il y a un problème...');
                            result.put('message','Les colonnes nécessaires à la création des enregistrements n\'ont pas été trouvées.');
                            break;
                        }
                        recordsUploaded.add(obj);
                    }    
                }
                if(result.get('success')!='false'){
                    result.put('success','true');
                    result.put('title','Succès');
                    result.put('message',recordsUploaded.size()+' enregistrements ont été trouvés.');
                    result.put('records',JSON.serialize(recordsUploaded));
                }
                return result;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description trims and removes double quotes if need be.
     * @param line
     * @return  `String`
     */
    public static String cleanUpLine(String line){
        String cleaned = line;
        cleaned = cleaned.trim();
        cleaned = (cleaned.left(1)=='"')?cleaned.right(cleaned.length()-1):cleaned;
        cleaned = (cleaned.right(1)=='"')?cleaned.left(cleaned.length()-1):cleaned;
        return cleaned;
    }

    /**
     * @description deletes selected records.
     * @param recordIds 
     * @exception 
     */
    @AuraEnabled
    public static void deleteRecords(List<Object> recordIds){
        try {
            if(ContentDocument.SObjectType.getDescribe().isAccessible()&&ContentDocument.SObjectType.getDescribe().isDeletable()){
                List<ID> ids = new List<ID>();
                for(Object fileID: recordIds){
                    ids.add((String)fileID);
                }
                List<ContentDocument> docs = [SELECT ID FROM ContentDocument WHERE ID IN :ids];
                delete docs;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
