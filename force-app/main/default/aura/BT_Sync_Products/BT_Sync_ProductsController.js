({
    doInit : function(component, event, helper) {
        var action = component.get("c.getQuoteLineRecordList");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS') {
                var QuoteLineList = response.getReturnValue();
                console.log('QuoteLine_modified ',QuoteLineList);
                component.set("v.quoteLineList", QuoteLineList);
                // console.log(' QuoteLine-->',JSON.parse(JSON.stringify(component.get("v.quoteLineList"))));
                var QuoteLine_modified = QuoteLineList;
                for(var item of QuoteLine_modified){
                    item.value = '';
                    console.log(item);
                }
                component.set('v.QuoteLine_modified', QuoteLine_modified);
                console.log('QuoteLine_modified >. ', JSON.parse(JSON.stringify(component.get("v.QuoteLine_modified"))));
            }
        });
        $A.enqueueAction(action);
    },
    closeModel : function (component,event,helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    editProduct: function(component, event, helper) {
        var Id=  event.currentTarget.dataset.iconattr;
        console.log('id-->',Id);
        component.set("v.selectedRecId", Id); 
        component.set('v.displayProduct', false);
        component.set("v.isFieldDisabled", false);
        console.log(component.get("v.selectedRecId"));

    },
    save:function(component, event, helper) {
        var Id=  event.currentTarget.dataset.value;
        console.log('id New-->',Id);

    },
    clickHandlerProduct: function(component, event, helper){
        try{

            console.log("Select Product---->");
            var prodName = '';
            component.set('v.displayProduct', false);   
            var recordId = event.currentTarget.dataset.value;
            console.log('clickHandlerProduct---->',recordId);
            var qutLineId =  component.get("v.selectedRecId");
    
            console.log('clickHandlerProduct---->',qutLineId);
            // component.set('v.selectedProductId', recordId);
            var productList = component.get("v.productList");
            var QuoteLine_modified = component.get('v.QuoteLine_modified');
           
            productList.forEach(element => {
                if (recordId == element.Id) {
                    prodName = element.Name;
                    component.set('v.selectedProductId', element.Id);
                    component.set('v.selectedProductName', element.Name);
                    console.log('idd --> ', qutLineId);
                    QuoteLine_modified.forEach(ele => {
                        // console.log("aq" , ele.Id);
                        if(ele.Id == qutLineId){
                            console.log('indise >> ');
                            ele.value = element.Name;
                        }
                    })
                    console.log('after select product >> ', JSON.parse(JSON.stringify(QuoteLine_modified)));
                    console.log('QuoteLine_modified------9090909 >. ', component.get('v.QuoteLine_modified'));
                }
            });
            var productId = recordId; 
            console.log("INPUT Name--->", prodName);
        }
        catch(error){
            console.log('error in click >> ', error.stack);
        }
    },
    searchProductData: function(component, event, helper) {
        console.log("Search for Product---->");
        component.set('v.displayProduct', true);
        var searchFilter = '';
        console.log('id ==> ', event.getSource().get("v.id"));
        helper.getPricebooksProduct(component, event, helper, searchFilter);
        // event.stopPropagation();
    },
    keyupProductData:function(component, event, helper) {
        console.log("Search Enterd prod NAme---->");
        component.set('v.displayProduct', true);

            var allRecords = component.get("v.productList");
            var searchFilter = event.getSource().get("v.value").toUpperCase();
            var tempArray = [];
            var i;
            for (i = 0; i < allRecords.length; i++) {
                if ((allRecords[i].Name && allRecords[i].Name.toUpperCase().indexOf(searchFilter) != -1)) {
                    tempArray.push(allRecords[i]);
                }else{
                    component.set('v.selectedProductId' , ' ')
                }
            }
            component.set("v.productList", tempArray);
            helper.getPricebooksProduct(component, event, helper , searchFilter);
    },
    hideList : function(component, event, helper) {
        console.log("Method Called");
        component.set('v.displayProduct', false);
    }

    
})