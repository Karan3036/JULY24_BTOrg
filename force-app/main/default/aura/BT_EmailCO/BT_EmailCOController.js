({
	
	doInit : function(component, event, helper) {
        var objectName = component.get("v.sObjectName");
        var dbAction = component.get("c.getsubject");
        // var objApiName ;
        // if (objectName) {
        //     objApiName = component.get("v.objectAPI");
        // }
        // else{
        //     objApiName = component.get("v.sObjectName");
        // }
        dbAction.setParams({
            recordId : component.get("v.recordId"),
            objectAPIName: component.get("v.sObjectName"),
        });
        dbAction.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(objectName == 'buildertek__Change_Order__c'){
                    component.set("v.subject", '');
                }else{

                    component.set("v.subject", response.getReturnValue());
                }
            }
        });
        $A.enqueueAction(dbAction);
        console.log({objectName});
        // console.log(objApiName);

        if(objectName == 'buildertek__Submittal__c'){
             component.set("v.showTemplate", false);
             helper.getFiles(component, event, helper);
             helper.getContact(component, event, helper);    
        }
        else if (objectName == 'buildertek__RFI__c') {
            // component.set("v.showBodyTemplate",true);
            helper.getFiles(component, event, helper);
            helper.getContact(component, event, helper);
            helper.getTemplate(component, event, helper);
        }
        else if (objectName == 'buildertek__Quote__c') {
            helper.getBody(component, event, helper);
            helper.getTemplate(component, event, helper);
        }
        else {
            if(objectName == 'buildertek__Account_Payable__c' || objectName == 'buildertek__Billings__c'){
                component.set("v.showBodyTemplate",true);
                helper.getbodyTemplate(component, event, helper);
            }
            
            helper.getTemplate(component, event, helper);
        }
        helper.getProjectName(component, event, helper);    
       

       
	},
    emailTemplate : function(component, event, helper) {
        var objectName = component.get("v.objectAPI");
         // alert('component.get("v.selectedbodyTemplateItem")'+component.get("v.selectedbodyTemplateItem"));
          /*  if(objectName == 'buildertek__Account_Payable__c'){
                component.set("v.showBodyTemplate",true);
                helper.getbodyTemplate(component, event, helper);
            }*/
            helper.getBodyContent(component,component.get("v.selectedbodyTemplateItem"));
           // helper.getBodyContent(component, event, helper);
    },   
	sendemail : function(component, event, helper) {
		console.log("selectedToContact--->",component.get("v.selectedToContact"));
		console.log("selectedCcContact--->",component.get("v.selectedCcContact"));
		console.log("selectedfiles--->",component.get("v.selectedFiles"));
		 //alert('selected Users-------'+JSON.stringify(component.get("v.selectedFiles")));        
	    if(component.get("v.selectedToContact") != ''){ 
            // if(component.get("v.selectedfilesFill").length>0) {
                // $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();

                // helper.uploadHelper(component, event, component.get("v.recordId"),helper);    
            // }else{
                $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
                helper.send(component, event, helper);
            // }
           
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                mode: 'sticky',
                message: 'Please Select To Address',
                type : 'error',
                duration: '5000',
                mode: 'dismissible'
            });
            toastEvent.fire();  
        }
	},
	uploadFileAdd : function(component, event, helper) {
        console.log(component.get("v.selectedFiles"));
        console.log(component.get("v.objectAPI"));

		$A.createComponents(
            [
                ["aura:html", {
                    "tag": "h2",
                    "body": "Upload File",
                    "HTMLAttributes": { 
                        "class": "slds-text-heading_medium slds-hyphenate" 
                    }
                }],
                ["c:BT_AddFiles", {
                    "mainObjectFieldAPI": component.get("v.objectAPI"),
                    "mainObjectId": component.get("v.recordId"),
                    "selectedFiles": component.get("v.selectedFiles"),
                    "onCancel":function(){
                    	 component.get('v.modalPromise').then(function (modal) {
	                        modal.close();
	                        //$A.enqueueAction(component.get("c.doInit"));
	                    });
                    },
                    "onSuccess":function(file){
                    	 component.get('v.modalPromise').then(function (modal) {
	                        modal.close();
	                        //$A.enqueueAction(component.get("c.doInit"));
	                    });
	                    
	                    //alert('file --------> '+file);
	                    var selectedFiles = [];
	                    for(var i=0; i<file.length; i++){
	                        selectedFiles.push({
	                            "Id" : file[i].Id,
	                            "Name" : file[i].Name
	                        });    
	                    }
	                    //alert('selectedFiles ---------> '+selectedFiles.length);
			            component.set("v.selectedFiles", selectedFiles);
                    }
                }], 
                
            ], function(components, status) {
                if (status === 'SUCCESS') {
                    
                   var modalPromise = component.find('overlay').showCustomModal({
                        header: components[0],
                        body: components[1],
                        footer:components[1].find("footer") ,
                        showCloseButton: true,
                        cssClass: '',
                        closeCallback: function() {
                            
                        }
                    });
                    component.set("v.modalPromise", modalPromise);
                }
            });
	},
	
	cancel:function(component, event, helper){
		component.get("v.onCancel")();
	},
     onEmailChange: function (component, event, helper) {
        var emailId = component.find('emailForm').get('v.value');
        var emailIds = component.get('v.emailIds');
        var reg = /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/;
        if (emailId.charAt(emailId.length - 1) == ';') {
            emailId = emailId.replace(';', '');
            if (reg.test(emailId)) {
                component.set("v.toEmail", '');
                if (!emailIds.includes(emailId)) {
                    emailIds.push(emailId);
                }
            }
        }
        if(emailIds != null && emailIds != ''){
          component.set('v.emailIds', emailIds);  
        }else{
            component.set('v.emailIds', emailId);
        }
        
    },
     handleEmailRemove: function (component, event, helper) {
        var removeIndex = event.getSource().get("v.name");
        var emailIds = component.get('v.emailIds');
        emailIds.splice(removeIndex, 1);
        component.set('v.emailIds', emailIds);
    },
    
	handleFilesChange: function(component, event, helper) {
        console.log('handleFilesChange');
        var fileName = 'No File Selected..';                
            //alert(event.getSource().get("v.files").length);
        if (event.getSource().get("v.files").length > 0) {
            // fileName = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.selectedfileslist",event.getSource().get("v.files"));

        var fileCount=event.getSource().get("v.files").length;

        
        var files='';
        var mapData = [];
        if (fileCount > 0) {
            for (var i = 0; i < fileCount; i++) 
            {
                fileName = event.getSource().get("v.files")[i]["name"];
                var obj = {};
                obj['Name'] = fileName;                
                if(i == 0){
                	files=fileName;    
                }else{
                    files=files+','+fileName;
                }
                mapData.push(obj);                
            }
        }
        else
        {
            files=fileName;
        }
        component.set("v.fileName", files);            
        component.set("v.selectedfilesFill",mapData);

        console.log(component.get("v.fileName"));
        console.log(component.get("v.selectedfilesFill"));

    }, 
                
                
  // function for clear the Record Selaction 
    clear :function(component,event,heplper){
        var selectedPillId = event.getSource().get("v.name");
        console.log('ID :--->',selectedPillId);
        var AllPillsList = component.get("v.selectedfilesFill"); 
        console.log('ID LIST:--->',AllPillsList);
        
        for(var i = 0; i < AllPillsList.length; i++){
            if(AllPillsList[i].Id == selectedPillId){
                AllPillsList.splice(i, 1);
                component.set("v.selectedfilesFill", AllPillsList);
            }  
        }
    },                
    closeWindow: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
     openPopupModel:function(component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();        // var Id=  event.currentTarget.dataset.iconattr;
        // component.set("v.quoteLineId",Id);
        component.set("v.selectedFile", []);
        console.log('1');
        helper.getFileList(component, event, helper);
    },    
    closeFileModel : function (component,event,helper) {
        component.set("v.showModel",false);
        component.set("v.selectedFile", []);
    },  
    saveFile: function(component, event, helper){
        var selectedFile = component.get("v.selectedFile");
        if (selectedFile.length > 0) {
            component.set("v.showModel",false);
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                mode: 'sticky',
                message: 'Please select atlease one file.',
                type : 'error',
                duration: '5000',
                mode: 'dismissible'
            });
            toastEvent.fire();  
        }
    },   
    // handleCheckboxChange: function(component, event, helper) {
    //     var fileName = 'No File Selected..';
    //     var fileId = '';
    //     var file = event.getSource().get("v.name");
    //     console.log('fileId : ->', file);
    
    //     var selectedFiles = component.get("v.selectedFile") || [];
    //     if (event.getSource().get("v.checked")) {
    //         selectedFiles.push(file);
    //     } else {
    //         selectedFiles = selectedFiles.filter(function(id) {
    //             return id.Id !== file.Id;
    //         });
    //     }
    
    //     selectedFiles = JSON.parse(JSON.stringify(selectedFiles));
    //     component.set("v.selectedFile", selectedFiles);
    //     console.log('selectedFiles :->', selectedFiles);
    
    //     var fileCount = selectedFiles.length;
    //     var files = '';
    //     var mapData = [];
    //     mapData = component.get("v.selectedfilesFill");
    
    //     if (fileCount > 0) {
    //         for (var i = 0; i < fileCount; i++) {
    //             fileName = selectedFiles[i].Title;
    //             fileId = selectedFiles[i].ContentDocumentId;
    //             var obj = {};
    //             obj['Name'] = fileName;
    //             obj['Id'] = fileId;
    //             mapData.push(obj);
    
    //             if (i == 0) {
    //                 files = fileName;
    //             } else {
    //                 files = files + ',' + fileName;
    //             }
    //         }
    //     } else {
    //         files = fileName;
    //     }
    
    //     component.set("v.fileName", files);
    //     component.set("v.selectedfilesFill", mapData);
    //     var fileIds = mapData.map(function(v) {
    //         return v.Id;
    //     });
    //     component.set("v.selectedFillIds", fileIds);
    
    //     console.log(component.get("v.fileName"));
    //     console.log('fileIds :->', fileIds);
    //     console.log('selected :-->', component.get("v.selectedfilesFill"));
    // },
    
    handleCheckboxChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        var fileId = '';
        var file = event.getSource().get("v.name");
        console.log('fileId : ->', file);
    
        var selectedFiles = component.get("v.selectedFile") || [];
    
        // Check if the file is already in the selectedFiles array
        var fileIndex = selectedFiles.findIndex(function(selectedFile) {
            return selectedFile.Id === file.Id;
        });
    
        if (event.getSource().get("v.checked")) {
            // If the file is not already in the array, add it
            if (fileIndex === -1) {
                selectedFiles.push(file);
            }
        } else {
            // If the file is in the array, remove it
            if (fileIndex !== -1) {
                selectedFiles.splice(fileIndex, 1);
            }
        }
    
        // No need to stringify and parse, just set the array
        component.set("v.selectedFile", selectedFiles);
        console.log('selectedFiles :->', selectedFiles);
    
        var fileCount = selectedFiles.length;
        var files = '';
        var mapData = component.get("v.selectedfilesFill") || [];
    
        if (fileCount > 0) {
            for (var i = 0; i < fileCount; i++) {
                fileName = selectedFiles[i].Title;
                fileId = selectedFiles[i].ContentDocumentId;
    
                // Check if the fileId is already in the mapData
                var fileInMap = mapData.some(function(mapFile) {
                    return mapFile.Id === fileId;
                });
    
                // If the fileId is not in the mapData, add it
                if (!fileInMap) {
                    var obj = {};
                    obj['Name'] = fileName;
                    obj['Id'] = fileId;
                    mapData.push(obj);
    
                    if (i == 0) {
                        files = fileName;
                    } else {
                        files = files + ',' + fileName;
                    }
                }
            }
        } else {
            files = fileName;
        }
    
        component.set("v.fileName", files);
        component.set("v.selectedfilesFill", mapData);
        var fileIds = mapData.map(function(v) {
            return v.Id;
        });
        component.set("v.selectedFillIds", fileIds);
    
        console.log(component.get("v.fileName"));
        console.log('fileIds :->', fileIds);
        console.log('selected :-->', component.get("v.selectedfilesFill"));
    },
    
    
    handleFileChange: function(component, event, helper) {
        console.log('handleFilesChange');
        var fileName = 'No File Selected..';
        var fileId = '';
    
        var existingMapData = component.get('v.selectedfilesFill');
        var newFilesList = event.getParam('files');
    
        var fileCount = newFilesList.length;
        var files = '';
        var mapData = existingMapData || [];
    
        if (fileCount > 0) {
            for (var i = 0; i < fileCount; i++) {
                fileName = newFilesList[i]['name'];
                fileId = newFilesList[i].documentId;
    
                var obj = {};
                obj['Name'] = fileName;
                obj['Id'] = fileId;
    
                mapData.push(obj);
            }
    
            // Construct the files string after adding all files to mapData
            files = mapData.map(function(file) {
                return file.Name;
            }).join(', ');
        } else {
            files = fileName;
        }
    
        component.set('v.selectedfilesFill', mapData);
        console.log(component.get('v.selectedfilesFill'));
    }
    
    

    

    
                
})