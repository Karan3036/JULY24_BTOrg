({
    // createPO : function(component, event, helper) {
    //     var action = component.get("c.Create_customer_item_po_in_QB_flow");
    //     action.setParams({
    //         recordId : component.get("v.recordId"),
    //         Objecttype : component.get("v.sobjecttype")
    //     });
        
    //     action.setCallback(this, function(response) {
    //         var state = response.getState();
    //         console.log('state ==> ' + state);
            
    //         if(state === "SUCCESS") {
    //             var result = response.getReturnValue();
    //             console.log('return value ==> '+ result);
    //             $A.get("e.force:closeQuickAction").fire();
    //             if(result == 'success'){
    //         		component.find('notifLib').showNotice({
    // 		            "variant": "success",
    // 		            "header": "Success",
    // 		            "message": "Completed",
    // 		        });    
    //             }else if(result == 'no_invoicelines') {
    //                 component.find('notifLib').showNotice({
    // 		            "variant": "error",
    // 		            "header": "Error",
    // 		            "message": 'There are no PO Line(s) associated with the PO.',
    // 		        });    
    //             }else if(result == 'no_customer_account'){
    //                 component.find('notifLib').showNotice({
    // 		            "variant": "error",
    // 		            "header": "Error",
    // 		            "message": 'There are no Vendor account associated with the PO.',
    // 		        });  
    //             }else{
    //                 component.find('notifLib').showNotice({
    // 		            "variant": "error",
    // 		            "header": "Error",
    // 		            "message": 'Something Went Wrong !!!',
    // 		        });  
    //             }
                
    //         }
    //     });
        
    //     $A.enqueueAction(action);	
    // },


    Post_Customer_vendor_ToQBHelper: function(component, event, helper){
        console.log("Inside Customer/Vendor Integration helper");
        var action = component.get("c.Create_Customer_or_Vendor_In_QB_AuraCallout");
        action.setParams({
            AccoountId : component.get("v.recordId"),
            AccountType : component.get("v.AccountType")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state ==> ' + state);
            var result = response.getReturnValue();
            console.log('result ==> ' + result);
        });

        $A.enqueueAction(action);
    },

})