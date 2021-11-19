public with sharing class SampleResultController {

    @AuraEnabled
    public static List<SObject> getRecords(String query){
        try {
            List<SObject> result = Database.query(query+' LIMIT 10');
            return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
