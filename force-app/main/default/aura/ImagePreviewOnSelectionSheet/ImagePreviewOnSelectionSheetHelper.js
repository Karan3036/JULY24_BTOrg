({
    getSelectionSheetRelatedCategories: function (component, event, helper) {
        var recordId = component.get("v.recordId");
        console.log('recordId => ' + recordId);

        var action = component.get("c.getSelectionCategories");

        action.setParams({
            recordId: component.get("v.recordId")
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('Status =>', { state });

            if (state === "SUCCESS") {
                // Add the "None" option at the top of the list
                var selectionCategories = response.getReturnValue();
                selectionCategories.unshift({ Name: '---None---', Id: null });

                component.set("v.selectionCategories", selectionCategories);
            } else {
                console.error("Error fetching product files.");
            }
        });

        $A.enqueueAction(action);
    }
})