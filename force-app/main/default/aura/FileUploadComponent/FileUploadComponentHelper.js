({  
    UpdateDocument : function(component,event,helper,Id) {
         var action = component.get("c.UpdateFiles");
          var fNameSup='';
         if(component.find("fileName2")[0] != undefined){
           fNameSup = (component.find("fileName2")[0]).get('v.value');
         }
         var fName =  component.find("accordion").get('v.activeSectionName');
         console.log(fNameSup);
         console.log(fName);
         console.log(component.get("v.recordId"));
         //alert('File Name'+fName);
         action.setParams({"documentId":Id,
                  "title": fName,
                  "suppName": fNameSup,
                  "recordId": component.get("v.recordId")
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
        calcProgress: function (component) {
            var files = component.get("v.files");
            var neededDocuments = new Set() ;
            var requiredDocuments = new Set();
            var mandatory = false;
            console.log('---- ici mes documents -----');
            console.log(component.get('v.documents'));
            component.get("v.documents").forEach(function(element){
                //---------- Progress pour le bouton  'soumettre' -----------
            	if(element.mandatory){
            	    requiredDocuments.add(element.uniqName);
            		mandatory = true;
            	}

            	neededDocuments.add(element.uniqName);
            });

            //---------- Progress à afficher en fonction de tous les documents  -----------
            //if(mandatory){
                var countedDocs = new Set();
                files.forEach(function(element){
                    if (neededDocuments.has(element.Description)){
                        countedDocs.add(element.Description);
                    }
                });

                var x = countedDocs.size;
                var y = neededDocuments.size;
                var progress = 0;
                if(y>0){
                        progress = Math.min(Math.trunc(100*x/y),100);
                }
                component.set('v.progress', progress);
          //  }else{
          //      component.set('v.progress', 100);
          //  }

            //---------- Progress pour le bouton  'soumettre' : que les documents obligatoires -----------
            if(mandatory){
                var countedDocs2 = new Set();
                 files.forEach(function(element){
                     if (requiredDocuments.has(element.Description)){
                             countedDocs2.add(element.Description);
                     }
                });
                var x2 = countedDocs2.size;
                var y2 = requiredDocuments.size;
                var progress2 = 0;
                if(y2 >0){
                    var progress2 = Math.min(Math.trunc(100*x2/y2),100);
                }
                component.set('v.submitProgress', progress2);
            }


            console.log('### PERCENT ###');
        },



        HideSubmitButton: function(component){
            var action = component.get("c.HideSubmit");
            action.setCallback(this,function(response){
                       var state = response.getState();
                       if(state=='SUCCESS'){
                         var result = response.getReturnValue();
                         component.set("v.hideSubmitButton", result);
                       }
                     });
            $A.enqueueAction(action);


        },



        HsendMailToManagerRH : function(component, event, helper){
             var action = component.get("c.sendMailToManagerRH");
             action.setCallback(this,function(response){
                    var state = response.getState();
                    if(state=='SUCCESS'){

                    }
                    });
             $A.enqueueAction(action);
        }


 })