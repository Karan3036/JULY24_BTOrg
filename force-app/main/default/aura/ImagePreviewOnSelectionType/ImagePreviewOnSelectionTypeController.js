({
    init: function (component, event, helper) {
        var sobjectname = component.get("v.sObjectName");

        var recordId = component.get("v.selectedImageId");
        console.log('Categary recordId => ' + recordId);
        var recordId1 = component.get("v.recordId");
        console.log('recordId => ' + recordId1);
        if (sobjectname == 'buildertek__Question_Group__c') {
            component.set("v.mainRecordId", recordId1);
        } else if(sobjectname == 'buildertek__Section__c' || sobjectname == 'buildertek__Selection__c'){
            component.set("v.mainRecordId", recordId);
        }

        var action = component.get("c.selectionTypeDetail");

        action.setParams({
            recordId: component.get("v.mainRecordId")
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('Status =>', { state });

            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('Result =>', { result });
                if (result != null) {
                    component.set("v.SelectionTypeName", result[0].Name);
                    component.set("v.SelectionTypeId", result[0].Id);
                    helper.getfilesfromproduct(component, event, helper);
                } else {
                    component.set("v.displayImage", false);
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

            var clickedDiv = event.currentTarget;
            var imageSrc = clickedDiv.getAttribute('data-src');
            var imageId = clickedDiv.getAttribute('id');
            var imageTitle = clickedDiv.getAttribute('data-description');
            var outerId = clickedDiv.getAttribute('data-outerid');
            // var ImageId = component.get("v.PreviewImageId");
            // component.set("v.outerId", clickedDiv.getAttribute('data-outerid'));

            helper.changeImageHelper(component, event, helper, imageId, outerId, false);
            helper.openCustomPreviewHelper(component, event, helper, imageSrc, imageTitle, imageId);
        } catch (error) {
            console.log('error-->',error);
        }

    },

    doView: function(component, event, helper) {
        var editRecordEvent = $A.get("e.force:navigateToSObject");
        editRecordEvent.setParams({
            "recordId": event.currentTarget.dataset.record
        });
        editRecordEvent.fire();
    },

    accordionAction : function(component, event, helper) {
		var thisObj = event.target.name;
        var w3webAccordionListOver = document.getElementById('w3webAccordionListOver');
        var accordionListAll =  w3webAccordionListOver.querySelectorAll('.slds-accordion__list-item');
        //alert(accordionListAll.length);
 
        var conainActive = document.getElementById(thisObj).classList.contains('activeRow');
        for(var i=0; i<accordionListAll.length; i++){
            accordionListAll[i].classList.remove('activeRow');
        }
 
        if(conainActive == true){
            document.getElementById(thisObj).classList.remove('activeRow');
        }else{
            document.getElementById(thisObj).classList.toggle('activeRow');        
        }
 
	},

    stopEventPropogation: function(component, event, helper){
        event.stopPropagation();
    },
    closeImagePreview : function(component, event, helper){
        component.set("v.Is_ImageHavePreview", false);
        component.set('v.Show_ImagePreview', false);
        helper.setNextPreviousButton(component, event, helper);

    },
    Handle_imageLoaded: function(component, event, helper){
        console.log('image loaded');
        component.set("v.PreviewImgSpinner", false);
    },
    
    Handle_imageNotLoaded: function(component, event, helper){
        console.log('image not loaded');
        component.set("v.Is_ImageHavePreview", false);
        component.set("v.PreviewImgSpinner", false);

    },
    ChangeImg: function(component, event, helper){
        component.set("v.Is_ImageHavePreview", false);
        component.set('v.Show_ImagePreview', false);
        helper.changeImageHelper(component, event, helper, null, null, true);
    },

});