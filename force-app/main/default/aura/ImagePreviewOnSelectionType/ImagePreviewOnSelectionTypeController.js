({
    init: function (component, event, helper) {
        var recordId = component.get("v.recordId");
        console.log('recordId => ' + recordId);

        var action = component.get("c.getProductFilesMap");

        action.setParams({
            recordId: recordId
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('Status =>', { state });

            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('Result =>', { result });
                if (result && Object.keys(result).length > 0) {
                    var contentDocsList = helper.convertMapToList(result);
                    console.log('contentDocsList--->',contentDocsList);
                    component.set("v.contentDocsList", contentDocsList);
                } else {
                    component.set("v.displayImage", false);
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
    },

    handle_img_click: function(component, event, helper){
        try {
            console.log('in handle images-->');
            var imageSrc = event.getSource().get("v.src");
            var imageTitle = 'Image';
            var imageId = event.getSource().get("v.id")

            helper.changeImageHelper(component, event, helper, imageId, false);
            helper.openCustomPreviewHelper(component, event, helper, imageSrc, imageTitle, imageId);
        } catch (error) {
            console.log('error-->',error);
        }

    },

    doView: function(component, event, helper) {
        ////console.log(event.currentTarget.dataset.record);
        var editRecordEvent = $A.get("e.force:navigateToSObject");
        console.log('event.currentTarget.dataset.record-->',event.currentTarget.dataset.record);
        editRecordEvent.setParams({
            "recordId": event.currentTarget.dataset.record
        });
        editRecordEvent.fire();
    },

});
