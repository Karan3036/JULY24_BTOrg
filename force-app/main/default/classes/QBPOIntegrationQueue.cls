public with sharing class QBPOIntegrationQueue {

    @future(callout=true)
    public static void QB_PO_Flow_Callout(Id accountId){
        try {
            Account acc = new Account();
            acc = [SELECT ID, Name,buildertek__Email_Address__c,Fax,buildertek__QBO_ID__c, buildertek__QB_Record_URL__c, buildertek__QBO_SyncToken__c, Description,ShippingCity,ShippingStreet,ShippingState,ShippingPostalCode,ShippingLatitude,ShippingLongitude,ShippingCountry,Phone,BillingCity,BillingStreet,BillingState,BillingPostalCode,BillingLatitude,BillingLongitude,BillingCountry FROM Account WHERE Id =: accountId limit 1];

            buildertek__QuickBooks_Setting__mdt QBMetadata = [SELECT Id, DeveloperName,buildertek__Base_Url__c, buildertek__minorversion__c, MasterLabel, buildertek__Access_Token__c, buildertek__Client_Id__c, buildertek__Client_Secret__c, buildertek__Refresh_Token__c, buildertek__Qb_URL__c, buildertek__Scope__c, buildertek__Company_Id__c FROM buildertek__QuickBooks_Setting__mdt LIMIT 1];
            
            Boolean Get_Access_Token = false;

            if(acc.buildertek__QBO_ID__c == null){
                Create_Vendor_in_QB(acc, QBMetadata, Get_Access_Token, 'buildertek__Purchase_Order__c');  // Last Parameter(SyncObjName) defines Which Objcet We are going to Create In QB.....
            }
            // else{
            //     String CustomerQBId = acc.buildertek__QBO_ID__c;
            //     System.debug('Customer Available in QB');
            //     if(SI.buildertek__Tax_Rate__c != null && (SI.buildertek__QBO_Tax_Rate_ID__c == null || SI.buildertek__Tax_Rate__c != SI.buildertek__QBO_Tax_Rate__c)){
            //         Create_TaxRate_item_invoice_payment_in_QB(SILines, SI, CustomerQBId, QBMetadata, Get_Access_Token, receiptID, Create_Payment);
            //     }
            //     else{
            //         System.debug('Tax rate not available for Invoice');
            //         String taxCodeId;
            //         double taxRateValue;
            //         if(SI.buildertek__Tax_Rate__c == null){
            //             taxCodeId = null;
            //             taxRateValue = null;
            //         }
            //         else if(SI.buildertek__QBO_Tax_Rate_ID__c != null && SI.buildertek__Tax_Rate__c == SI.buildertek__QBO_Tax_Rate__c){
            //                 taxCodeId = SI.buildertek__QBO_Tax_Rate_ID__c;
            //                 taxRateValue = SI.buildertek__QBO_Tax_Rate__c;
            //         }

            //         if(SI.buildertek__Terms__c != null){
            //             // Create invoic With Term...
            //             Create_Term_item_invoice_payment_in_QB(SILines, SI, CustomerQBId, QBMetadata, Get_Access_Token, receiptID, Create_Payment, taxCodeId, taxRateValue);
            //         }
            //         else{
            //             // Create Invoice without Term...
            //             String  TermQBId = null;
            //             if(SILines.size() > 0){
            //                 // items - invoice - PAYMENT
            //                 Create_item_invoice_Payment_in_QB(SILines, SI, CustomerQBId, QBMetadata, Get_Access_Token, receiptID, Create_Payment, taxCodeId, taxRateValue, TermQBId);
            //             }
            //         }
            //     }

            // }

        } catch (Exception e) {
            System.debug('Error in QB_PO_Flow_Callout ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }

    }

    public static void Create_Vendor_in_QB(Account acc, buildertek__QuickBooks_Setting__mdt QBMetadata, Boolean Get_Access_Token, String SyncObjName){
        try {
            String Customer_EndPoint = '/v3/company/' + QBMetadata.buildertek__Company_Id__c + '/vendor?minorversion=' + QBMetadata.buildertek__minorversion__c;            
            String Customer_RequestBody = QBMap.mapVendorAccountData(acc, 1);
            system.debug('JSON Body >>' +  Customer_RequestBody);
            HttpResponse Customer_Response = QBCallOutService.QBAPICallOut(Customer_EndPoint , Customer_RequestBody, Get_Access_Token);
            system.debug('Customer API Status Code >> ' + Customer_Response.getStatusCode());
            System.debug('Customer_Response.getBody() :: '+ Customer_Response.getBody());
            if(Customer_Response.getStatusCode() == 200){
                QBVendorResponseJSON Customer_Response_Deser = QBVendorResponseJSON.parse(Customer_Response.getBody());
                QBVendorResponseJSON.Vendor customer = new QBVendorResponseJSON.Vendor();
                customer = Customer_Response_Deser.Vendor;
                String CustomerQBId = customer.Id;
                String SyncToken = customer.SyncToken;

                if(SyncObjName == 'buildertek__Purchase_Order__c'){
                    // Create Purchase Order In QB
                    // Run Purchase Order Integartion Logic
                }
                else if(SyncObjName == 'buildertek__Account_Payable__c'){
                    // Create Contractor Invoice (Bill) In QB
                    // Run Contractor Invoice Integartion Logic
                }
                else if(SyncObjName == 'buildertek__Account_Payable_Clone__c'){
                    // Create Payable Invoice(Bill) In QB
                    // Run Payable Invoice Integartion Logic
                }
                // Create_TaxRate_item_invoice_payment_in_QB(SILines, SI, CustomerQBId, QBMetadata, Get_Access_Token, receiptID, Create_Payment);
                UpdateAccount(acc.Id, CustomerQBId, QBMetadata, SyncToken);
            }
            else{
                QBException.QB_response( Customer_Response.getStatusCode(),  Customer_Response.getBody(), 'QBPOIntegrationQueue', 'Create_Vendor_in_QB');
            }
            
        } catch (Exception e) {
            System.debug('Error in Create_Vendor_in_QB ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }
    }

    public static void UpdateAccount(String acc_Id, String QB_Id , buildertek__QuickBooks_Setting__mdt  QBMetadata, String SyncToken){
        try {
            system.debug('Account going to Update');
            String qbCustomerURL = QBMetadata.buildertek__Qb_URL__c + 'vendordetail?nameId=' + QB_Id;
            Account Acc = [SELECT Id,Name, buildertek__QBO_ID__c,buildertek__QB_Record_URL__c  FROM Account WHERE Id =: acc_Id LIMIT 1];
            Acc.buildertek__QBO_ID__c = QB_Id;
            Acc.buildertek__QB_Record_URL__c = qbCustomerURL;
            Acc.buildertek__QBO_SyncToken__c = SyncToken;
            update Acc;
        
        } catch (Exception e) {
            System.debug('Error in UpdateAccount : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }
    }
}