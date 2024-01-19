({
    convertMapToList: function(map) {
        var list = [];
        for (var key in map) {
            if (map.hasOwnProperty(key)) {
                list.push({ key: key, value: map[key] });
            }
        }
        return list;
    },

    changeImageHelper: function(component, event, helper, imageId, next_previus_btn_click){
        // try {
            console.log('In changeImageHelper');
            event.stopPropagation();
            var operation;
            var imageId;
            if(next_previus_btn_click){
                // When Function called from Next/Previous Btn
                operation = event.currentTarget.dataset.name;
                imageId = component.get("v.PreviewImageId");
            }
            else{
                // When Function not called from Next/Previous Btn
                // To set Next/Previous Btn Visibility
                operation = null;
                imageId = imageId;
            }

            const div = document.getElementById(imageId);  // This Div use to check-in's Id, contentDocument Id, etc
            const checkIns = component.get('v.contentDocsList');
            console.log('checkIns--->',checkIns);

            checkIns.forEach(checkIn =>{
                if(checkIn.Id == div.dataset.cid){
                    for(var j = 0; j< checkIn.ContentDocumentLinks.length; j++){
                        if(j == div.dataset.cdlindex && checkIn.ContentDocumentLinks[j].Id == div.dataset.cdid){
                            
                            if(next_previus_btn_click == true){
                                // Main Next/Previous Logic
                                if(operation == 'Previous_Image'){
                                    console.log('Previous_Image');
                                    var imageSrc = '/sfc/servlet.shepherd/document/download/' + checkIn.ContentDocumentLinks[j - 1].ContentDocumentId;
                                    var imageTitle = checkIn.ContentDocumentLinks[j - 1].ContentDocument.Title;
                                    var imageId = checkIn.ContentDocumentLinks[j - 1].ContentDocumentId;
                                    helper.changeImageHelper(component, event, helper, imageId, false);  // To set Visibilti of Next - Previuos button for First & last img
                                    helper.openCustomPreviewHelper(component, event, helper, imageSrc, imageTitle, imageId);    // reopen preview div to call 'onload' and 'onerror' method for image
                                }
                                else if(operation == 'Next_Image'){
                                    console.log('Next_Image');
                                    var imageSrc = '/sfc/servlet.shepherd/document/download/' + checkIn.ContentDocumentLinks[j + 1].ContentDocumentId;
                                    var imageTitle = checkIn.ContentDocumentLinks[j + 1].ContentDocument.Title;
                                    var imageId = checkIn.ContentDocumentLinks[j + 1].ContentDocumentId;
                                    helper.changeImageHelper(component, event, helper, imageId, false);  // To set Visibilti of Next - Previuos button for First & last img
                                    helper.openCustomPreviewHelper(component, event, helper, imageSrc, imageTitle, imageId);    // reopen preview div to call 'onload' and 'onerror' method for image
                                }
                            }
                            else if(next_previus_btn_click == false){
                                // To set Next/Previous Button Visibility for First & last Image
                                if(j == 0){
                                    console.log('First_Img');
                                    component.set("v.NotFirstImg", false);
                                }
                                else if(j != 0){
                                    component.set("v.NotFirstImg", true);
                                }
                                if(j == (checkIn.ContentDocumentLinks.length - 1)){
                                    component.set("v.NotLastImg", false);
                                    console.log('Last_Img');
                                }
                                else if(j != (checkIn.ContentDocumentLinks.length - 1)){
                                    component.set("v.NotLastImg", true);
                                }
                            }
                            
                        }
                    }
                }
            })
            
        // } catch (error) {
        //     console.log('error >> ', error.stack);
        // }
    },

    openCustomPreviewHelper: function(component, event, helper, imageSrc, imageTitle, imageId){
        component.set("v.PreviewImageSrc", imageSrc);
        component.set("v.PreviewImageTitle", imageTitle);
        component.set("v.PreviewImageId", imageId);
        console.log(component.get("v.orgBaseURL"));
        console.log('imgSRC > ', imageSrc);


        component.set("v.PreviewImgSpinner", true);
        component.set("v.Is_ImageHavePreview", true);
        component.set('v.Show_ImagePreview', true);

    },

})
