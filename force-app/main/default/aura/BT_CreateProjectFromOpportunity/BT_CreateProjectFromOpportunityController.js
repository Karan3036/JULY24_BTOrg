({
	doInit : function(component, event, helper) {
        // component.set("v.Spinner", true);
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        var pageRef = component.get("v.pageReference");
        // console.log('pageRef--',JSON.stringify(pageRef));
        if (pageRef != undefined) {
            var state = pageRef.state; // state holds any query params	        
            // console.log('state = ' + JSON.stringify(state));
            if (state != undefined && state.c__Id != undefined) {
                component.set("v.recordId", state.c__Id);
            }
            if (state != undefined && state.buildertek__Id != undefined) {
                component.set("v.recordId", state.buildertek__Id);
            }
        }
	    // var recordId = component.get("v.recordId");
        var action = component.get("c.getOpportunity");
        action.setParams({
           recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            // component.set("v.Spinner", false);
            $A.get("e.c:BT_SpinnerEvent").setParams({
                "action": "HIDE"
            }).fire();
            if(state === "SUCCESS"){
                var result = response.getReturnValue();
                if(result.AccountId != undefined){
                    component.find("accountId").set("v.value", result.Account.Id);
                }
                if(result.CloseDate != null){
                    component.find("closeDateId").set("v.value", result.CloseDate);
                }
            }
        });
        $A.enqueueAction(action);
    },

    closeModel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        var redirectUrl = '/one/one.app?#/sObject/' + component.get('v.recordId') + '/view';
        $A.get("e.force:navigateToURL").setParams({
            "url": redirectUrl,
            "isredirect": true
        }).fire();
    },

    saveModel : function(component, event, helper) {
        // component.set("v.Spinner", true);
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        var project = component.find("projectNameId").get("v.value");
        var accountId = component.find("accountId").get("v.value");
        var projectManagerId = component.find("projectManagerId").get("v.value");
        var contractDateId = component.find("contractDateId").get("v.value");
        var closeDateId = component.find("closeDateId").get("v.value");
        console.log('projectName-->',project);
        console.log('closeDateId-->',closeDateId);
        if (project != null && project != '') {
            var action = component.get("c.createProject");
            action.setParams({
                recordId : component.get("v.recordId"),
                projectName : project,
                account : accountId,
                projectManager : projectManagerId,
                contractDate : contractDateId,
                closeDate : closeDateId
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    let result=response.getReturnValue();
                    // component.set("v.Spinner", false);
                    $A.get("e.c:BT_SpinnerEvent").setParams({
                        "action": "HIDE"
                    }).fire();
                    $A.get("e.force:closeQuickAction").fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "message": "Project Created successfully.",
                        "mode": 'sticky',
                        "type": 'success',
                        "duration": 3000
                    });
                    toastEvent.fire();
                    var redirectUrl = '/one/one.app?#/sObject/' + component.get('v.recordId') + '/view';
                    $A.get("e.force:navigateToURL").setParams({
                        "url": redirectUrl,
                        "isredirect": true
                    }).fire();
                    $A.get('e.force:refreshView').fire();
                }else{
                    // component.set("v.Spinner", false);
                    $A.get("e.c:BT_SpinnerEvent").setParams({
                        "action": "HIDE"
                    }).fire();
                    $A.get("e.force:closeQuickAction").fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "message": "Something went wrong",
                        "mode": 'sticky',
                        "type": 'error',
                        "duration": 3000
                    });
                    toastEvent.fire();

                }
            });
            $A.enqueueAction(action);
        } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "message": "Project Name should not be empty.",
                "mode": 'sticky',
                "type": 'error',
                "duration": 1500
            });
            toastEvent.fire();
            // component.set("v.Spinner", false);
            $A.get("e.c:BT_SpinnerEvent").setParams({
                "action": "HIDE"
            }).fire();
        }

    },

    clearAccountSelectedValue : function(component, event, helper) {
	    component.set("v.isAccount", true);
	    component.set("v.selectedLookUpRecord", null);
	    component.set("v.selectedLookUpRecordName", '');
	}
})