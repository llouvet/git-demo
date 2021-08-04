@isTest
public with sharing class FileImportController_TEST {

    @TestSetup
    static void makeData(){
        String data = 'COL1,COL2,COL3\nval1,val2,val3';
        ContentVersion version = new ContentVersion(Title='Test Version',PathOnClient='test.csv',VersionData=Blob.valueOf(data));
        insert version;

        String dataWithDoubleQuotes = '"COL1","COL2","COL3"\n"val1","val2","val3"';
        ContentVersion versionDoubleQuotes = new ContentVersion(Title='Test Version2',PathOnClient='test2.csv',VersionData=Blob.valueOf(dataWithDoubleQuotes));
        insert versionDoubleQuotes;

        String dataWithSemiColon = 'COL1;COL2;COL3\nval1;val2;val3';
        ContentVersion versionSemiColon = new ContentVersion(Title='Test Version3',PathOnClient='test3.csv',VersionData=Blob.valueOf(dataWithSemiColon));
        insert versionSemiColon;

        String dataWithSemiColonAndDoubleQuotes = '"COL1";"COL2";"COL3"\n"val1";"val2";"val3"';
        ContentVersion versionSemiColonAndDoubleQuotes = new ContentVersion(Title='Test Version4',PathOnClient='test4.csv',VersionData=Blob.valueOf(dataWithSemiColonAndDoubleQuotes));
        insert versionSemiColonAndDoubleQuotes;
    }

    @isTest
    public static void readRecordsWithRightColumns(){
        ContentVersion version = [SELECT ContentDocumentId from ContentVersion WHERE Title = 'Test Version'];
        ContentDocument doc = [SELECT ID FROM ContentDocument WHERE ID = :version.ContentDocumentId];
        List<Object> fileIDS = new List<Object>();
        fileIDS.add(doc.ID);
        String objApiName = 'Account';
        Object columnMap = new Map<Object,Object>{'COL1'=>'Name','COL2'=>'Type','COL3'=>'Phone'};
        Map<String,String> result = FileImportController.readRecords(fileIDS, objApiName, columnMap);
        System.assert(result.get('success')=='true');
    }

    @isTest
    public static void readRecordsWithRightColumnsDoubleQuotes(){
        ContentVersion version = [SELECT ContentDocumentId from ContentVersion WHERE Title = 'Test Version2'];
        ContentDocument doc = [SELECT ID FROM ContentDocument WHERE ID = :version.ContentDocumentId];
        List<Object> fileIDS = new List<Object>();
        fileIDS.add(doc.ID);
        String objApiName = 'Account';
        Object columnMap = new Map<Object,Object>{'COL1'=>'Name','COL2'=>'Type','COL3'=>'Phone'};
        Map<String,String> result = FileImportController.readRecords(fileIDS, objApiName, columnMap);
        System.assert(result.get('success')=='true');
    }

    @isTest
    public static void readRecordsWithRightColumnsSemiColon(){
        ContentVersion version = [SELECT ContentDocumentId from ContentVersion WHERE Title = 'Test Version3'];
        ContentDocument doc = [SELECT ID FROM ContentDocument WHERE ID = :version.ContentDocumentId];
        List<Object> fileIDS = new List<Object>();
        fileIDS.add(doc.ID);
        String objApiName = 'Account';
        Object columnMap = new Map<Object,Object>{'COL1'=>'Name','COL2'=>'Type','COL3'=>'Phone'};
        Map<String,String> result = FileImportController.readRecords(fileIDS, objApiName, columnMap);
        System.assert(result.get('success')=='true');
    }

    @isTest
    public static void readRecordsWithRightColumnsSemiColonAndDoubleQuotes(){
        ContentVersion version = [SELECT ContentDocumentId from ContentVersion WHERE Title = 'Test Version4'];
        ContentDocument doc = [SELECT ID FROM ContentDocument WHERE ID = :version.ContentDocumentId];
        List<Object> fileIDS = new List<Object>();
        fileIDS.add(doc.ID);
        String objApiName = 'Account';
        Object columnMap = new Map<Object,Object>{'COL1'=>'Name','COL2'=>'Type','COL3'=>'Phone'};
        Map<String,String> result = FileImportController.readRecords(fileIDS, objApiName, columnMap);
        System.assert(result.get('success')=='true');
    }

    @isTest
    public static void readRecordsWithWrongColumns(){
        ContentVersion version = [SELECT ContentDocumentId FROM ContentVersion WHERE Title = 'Test Version'];
        ContentDocument doc = [SELECT ID FROM ContentDocument WHERE ID = :version.ContentDocumentId];
        List<Object> fileIDS = new List<Object>();
        fileIDS.add(doc.ID);
        String objApiName = 'Account';
        Object columnMap = new Map<Object,Object>{'COL1'=>'Name','COL2'=>'Type','COL7'=>'Phone'};
        Map<String,String> result = FileImportController.readRecords(fileIDS, objApiName, columnMap);
        System.assert(result.get('success')=='false');
    }

    @isTest
    public static void deleteRecords(){
        ContentVersion version = [SELECT ContentDocumentId FROM ContentVersion WHERE Title = 'Test Version'];
        ContentDocument doc = [SELECT ID FROM ContentDocument WHERE ID = :version.ContentDocumentId];
        List<Object> fileIDS = new List<Object>();
        fileIDS.add(doc.ID);
        FileImportController.deleteRecords(fileIDS);
        List<ContentVersion> result = [SELECT ID FROM ContentVersion WHERE Title = 'Test Version'];
        System.assert(result.size()==0);
    }
}
