public without sharing class RequestInvoicePageController{
    public string companycurrency {get;set;}

    public boolean multicurrency {get;set;}

    public string purchaseOrderId{ get; set; }

    public Boolean isErrorMessage{ get; set; }

    public String errorMessage{ get; set; }

    public Boolean isReload{ get; set; }

    public buildertek__Purchase_Order__c purchaseOrderRecord{ get; set; }

    public List<buildertek__Purchase_Order_Item__c> poLineRecord{ get; set; }

    public String latestFileName { get; set; }

    public String fileContents { get; set; }

    public String fileType { get; set; }

    public Integer fileSize { get; set; }

    public Boolean successMessageVisible { get; set; }

    public Boolean errorMessageVisible { get; set; }

    public Boolean isModalVisible { get; set; }

    public String modalTitle { get; set; }

    public String modalMessage { get; set; }

    public String modalButtonLabel { get; set; }

    public Boolean ShowSubmitButton { get; set; }

    public RequestInvoicePageController(){
        isErrorMessage = false;
        errorMessage = '';
        companycurrency = UserInfo.getDefaultCurrency();
        multicurrency = UserInfo.isMultiCurrencyOrganization();
        purchaseOrderId = ApexPages.currentPage().getParameters().get('Id').escapeHtml4();
        purchaseOrderRecord = new buildertek__Purchase_Order__c();
        poLineRecord = new List<buildertek__Purchase_Order_Item__c>();
        ShowSubmitButton = false;
        try{

            String queryPO = 'Select Name, buildertek__Project__c, buildertek__Project__r.Name, buildertek__Vendor__c, buildertek__Vendor__r.Name, buildertek__PO_Total__c, buildertek__Description__c From buildertek__Purchase_Order__c Where ID =:purchaseOrderId Limit 1';
            purchaseOrderRecord = Database.query(queryPO);

            String queryPOItem = 'Select Name, buildertek__Product__c, buildertek__Product__r.Name, buildertek__Description__c, buildertek__Quantity__c, buildertek__Unit_Price__c, buildertek__Total_Price__c From buildertek__Purchase_Order_Item__c Where buildertek__Purchase_Order__c =:purchaseOrderId Order by Name';
            poLineRecord = Database.query(queryPOItem);

            successMessageVisible = false;
        errorMessageVisible = false;

        } catch (Exception ex){
            System.debug('linenumber--->'+ex.getLineNumber());
            System.debug('message------>'+ex.getMessage());
            throw ex;
        }
    }

    public void uploadFileToPurchaseorder(){
        isErrorMessage = false;
        errorMessage = '';
        try {
            fileContents = Apexpages.currentpage().getparameters().get('secondParam');
            fileContents = EncodingUtil.urlDecode(fileContents, 'UTF-8');
            Blob blobValue = EncodingUtil.base64Decode(fileContents);
            String attachmentBody = EncodingUtil.base64Encode(blobValue);

            ContentVersion contentToInsert =new ContentVersion();
            contentToInsert.Title =EncodingUtil.urlDecode(latestFileName, 'UTF-8');
            contentToInsert.VersionData = EncodingUtil.base64Decode(attachmentBody);
            contentToInsert.PathOnClient='/' + EncodingUtil.urlDecode(latestFileName, 'UTF-8') ;
            contentToInsert.IsMajorVersion = false;
            insert contentToInsert;

            contentToInsert = [select id, ContentDocumentId from ContentVersion WHERE Id =: contentToInsert.Id];
            ContentDocumentLink cl = new ContentDocumentLink();
            cl.ContentDocumentId = contentToInsert.ContentDocumentId;
            cl.LinkedEntityId = purchaseOrderId;
            cl.ShareType = 'V';
            cl.Visibility = 'AllUsers';
            insert cl;
            handleSuccess();
        } catch (Exception ex) {
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(ex);
            }
            handleError(ex.getMessage());
        }
    }

    public void handleSuccess() {
        // Set modal properties
        modalTitle = 'Success';
        modalMessage = 'File uploaded successfully.';
        modalButtonLabel = 'Close';
        isModalVisible = true;
        ShowSubmitButton = true;
        isErrorMessage = true;
        errorMessage = 'Invoice Uploaded Successfully!';
    }

    // Method to handle upload error
    public void handleError(String errorMessage) {
        // Set modal properties
        modalTitle = 'Error';
        modalMessage = errorMessage;
        modalButtonLabel = 'Close';
        isModalVisible = true;
    }

}