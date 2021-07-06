({
    handleUploadFinished : function(component, event, helper) {
     var uploadedFiles = event.getParam("files");
     var documentId = uploadedFiles[0].documentId;
     var fileName =   component.find("accordion").get('v.activeSectionName');
     helper.UpdateDocument(component,event,helper,documentId);
     var toastEvent = $A.get("e.force:showToast");
     console.log(toastEvent);
     console.log('test');
     toastEvent.setParams({
       "title": $A.getReference("$Label.c.CMT_Upl_SuccessUploadTitle"),
       "message": $A.getReference("$Label.c.CMT_Upl_SuccessUpload")
     });
     console.log($A.getReference("$Label.c.CMT_Upl_SuccessUploadTitle"));
     toastEvent.fire();
     /* Open File after upload
     $A.get('e.lightning:openFiles').fire({
       recordIds: [documentId]
     });*/
   },
 
   doInit:function(component,event,helper){
     console.log('Document uploadr ENTER ###');
     var action = component.get("c.getFiles");
     // action.setParams({
     //   "recordId":component.get("v.recordId")
     // });
     action.setCallback(this,function(response){
       var state = response.getState();
       console.log(state);
       if(state=='SUCCESS'){
         var result = response.getReturnValue();
         console.log(result);
         component.set("v.files",result.docList);
         component.set("v.recordId",result.recordId);
         component.set("v.documents",result.neededDocuments);
         console.log('---- TEST TEST ----');
         console.log(component.get("v.documents"));
         component.set("v.lockSubmit",result.lock);
         helper.calcProgress(component);
         helper.HideSubmitButton(component);
         //this.HupdateContact(component);
       }
     });
     $A.enqueueAction(action);
   } ,


   //Open File onclick event
   OpenFile :function(component,event,helper){
     var rec_id = event.currentTarget.id;
     $A.get('e.lightning:openFiles').fire({ //Lightning Openfiles event
       recordIds: [rec_id] //file id
     });
   } ,

   handleSubmit :function(component,event,helper){
     var action = component.get("c.submit");
     // action.setParams({
     //   "recordId":component.get("v.recordId")
     // });
     action.setCallback(this,function(response){
       var state = response.getState();
       if(state=='SUCCESS'){
         var result = response.getReturnValue();
         if (result){
             if(component.get("v.submitProgress")!= 100){
                  var toastEvent = $A.get("e.force:showToast");
                   toastEvent.setParams({
                   "title":  $A.getReference("$Label.c.CMT_Upl_Error"),
                   "message":  $A.getReference("$Label.c.CMT_Upl_ErrorMessage_Files"),
                   "type" : 'error'
             });
                   toastEvent.fire();
             }else{
                component.set("v.lockSubmit",true);
                helper.HsendMailToManagerRH(component, event, helper);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                "title": $A.getReference("$Label.c.CMT_Upl_SuccessUploadTitle"),
                "message": $A.getReference("$Label.c.CMT_Upl_SuccessSubmit"),
                "duration" : 18000
                });
                toastEvent.fire();
			}
         } else{
                 var toastEvent = $A.get("e.force:showToast");
                 toastEvent.setParams({
                 "title":  $A.getReference("$Label.c.CMT_Upl_Error"),
                 "message":  $A.getReference("$Label.c.CMT_Upl_ErrorMessage_Survey"),
                 "type" : 'error'
                 });
                 toastEvent.fire();
         }
       }
     });
     $A.enqueueAction(action);
   },

    removeLine: function(component, event, helper) {
        //.dataset.index
        var selectedItem = event.getSource().get("v.value");
        console.log(selectedItem);

         var action = component.get("c.removeFile");
	     action.setParams({
	     	"documentId" :selectedItem,
	       	"recordId":component.get("v.recordId")
	     });

	     action.setCallback(this,function(response){
	       var state = response.getState();
	       console.log(state);
	       if(state=='SUCCESS'){
	         var result = response.getReturnValue();
	         component.set("v.files",result);
	         helper.calcProgress(component);
	       }
	     });
	     $A.enqueueAction(action);

    },




     HupdateContact : function(component){
             var action = component.get("c.UpdateContact");
                      action.setParams({
                           "progress": component.get("v.progress")
                      });
                      action.setCallback(this,function(response){
                            var state = response.getState();
                            if(state=='SUCCESS'){
                            }
                      });
                      $A.enqueueAction(action);
        },


})