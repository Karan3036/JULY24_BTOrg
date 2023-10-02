({
    doInit : function(component, event, helper) {
        var action = component.get("c.getQuoteLineRecordList");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS') {
                var QuoteLineList = response.getReturnValue();
                component.set("v.quoteLineList", QuoteLineList);
                component.set("v.changeColorToRed", true);
                console.log(' QuoteLine-->',component.get("v.quoteLineList"));
            }
        });
        $A.enqueueAction(action);
    },
    closeModel : function (component,event,helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    editProduct: function(component, event, helper) {
        component.set("v.editMode", true); // Enable editing
        var Id=  event.currentTarget.dataset.iconattr;
        console.log('id-->',Id);
        component.set("v.selectedRecId", Id); 
        component.set("v.isFieldDisabled", false);
        console.log(component.get("v.selectedRecId"));

    }
    
})