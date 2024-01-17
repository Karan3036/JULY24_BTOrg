({
    init: function (component, event, helper) {
        var recordId = component.get("v.recordId");
        console.log('recordId => ' + recordId);

        var action = component.get("c.getProductFilesMap"); // Updated method name

        action.setParams({
            recordId: recordId
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('Status =>', { state });

            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('Result =>', { result });

                // Check if the result is not an error
                if (result) {
                    // Convert the map to a list of objects with key and value properties
                    var contentDocsList = helper.convertMapToList(result);
                    component.set("v.contentDocsList", contentDocsList);
                } else {
                    console.error("Error fetching product files.");
                }
            } else {
                console.error("Error fetching product files.");
            }
        });

        $A.enqueueAction(action);
    },
    
    handleSectionToggle: function (cmp, event) {
        var openSections = event.getParam('openSections');

        if (openSections.length === 0) {
            cmp.set('v.activeSectionsMessage', "All sections are closed");
        } else {
            cmp.set('v.activeSectionsMessage', "Open sections: " + openSections.join(', '));
        }
    }
});
