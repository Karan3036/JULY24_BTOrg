({
    doInit: function (component, event, helper) {
        var recordId = component.get("v.recordId");
        helper.loadTasks(component, recordId);
    },
    Filter: function(component) {
        var vendorId = Object.keys(JSON.parse(JSON.stringify(component.get("v.selectedVendor")))) ? JSON.parse(JSON.stringify(component.get("v.selectedVendor"))).Id : '';
        var recordId = component.get("v.recordId");
        helper.FieterTaskWithVendorNameAndCurrentProject(component, recordId, vendorId);
    }
})