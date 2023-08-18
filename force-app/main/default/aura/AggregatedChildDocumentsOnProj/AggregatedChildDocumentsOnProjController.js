({
    doInit : function(component, event, helper) {

        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();

       

        var action=component.get('c.getChildObectName');
        action.setParams({
            "projectId": component.get('v.recordId'),
        });
        action.setCallback(this, function (response) {
            console.log(response.getError());            
            let state=response.getState();
            if(state == 'SUCCESS'){
                let result=response.getReturnValue();
                console.log(result);
                component.set('v.objectNameList' ,result );

            }
            

            $A.get("e.c:BT_SpinnerEvent").setParams({
                "action": "HIDE"
            }).fire();
        });
        $A.enqueueAction(action);

    },
    handleSectionToggle: function(component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();

        console.log("active sections name: ", component.find("accordion").get('v.activeSectionName'));
        var getSectionName=component.find("accordion").get('v.activeSectionName');
        if(getSectionName != undefined && getSectionName != ''){
            var action = component.get("c.getAttachement");
            action.setParams({
                "objectName": getSectionName,
            });
            action.setCallback(this, function (response) {
                console.log(response.getError());            
                let state=response.getState();
                if(state == 'SUCCESS'){
                    let result=response.getReturnValue();
                    console.log(result);
                    component.set('v.attachmentData' , result);
    
                }
                
    
                $A.get("e.c:BT_SpinnerEvent").setParams({
                    "action": "HIDE"
                }).fire();
            });
            $A.enqueueAction(action);
        }

       
    

    },
    openRecordPage: function(component, event, helper) {
        var recordId = event.currentTarget.dataset.recordId;
        
        var navService = component.find("navService");
        var pageReference = {
            type: "standard__recordPage",
            attributes: {
                recordId: recordId,
                actionName: "view"
            }
        };
        navService.navigate(pageReference);
    }
})