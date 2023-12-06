({
    doInit : function(component, event, helper) {
        var id = component.get("v.recordId");
        console.log(id);

        var Objectname = component.get("v.sobjecttype");
        console.log('Objectname---> ',Objectname);

        if(Objectname == "Account"){
            component.set("v.ShowAccountTypeOpt", true);
        }

        if (Objectname == 'buildertek__Purchase_Order__c') {
            // helper.createPO(component, event, helper);
        }
    },

    handleRecordLoaded: function(component, event, helper) {

        console.log(component.get("v.BTAccountType.buildertek__BT_Account_Type__c"));
        var BTAccountType = component.get("v.BTAccountType")["buildertek__BT_Account_Type__c"];
        if(BTAccountType == "Customer" || BTAccountType == "Vendor"){
            component.set("v.AccountType", BTAccountType)
        }

      },

    handleChangeAccountType: function(component, event, helper){
        var auraIdField = event.getSource().getLocalId();

        console.log('Selected account type : ',component.find(auraIdField).get("v.value"));

        component.set("v.AccountType",component.find(auraIdField).get("v.value"));
    },

    PostAccountToQuickbook: function(component, event, helper){
        var accountType = component.get("v.AccountType");
        if(accountType == 'Customer' || accountType == 'Vendor'){
            component.set("v.ShowAccountTypeOpt", false);
            helper.Post_Customer_vendor_ToQBHelper(component, event, helper);
        }
        else{
            component.find('notifLib').showNotice({
                "variant": "error",
                "header": "Error",
                "message": 'Please Select at least on Account Type!',
            });    
        }
    },

    CloseQuickAction: function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    },

})