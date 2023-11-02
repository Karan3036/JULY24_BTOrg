({
    loadTasks: function (component, recordId) {
        var action = component.get("c.gettaskOfSchedules");
        action.setParams({ "recordId": recordId });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var tasks = response.getReturnValue();
                console.log('tasks---->', tasks);
                component.set("v.tasks", tasks);
                this.filterTasks(component);
            } else {
                console.log("Error: " + response.getError());
            }
        });

        $A.enqueueAction(action);
    },

    filterTasks: function (component) {
        try {
            // var tasks = component.get("v.tasks");
            // var today = new Date();
            // var thisWeekStart = new Date(today);
            // thisWeekStart.setDate(today.getDate() - today.getDay()); // Start of the week (Sunday)
            // var thisWeekEnd = new Date(thisWeekStart);
            // thisWeekEnd.setDate(thisWeekStart.getDate() + 6); // End of the week (Saturday)

            // // Implement the logic to filter tasks into Past Due, Due This Week, and Due Next Week
            // var pastDueTasks = tasks.filter(task => new Date(task.buildertek__Finish__c) < today);
            // var dueThisWeekTasks = tasks.filter(task => new Date(task.buildertek__Finish__c) >= thisWeekStart && new Date(task.buildertek__Finish__c) <= thisWeekEnd);
            // var nextWeekStart = new Date(thisWeekEnd);
            // nextWeekStart.setDate(thisWeekEnd.getDate() + 1); // Start of next week (Sunday)
            // console.log('nextWeekStart--->',nextWeekStart);
            // var nextWeekEnd = new Date(nextWeekStart);
            // nextWeekEnd.setDate(nextWeekStart.getDate() + 6); // End of next week (Saturday)
            // console.log('nextWeekEnd--->',nextWeekEnd);
            // var finish = new Date(tasks[0].buildertek__Finish__c);
            // console.log('finishdate--->',finish);
            // var dueNextWeekTasks = tasks.filter(task => new Date(task.buildertek__Finish__c) >= nextWeekStart && new Date(task.buildertek__Finish__c) <= nextWeekEnd);

            // component.set("v.pastDueTasks", pastDueTasks);
            // component.set("v.dueThisWeekTasks", dueThisWeekTasks);
            // component.set("v.dueNextWeekTasks", dueNextWeekTasks);

            var tasks = component.get("v.tasks");
            // var tasks= [];
            // taskList.forEach(function(task) {
            //     if (task.Name.length > 18) {
            //         console.log('IN IF CONDITION');
            //         task.Name = task.Name.slice(0,18)+'...';
            //         tasks.push(task);
            //     }else{
            //         task.Name = task.Name;
            //         tasks.push(task);
            //     }
            // });
            var today = new Date();
            today.setHours(0, 0, 0, 0); // Set the time to midnight

            var thisWeekStart = new Date(today);
            thisWeekStart.setDate(today.getDate() - today.getDay()); // Start of the week (Sunday)
            thisWeekStart.setHours(0, 0, 0, 0); // Set the time to midnight

            var thisWeekEnd = new Date(thisWeekStart);
            thisWeekEnd.setDate(thisWeekStart.getDate() + 6); // End of the week (Saturday)
            thisWeekEnd.setHours(23, 59, 59, 999); // Set the time to 23:59:59.999

            // Implement the logic to filter tasks into Past Due, Due This Week, and Due Next Week
            var pastDueTasks = tasks.filter(task => new Date(task.buildertek__Finish__c) < thisWeekStart);
            var dueThisWeekTasks = tasks.filter(task => {
                var taskDate = new Date(task.buildertek__Finish__c);
                return taskDate >= thisWeekStart && taskDate <= thisWeekEnd;
            });

            var nextWeekStart = new Date(thisWeekEnd);
            nextWeekStart.setDate(thisWeekEnd.getDate() + 1); // Start of next week (Sunday)
            nextWeekStart.setHours(0, 0, 0, 0); // Set the time to midnight

            var nextWeekEnd = new Date(nextWeekStart);
            nextWeekEnd.setDate(nextWeekStart.getDate() + 6); // End of next week (Saturday)
            nextWeekEnd.setHours(23, 59, 59, 999); // Set the time to 23:59:59.999

            var dueNextWeekTasks = tasks.filter(task => {
                var taskDate = new Date(task.buildertek__Finish__c);
                return taskDate >= nextWeekStart && taskDate <= nextWeekEnd;
            });

            component.set("v.pastDueTasks", pastDueTasks);
            component.set("v.dueThisWeekTasks", dueThisWeekTasks);
            component.set("v.dueNextWeekTasks", dueNextWeekTasks);

        } catch (error) {
            console.log('error--->',error);
        }
    },
    FieterTaskWithVendorNameAndCurrentProject: function(component,recordId, vendorId) {
        console.log("METHOD");
        var action = component.get("c.getTaskDataByVendorAndProject");
        action.setParams({
            "recordId": recordId,
            "vendorId" : vendorId
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var tasks = response.getReturnValue();
                console.log('tasks---->', tasks);
                component.set("v.tasks", tasks);
                this.filterTasks(component);
            } else {
                console.log("Error: " + response.getError());
            }
        });

        $A.enqueueAction(action);
        helper.filterTasks(component);
    }
})