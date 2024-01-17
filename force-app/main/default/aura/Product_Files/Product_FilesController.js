({
    init : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        console.log('recordId => ' + recordId);
        var orgId = $A.get("$SObjectType.CurrentUser.Id");
        var baseUrl = window.location.protocol + '//' + window.location.hostname + '/' + orgId.substring(0, 15);
        console.log('Organization Base URL: ' + baseUrl);
        component.set('v.orgBaseURL', baseUrl);

        var action = component.get("c.getProductFiles");
        action.setParams({
            recordId: recordId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('Status =>', {state});
            var result = response.getReturnValue();
            console.log('Result =>', {result});
            if (result.status != 'error') {
                component.set("v.contentDocsList", result.contentLink);
                console.log(component.get("v.contentDocsList"));
            }
        });
        $A.enqueueAction(action);
    },
})