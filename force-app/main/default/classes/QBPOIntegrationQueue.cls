public with sharing class QBPOIntegrationQueue {

    @future(callout=true)
    public static void QB_PO_Flow_Callout(Id recordId){
        try {
            buildertek__Purchase_Order__c PO = [SELECT Id, Name, buildertek__Vendor__c,buildertek__QBO_ID__c,buildertek__QBO_SyncToken__c,buildertek__Project__r.buildertek__Customer__c,buildertek__PO_Total__c,buildertek__Tax_Amount__c FROM buildertek__Purchase_Order__c WHERE Id =: recordId LIMIT 1];
            Account acc = new Account();
            if(PO.buildertek__Vendor__c != null){
                acc = [SELECT ID, Name,buildertek__Email_Address__c,Fax,buildertek__QBO_ID__c, buildertek__QB_Record_URL__c, buildertek__QBO_SyncToken__c, Description,ShippingCity,ShippingStreet,ShippingState,ShippingPostalCode,ShippingLatitude,ShippingLongitude,ShippingCountry,Phone,BillingCity,BillingStreet,BillingState,BillingPostalCode,BillingLatitude,BillingLongitude,BillingCountry FROM Account WHERE Id =: PO.buildertek__Vendor__c limit 1];
            }
            else if(PO.buildertek__Vendor__c == null){
                system.debug('Project Id ' + PO.buildertek__Project__r.buildertek__Customer__c);
                acc = [SELECT ID, Name,buildertek__Email_Address__c,Fax,buildertek__QBO_ID__c, buildertek__QB_Record_URL__c, buildertek__QBO_SyncToken__c, Description,ShippingCity,ShippingStreet,ShippingState,ShippingPostalCode,ShippingLatitude,ShippingLongitude,ShippingCountry,Phone,BillingCity,BillingStreet,BillingState,BillingPostalCode,BillingLatitude,BillingLongitude,BillingCountry FROM Account WHERE Id =: PO.buildertek__Project__r.buildertek__Customer__c limit 1];
            }
            List<buildertek__Purchase_Order_Item__c> POLines = [SELECT Id, Name, buildertek__Purchase_Order__c,buildertek__Purchase_Order__r.Name,buildertek__Total_Price__c,buildertek__Item_Name__c,buildertek__Quantity__c,buildertek__QBO_ID__c,buildertek__QBO_Name__c,buildertek__QBO_SyncToken__c,buildertek__Description__c,buildertek__Unit_Price__c FROM buildertek__Purchase_Order_Item__c WHERE buildertek__Purchase_Order__c =: recordId];

            buildertek__QuickBooks_Setting__mdt QBMetadata = [SELECT Id, DeveloperName,buildertek__Base_Url__c, buildertek__minorversion__c, MasterLabel, buildertek__Access_Token__c, buildertek__Client_Id__c, buildertek__Client_Secret__c, buildertek__Refresh_Token__c, buildertek__Qb_URL__c, buildertek__Scope__c, buildertek__Company_Id__c FROM buildertek__QuickBooks_Setting__mdt LIMIT 1];
            
            Boolean Get_Access_Token = false;

            Create_Vendor_in_QB(POLines, PO, acc, QBMetadata, Get_Access_Token);

        } catch (Exception e) {
            System.debug('Error in QB_PO_Flow_Callout ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }

    }

    public static void Create_Vendor_in_QB(List<buildertek__Purchase_Order_Item__c> POLines, buildertek__Purchase_Order__c PO,Account acc, buildertek__QuickBooks_Setting__mdt QBMetadata, Boolean Get_Access_Token){
        try {
            String Vendor_EndPoint = '/v3/company/' + QBMetadata.buildertek__Company_Id__c + '/vendor?minorversion=' + QBMetadata.buildertek__minorversion__c;            
            String Vendor_RequestBody = QBMap.mapVendorAccountData(acc);
            system.debug('JSON Body >>' +  Vendor_RequestBody);
            HttpResponse Vendor_Response = QBCallOutService.QBAPICallOut(Vendor_EndPoint , Vendor_RequestBody, Get_Access_Token);
            system.debug('Vendor API Status Code >> ' + Vendor_Response.getStatusCode());
            System.debug('_Response.getBody() :: '+ Vendor_Response.getBody());
            if(Vendor_Response.getStatusCode() == 200){
                QBVendorResponseJSON Vendor_Response_Deser = QBVendorResponseJSON.parse(Vendor_Response.getBody());
                QBVendorResponseJSON.Vendor Vendor = new QBVendorResponseJSON.Vendor();
                vendor = Vendor_Response_Deser.Vendor;
                String VendorQBId = vendor.Id;
                String SyncToken = vendor.SyncToken;

                Create_item_po_in_QB(POLines, PO, VendorQBId, QBMetadata, Get_Access_Token);
                UpdateAccount(acc.Id, VendorQBId, QBMetadata, SyncToken);
            }
            else{
                QBException.QB_response( Vendor_Response.getStatusCode(),  Vendor_Response.getBody(), 'QBPOIntegrationQueue', 'Create_Vendor_in_QB');
            }
            
        } catch (Exception e) {
            System.debug('Error in Create_Vendor_in_QB ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }
    }

    public static void UpdateAccount(String acc_Id, String QB_Id , buildertek__QuickBooks_Setting__mdt  QBMetadata, String SyncToken){
        try {
            system.debug('Account going to Update');
            String qbVendorURL = QBMetadata.buildertek__Qb_URL__c + 'vendordetail?nameId=' + QB_Id;
            Account Acc = [SELECT Id,Name, buildertek__QBO_ID__c,buildertek__QB_Record_URL__c  FROM Account WHERE Id =: acc_Id LIMIT 1];
            Acc.buildertek__QBO_ID__c = QB_Id;
            Acc.buildertek__QB_Record_URL__c = qbVendorURL;
            Acc.buildertek__QBO_SyncToken__c = SyncToken;
            update Acc;
        
        } catch (Exception e) {
            System.debug('Error in UpdateAccount : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static String Create_vendor_item_po_in_QB_flow(String recordId, String Objecttype){
        try {
            if (Objecttype == 'buildertek__Purchase_Order__c') {
                buildertek__Purchase_Order__c PO = [SELECT Id, Name, buildertek__Vendor__c,buildertek__QBO_ID__c,buildertek__QBO_SyncToken__c,buildertek__Project__r.buildertek__Customer__c,buildertek__PO_Total__c,buildertek__Tax_Amount__c FROM buildertek__Purchase_Order__c WHERE Id =: recordId LIMIT 1];

                Account acc = new Account();
                if(PO.buildertek__Vendor__c != null){
                    acc = [SELECT ID, Name,buildertek__Email_Address__c,Fax,buildertek__QBO_ID__c,buildertek__QBO_SyncToken__c, Description,ShippingCity,ShippingStreet,ShippingState,ShippingPostalCode,ShippingLatitude,ShippingLongitude,ShippingCountry,Phone,BillingCity,BillingStreet,BillingState,BillingPostalCode,BillingLatitude,BillingLongitude,BillingCountry FROM Account WHERE Id =: PO.buildertek__Vendor__c limit 1];
                }
                else if(PO.buildertek__Vendor__c == null && PO.buildertek__Project__c != null){
                    system.debug('Project Id ' + PO.buildertek__Project__r.buildertek__Customer__c);
                    acc = [SELECT ID, Name,buildertek__Email_Address__c,Fax,buildertek__QBO_ID__c,buildertek__QBO_SyncToken__c, Description,ShippingCity,ShippingStreet,ShippingState,ShippingPostalCode,ShippingLatitude,ShippingLongitude,ShippingCountry,Phone,BillingCity,BillingStreet,BillingState,BillingPostalCode,BillingLatitude,BillingLongitude,BillingCountry FROM Account WHERE Id =: PO.buildertek__Project__r.buildertek__Customer__c limit 1];
                }
                else{
                    acc = null;
                }

                List<buildertek__Purchase_Order_Item__c> POLines = [SELECT Id, Name, buildertek__Purchase_Order__c,buildertek__Purchase_Order__r.Name,buildertek__Total_Price__c,buildertek__Item_Name__c,buildertek__Quantity__c,buildertek__QBO_ID__c,buildertek__QBO_Name__c,buildertek__QBO_SyncToken__c,buildertek__Description__c,buildertek__Unit_Price__c FROM buildertek__Purchase_Order_Item__c WHERE buildertek__Purchase_Order__c =: recordId];
                if(POLines.size() > 0 && acc != null){
                    string receiptID;
                    QB_PO_Flow_Callout(recordId);
                    return 'success';
                }
                else if(POLines.size() == 0){
                    return 'no_polines';
                }
                else if(acc == null){
                    return 'no_vendor_account';
                }
                else{
                    return null;
                }
            }
            return null;
        } catch (Exception e) {
            System.debug('Error in Create_vendor_item_po_in_QB_flow : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            return null;
        }
    }

    public static void Create_item_po_in_QB(List<buildertek__Purchase_Order_Item__c> POLines, buildertek__Purchase_Order__c PO, String VendorQBId, buildertek__QuickBooks_Setting__mdt QBMetadata, Boolean Get_Access_Token){
        try {

            List<buildertek__Purchase_Order_Item__c> ItemstoCreate = new List<buildertek__Purchase_Order_Item__c>();
            for(buildertek__Purchase_Order_Item__c Items : POLines){
                if(Items.buildertek__QBO_ID__c == null){
                    ItemstoCreate.add(Items);
                }
            }

            if(ItemstoCreate.size() > 0){
                Integer totalItems = ItemstoCreate.size();
                Integer batchSize = 30;
                Integer totalBatches = (totalItems + batchSize - 1) / batchSize; // Calculate total batches needed
                Map<Id, List<String>> lineIdsMap = new Map<Id, List<String>>();

                for (Integer i = 0; i < totalBatches; i++) {
                    Integer startIdx = i * batchSize;
                    Integer endIdx = Math.min((i + 1) * batchSize, totalItems);
    
                    List<buildertek__Purchase_Order_Item__c> itemsBatch = new List<buildertek__Purchase_Order_Item__c>();
    
                    // Create the sublist for the current batch
                    for (Integer j = startIdx; j < endIdx; j++) {
                            itemsBatch.add(ItemstoCreate[j]);
                    }
                    System.debug((i+1) +' ***** No. Batch length ******** '+ itemsBatch.size());
                    String POItem_EndPoint = '/v3/company/' + QBMetadata.buildertek__Company_Id__c + '/batch?minorversion=' + QBMetadata.buildertek__minorversion__c;
                    String POItem_RequestBody = QBMap.mapPOLineToBatch(itemsBatch); 
                    System.debug('POItem_RequestBody ' +POItem_RequestBody);
                    HttpResponse POItem_Response = QBCallOutService.QBAPICallOut(POItem_EndPoint , POItem_RequestBody, Get_Access_Token);

                    system.debug('PO Line API Status Code >> ' + POItem_Response.getStatusCode());
                    system.debug('PO Line Resopnce >> ' + POItem_Response.getBody());

                    if(POItem_Response.getStatusCode() == 200){
                        QBBatchResJSON response = QBBatchResJSON.parse(POItem_Response.getBody());

                        // First Add Existing PO Lines(if available)....And Then Added Newly created po Lines to the Qb PO....
                        for(buildertek__Purchase_Order_Item__c POL : POLines){
                            if(POL.buildertek__QBO_ID__c != null){
                                lineIdsMap.put(
                                    Id.valueOf(POL.Id), 
                                    new List<String>{POL.buildertek__QBO_ID__c, POL.buildertek__QBO_Name__c, string.valueOf(POL.buildertek__Total_Price__c), string.valueOf(POL.buildertek__Quantity__c), string.valueOf(POL.buildertek__Unit_Price__c)}
                                );
                            }
                        }

                        for (QBBatchResJSON.BatchItemResponse batchItem : response.BatchItemResponse) {
                            if (batchItem != null && batchItem.Item != null && batchItem.bId != null) {
                                lineIdsMap.put(
                                    // Assuming SalesforceId__c is of type Id and QbId__c is of type String
                                    Id.valueOf(batchItem.bId), // Salesforce ID
                                    // List Of QB Line Id, QB Line Name , Total Price, Quantity, Unite Price...
                                    new List<String> { batchItem.Item.Id , batchItem.Item.Name, String.valueOf((batchItem.Item.QtyOnHand)*(batchItem.Item.UnitPrice)), String.valueOf(batchItem.Item.QtyOnHand), String.valueOf(batchItem.Item.UnitPrice) } // QuickBooks ID
                                );
                            }
                        }
                        
                        if( i == (totalBatches-1)){
                            System.debug('when last batch finish.. create PO');
                            System.debug('lineIdsMap >> ' + lineIdsMap);
                            Create_PO_in_QB(PO, VendorQBId, lineIdsMap,QBMetadata, Get_Access_Token);
                            UpdatePOline(ItemstoCreate, lineIdsMap);
                        }
                    }
                    else{
                        QBException.QB_response( POItem_Response.getStatusCode(),  POItem_Response.getBody(), 'QBPOIntegrationQueue', 'Create_item_po_in_QB');
                    }
                }
            }
            else{
                System.debug('All Items of the po is available in QB');
                Map<Id, List<String>> lineIdsMap1 = new Map<Id, List<String>>();
                for(buildertek__Purchase_Order_Item__c POL : POLines){
                    lineIdsMap1.put(
                            // Assuming SalesforceId__c is of type Id and QbId__c is of type String
                            Id.valueOf(POL.Id), // Salesforce ID
                            new List<String> { POL.buildertek__QBO_ID__c , POL.buildertek__QBO_Name__c, string.valueOf(POL.buildertek__Total_Price__c), string.valueOf(POL.buildertek__Quantity__c), string.valueOf(POL.buildertek__Unit_Price__c) } // QuickBooks ID
                    );
                }
                Create_PO_in_QB(PO, VendorQBId, lineIdsMap1,QBMetadata, Get_Access_Token);
            }
        } catch (Exception e) {
            System.debug('Error in Create_item_po_in_QB ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }
    }

    public static void UpdatePOline(list<buildertek__Purchase_Order_Item__c> SILines, Map<Id, List<String>> lineIdsMap){
        try {
            system.debug('PO line going to Update');

            for (buildertek__Purchase_Order_Item__c record : SILines) {
                // Check if the Salesforce ID exists in the mapping and update the QuickBooks ID
                List<String> qbIdAndNameList = lineIdsMap.get(record.Id);

                // Assuming the list contains QB ID and QB Name in index 0 and 1 respectively
                if (qbIdAndNameList != null && qbIdAndNameList.size() >= 2) {
                    record.buildertek__QBO_ID__c = qbIdAndNameList[0]; // Assign QuickBooks ID
                    record.buildertek__QBO_Name__c = qbIdAndNameList[1];
                    // Optionally, you can also use qbIdAndNameList[1] to access QuickBooks Name if needed
                }
            }

            update SILines;
        } catch (Exception e) {
            System.debug('Error in UpdatePOline : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }
    }

    public static void Create_PO_in_QB(buildertek__Purchase_Order__c PO, String VendorQBId,Map<Id, List<String>> lineIdsMap, buildertek__QuickBooks_Setting__mdt QBMetadata, Boolean Get_Access_Token){
        try {
            String PO_EndPoint = '/v3/company/' + QBMetadata.buildertek__Company_Id__c + '/purchaseorder?minorversion=' + QBMetadata.buildertek__minorversion__c;
            String PO_RequestBody = QBMap.mapPODataBatch(PO, VendorQBId, lineIdsMap);
            System.debug('PO_RequestBody >> ' + PO_RequestBody);
            HttpResponse PO_Response = QBCallOutService.QBAPICallOut(PO_EndPoint , PO_RequestBody, Get_Access_Token);
            
            system.debug('PO API Status Code >> ' + PO_Response.getStatusCode());
            system.debug('PO Resopnce >> ' + PO_Response.getBody());
            
            if(PO_Response.getStatusCode() == 200){
                QBPOResponseJSON PO_Response_desr = QBPOResponseJSON.parse(PO_Response.getBody());
                QBPOResponseJSON.PurchaseOrder pos = new QBPOResponseJSON.PurchaseOrder();
                pos = PO_Response_desr.PurchaseOrder;
                String POQBId = pos.Id;
                String QbInvNumber = pos.DocNumber;
                String QBInvSyncTocken = pos.SyncToken;
                UpdatePO(PO.Id, POQBId,QBMetadata, QbInvNumber, QBInvSyncTocken);
            }
            else{
                QBException.QB_response( PO_Response.getStatusCode(),  PO_Response.getBody(), 'QBPOIntegrationQueue', 'Create_PO_in_QB');
            }

            
        } catch (Exception e) {
            System.debug('Error in Create_inoice_Payment_in_QB ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }
    }

    public static void UpdatePO(String recordId, String QB_PO_Id, buildertek__QuickBooks_Setting__mdt  QBMetadata, String QbInvNumber, String QBInvSyncTocken){
        try {
            system.debug('PO going to Update');
            String qbPOURL = QBMetadata.buildertek__Qb_URL__c + 'purchaseorder?txnId=' + QB_PO_Id;
            buildertek__Purchase_Order__c PO = [SELECT Id, Name, buildertek__QB_PO_URL__c, buildertek__QB_PO_Number__c, buildertek__QBO_ID__c, buildertek__QBO_SyncToken__c FROM buildertek__Purchase_Order__c WHERE Id =: recordId LIMIT 1];
            PO.buildertek__QBO_ID__c = QB_PO_Id;
            PO.buildertek__QB_PO_URL__c = qbPOURL;
            PO.buildertek__QB_PO_Number__c = QbInvNumber;
            PO.buildertek__QBO_SyncToken__c = QBInvSyncTocken;
            update PO;
        } catch (Exception e) {
            System.debug('Error in UpdatePO : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }
    }
}