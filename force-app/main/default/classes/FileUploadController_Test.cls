/**
 * Created by Ferroudja Alouanne on 25/04/2019.
 */

@IsTest
private class FileUploadController_Test {

    public static Boolean generateException = false;

    @TestSetup
    static void testBehavior(){
        GoLiveDate__c dateGoLive = new GoLiveDate__c();
        dateGoLive.GoLiveDate__c =  System.today();
        insert dateGoLive;
    }

    @IsTest
    static void test_getFiles(){
        UserRole r = new UserRole(name = 'TEST ROLE');
        Database.insert(r);
        User userWithRole = new User(alias = 'hasrole', email='userwithrole@vulcain.com', userroleid = r.id,
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = UserInfo.getProfileId(),
                timezonesidkey='America/Los_Angeles', username='fileUpload@testorg.com',
                Company__c = 'Vulcain', Country__c='France', Level__c='BUM');

        insert userWithRole;

        System.runAs(userWithRole) {
            PAD.ApexForcedBypass.addAll(new set<String>{'EmptyContactAccount','ChangedContactAccount', 'CreateContact', 'UpdateContact'});
            RecordType rType = [SELECT Id,DeveloperName FROM RecordType WHERE DeveloperName = 'Candidat'];
            RecordType rTypeAccount = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName ='Compte_client'];

            //Créer trois comptes
            List<Account> accounts = new List<Account>();
            for(Integer i=0; i<4; i++){
                Account acct = new Account();
                acct.Type='Customer2';
                acct.Name='test Name';
                acct.Phone='0143410230';
                acct.RecordTypeId = rTypeAccount.Id;
                acct.ShippingStreet='Pierre Vasseur';
                acct.ShippingCity='Alexandre Manceau';
                acct.ShippingPostalCode='91120';
                acct.ShippingCountry='France';
                accounts.add(acct);
            }
            accounts[0].Name='CONSULTYS';
            accounts[1].Name='VULCAIN SERVICES';
            accounts[2].Name='VULCAIN EXPANSION';

            insert accounts;

            //Créer un contact
            Contact cont = new Contact();
            cont.LastName = 'contTest';
            cont.FirstName = 'contTest';
            cont.AccountId = accounts[1].Id;
            cont.Statut__c = 'Embauchable';
            cont.Email = 'test@vulcain.com';
            cont.Recruiting_country__c = 'FR';
            cont.ChangementStatutNecessaire__c = true;
            insert cont;
            Profile p = [SELECT Id, Name FROM Profile WHERE Name='Vulcain Customer Community Login User' limit 1];
            User userCommunity = new User(
                    LastName='FirstName_test',
                    FirstName='LastName_test',
                    Alias = 'test',
                    Email='test@vulcain.eu',
                    EmailEncodingKey='UTF-8',
                    LanguageLocaleKey='en_US',
                    LocaleSidKey='en_US',
                    ProfileId = p.Id,
                    UserName='test@vulcain.dev',
                    TimeZoneSidKey='America/Los_Angeles',
                    IsActive=true,
                    ContactId=cont.Id);
            insert userCommunity;


            System.runAs(userCommunity){
                Test.startTest();
                FilesUploadController.ResponseWrapper response = FilesUploadController.getFiles();
                System.assert(response != null);

                String country = cont.Recruiting_country__c;
                String sqlQuery = '	Select 	Id, Label, EnglishLabel__c, FrenchLabel__c, NLLabel__c, Mandatory__c, Phase1__c, Phase2__c, ChangementStatut__c, Order__c, Country__c';
                sqlQuery += ' FROM Portal_NeededDocs__mdt ';
                String sqlQueryFilter = ' WHERE ChangementStatut__c = true ';
                sqlQueryFilter += ' AND Country__c =: country ';
                sqlQuery += sqlQueryFilter +' ORDER BY Order__c ASC ';
                List<Portal_NeededDocs__mdt> settings = Database.query(sqlQuery);

                System.assertEquals(response.neededDocuments.size(),settings.size());
                for(Integer i = 0; i < response.neededDocuments.size(); i++){
                    if(userCommunity.LanguageLocaleKey == 'fr'){
                        System.assertEquals(response.neededDocuments[i].label, settings[i].FrenchLabel__c);
                    }else{
                        System.assertEquals(response.neededDocuments[i].label, settings[i].EnglishLabel__c);
                    }
                    System.assertEquals(response.neededDocuments[i].mandatory, settings[i].Mandatory__c);

                }
            }

        }



    }






    @IsTest
    static void test_UpdateFiles(){
        UserRole r = new UserRole(name = 'TEST ROLE');
        Database.insert(r);
        User userWithRole = new User(alias = 'hasrole', email='userwithrole@vulcain.com', userroleid = r.id,
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = UserInfo.getProfileId(),
                timezonesidkey='America/Los_Angeles', username='fileUpload@testorg.com',
                Company__c = 'Vulcain', Country__c='France', Level__c='BUM');

        insert userWithRole;

        System.runAs(userWithRole){

            RecordType rType = [SELECT Id,DeveloperName FROM RecordType WHERE DeveloperName = 'Candidat'];
            RecordType rTypeAccount = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName ='Compte_client'];

            //Créer trois comptes
            List<Account> accounts = new List<Account>();
            for(Integer i=0; i<4; i++){
                Account acct = new Account();
                acct.Type='Customer2';
                acct.Name='test Name';
                acct.Phone='0143410230';
                acct.RecordTypeId = rTypeAccount.Id;
                acct.ShippingStreet='Pierre Vasseur';
                acct.ShippingCity='Alexandre Manceau';
                acct.ShippingPostalCode='91120';
                acct.ShippingCountry='France';
                accounts.add(acct);
            }
            accounts[0].Name='CONSULTYS';
            accounts[1].Name='VULCAIN SERVICES';
            accounts[2].Name='VULCAIN EXPANSION';

            insert accounts;

            //Créer un contact
            Contact cont = new Contact();
            cont.LastName = 'nom';
            cont.FirstName = 'prenom';
            cont.AccountId = accounts[1].Id;
            cont.Email = 'test@vulcain.com';
            insert cont;
            Profile p = [SELECT Id, Name FROM Profile WHERE Name='Vulcain Customer Community Login User' limit 1];
            User userCommunity = new User(
                    LastName='FirstName_test',
                    FirstName='LastName_test',
                    Alias = 'test',
                    Email='test@vulcain.eu',
                    EmailEncodingKey='UTF-8',
                    LanguageLocaleKey='en_US',
                    LocaleSidKey='en_US',
                    ProfileId = p.Id,
                    UserName='test@vulcain.dev',
                    TimeZoneSidKey='America/Los_Angeles',
                    IsActive=true,
                    ContactId=cont.Id);
            insert userCommunity;

            ContentVersion contentVersionInsert = new ContentVersion(
                    Title = 'Test BEFORE',
                    PathOnClient = 'Test.jpg',
                    VersionData = Blob.valueOf('Test Content Data'),
                    IsMajorVersion = true
            );
            insert contentVersionInsert;


            // Test INSERT
            ContentVersion contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionInsert.Id LIMIT 1];
            List<ContentDocument> documents = [SELECT Id, Title, FileType, ContentSize, Description, LatestPublishedVersionId FROM ContentDocument];


            ContentDocumentLink contentlink=new ContentDocumentLink();
            contentlink.LinkedEntityId=cont.Id;
            contentlink.ShareType= 'I';
            contentlink.ContentDocumentId=documents[0].Id;
            contentlink.Visibility = 'AllUsers';
            insert contentlink;


            System.runAs(userCommunity){
                FilesUploadController.ResponseWrapper response = FilesUploadController.getFiles();
                String recordId = response.recordId;
                String supName = 'after';
                Test.startTest();
                List<ContentDocument> documents2 = FilesUploadController.UpdateFiles(documents[0].Id, documents[0].Title, supName, recordId);
                Test.stopTest();
                System.debug('### !!! '+documents2);
                System.assert(documents2 != null);
                System.assertEquals(documents2[0].Title, 'Test BEFORE_after-Prenom-NOM-1');

            }



        }
    }







    @IsTest
    static void test_removeFile() {
        UserRole r = new UserRole(name = 'TEST ROLE');
        Database.insert(r);
        User userWithRole = new User(alias = 'hasrole', email = 'userwithrole@vulcain.com', userroleid = r.id,
                emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
                localesidkey = 'en_US', profileid = UserInfo.getProfileId(),
                timezonesidkey = 'America/Los_Angeles', username = 'fileUpload@testorg.com',
                Company__c = 'Vulcain', Country__c = 'France', Level__c = 'BUM');

        insert userWithRole;

        System.runAs(userWithRole) {
            RecordType rType = [SELECT Id,DeveloperName FROM RecordType WHERE DeveloperName = 'Candidat'];
            RecordType rTypeAccount = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'Compte_client'];

            //Créer trois comptes
            List<Account> accounts = new List<Account>();
            for (Integer i = 0; i < 4; i++) {
                Account acct = new Account();
                acct.Type = 'Customer2';
                acct.Name = 'test Name';
                acct.Phone = '0143410230';
                acct.RecordTypeId = rTypeAccount.Id;
                acct.ShippingStreet = 'Pierre Vasseur';
                acct.ShippingCity = 'Alexandre Manceau';
                acct.ShippingPostalCode = '91120';
                acct.ShippingCountry = 'France';
                accounts.add(acct);
            }
            accounts[0].Name = 'CONSULTYS';
            accounts[1].Name = 'VULCAIN SERVICES';
            accounts[2].Name = 'VULCAIN EXPANSION';

            insert accounts;

            //Créer un contact
            Contact cont = new Contact();
            cont.LastName = 'contTest';
            cont.FirstName = 'contTest';
            cont.AccountId = accounts[1].Id;
            cont.Email = 'test@vulcain.com';
            insert cont;

            ContentVersion contentVersionInsert = new ContentVersion(
                    Title = 'Test BEFORE',
                    PathOnClient = 'Test.jpg',
                    VersionData = Blob.valueOf('Test Content Data'),
                    IsMajorVersion = true
            );
            insert contentVersionInsert;


            // Test INSERT
            ContentVersion contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionInsert.Id LIMIT 1];
            List<ContentDocument> documents = [SELECT Id, Title, FileType, ContentSize, Description, LatestPublishedVersionId FROM ContentDocument];


            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = cont.Id;
            contentlink.ShareType = 'I';
            contentlink.ContentDocumentId = documents[0].Id;
            contentlink.Visibility = 'AllUsers';
            insert contentlink;

            Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'Vulcain Customer Community Login User' limit 1];
            User userCommunity = new User(
                    LastName = 'FirstName_test',
                    FirstName = 'LastName_test',
                    Alias = 'test',
                    Email = 'test@vulcain.com',
                    EmailEncodingKey = 'UTF-8',
                    LanguageLocaleKey = 'en_US',
                    LocaleSidKey = 'en_US',
                    ProfileId = p.Id,
                    UserName = 'test@vulcain.dev',
                    TimeZoneSidKey = 'America/Los_Angeles',
                    IsActive = true,
                    ContactId = cont.Id);
            insert userCommunity;



            Test.startTest();
            List<ContentDocument> documents2 = FilesUploadController.removeFile(documents[0].Id,userCommunity.ContactId);
            Test.stopTest();
            System.assert(documents2 != null);
            System.assertEquals(documents2.size(), 0);
        }
    }






    @IsTest
    static void test_UpdateContact(){
        UserRole r = new UserRole(name = 'TEST ROLE');
        Database.insert(r);
        User userWithRole = new User(alias = 'hasrole', email = 'userwithrole@vulcain.com', userroleid = r.id,
                emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
                localesidkey = 'en_US', profileid = UserInfo.getProfileId(),
                timezonesidkey = 'America/Los_Angeles', username = 'fileUpload@testorg.com',
                Company__c = 'Vulcain', Country__c = 'France', Level__c = 'BUM');

        insert userWithRole;

        System.runAs(userWithRole) {
            RecordType rType = [SELECT Id,DeveloperName FROM RecordType WHERE DeveloperName = 'Candidat'];
            RecordType rTypeAccount = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'Compte_client'];

            //Créer trois comptes
            List<Account> accounts = new List<Account>();
            for (Integer i = 0; i < 4; i++) {
                Account acct = new Account();
                acct.Type = 'Customer2';
                acct.Name = 'test Name';
                acct.Phone = '0143410230';
                acct.RecordTypeId = rTypeAccount.Id;
                acct.ShippingStreet = 'Pierre Vasseur';
                acct.ShippingCity = 'Alexandre Manceau';
                acct.ShippingPostalCode = '91120';
                acct.ShippingCountry = 'France';
                accounts.add(acct);
            }
            accounts[0].Name = 'CONSULTYS';
            accounts[1].Name = 'VULCAIN SERVICES';
            accounts[2].Name = 'VULCAIN EXPANSION';

            insert accounts;

            //Créer un contact
            Contact cont = new Contact();
            cont.LastName = 'contTest';
            cont.FirstName = 'contTest';
            cont.AccountId = accounts[1].Id;
            cont.Email = 'test@vulcain.com';
            insert cont;
            Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'Vulcain Customer Community Login User' limit 1];
            User userCommunity = new User(
                    LastName = 'FirstName_test',
                    FirstName = 'LastName_test',
                    Alias = 'test',
                    Email = 'test@vulcain.com',
                    EmailEncodingKey = 'UTF-8',
                    LanguageLocaleKey = 'en_US',
                    LocaleSidKey = 'en_US',
                    ProfileId = p.Id,
                    UserName = 'test@vulcain.dev',
                    TimeZoneSidKey = 'America/Los_Angeles',
                    IsActive = true,
                    ContactId = cont.Id);
            insert userCommunity;

            System.runAs(userCommunity){
                Test.startTest();
                Contact cont2 = FilesUploadController.UpdateContact(70);
                Test.stopTest();

                System.assert(cont2 != null);
                System.assertEquals(cont2.DocumentCompletion__c, 70);

            }

        }


    }





    @IsTest
    static void test_submit(){
        UserRole r = new UserRole(name = 'TEST ROLE');
        Database.insert(r);
        User userWithRole = new User(alias = 'hasrole', email = 'userwithrole@vulcain.com', userroleid = r.id,
                emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
                localesidkey = 'en_US', profileid = UserInfo.getProfileId(),
                timezonesidkey = 'America/Los_Angeles', username = 'fileUpload@testorg.com',
                Company__c = 'Vulcain', Country__c = 'France', Level__c = 'BUM');

        insert userWithRole;

        System.runAs(userWithRole) {
            RecordType rType = [SELECT Id,DeveloperName FROM RecordType WHERE DeveloperName = 'Candidat'];
            RecordType rTypeAccount = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'Compte_client'];

            //Créer trois comptes
            List<Account> accounts = new List<Account>();
            for (Integer i = 0; i < 4; i++) {
                Account acct = new Account();
                acct.Type = 'Customer2';
                acct.Name = 'test Name';
                acct.Phone = '0143410230';
                acct.RecordTypeId = rTypeAccount.Id;
                acct.ShippingStreet = 'Pierre Vasseur';
                acct.ShippingCity = 'Alexandre Manceau';
                acct.ShippingPostalCode = '91120';
                acct.ShippingCountry = 'France';
                accounts.add(acct);
            }
            accounts[0].Name = 'CONSULTYS';
            accounts[1].Name = 'VULCAIN SERVICES';
            accounts[2].Name = 'VULCAIN EXPANSION';

            insert accounts;

            //Créer un contact
            Contact cont = new Contact();
            cont.LastName = 'contTest';
            cont.FirstName = 'contTest';
            cont.AccountId = accounts[1].Id;
            cont.Email = 'test@vulcain.com';
            cont.Statut__c = 'Embauchable';
            insert cont;

            Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'Vulcain Customer Community User' limit 1];
            User userCommunity = new User(
                    LastName = 'FirstName_test',
                    FirstName = 'LastName_test',
                    Alias = 'test',
                    Email = 'test@vulcain.com',
                    EmailEncodingKey = 'UTF-8',
                    LanguageLocaleKey = 'en_US',
                    LocaleSidKey = 'en_US',
                    ProfileId = p.Id,
                    UserName = 'test@vulcain.dev',
                    TimeZoneSidKey = 'America/Los_Angeles',
                    IsActive = true,
                    ContactId = cont.Id);
            insert userCommunity;

            System.runAs(userCommunity){
                Test.startTest();
                Boolean isSubmitted = FilesUploadController.submit();
                cont.Statut__c = 'Valide';
                update cont;
                Boolean isSubmitted2 = FilesUploadController.submit();
                Test.stopTest();

                System.assert(isSubmitted != null);
                System.assertEquals(isSubmitted, false);
                System.assert(isSubmitted2 != null);
                System.assertEquals(isSubmitted2, true);

            }

        }

    }


    @IsTest
    static void test_HideSubmit(){
        UserRole r = new UserRole(name = 'TEST ROLE');
        Database.insert(r);
        Profile admin = [select Id,name from Profile WHERE Name LIKE'%Admin%' limit 1];
        User userWithRole = new User(alias = 'hasrole', email = 'userwithrole@vulcain.com', userroleid = r.id,
                emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
                localesidkey = 'en_US', profileId = admin.id,
                timezonesidkey = 'America/Los_Angeles', username = 'fileUpload@testorg.com',
                Company__c = 'Vulcain', Country__c = 'France', Level__c = 'BUM');

        insert userWithRole;

        System.runAs(userWithRole) {
            RecordType rType = [SELECT Id,DeveloperName FROM RecordType WHERE DeveloperName = 'Candidat'];
            RecordType rTypeAccount = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'Compte_client'];

            //Créer trois comptes
            List<Account> accounts = new List<Account>();
            for (Integer i = 0; i < 4; i++) {
                Account acct = new Account();
                acct.Type = 'Customer2';
                acct.Name = 'test Name';
                acct.Phone = '0143410230';
                acct.RecordTypeId = rTypeAccount.Id;
                acct.ShippingStreet = 'Pierre Vasseur';
                acct.ShippingCity = 'Alexandre Manceau';
                acct.ShippingPostalCode = '91120';
                acct.ShippingCountry = 'France';
                accounts.add(acct);
            }
            accounts[0].Name = 'CONSULTYS';
            accounts[1].Name = 'VULCAIN SERVICES';
            accounts[2].Name = 'VULCAIN EXPANSION';

            insert accounts;

            //Créer un contact
            Contact cont = new Contact();
            cont.LastName = 'contTest';
            cont.FirstName = 'contTest';
            cont.AccountId = accounts[1].Id;
            cont.Email = 'test@vulcain.com';
            cont.Statut__c = 'Embauchable';
            cont.Manager_RH__c  = userWithRole.Id;
            insert cont;

            Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'Vulcain Customer Community User' limit 1];
            User userCommunity = new User(
                    LastName = 'FirstName_test',
                    FirstName = 'LastName_test',
                    Alias = 'test',
                    Email = 'test@vulcain.com',
                    EmailEncodingKey = 'UTF-8',
                    LanguageLocaleKey = 'en_US',
                    LocaleSidKey = 'en_US',
                    ProfileId = p.Id,
                    UserName = 'test@vulcain.dev',
                    TimeZoneSidKey = 'America/Los_Angeles',
                    IsActive = true,
                    ContactId = cont.Id);
            insert userCommunity;

            System.runAs(userCommunity){
                Test.startTest();
                Boolean isHidden = FilesUploadController.HideSubmit();
                cont.Statut__c = 'Valide';
                update cont;
                Boolean isHidden2 = FilesUploadController.HideSubmit();
                Test.stopTest();

                System.assert(isHidden != null);
                System.assertEquals(isHidden, true);
                System.assert(isHidden2 != null);
                System.assertEquals(isHidden2, false);
            }

        }
    }


    @IsTest
    static void sendMailToManagerRH(){
        UserRole r = new UserRole(name = 'TEST ROLE');
        Database.insert(r);
        User userWithRole = new User(alias = 'hasrole', email = 'userwithrole@vulcain.com', userroleid = r.id,
                emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
                localesidkey = 'en_US', profileid = UserInfo.getProfileId(),
                timezonesidkey = 'America/Los_Angeles', username = 'fileUpload@testorg.com',
                Company__c = 'Vulcain', Country__c = 'France', Level__c = 'BUM');

        insert userWithRole;

        System.runAs(userWithRole) {
            RecordType rType = [SELECT Id,DeveloperName FROM RecordType WHERE DeveloperName = 'Candidat'];
            RecordType rTypeAccount = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'Compte_client'];

            //Créer trois comptes
            List<Account> accounts = new List<Account>();
            for (Integer i = 0; i < 4; i++) {
                Account acct = new Account();
                acct.Type = 'Customer2';
                acct.Name = 'test Name';
                acct.Phone = '0143410230';
                acct.RecordTypeId = rTypeAccount.Id;
                acct.ShippingStreet = 'Pierre Vasseur';
                acct.ShippingCity = 'Alexandre Manceau';
                acct.ShippingPostalCode = '91120';
                acct.ShippingCountry = 'France';
                accounts.add(acct);
            }
            accounts[0].Name = 'CONSULTYS';
            accounts[1].Name = 'VULCAIN SERVICES';
            accounts[2].Name = 'VULCAIN EXPANSION';

            insert accounts;

            //Créer un contact
            Contact cont = new Contact();
            cont.LastName = 'contTest';
            cont.FirstName = 'contTest';
            cont.AccountId = accounts[1].Id;
            cont.Email = 'test@vulcain.com';
            cont.Statut__c = 'Embauchable';
            cont.Manager_RH__c  = userWithRole.Id;
            insert cont;

            Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'Vulcain Customer Community User' limit 1];
            User userCommunity = new User(
                    LastName = 'FirstName_test',
                    FirstName = 'LastName_test',
                    Alias = 'test',
                    Email = 'test@vulcain.com',
                    EmailEncodingKey = 'UTF-8',
                    LanguageLocaleKey = 'en_US',
                    LocaleSidKey = 'en_US',
                    ProfileId = p.Id,
                    UserName = 'test@vulcain.dev',
                    TimeZoneSidKey = 'America/Los_Angeles',
                    IsActive = true,
                    ContactId = cont.Id);
            insert userCommunity;

            System.runAs(userCommunity){
                Test.startTest();
                FilesUploadController.sendMailToManagerRH();
                Test.stopTest();

            }
            userWithRole.languagelocalekey = 'fr';
            update userWithRole;
            System.runAs(userCommunity){
                FilesUploadController.sendMailToManagerRH();
            }

            userWithRole.languagelocalekey = 'nl_NL';
            update userWithRole;
            System.runAs(userCommunity){
                FilesUploadController.sendMailToManagerRH();
            }

            userWithRole.languagelocalekey = 'es';
            update userWithRole;
            System.runAs(userCommunity){
                FilesUploadController.sendMailToManagerRH();
            }


        }
    }


}