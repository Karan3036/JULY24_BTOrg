({
    doInit : function(component, event, helper) {
        var id = component.get("v.recordId");
        console.log(id);
        var Objectname = component.get("v.sobjecttype");
        console.log('Objectname---> ',Objectname);
        if (Objectname == 'buildertek__Purchase_Order__c') {
            helper.createPO(component, event, helper);
        }
    }
})