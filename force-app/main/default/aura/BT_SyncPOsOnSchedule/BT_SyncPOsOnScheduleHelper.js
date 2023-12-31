({
    getAllScheduleItems: function (component, event, helper) {
        let action = component.get("c.fetchScheduleItem");
        let recordId = component.get("v.recordId");
        action.setParams({
            "scheduleId": recordId,
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.scheduleItemList", response.getReturnValue());
                console.log('scheduleItemList: ' + JSON.stringify(response.getReturnValue()));
            } else {
                let error = response.getError();
                console.log('Error =>', { error });
                showToast('Error', 'Error', 'Something Went Wrong', '3000');
            }
        });
        $A.enqueueAction(action);
    },

    getAllPOs: function (component, event, helper) {
        component.set("v.spinner", true);
        let action = component.get("c.fetchAllPOs");
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let result = response.getReturnValue();
                result.forEach(po => {
                    po.isDisabled = false;
                });

                component.set("v.poList", result);
                console.log('PO List: ' + JSON.stringify(result));
            } else {
                let error = response.getError();
                console.log('Error =>', { error });
                showToast('Error', 'Error', 'Something Went Wrong', '3000');
            }
        });
        setTimeout(function () {
            component.set("v.spinner", false);
        }, 3000);
        $A.enqueueAction(action);
    },

    showToast: function (type, title, message, time) {
        try {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": title,
                "type": type,
                "message": message,
                "duration": time
            });
            toastEvent.fire();
        } catch (error) {
            console.log({ error });
        }
    },

    saveSchedulePO: function (component, event, helper) {
        let selectedPOItems = component.get("v.selectedPOItems");
        let jsonSchedulePO = JSON.stringify(selectedPOItems);
        let action = component.get("c.setPOForScheduleItem");
        action.setParams({
            "schedulePO": jsonSchedulePO,
            "scheduleId": component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let result = response.getReturnValue();
                console.log('result: ' + JSON.stringify(result));
                helper.showToast('success', 'Success', 'POs are successfully synced', '3000');
                $A.get("e.force:closeQuickAction").fire();
            } else {
                let error = response.getError();
                console.log('Error =>', { error });
                helper.showToast('Error', 'Error', 'Something Went Wrong', '3000');
            }
            if (callback && typeof callback === "function") {
                callback();
            }
        });
        $A.enqueueAction(action);
    }
})