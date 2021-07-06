public with sharing class FilesUploadController {


	public class ResponseWrapper {
		@AuraEnabled
		public List<ContentDocument> docList ;
		@AuraEnabled
		public String recordId ;
		@AuraEnabled
		public List<DocumentsWrapper> neededDocuments ;
		@AuraEnabled
		public Boolean lock ;
	}

	public class DocumentsWrapper {
		@AuraEnabled
		public String uniqName {get;set;}
		@AuraEnabled
		public String label {get;set;}
		@AuraEnabled
		public Boolean mandatory {get;set;}

		public DocumentsWrapper(String uniqName, String label, Boolean mandatory){
		this.uniqName = uniqName ;
		this.label = label ;
		this.mandatory = mandatory ;
		}
	}

	@AuraEnabled
	public static Boolean submit() {
		User currentUser = [select id, Name, contactId from User where id = :userInfo.getUserId()];
		String recordId = currentUser.contactId;
		Contact cont = [select id, Name, Statut__c, DossierCandidatureSoumis__c, Nombre_de_questionnaire_Sant__c from Contact where id = :recordId];
		PAD.ApexForcedBypass.addAll(new set<String>{
				'EmptyContactAccount', 'ChangedContactAccount', 'CreateContact', 'UpdateContact'
		});
		if (cont.Nombre_de_questionnaire_Sant__c < 1 && cont.Statut__c == 'Embauchable') {
			System.debug('faux 19/04/2019');
			cont.DossierCandidatureSoumis__c = false;
			PAD.ApexForcedBypass.addAll(new set<String>{
					'EmptyContactAccount', 'ChangedContactAccount', 'CreateContact', 'UpdateContact'
			});
			update cont;
			return false;
		} else {
			cont.DossierCandidatureSoumis__c = true;
			PAD.ApexForcedBypass.addAll(new set<String>{
					'EmptyContactAccount', 'ChangedContactAccount', 'CreateContact', 'UpdateContact'
			});
			update cont;
			return true;
		}
	}

	@AuraEnabled
	public static Boolean HideSubmit(){
		User currentUser = [select id, Name, contactId from User where id = : userInfo.getUserId()];
		String recordId = currentUser.contactId;
		Contact cont = [select id, Name, Statut__c from Contact where id=:recordId];
		if(cont.Statut__c == 'Embauchable'){
					return true;
		}else{
			return false;
		}
	}




	@AuraEnabled
	public static ResponseWrapper getFiles() {

		List<ContentDocument> DocumentList = new List<ContentDocument>();
		Set<Id> documentIds = new Set<Id>();  //store file ids
		User currentUser = [select id, Name, contactId, Country__c, contact.Statut__c, contact.ChangementStatutNecessaire__c, contact.DossierCandidatureSoumis__c from User where id = : userInfo.getUserId()];
		String recordId = currentUser.contactId;
		if (recordId==null){
			currentUser = [select id, Name, contactId,Country__c,  contact.Statut__c, contact.ChangementStatutNecessaire__c, contact.DossierCandidatureSoumis__c from User where contactId<>'' limit 1];
			recordId = currentUser.contactId;
		}
		Contact candidate = [select id, Recruiting_country__c, ChangementStatutNecessaire__c, Statut__c from Contact where id=:recordId limit 1];
		List<ContentDocumentLink> cdl = [select id, LinkedEntityId, ContentDocumentId from ContentDocumentLink where LinkedEntityId = :recordId];
		for (ContentDocumentLink cdLink : cdl) {
			documentIds.add(cdLink.ContentDocumentId);  // Document ids
		}
		DocumentList = [select Id, Title, FileType, ContentSize, Description from ContentDocument where id IN: documentIds];
		ResponseWrapper res = new ResponseWrapper();
		res.docList = DocumentList;
		res.recordId = recordId;
		res.lock=true;

		String langCode = UserInfo.getLanguage();
		res.neededDocuments = new List<DocumentsWrapper>();
		Map<String,String> mapLangFieldLabel =  new Map<String, String> {
			'en_US'              =>     'EnglishLabel__c',
			'en_GB'				 =>		'EnglishLabel__c',
			'fr'                 =>    	'FrenchLabel__c',
			'nl_NL'				 =>		'NLLabel__c'};

		String sqlQuery = '	Select 	Id, Label, Country__c, EnglishLabel__c, FrenchLabel__c, NLLabel__c, Mandatory__c, Phase1__c, Phase2__c, ChangementStatut__c, Order__c';
		sqlQuery += ' FROM Portal_NeededDocs__mdt ';
		String sqlQueryFilter = ' WHERE phase1__c=true ';


		if(String.isNotEmpty(candidate.Statut__c)){
			if(candidate.Statut__c.equals('Embauchable')){
				sqlQueryFilter = ' WHERE phase2__c=true ';
				if(candidate.ChangementStatutNecessaire__c){
					sqlQueryFilter = ' WHERE ChangementStatut__c=true ';
				}
				res.lock=false;
			}

			String country = candidate.Recruiting_country__c;
			sqlQueryFilter += ' AND Country__c =: country ';
			sqlQuery += sqlQueryFilter +' ORDER BY Order__c ASC ';
			System.debug('@@@ requete '+sqlQuery);
			for(Portal_NeededDocs__mdt setting: Database.query(sqlQuery)){
				String langlabel = (String)setting.get(mapLangFieldLabel.get(langCode));
				System.debug('langCode' + langCode);
				System.debug(langlabel);
				if (String.isEmpty(langlabel)){
					langlabel = setting.EnglishLabel__c;
				}
				res.neededDocuments.add(
					new DocumentsWrapper (	setting.Label,
											langlabel,
											setting.Mandatory__c)
					);
			}			
		}

		if (currentUser.contact.DossierCandidatureSoumis__c){
			res.lock=true;
		}

		return res;
	}

	@AuraEnabled
	public static List<ContentDocument> UpdateFiles(string documentId, string title, String suppName,  String recordId) {

		Contact contact = [Select FirstName, LastName from Contact where id =:recordId];
		List<ContentDocument> DocumentList = new List<ContentDocument>();
		Set<Id> documentIds = new Set<Id>();
		List<ContentDocumentLink> cdl = [select id, LinkedEntityId, ContentDocumentId from ContentDocumentLink where LinkedEntityId = :recordId];
		for (ContentDocumentLink cdLink : cdl) {
			documentIds.add(cdLink.ContentDocumentId);
		}

		Map<Id, ContentDocument> documentMap =  new Map<Id, ContentDocument>([select Id, Title, FileType, ContentSize, Description from ContentDocument where id IN: documentIds]);
		DocumentList = documentMap.values();

		Integer i = 1;
		for (ContentDocument cd : DocumentList) {
			if (cd.Id != documentId && cd.Title.startsWith(title)) {
				i += 1;
			}
		}
		ContentDocument cd = documentMap.get(documentId); // Getting files from Parent record
		cd.Title = title; 
		if (String.isNotEmpty(suppName)){
			cd.Title += '_'+suppName;
		}
		cd.Title += '-' +contact.FirstName + '-' + contact.LastName + '-' + String.valueOf(i); // Changing file Title with user entered title
		cd.Description = title;

		try {
			update cd;  // Update ContentDocument (File)
		} catch (DMLException e) {
			system.debug('Exception has occurred! ' + e.getMessage());
		}

		return DocumentList;  // Return list of files on parent record

	}

	@AuraEnabled
	public static List<ContentDocument> removeFile(string documentId,  String recordId) {

		ContentDocument file = [Select Id from ContentDocument where id =:documentId limit 1];	
		delete file;

		System.debug('Record id '+recordId);
		Contact contact = [Select FirstName, LastName from Contact where id =:recordId];
		List<ContentDocument> DocumentList = new List<ContentDocument>();
		Set<Id> documentIds = new Set<Id>();
		List<ContentDocumentLink> cdl = [select id, LinkedEntityId, ContentDocumentId from ContentDocumentLink where LinkedEntityId = :recordId];
		for (ContentDocumentLink cdLink : cdl) {
			documentIds.add(cdLink.ContentDocumentId);
		}

		Map<Id, ContentDocument> documentMap =  new Map<Id, ContentDocument>([select Id, Title, FileType, ContentSize, Description from ContentDocument where id IN: documentIds]);
		return documentMap.values();
	}




	@AuraEnabled
	public static Contact UpdateContact(Integer progress){
		User currentUser = [select id, Name, contactId from User where id = : userInfo.getUserId()];
		String recordId = currentUser.contactId;
		Contact cont = [select id, Name, Statut__c, DocumentCompletion__c from Contact where id=:recordId];

		cont.DocumentCompletion__c = progress;
		update cont;
		return cont;
	}


	@AuraEnabled
	public static void sendMailToManagerRH(){
		User currentUser = [select id, Name, contactId from User where id = : userInfo.getUserId()];
		String recordId = currentUser.contactId;
		Contact cont = [select id, Email, MobilePhone, FirstName, LastName, Statut__c, OwnerId, Manager_RH__c, HRManagerContactInfo__c, BusinessManagerContactInfo__c from Contact where id=:recordId];
		User managerRH = [select id, LanguageLocaleKey from user where id=:cont.Manager_RH__c];
		User businessManager = [select id, LanguageLocaleKey from user where id=:cont.OwnerId];

		String texte = ''; String subject ='';
		String [] managerRH_Info = cont.HRManagerContactInfo__c.split(' -');
		String [] businessManager_Info = cont.BusinessManagerContactInfo__c.split(' -');

		switch on managerRH.LanguageLocaleKey{
			when 'fr'{
				texte = 'Bonjour '+managerRH_Info[0]+',\n \n'
						+'Nous vous informons que '+cont.FirstName + ' '  +cont.LastName + ' au statut « Retenu » vient de finaliser sa candidature Vulcain en déposant les dernières pièces justificatives manquantes sur le portail Candidat ; son dossier est maintenant réputé complet.\n'
						+'Pour mémoire, son adresse mail est ' +cont.Email+ ' et son N° de téléphone est ' +cont.MobilePhone+ ' . \n \nCordialement, \nL’équipe Vulcain.';
				subject = cont.FirstName + ' ' + cont.LastName+' - Dossier de candidature complet !';
			}
			when 'en_US'{
				texte = 'Bonjour '+managerRH_Info[0]+',\n \n'
						+'Nous vous informons que '+cont.FirstName + ' '  +cont.LastName + ' au statut « Retenu » vient de finaliser sa candidature Vulcain en déposant les dernières pièces justificatives manquantes sur le portail Candidat ; son dossier est maintenant réputé complet.\n'
						+'Pour mémoire, son adresse mail est ' +cont.Email+ ' et son N° de téléphone est ' +cont.MobilePhone+ ' . \n \nCordialement, \nL’équipe Vulcain.';
				subject = cont.FirstName + ' ' + cont.LastName+' - Dossier de candidature complet !';
			}
			when 'nl_NL'{
				texte = 'Bonjour '+managerRH_Info[0]+',\n \n'
						+'Nous vous informons que '+cont.FirstName + ' '  +cont.LastName + ' au statut « Retenu » vient de finaliser sa candidature Vulcain en déposant les dernières pièces justificatives manquantes sur le portail Candidat ; son dossier est maintenant réputé complet.\n'
						+'Pour mémoire, son adresse mail est ' +cont.Email+ ' et son N° de téléphone est ' +cont.MobilePhone+ ' . \n \nCordialement, \nL’équipe Vulcain.';
				subject = cont.FirstName + ' ' + cont.LastName+' - Dossier de candidature complet !';
			}
			when else{
				texte = 'Bonjour '+managerRH_Info[0]+',\n \n'
						+'Nous vous informons que '+cont.FirstName + ' '  +cont.LastName + ' au statut « Retenu » vient de finaliser sa candidature Vulcain en déposant les dernières pièces justificatives manquantes sur le portail Candidat ; son dossier est maintenant réputé complet.\n'
						+'Pour mémoire, son adresse mail est ' +cont.Email+ ' et son N° de téléphone est ' +cont.MobilePhone+ ' . \n \nCordialement, \n L’équipe Vulcain.';
				subject = cont.FirstName + ' ' + cont.LastName+' - Dossier de candidature complet !';
			}
		}
		List<String> emails = new List<String>();
		List<String> emails_cc = new List<String>();
		emails.add(managerRH_Info[1]);
		emails_cc.add(businessManager_Info[1]);
		Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
		message.toAddresses = emails;
		message.setCcAddresses(emails_cc);
		message.subject = subject;
		message.plainTextBody = texte;
		Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
		Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
	}

}