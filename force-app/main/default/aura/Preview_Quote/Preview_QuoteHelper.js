({
    getTemplateBody: function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.getQuoteLines");
        action.setParams({
            recordId: recordId,
            templateId: component.get("v.selectedTemplate")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('get template body');
                console.log({ result });
                component.set("v.quoteLines", result);
            }
        });
        $A.enqueueAction(action);
    },

    getContact: function(component, event, helper) {
        var action = component.get("c.getObjectContact");
        action.setParams({
            "recordId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                //alert('result ---------> '+result);
                var selectedContact = component.get("v.selectedToContact");
                if (result != undefined) {
                    result.forEach(function(elem){
                        console.log(elem.buildertek__Primary_Contact__c);
                        if(elem.buildertek__Primary_Contact__c){
                            selectedContact.push(elem);
                        }
                    })
                }
                component.set("v.selectedToContact", selectedContact);
                console.log(component.get("v.selectedToContact"));
            }
        });
        $A.enqueueAction(action);
    },

    getProposalImagesList: function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.getProposalImages");
        action.setParams({
            recordId: recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {

                var result = response.getReturnValue();
                // alert(JSON.stringify(result));
                component.set("v.ProposalImages", result);
                console.log(component.get("v.ProposalImages"));
                //  alert('*****'+component.get("v.ProposalImages"));
            }
        });
        $A.enqueueAction(action);
    },

    getuploadSignature: function(component, event) {
        component.set("v.parentId", component.get("v.recordId"));
        var recId = component.get("v.parentId");

        var signName = component.get("v.SignatureName");
        var signatureaction = component.get("c.saveSign");
        var toastEvent = $A.get('e.force:showToast');
        var vSplit = document.getElementById("divsign").toDataURL().split(',')[1];

        signatureaction.setParams({
            base64Data: encodeURIComponent(vSplit),
            contentType: "image/png",
            recId: recId,
            signName: signName,
        });
        signatureaction.setCallback(this, function(e) {
            if (e.getState() == 'SUCCESS') {
                var result = e.getReturnValue();
                component.set("v.Spinner", false);
                component.set("v.fileimageId", result);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": 'success',
                    "message": "Signature Saved Successfully"
                });
                toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
                // location.reload();

            } else {
                alert(JSON.stringify(e.getError()));
            }
        });
        $A.enqueueAction(signatureaction);

    },

    acceptandsendemailhelper: function(component, event) {
        //alert('hi2');
        var files, fileIds = [];
        files = component.get("v.selectedFillIds");
        files.forEach(function(v){ fileIds.push(v) });
        var toIds = [];
        var ccIds = [];
        var to = component.get("v.selectedToContact");
        var cc = component.get("v.selectedCcContact");
        var emailIds = component.get("v.emailIds");

        to.forEach(function(v) {
            toIds.push(v.Id)
        });
        cc.forEach(function(v) {
            ccIds.push(v.Id)
        });

        var signid = component.get("v.fileimageId");
        console.log('signid===>',signid);
        // alert('imageId'+component.get("v.fileimageId"));
        var action = component.get("c.acceptandsendProposal");
        action.setParams({
            htmlBody: component.get("v.quoteLines"),
            recordId: component.get("v.recordId"),
            templateId: component.get("v.selectedTemplate"),
            to: toIds,
            cc: ccIds,
            fileid: signid,
            emailIds: emailIds,
            memovalue: component.get("v.memoquote"),
            files: fileIds
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var subject = 'Quote[ref:' + component.get("v.recordId") + ']';
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if (result === 'Success') {
                    component.set("v.Spinner", false);
                    $A.get("e.force:closeQuickAction").fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type": 'success',
                        "message": "Email Sent Successfully"
                    });
                    toastEvent.fire();
                    // location.reload();
                } else {
                    $A.get("e.force:closeQuickAction").fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": 'error',
                        "message": result
                    });
                    toastEvent.fire();
                }
                $A.get('e.force:refreshView').fire();
            }
        });

        $A.enqueueAction(action);

        component.set("v.Spinner", false);


    },

    AcceptSignature: function(component, event) {
        component.set("v.parentId", component.get("v.recordId"));
        var recId = component.get("v.parentId");

        var signName = component.get("v.SignatureName");
        var signatureaction = component.get("c.saveSign");
        var toastEvent = $A.get('e.force:showToast');
        var vSplit = document.getElementById("divsign").toDataURL().split(',')[1];

        signatureaction.setParams({
            base64Data: encodeURIComponent(vSplit),
            contentType: "image/png",
            recId: recId,
            signName: signName
        });
        signatureaction.setCallback(this, function(e) {
            if (e.getState() == 'SUCCESS') {
                var result = e.getReturnValue();

                component.set("v.fileimageId", result);
                setTimeout(
                    function() {
                        component.acceptandSendMethod();
                    }, 2000);


                /* var toastEvent = $A.get("e.force:showToast");
                   toastEvent.setParams({
                       "title": "Success!",
                       "type": 'success',
                       "message": "Signature Saved Successfully"
                   });
                   toastEvent.fire();*/


            } else {
                alert(JSON.stringify(e.getError()));
            }
        });
        $A.enqueueAction(signatureaction);

    },
    getmemovalue: function(component, event, helper) {
        var action = component.get("c.getmemoval");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === "SUCCESS") {
                component.set("v.memoquote", result.buildertek__Memo__c);
            }
        });

        $A.enqueueAction(action);
    },
    sendemailhelper: function(component, event, helper) {
        var files, fileIds = [], toIds = [], ccIds = [];
        var emailIds = component.get('v.emailIds');
        files = component.get("v.selectedFillIds");
        var to = component.get("v.selectedToContact");
        var cc = component.get("v.selectedCcContact");
        files.forEach(function(v){ fileIds.push(v) });
        to.forEach(function(v) { toIds.push(v.Id) });
        cc.forEach(function(v) { ccIds.push(v.Id) });
        var action = component.get("c.sendProposal");
            action.setParams({
                htmlBody: component.get("v.quoteLines"),
                recordId: component.get("v.recordId"),
                templateId: component.get("v.selectedTemplate"),
                to: toIds,
                cc: ccIds,
                emailIds: emailIds,
                memovalue: component.get("v.memoquote"),
                files: fileIds
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                var subject = 'Quote[ref:' + component.get("v.recordId") + ']';
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    if (result === 'Success') {
                        // debugger;
                        component.set("v.Spinner", false);
                        $A.get("e.force:closeQuickAction").fire();
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "type": 'success',
                            "message": "Email Sent Successfully"
                        });
                        toastEvent.fire();
                    } else {
                        $A.get("e.force:closeQuickAction").fire();
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": 'error',
                            "message": result
                        });
                        toastEvent.fire();
                    }
                    $A.get('e.force:refreshView').fire();
                }
            });
            $A.enqueueAction(action);
    },

    MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB 
    CHUNK_SIZE: 750000,      //Chunk Max size 750Kb      
    filesCount : 0,
    fileInputLenght: 0,
    fileIds:[],

    uploadHelper: function(component, event, recid,helper) {
        var fileInput = component.get("v.selectedfileslist");
        console.log('fileInput ==> ',fileInput);
        this.fileInputLenght = fileInput.length;
        var fills = component.get("v.selectedfilesFill");
        for (var i = 0; i < fileInput.length; i++) { 
            var filenameexists = false;
            for (var j = 0; j < fills.length; j++) {
                if(fileInput[i]["name"] == fills[j].Name){
					filenameexists = true; 
                    break;
                }
            }
            
            if(filenameexists){
                var file = fileInput[i];
                var self = this;

                console.log(file.size , '=======file.size=========');
                // check the selected file size, if select file size greter then MAX_FILE_SIZE,
                // then show a alert msg to user,hide the loading spinner and return from function 
                if (file.size > self.MAX_FILE_SIZE) {
                    component.set("v.fileName", 'Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
                    component.set("v.Spinner", false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type": 'error',
                        "message": 'File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size
                    });
                    toastEvent.fire();
                    return;
                }
                self.uploadFile(component, file,recid,helper); 
            }
            
            
        }
    },
    uploadFile:function(component, file,recid,helper) {;
        var self = this;
        // create a FileReader object 
        var objFileReader = new FileReader();
        // set onload function of FileReader object   
        objFileReader.onload = $A.getCallback(function() { 
            var fileContents = objFileReader.result;
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;
            fileContents = fileContents.substring(dataStart);
            console.log('fileContents',fileContents);
            // call the uploadProcess method 
            self.uploadProcess(component, file, fileContents,recid,helper);
        });
        objFileReader.readAsDataURL(file);
    },
    uploadProcess: function(component, file, fileContents,recid,helper) {
        console.log("Uploading files"); 
        var self = this;
        // set a default size or startpostiton as 0 
        var startPosition = 0;
        // calculate the end size or endPostion using Math.min() function which is return the min. value   
        var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
        // start with the initial chunk, and set the attachId(last parameter)is null in begin
        this.uploadInChunk(component, file, fileContents, startPosition, endPosition, '',recid,helper); 
        
    },
    uploadInChunk: function(component, file, fileContents, startPosition, endPosition, attachId,recid,helper) {
        console.log('== uploadInChunk ==');      
        var getchunk = fileContents.substring(startPosition, endPosition);
        //alert('getchunk--->'+getchunk);

        console.log('recid ==> '+recid);
        console.log('file.name ==> '+file.name);
        console.log('getchunk ==> '+getchunk);
        console.log('file.type ==> '+file.type);
        console.log('attachId ==> '+attachId);

        var action = component.get("c.uploadFile");
        action.setParams({ 
            parentId: recid,
            fileName: file.name,
            base64Data: encodeURIComponent(getchunk),
            contentType: file.type, 
            fileId: attachId
        });
        // set call back 
        action.setCallback(this, function(response) { 
            console.log(' -- setCallback --');  
            attachId = response.getReturnValue();
            console.log('attachId ==> '+attachId);
            this.fileIds.push(attachId);
            var state = response.getState();
            console.log('state ==> '+state);
            var responce = response.getReturnValue();
            console.log('Responce -> ',{responce});
            if (state === "SUCCESS") {
                this.filesCount++; 
                // update the start position with end postion
                startPosition = endPosition;
                endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
                // check if the start postion is still less then end postion 
                // then call again 'uploadInChunk' method , 
                // else, diaply alert msg and hide the loading spinner
                console.log(startPosition < endPosition);
                console.log({startPosition});
                console.log({endPosition});

                if (startPosition < endPosition) {
                    this.uploadInChunk(component, file, fileContents, startPosition, endPosition, attachId,recid,helper);
                    // debugger;
                } 
                if(this.filesCount == this.fileInputLenght){ 
                    console.log('this.fileIds ==> '+this.fileIds);
                    component.set("v.selectedFillIds",this.fileIds);
                    var sendEmailBooleen = component.get("v.sendEmailBool");
                    console.log('sendEmailBooleen==>',sendEmailBooleen);
                    if (sendEmailBooleen) {
                        this.sendemailhelper(component, event, helper);
                        this.filesCount = 0;
                        this.fileInputLenght = 0;
                        this.fileIds = [];
                    } else {
                        this.AcceptSignature(component, event);
                        this.filesCount = 0;
                        this.fileInputLenght = 0;
                        this.fileIds = [];
                    }
                   
                }
                // handel the response errors        
            } else if (state === "INCOMPLETE") { 
                component.set("v.Spinner", false); 
                
            } else if (state === "ERROR") {
                component.set("v.Spinner", false);
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "type": 'error',
                            "message": response.getReturnValue()
                        });
                        toastEvent.fire();
                    }
                } else {
                    console.log("Unknown error");
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type": 'error',
                        "message": "Unknown error"
                    });
                    toastEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);
    },

})