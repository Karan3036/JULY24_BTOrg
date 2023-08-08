({
   doInit : function(component, event, helper) {
       helper.doInitHelper(component, event, helper)
   }, 

   closeCmp : function(component, event, helper) {
       component.set("v.openProductBox", false);
    //    $A.get("e.force:closeQuickAction").fire() 

   }, 

   changePricebook: function(component, event, helper) {
     var selectedPricebook = component.find("selectedPricebook").get("v.value");
       helper.changePricebookHelper(component, event, helper , selectedPricebook);
   },
   changeProductFamily: function(component, event, helper) {
    var selectedPricebook = component.find("selectedPricebook").get("v.value");
    var selectedProductFamily = component.find("selectedProductFamily").get("v.value");
      helper.changeProductFamilyHelper(component, event, helper , selectedPricebook, selectedProductFamily);
  },

   searchInDatatable: function(component, event, helper){
       helper.searchDatatableHelper(component, event, helper);
   }, 

   goToEditModal: function(component, event, helper) {
       helper.goToEditModalHelper(component, event, helper);
   },
   
   goToProductModal: function(component, event, helper) {
       var quoteLineList = component.get("v.quoteLineList");
       var checkAll = true;
       quoteLineList.forEach(element => {
           if (!element.Selected) {
               checkAll = false
           }
       });
       
    //    component.set("v.sProductFamily", '');
       component.set("v.sProductName", '');

       component.set("v.tableDataList", quoteLineList);
       component.set("v.selecteProducts", true);
       component.find("selectAll").set("v.checked", checkAll);
   },


   checkAllProduct: function(component, event, helper){
       var value = event.getSource().get("v.checked"); 
       var tableDataList = component.get("v.tableDataList");
       tableDataList.forEach(element => {
           element.Selected = value;
       });
       component.set("v.tableDataList", tableDataList);
   }, 

   checkboxChange : function(component, event, helper) {
       var tableDataList = component.get("v.tableDataList");
       var checkAll = true;
       tableDataList.forEach(element => {
           if (!element.Selected) {
               checkAll = false
           }
       });
       component.find("selectAll").set("v.checked", checkAll);
       var quoteLineList = component.get("v.quoteLineList");
        console.log('quoteLineList => ',{quoteLineList});
        var selectedProducts = [];
        var phaseValue= component.get('v.getPhase');
        //find No Grouping from quoteLineGroupOptions and store it's Id in noGroupingId
        var noGroupingId = '';
        var quoteLineGroupOptions = component.get("v.quoteLineGroupOptions");
        //iterate through quoteLineGroupOptions and find first No Grouping
        quoteLineGroupOptions.forEach(element => {
            if (element.key == 'No Grouping') {
                noGroupingId = element.value;
            }
        });
        quoteLineList.forEach(element => {
            console.log(phaseValue);
            console.log(phaseValue!= undefined);
            if(element.Selected){
                selectedProducts.push({
                    'Id':element.Id,
                    'Name': element.Name,
                    'buildertek__Unit_Price__c': element.UnitPrice,
                    'buildertek__Grouping__c': element.Phase ? element.Phase : noGroupingId,
                    'buildertek__Quantity__c': '1',
                    'buildertek__Additional_Discount__c': element.Discount ? element.Discount : 0,
                    'buildertek__Unit_Cost__c': element.UnitCost ? element.UnitCost : element.UnitPrice,
                    'buildertek__Markup__c': element.MarkUp ? element.MarkUp : 0,
                    'buildertek__Product__c': element.Id,
                    'buildertek__Size__c': element.Size,
                    'buildertek__Description__c': element.Description ? element.Description : element.Name,
                    'buildertek__Product_Family__c': element.Family ? element.Family : 'No Grouping',
                    'buildertek__UOM__c': element.QuantityUnitOfMeasure     //----

                })
                console.log('Quantity Unit Of Measure => ', element.QuantityUnitOfMeasure);
            }
            
        });
        console.log('selectedProducts => ',{selectedProducts});
        var try001 = component.set("v.trueCheckBoxList",selectedProducts);
        console.log('try001===>',{try001});


", checkAll);
   console.log('saveQuoteLine');
       var listQlines = component.get("v.selectedProducts");
       var flag=false;
       listQlines.forEach(function(elem){
        console.log({elem});
        console.log(elem.buildertek__Description__c);
            if(elem.buildertek__Description__c == '' || elem.buildertek__Description__c== undefined){
                flag=true;
            }
            
       });

       console.log({flag});
       if(listQlines.length > 0 && flag== false){
                var action10 = component.get("c.QuoteLinesInsert");
                action10.setParams({
                    "Quotelines": listQlines,
                    "QuoteId": component.get("v.quoteId")
                });

                action10.setCallback(this, function(response) {
                    console.log(response.getReturnValue());
                    component.set("v.openQuoteLineBox", false);
                    $A.get("e.force:refreshView").fire();
                    component.set("v.Spinner", false);
                    component.set("v.openProductBox", false);        
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Success',
                        message: 'Quote Lines are created successfully',
                        duration: ' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                });
                $A.enqueueAction(action10);

       }else if(flag){
                component.set("v.Spinner", false);
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Error',
                        message: 'Please select Description.',
                        duration: ' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
       }else{
        component.set("v.Spinner", false);

        var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Error',
                message: 'Please select at least one Product.',
                duration: ' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();

       }
       
   },
   removeQuoteLine:function(component, event, helper){
     var currentId=event.currentTarget.dataset.id;
     var productList=component.get('v.selectedProducts');
     var updatedList=[];
     productList.forEach(function(value){
        if(value.Id !== currentId){
            updatedList.push(value);
        }

     });
     component.set('v.selectedProducts' , updatedList);

     var quoteLineList = component.get("v.quoteLineList");
       quoteLineList.forEach(element => {
            if(element.Id === currentId){
                element.Selected=false;
            }
       });

   }

})