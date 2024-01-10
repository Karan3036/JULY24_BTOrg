({
	getPayableInvoiceInfo: function (component, event, helper, parentRecordId) {
		var action = component.get("c.getPayableInfo")
		action.setParams({
			recordId: component.get("v.recordId")
		});
		action.setCallback(this, function (response) {
			if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
				component.set("v.Spinner", false);
				var customerId = response.getReturnValue();
				component.set("v.customerId", customerId);
				console.log('customerId-->>',component.get("v.customerId"));
			}
		});
		$A.enqueueAction(action); 
	},

	setupListofPOItem: function (component, event, helper) {
		var listofPOItems = [];
		for (var i = 1; i < 2; i++){
			listofPOItems.push({
				'index': i,
				'Name': '',
				'buildertek__Quantity__c': '',
				'buildertek__Unit_Price__c': '',
		});
		}
		console.log('listofPOItems-->>',{listofPOItems});
		component.set("v.listofPOItems", listofPOItems);
	},

	savePOLineItems : function(component, event, helper, recordId) {
		var listofPOItems = component.get("v.listofPOItems");
		var listofPOItemsToSave = [];
		for (var i = 0; i < listofPOItems.length; i++){
			if (listofPOItems[i].Name != '' && listofPOItems[i].buildertek__Quantity__c != '' && listofPOItems[i].buildertek__Unit_Price__c != '') {
				// listofPOItemsToSave.push(listofPOItems[i]);
				let poLineObj = {
					'Name' : listofPOItems[i].Name,
					'buildertek__Quantity__c' : listofPOItems[i].buildertek__Quantity__c,
					'buildertek__Unit_Price__c' : listofPOItems[i].buildertek__Unit_Price__c
				}
				listofPOItemsToSave.push(poLineObj);
			}
		}
		console.log('listofPOItemsToSave-->>',{listofPOItemsToSave});
		console.log('recordId-->>',{recordId});
		debugger;
		var action6 = component.get("c.savePOLineItems");
		action6.setParams({
			listofPOItemsToSave: listofPOItemsToSave,
			recordId: recordId
		});
		action6.setCallback(this, function (response) {
			console.log('callback');
			if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
				console.log('inserted')
			}
		});
		$A.enqueueAction(action6);
	},


})