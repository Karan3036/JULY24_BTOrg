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

    

    changeImageHelper: function(component, event, helper, imageId, nextPreviousBtnClick) {
        try {
            event.stopPropagation();
            const outerId = component.get("v.outerId");
            const contentDocsList = component.get('v.contentDocsList');
    
            for (let i in contentDocsList) {
                if (contentDocsList[i].key === outerId) {
                    const innerListValue = contentDocsList[i].innerList[0].value;
    
                    for (let j in innerListValue) {
                        const contentDocumentId = innerListValue[j].contentDocumentId;
    
                        if (nextPreviousBtnClick) {
                            // Logic for Next/Previous button click
                            if (contentDocumentId === imageId) {
                                let newIndex;
    
                                if (event.currentTarget.dataset.name === 'Next_Image' && parseInt(j) < innerListValue.length - 1) {
                                    newIndex = parseInt(j) + 1;
                                } else if (event.currentTarget.dataset.name === 'Previous_Image' && parseInt(j) > 0) {
                                    newIndex = parseInt(j) - 1;
                                }
    
                                if (newIndex !== undefined) {
                                    const newImageId = innerListValue[newIndex].contentDocumentId;
                                    const imageSrc = '/sfc/servlet.shepherd/document/download/' + newImageId;
                                    component.set("v.PreviewImageSrc", imageSrc);
                                    component.set("v.PreviewImageId", newImageId);
                                    helper.setNextPreviousButton(component, event, helper);
                                }
                            }
                        } else {
                            // Logic for direct image change
                            if (contentDocumentId === imageId) {
                                const imageSrc = '/sfc/servlet.shepherd/document/download/' + innerListValue[parseInt(j) + 1].contentDocumentId;
                                component.set("v.PreviewImageSrc", imageSrc);
                                component.set("v.PreviewImageId", innerListValue[parseInt(j) + 1].contentDocumentId);
                                helper.setNextPreviousButton(component, event, helper);
                            }
                        }
                    }
                }
            }
        } catch (error) {
            console.log('error in changeImageHelper: ', error.stack);
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
