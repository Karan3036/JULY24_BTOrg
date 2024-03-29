({
    doInit : function(component, event, helper) {
        component.set("v.Spinner", true);

        var action = component.get("c.getFieldSet");
        action.setParams({
            objectName: 'buildertek__BT_Payment__c',
            fieldSetName: 'buildertek__New_Payment_Component'
        });
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                component.set("v.Spinner", false);
                var listOfFields = JSON.parse(response.getReturnValue());
                component.set("v.listOfFields", listOfFields);
            }
        });
            
        $A.enqueueAction(action);
        helper.getPayableInvoiceInfo(component, event, helper);
    },
    
    closeModel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },

    handleSubmit : function(component, event, helper) {
        component.set("v.Spinner", true);
        console.log('handleSubmit');
        event.preventDefault();  
        var fields = event.getParam('fields');
        console.log('fields: ' + JSON.stringify(fields));
        var data = JSON.stringify(fields);
        console.log('data-->>',{data});
        var action = component.get("c.saveRecord");
        action.setParams({
            "data": data
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            var error = response.getError();
            console.log('Error =>',{error});
            if (state === "SUCCESS") {
                console.log('success');
                console.log(response.getReturnValue());
                var recordId = response.getReturnValue();
                console.log('recordId-->>',{recordId});
                var listofPOItems = component.get("v.listofPOItems");
                if(listofPOItems.length > 0){
                helper.savePOLineItems(component, event, helper, recordId);
                }
                component.set("v.Spinner", false);              
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "Success",
                    "title": "Success!",
                    "message": "The record has been created successfully."
                });
                toastEvent.fire();

                var saveNnew = component.get("v.isSaveNew");
                console.log('saveNnew: ' + saveNnew);

                if(saveNnew){
                    $A.get('e.force:refreshView').fire();
                }
                else{
                    console.log('---Else---');
                    console.log('saveAndClose');
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": recordId,
                        "slideDevName": "Detail"
                    });
                    navEvt.fire();
                    component.set("v.parentRecordId", null);

                    var focusedTabId = '';
                    var workspaceAPI = component.find("workspace");
                    workspaceAPI.getFocusedTabInfo().then(function(response) {
                        focusedTabId = response.tabId;
                    })

                    window.setTimeout(
                        $A.getCallback(function() {
                            workspaceAPI.closeTab({tabId: focusedTabId});
                        }), 1000
                    );
                }
            }
            else if (state === "ERROR") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "Error",
                    "title": "Error!",
                    "message": "Something Went Wrong"
                });
                toastEvent.fire();
                console.log('error', response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    handlesaveNnew : function(component, event, helper) {
        component.set("v.isSaveNew", true);
    },

    saveNnew : function(component, event, helper) {
        component.set("v.saveAndNew", true);
        console.log('saveNnew');
    },

    removePOLine : function(component, event, helper) {
        var currentId=event.currentTarget.dataset.id;
        console.log('current ID', {currentId});
        var listofPOItems=component.get("v.listofPOItems");
        //loop over the list and find the index to remove
        for(var i=0;i<listofPOItems.length;i++){
            if(listofPOItems[i].index==currentId){
                listofPOItems.splice(i,1);
                break;
            }
        }
        component.set("v.listofPOItems",listofPOItems);
    },

    addNewRow : function(component, event, helper) {
        var listofPOItems=component.get("v.listofPOItems");
        listofPOItems.push({
            index: listofPOItems.length,
            Name : '',
            buildertek__Quantity__c : '',
            buildertek__Unit_Price__c : '',
        });
        component.set("v.listofPOItems",listofPOItems);
    },

    handleVersionChange : function(component, event, helper) {
        var selectedVersion = component.find("version").get("v.value");
        console.log('selectedVersion', {selectedVersion});
        // var listofPOItems=component.get("v.listofPOItems");
        // for(var i=0;i<listofPOItems.length;i++){
        //     listofPOItems[i].buildertek__Version__c = selectedVersion;
        // }
        // component.set("v.listofPOItems",listofPOItems);
        
    },

})