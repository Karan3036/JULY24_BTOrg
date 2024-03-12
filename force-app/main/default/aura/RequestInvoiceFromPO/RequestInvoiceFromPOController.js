({
    // handleInit: function(component, event, helper) {
    //     var actionAPI = component.find("quickActionAPI");
    //     var args = { actionName: "Case.CaseComment" }; // Specify your Quick Action API name here

    //     actionAPI.getDescribe(args).then(function(response) {
    //         console.log('Quick Action Name: ' + response.label); // Displaying Quick Action Name
    //         var toastEvent = $A.get("e.force:showToast");
    //         toastEvent.setParams({
    //             "title": "Quick Action Details",
    //             "message": "Name: " + response.label // Displaying Quick Action Name in Toast message
    //         });
    //         toastEvent.fire();
    //     }).catch(function(error) {
    //         console.error('Error in fetching Quick Action details: ' + error.message);
    //     });
    // },
        

    sendmailtovendor: function (component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({"action": "SHOW"}).fire();
        var recordId = component.get("v.recordId");
        var action = component.get("c.sendMailtoVendor");
        action.setParams({
            recordId: recordId,
            quickActionName: 'RequestInvoice'
        });
        action.setCallback(this, function (response) {
            var result = response.getReturnValue();
            console.log('Result =>', { result });
            $A.get("e.c:BT_SpinnerEvent").setParams({"action": "HIDE"}).fire();
            $A.get("e.force:closeQuickAction").fire();
            if (result.status == 'SUCCESS') {
                helper.showToastHelper(component, event, helper,result.status , result.message , result.status , 3000);
            } else {
                helper.showToastHelper(component, event, helper,result.status , result.message , result.status , 3000);
            }
        });
        $A.enqueueAction(action);
    },    

    closeModal: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})