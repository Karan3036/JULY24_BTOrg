({
    convertMapToList: function(map) {
        var list = [];
    
        for (var outerKey in map) {
            if (map.hasOwnProperty(outerKey)) {
                var outerValue = map[outerKey];
                var innerList = [];
    
                for (var innerKey in outerValue) {
                    if (outerValue.hasOwnProperty(innerKey)) {
                        innerList.push({ key: innerKey, value: outerValue[innerKey] });
                    }
                }
    
                list.push({ key: outerKey, innerList: innerList });
            }
        }
    
        return list;
    },

    changeNextButton: function(component, event, helper){
        try {
            event.stopPropagation();
            console.log('inside changeNextButton');
           if(event.currentTarget.dataset.name == 'Next_Image'){
                var ImageId = component.get("v.PreviewImageId");
                var outerId = component.get("v.outerId");
                console.log('outerId --> ', outerId);
                console.log('ImageId --> ', ImageId);
                const contentDocsList = component.get('v.contentDocsList');

                for(var i in contentDocsList){
                    if(contentDocsList[i].key == outerId){
                        var InnerListValue = contentDocsList[i].innerList[0].value;
                        for(var j in InnerListValue){
                                var contentId = InnerListValue[j].contentDocumentId;
                                if(contentId == ImageId){
                                    var imageSrc = '/sfc/servlet.shepherd/document/download/' + InnerListValue[parseInt(j) + 1].contentDocumentId;
                                    component.set("v.PreviewImageSrc", imageSrc);
                                    component.set("v.PreviewImageId", InnerListValue[parseInt(j) + 1].contentDocumentId)
                                    helper.setNextPreviousButton(component, event, helper);
                                }
                        }
                    }
                }

           }
        } catch (error) {
            console.log('error in changeNextButton : ', error.stack);
            
        }
    },

    setNextPreviousButton : function(component, event, helper){
        try {
            if(event.currentTarget.dataset.name == 'Next_Image'){
                var ImageId = component.get("v.PreviewImageId");
                var outerId = component.get("v.outerId");
                console.log('outerId --> ', outerId);
                console.log('ImageId --> ', ImageId);
                const contentDocsList = component.get('v.contentDocsList');

                for(var i in contentDocsList){
                    if(contentDocsList[i].key == outerId){
                        var InnerListValue = contentDocsList[i].innerList[0].value;
                        for(var j in InnerListValue){
                                var contentId = InnerListValue[j].contentDocumentId;
                                if(contentId == ImageId){
                                    if(j == (InnerListValue.length)){
                                        component.set("v.NotLastImg", false);
                                        console.log('last Image');
                                    }
                                }
                        }
                    }
                }

           }
        } catch (error) {
            console.log('error in setNextPreviousButton : ', error.stack);
            
        }
    },

    

    changeImageHelper: function(component, event, helper, imageIds, outerIds, next_previus_btn_click) {
        try {
            event.stopPropagation();
            var operation;
            var selectedImageId;
            var outerId = component.get("v.outerId");
            var ImageId = component.get("v.PreviewImageId");
    
            if (next_previus_btn_click) {
                operation = event.currentTarget.dataset.name;
                selectedImageId = component.get("v.PreviewImageId");
            } else {
                operation = null;
                selectedImageId = imageId;
            }
            const contentDocsList = component.get('v.contentDocsList');
            for (var i in contentDocsList) {
                if (contentDocsList[i].key == outerId) {
                    var InnerListValue = contentDocsList[i].innerList[0].value;
                    for (var j in InnerListValue) {
                        if (InnerListValue[j].contentDocumentId == ImageId) {
                            if (next_previus_btn_click == true) {
                                if (operation == 'Previous_Image') {
                                    var imageSrc = '/sfc/servlet.shepherd/document/download/' + InnerListValue[parseInt(j) - 1].contentDocumentId;
                                    var imageTitle = InnerListValue[parseInt(j) - 1].title;
                                    var previewImageId = InnerListValue[parseInt(j) - 1].contentDocumentId;
                                    helper.changeImageHelper(component, event, helper, outerId, previewImageId, false);
                                    helper.openCustomPreviewHelper(component, event, helper, imageSrc, imageTitle, previewImageId);
                                } else if (operation == 'Next_Image') {
                                    var imageSrc = '/sfc/servlet.shepherd/document/download/' + InnerListValue[parseInt(j) + 1].contentDocumentId;
                                    var imageTitle = InnerListValue[parseInt(j) + 1].title;
                                    var previewImageId = InnerListValue[parseInt(j) + 1].contentDocumentId;
                                    helper.changeImageHelper(component, event, helper, previewImageId, false);
                                    helper.openCustomPreviewHelper(component, event, helper, imageSrc, imageTitle, previewImageId);
                                }
                            } 
                            else if (next_previus_btn_click == false) {
                                // Check if it's the first image
                                if (j == 0) {
                                    component.set("v.NotFirstImg", false);
                                } else {
                                    component.set("v.NotFirstImg", true);
                                }
    
                                // Check if it's the last image
                                if (j == InnerListValue.length - 1) {
                                    component.set("v.NotLastImg", false);
                                } else {
                                    component.set("v.NotLastImg", true);
                                }
                            }
                        }
                    }
                }
            }
        } catch (error) {
            console.log('error in changeImageHelper : ', error.stack);
        }
    },
    
    
    openCustomPreviewHelper: function(component, event, helper, imageSrc, imageTitle, imageId){
        component.set("v.PreviewImageSrc", imageSrc);
        console.log('imageSrc',imageSrc);
        component.set("v.PreviewImageTitle", imageTitle);
        component.set("v.PreviewImageId", imageId);
        component.set("v.PreviewImgSpinner", true);
        component.set("v.Is_ImageHavePreview", true);
        component.set('v.Show_ImagePreview', true);

    },

    getfilesfromproduct: function(component, event, helper) {

        var recordId = component.get("v.selectedImageId");
        console.log('recordId => ' + recordId);
        var action = component.get("c.getProductFilesMap");

        action.setParams({
            recordId: component.get("v.mainRecordId")
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

})
