public without sharing class RequestInvoicePageController{
    public string companycurrency {get;set;}

    public boolean multicurrency {get;set;}

    public string purchaseOrderId{ get; set; }

    public Boolean isErrorMessage{ get; set; }

    public String errorMessage{ get; set; }

    public Boolean isReload{ get; set; }

    public buildertek__Purchase_Order__c purchaseOrderRecord{ get; set; }

    public List<buildertek__Purchase_Order_Item__c> poLineRecord{ get; set; }

    public RequestInvoicePageController(){
        isErrorMessage = false;
        errorMessage = '';
        companycurrency = UserInfo.getDefaultCurrency();
        multicurrency = UserInfo.isMultiCurrencyOrganization();
        purchaseOrderId = ApexPages.currentPage().getParameters().get('Id').escapeHtml4();
        purchaseOrderRecord = new buildertek__Purchase_Order__c();
        poLineRecord = new List<buildertek__Purchase_Order_Item__c>();
        try{

            String queryPO = 'Select Name, buildertek__Project__c, buildertek__Project__r.Name, buildertek__Vendor__c, buildertek__Vendor__r.Name, buildertek__PO_Total__c, buildertek__Description__c From buildertek__Purchase_Order__c Where ID =:purchaseOrderId Limit 1';
            purchaseOrderRecord = Database.query(queryPO);

            String queryPOItem = 'Select Name, buildertek__Product__c, buildertek__Product__r.Name, buildertek__Description__c, buildertek__Quantity__c, buildertek__Unit_Price__c, buildertek__Total_Price__c From buildertek__Purchase_Order_Item__c Where buildertek__Purchase_Order__c =:purchaseOrderId Order by Name';
            poLineRecord = Database.query(queryPOItem);

        } catch (Exception ex){
            System.debug('linenumber--->'+ex.getLineNumber());
            System.debug('message------>'+ex.getMessage());
            throw ex;
        }
    }




    public void submintQuote(){
    
    }

}