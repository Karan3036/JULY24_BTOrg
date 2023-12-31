public with sharing class ImportTakeOffLinesBasic{
    public virtual class ResponseBase{
        @AuraEnabled
        public Boolean isSuccess;
        @AuraEnabled
        public String strMessage;
    }

    // @AuraEnabled
    // public static ResponseBase importRecords(Id takeOffId, String fileData){
    //     ResponseBase response = new ResponseBase();
    //     response.isSuccess = true;
    //     WrapperClass wrapper = new WrapperClass();
    //     Set<String> productNames = new Set<String>();
    //     try{
    //         if (fileData != null){
    //             List<List<String>> listCSVData;
    //             String strFileData;
    //             Blob fileContent = EncodingUtil.base64Decode(fileData);
    //             strFileData = fileContent.toString();
    //             System.debug('strFileData--->'+strFileData);
    //             if (!String.isBlank(strFileData) && response.isSuccess){
    //                 List<buildertek__Project_Takeoff_Lines__c> schItemToInsert = new List<buildertek__Project_Takeoff_Lines__c>();
    //                 wrapper = getListOfFileContentsAsStrings(strFileData);
    //                 listCSVData = wrapper.listOfFileContentsAsStrings;
    //                 productNames = wrapper.productNames;
    //                 Id productFamilyId = null;

    //                 Map<String, Product2> existingProductMap = new Map<String, Product2>();
    //                 Map<String, buildertek__Build_Phase__c> buildPhasemap = new Map<String, buildertek__Build_Phase__c>();
    //                 Map<String, buildertek__Trade_Type__c> existingTradeTypeMap = new Map<String, buildertek__Trade_Type__c>();
    //                 Map<String, buildertek__Cost_Codes__c> existingCostCodeMap = new Map<String, buildertek__Cost_Codes__c>();
    //                 Map<String, Account> accountMap = new Map<String, Account>();
    //                 Map<String, PricebookEntry> PBEMap = new Map<String, PricebookEntry>();
    //                 Map<String, Pricebook2> PBMap = new Map<String, Pricebook2>();

    //                 List<String> productList = new List<String>();
    //                 List<String> vendorList = new List<String>();
                    
    //                 for(Integer intIndex = 1; intIndex < listCSVData.size(); intIndex++) {
	// 					for(Integer intInnerIndex = 0; intInnerIndex < listCSVData.get(intIndex).size(); intInnerIndex++) {
    //                         switch on listCSVData.get(0).get(intInnerIndex) {
    //                             when 'Product' {
    //                                 if (String.isNotBlank(listCSVData.get(intIndex).get(intInnerIndex))){
    //                                     String tempProductNames  = listCSVData.get(intIndex).get(intInnerIndex).replace('\n', '');
    //                                     if (tempProductNames.startsWith('"') && tempProductNames.endsWith('"')) {
    //                                         String withoutOuterQuotes = tempProductNames.replaceAll('^"|"$', '');
    //                                         String finalString = withoutOuterQuotes.replaceAll('""', '"');
    //                                         productList.add(finalString);
    //                                     } else {
    //                                         productList.add(tempProductNames);
    //                                     }
    //                                 }
    //                             }
    //                             when 'Vendor' {
    //                                 if(String.isNotBlank(listCSVData.get(intIndex).get(intInnerIndex))) {
    //                                    vendorList.add(listCSVData.get(intIndex).get(intInnerIndex).replace('\n',''));
    //                                 }
    //                             }
    //                         }
    //                     }
    //                 }
    //                 // Find existing products
    //                 for (Product2 prod : [SELECT Id, Name FROM Product2 WHERE Name IN :productList]) {
    //                     existingProductMap.put(prod.Name, prod);
    //                 }

    //                 // Find existing pricebooks
    //                 for (Pricebook2 pricebook : [SELECT Id, Name FROM Pricebook2]) {
    //                     PBMap.put(pricebook.Name, pricebook);
    //                 }

    //                 // Find existing vendors
    //                 for (Account Acc : [SELECT Id, Name FROM Account WHERE Name IN :vendorList]) {
    //                     accountMap.put(Acc.Name, Acc);
    //                 }

    //                 // Find existing pricebookentries
    //                 for (PricebookEntry pricebookentry : [SELECT Id, Name, Pricebook2Id, Product2Id, Product2.Name, Pricebook2.Name FROM PricebookEntry WHERE Product2.Name IN :productList]) {
    //                     PBEMap.put(pricebookentry.Name, pricebookentry);
    //                 }

    //                 // Find existing build phases
    //                 for (buildertek__Build_Phase__c newbuildphase : [SELECT Id, Name FROM buildertek__Build_Phase__c]) {
    //                     buildPhasemap.put(newbuildphase.Name, newbuildphase);
    //                 }

    //                 // Find existing trade types
    //                 for (buildertek__Trade_Type__c tradeTypeRec : [SELECT Id, Name FROM buildertek__Trade_Type__c]) {
    //                     existingTradeTypeMap.put(tradeTypeRec.Name, tradeTypeRec);
    //                 }

    //                 // Find existing cost codes
    //                 for (buildertek__Cost_Codes__c costCodeRec : [SELECT Id, Name FROM buildertek__Cost_Codes__c]) {
    //                     existingCostCodeMap.put(costCodeRec.Name, costCodeRec);
    //                 }

    //                 for (Integer intIndex = 1; intIndex < listCSVData.size(); intIndex++){
    //                     buildertek__Project_Takeoff_Lines__c takeoffLines = new buildertek__Project_Takeoff_Lines__c(buildertek__Project_Takeoff__c = takeOffId);

    //                     for (Integer intInnerIndex = 0; intInnerIndex < listCSVData.get(intIndex).size(); intInnerIndex++){
    //                         switch on listCSVData.get(0).get(intInnerIndex){
    //                             when 'Product'{
    //                                 if (String.isNotBlank(listCSVData.get(intIndex).get(intInnerIndex))){
    //                                     String tempProductNames  = listCSVData.get(intIndex).get(intInnerIndex).replace('\n', '');
    //                                     if (tempProductNames.startsWith('"') && tempProductNames.endsWith('"')) {
    //                                         String withoutOuterQuotes = tempProductNames.replaceAll('^"|"$', '');
    //                                         String finalString = withoutOuterQuotes.replaceAll('""', '"');
    //                                         if (existingProductMap.containsKey(finalString)){
    //                                             productFamilyId = existingProductMap.get(finalString).Id;
    //                                             takeoffLines.buildertek__Product__c = productFamilyId;
    //                                             // BC - 12/17/23 - takeoffLines.buildertek__Description__c = existingProductMap.get(finalString).Name;                                                
    //                                             takeoffLines.buildertek__Description__c = existingProductMap.get(finalString).Name;  
    //                                         }
    //                                     } else {
	// 										if (existingProductMap.containsKey(tempProductNames)){
	// 											productFamilyId = existingProductMap.get(tempProductNames).Id;
    //                                             takeoffLines.buildertek__Product__c = productFamilyId;
    //                                             // BC - 12/17/23 - takeoffLines.buildertek__Description__c = existingProductMap.get(finalString).Name;  
    //                                             takeoffLines.buildertek__Description__c = existingProductMap.get(tempProductNames).Name;  
    //                                         }
    //                                     }
                                         
    //                                 }
                                    
    //                             }

    //                             when 'Price Book' {
    //                                 String tempPBphase = listCSVData.get(intIndex).get(intInnerIndex);
    //                                 if (String.isNotBlank(tempPBphase) && PBMap.containsKey(tempPBphase) && productFamilyId != null) {
    //                                     for (PricebookEntry pbe : PBEMap.values()) {
    //                                         if (pbe.Pricebook2Id == PBMap.get(tempPBphase).Id &&
    //                                             pbe.Product2Id == productFamilyId) {
    //                                             takeoffLines.buildertek__Price_Book__c = PBMap.get(tempPBphase).Id;
    //                                             break;
    //                                         }
    //                                     }
    //                                     productFamilyId = null;
    //                                 }
    //                             }

    //                             when 'Vendor'{
    //                                 if (String.isNotBlank(listCSVData.get(intIndex).get(intInnerIndex))){
    //                                     String tempVendorNames  = listCSVData.get(intIndex).get(intInnerIndex).replace('\n', '');
    //                                     if (tempVendorNames.startsWith('"') && tempVendorNames.endsWith('"')) {
    //                                         String withoutOuterQuotes = tempVendorNames.replaceAll('^"|"$', '');
    //                                         String finalVendorString = withoutOuterQuotes.replaceAll('""', '"');
    //                                         if (accountMap.containsKey(finalVendorString)){
    //                                             // vendorId = existingProductMap.get(finalVendorString).Id;
    //                                             takeoffLines.buildertek__Vendor__c = accountMap.get(finalVendorString).Id;
    //                                         }
    //                                     } else {
    //                                         if (accountMap.containsKey(tempVendorNames)){
    //                                             // vendorId = existingProductMap.get(finalVendorString).Id;
    //                                             takeoffLines.buildertek__Vendor__c = accountMap.get(tempVendorNames).Id;
    //                                         }
    //                                     }
                                         
    //                                 }
                                    
    //                             }

    //                             when 'Product SKU'{
    //                                 if (String.isNotBlank(listCSVData.get(intIndex).get(intInnerIndex))){
    //                                     takeoffLines.buildertek__StockKeepingUnit__c = listCSVData.get(intIndex).get(intInnerIndex);
    //                                 }
    //                             }

    //                             when 'Product Code'{
    //                                 if (String.isNotBlank(listCSVData.get(intIndex).get(intInnerIndex))){
    //                                     takeoffLines.buildertek__Product_Code__c = listCSVData.get(intIndex).get(intInnerIndex);
    //                                 }
    //                             }

    //                             when 'Build Phase'{
    //                                 String tempbuildphase = listCSVData.get(intIndex).get(intInnerIndex);
    //                                 if (String.isNotBlank(tempbuildphase) && buildPhasemap.containsKey(tempbuildphase)){
    //                                     takeoffLines.buildertek__Build_Phase__c = buildPhasemap.get(tempbuildphase).Id;
    //                                 }
    //                             }

    //                             when 'CategoryPL'{
    //                                 if (String.isNotBlank(listCSVData.get(intIndex).get(intInnerIndex))){
    //                                     takeoffLines.buildertek__Category__c = listCSVData.get(intIndex).get(intInnerIndex);
    //                                 }
    //                             }

    //                             when 'Trade Type'{
    //                                 String temptradetype = listCSVData.get(intIndex).get(intInnerIndex);
    //                                 if (String.isNotBlank(temptradetype) && existingTradeTypeMap.containsKey(temptradetype)){
    //                                     takeoffLines.buildertek__Trade_Type__c = existingTradeTypeMap.get(temptradetype).Id;
    //                                 }
    //                             }

    //                             when 'Location'{
    //                                 if (String.isNotBlank(listCSVData.get(intIndex).get(intInnerIndex))){
    //                                     takeoffLines.buildertek__Location__c = listCSVData.get(intIndex).get(intInnerIndex);
    //                                 }
    //                             }

    //                             when 'Quantity'{
    //                                 if (String.isNotBlank(listCSVData.get(intIndex).get(intInnerIndex))){
    //                                     String quantityString = listCSVData.get(intIndex).get(intInnerIndex).replaceAll('[^0-9.]', '');
    //                                     takeoffLines.buildertek__Quantity__c = Decimal.valueOf(quantityString);
    //                                 }
    //                             }

    //                             when 'UOM'{
    //                                 if (String.isNotBlank(listCSVData.get(intIndex).get(intInnerIndex))){
    //                                     takeoffLines.buildertek__UOM_PL__c = listCSVData.get(intIndex).get(intInnerIndex);
    //                                 }
    //                             }

    //                             when 'Cost Code'{
    //                                 String tempcostcode = listCSVData.get(intIndex).get(intInnerIndex);
    //                                 if (String.isNotBlank(tempcostcode) && existingCostCodeMap.containsKey(tempcostcode)){
    //                                         takeoffLines.buildertek__Cost_Code__c = existingCostCodeMap.get(tempcostcode).Id;
    //                                 }
    //                             }

    //                             when else {
    //                                 response.isSuccess = false;
    //                             }
    //                         }
    //                     }
    //                     schItemToInsert.add(takeoffLines);
    //                 }
    //                 if (!schItemToInsert.isEmpty()){
    //                     if (response.isSuccess) {
    //                         insert schItemToInsert;
    //                         response.strMessage = 'TakeOff lines inserted successfully.';
    //                     }
    //                     else {   
    //                         response.isSuccess = false;
    //                         response.strMessage = 'Please check the header.';
    //                     }
    //                 } else{
    //                     response.isSuccess = false;
    //                     response.strMessage = 'No takeoff lines present.';
    //                 }
    //             } else{
    //                 response.isSuccess = false;
    //                 response.strMessage = 'Please select valid CSV file.';
    //             }
    //         }
    //     } catch (Exception ex){
    //         response.isSuccess = false;
    //         response.strMessage = ex.getMessage();
    //         System.debug('Message:2:' + ex.getMessage());
    //         System.debug('Line:2:' + ex.getLineNumber());
    //     }
    //     return response;
    // }

    // /*
    //  @ Purpose     : Parse each row and column value into the element of List.
    //  @ Parameters  : String [ Contents of CSV file ].
    //  @ Return Type : List<List<String>> [ List of rows and Each row will have the list of columns ].
    //  */
    // public static WrapperClass getListOfFileContentsAsStrings(String strContents){
    //     WrapperClass wrapper = new WrapperClass();
    //     List<List<String>> listOfFileContentsAsStrings;
    //     Set<String> productNames = new Set<String>();
    //     if (String.isNotBlank(strContents)){
    //         List<String> listLines;

    //         if (strContents.contains('\r')){
    //             // Split up the file contents into List of rows [ Using new line ].
    //             listLines = strContents.split('\r');
    //         } else if (strContents.contains('\n')){
    //             // Split up the file contents into List of rows [ Using new line ].
    //             listLines = strContents.split('\n');
    //         }

    //         if (listLines != Null && !listLines.isEmpty()){
    //             // Appending cell values separated by New Lines.
    //             listLines = appendCellValuesSeparatedByNewLines(listLines);
    //             if (listLines != Null && !listLines.isEmpty()){

    //                 // Split up the each element of the list into List of columns [ Using comma ].
    //                 List<String> listRowContents;
    //                 listOfFileContentsAsStrings = new List<List<String>>();
    //                 for (String line : listLines){

    //                     if (line.contains(',')){
    //                         listRowContents = line.split(',');
    //                         if (listRowContents != Null && !listRowContents.isEmpty()){

    //                             // Appending cell values separated by Commas.
    //                             listRowContents = appendCellValuesSeparatedByCommas(listRowContents);
    //                             if (listRowContents != Null && !listRowContents.isEmpty()){
    //                                 listOfFileContentsAsStrings.add(listRowContents);
    //                                 productNames.add(listRowContents[0].replace('\n',''));
    //                             }
    //                         }
    //                     }
    //                 }
    //             }
    //         }
    //     }
	// 	System.debug('listOfFileContentsAsStrings' + listOfFileContentsAsStrings);
	// 	System.debug('productNames' + productNames);
    //     wrapper.listOfFileContentsAsStrings = listOfFileContentsAsStrings;
    //     wrapper.productNames = productNames;
    //     return wrapper;
    // }

    // /*
    //  @ Purpose     : Appends the CSV cells which are separated by New Line.
    //  @ Parameters  : List<String> [ List holds the strings separated by New Line ].
    //  @ Return Type : List<String> [ List appends the strings belong to same CSV cell ].
    //  */
    // public Static List<String> appendCellValuesSeparatedByNewLines(List<String> listValues){

    //     List<String> listToAppendCellValues;
    //     if (listValues != Null && !listValues.isEmpty()){

    //         Boolean isNewLineFound = False;
    //         String strValueToBeMerged = '';
    //         listToAppendCellValues = new List<String>();
    //         Integer intCountDoubleQuotes;

    //         for (String strValue : listValues){

    //             if (!isNewLineFound){
    //                 intCountDoubleQuotes = strValue.countMatches('\"');
    //                 if (intCountDoubleQuotes == 1){
    //                     isNewLineFound = True;
    //                 }
    //             }

    //             if (isNewLineFound){
    //                 strValueToBeMerged += strValue + '\n';
    //                 if (strValue.contains('\",')){

    //                     intCountDoubleQuotes = strValue.countMatches('\"');
    //                     if (Math.mod(intCountDoubleQuotes, 2) != 0){

    //                         isNewLineFound = False;
    //                         listToAppendCellValues.add(strValueToBeMerged);
    //                         strValueToBeMerged = '';
    //                     }
    //                 }
    //             } else{
    //                 listToAppendCellValues.add(strValue);
    //             }
    //         }
    //     }
    //     return listToAppendCellValues;
    // }

    // /*
    //  @ Purpose     : Appends the CSV cells which are separated by Commas.
    //  @ Parameters  : List<String> [ List holds the strings separated by Commas ].
    //  @ Return Type : List<String> [ List appends the strings belong to same CSV cell ].
    //  */
    // public static List<String> appendCellValuesSeparatedByCommas(List<String> listValues){

    //     List<String> listToAppendCellValues;
    //     if (listValues != Null && !listValues.isEmpty()){

    //         Boolean isCommaFoundInTheValue;
    //         listToAppendCellValues = new List<String>();
    //         String strValueToBeMerged = '';
    //         Integer intCountDoubleQuotes = 0;

    //         for (String strValue : listValues){

    //             if (isCommaFoundInTheValue == Null){
    //                 if (strValue.startsWith('\"')){
    //                     isCommaFoundInTheValue = True;
    //                     if (strValue.endsWith('\"')){
    //                         if (strValue.contains('\n') || strValue.contains('\r')){
    //                             isCommaFoundInTheValue = False;
    //                         } else{
    //                             intCountDoubleQuotes = strValue.countMatches('\"');
    //                             if (Math.mod(intCountDoubleQuotes, 2) == 0){
    //                                 isCommaFoundInTheValue = False;
    //                             }
    //                         }
    //                     }
    //                 }
    //             } else if (strValue.endsWith('\"')){
    //                 intCountDoubleQuotes = strValue.countMatches('\"');
    //                 if (Math.mod(intCountDoubleQuotes, 2) != 0){
    //                     isCommaFoundInTheValue = False;
    //                 }
    //             }

    //             if (isCommaFoundInTheValue != Null){
    //                 if (isCommaFoundInTheValue){
    //                     strValueToBeMerged += strValue + ',';
    //                 } else{
    //                     strValueToBeMerged += strValue;
    //                     if (strValueToBeMerged.contains('\"')){
    //                         strValueToBeMerged = strValueToBeMerged.replaceAll('\\\"+', '"');
    //                     }
    //                     listToAppendCellValues.add(strValueToBeMerged);
    //                     strValueToBeMerged = '';
    //                     isCommaFoundInTheValue = Null;
    //                 }
    //             } else{
    //                 listToAppendCellValues.add(strValue);
    //             }
    //         }
    //     }
    //     return listToAppendCellValues;
    // }

    @AuraEnabled
    public static ResponseBase importRecords(Id takeOffId, String fileData){
        ResponseBase response = new ResponseBase();
        System.debug('fileData----> '+fileData);
        Id productFamilyId = null;

        try {

            List<fieldWrapper> datalist = (List<fieldWrapper>)JSON.deserialize(fileData, List<fieldWrapper>.class);

            Map<String, Product2> existingProductMap = new Map<String, Product2>();
            Map<String, buildertek__Build_Phase__c> buildPhasemap = new Map<String, buildertek__Build_Phase__c>();
            Map<String, buildertek__Trade_Type__c> existingTradeTypeMap = new Map<String, buildertek__Trade_Type__c>();
            Map<String, buildertek__Cost_Codes__c> existingCostCodeMap = new Map<String, buildertek__Cost_Codes__c>();
            Map<String, Account> accountMap = new Map<String, Account>();
            Map<String, PricebookEntry> PBEMap = new Map<String, PricebookEntry>();
            Map<String, Pricebook2> PBMap = new Map<String, Pricebook2>();

            List<String> productList = new List<String>();
            List<String> priceBookList = new List<String>();
            List<String> vendorList = new List<String>();
            for (fieldWrapper data : dataList) {
                productList.add(data.Product.trim());
                priceBookList.add(data.PriceBook.trim());
                vendorList.add(data.Vendor.trim());
            }
            // Now productList contains all "Product" values, and priceBookList contains all "PriceBook" values
            System.debug('Product List: ' + productList);
            System.debug('PriceBook List: ' + vendorList);

            // List<String> productList = new List<String>();
            // List<String> vendorList = new List<String>();
            
            // Find existing products
            for (Product2 prod : [SELECT Id, Name FROM Product2 WHERE Name IN :productList]) {
                existingProductMap.put(prod.Name, prod);
                System.debug('existingProductMap-->' + prod);
            }

            // Find existing pricebooks
            for (Pricebook2 pricebook : [SELECT Id, Name FROM Pricebook2 WHERE Name IN :priceBookList]) {
                PBMap.put(pricebook.Name, pricebook);
            }

            // Find existing vendors
            for (Account Acc : [SELECT Id, Name FROM Account WHERE Name IN :vendorList]) {
                accountMap.put(Acc.Name, Acc);
            }

            // Find existing pricebookentries
            for (PricebookEntry pricebookentry : [SELECT Id, Name, Pricebook2Id, Product2Id, Product2.Name, Pricebook2.Name FROM PricebookEntry WHERE Product2.Name IN :productList]) {
                PBEMap.put(pricebookentry.Id, pricebookentry);
            }

            // Find existing build phases
            for (buildertek__Build_Phase__c newbuildphase : [SELECT Id, Name FROM buildertek__Build_Phase__c]) {
                buildPhasemap.put(newbuildphase.Name, newbuildphase);
            }

            // Find existing trade types
            for (buildertek__Trade_Type__c tradeTypeRec : [SELECT Id, Name FROM buildertek__Trade_Type__c]) {
                existingTradeTypeMap.put(tradeTypeRec.Name, tradeTypeRec);
            }

            // Find existing cost codes
            for (buildertek__Cost_Codes__c costCodeRec : [SELECT Id, Name FROM buildertek__Cost_Codes__c]) {
                existingCostCodeMap.put(costCodeRec.Name, costCodeRec);
            }


            List<buildertek__Project_Takeoff_Lines__c> TakeoffLinesToInsert = new List<buildertek__Project_Takeoff_Lines__c>();
            // List<fieldWrapper> datalist = (List<fieldWrapper>)JSON.deserialize(fileData, List<fieldWrapper>.class);

            for (fieldWrapper wrapper : datalist) {
                
                    buildertek__Project_Takeoff_Lines__c TakeoffLine = new buildertek__Project_Takeoff_Lines__c();
                    TakeoffLine.buildertek__Project_Takeoff__c = takeOffId;
                    // TakeoffLine.buildertek__Product__c = wrapper.Product;
                    String productName = wrapper.Product;
                    if (String.isNotBlank(productName) && existingProductMap.containsKey(productName)){
                        productFamilyId = existingProductMap.get(productName).Id;
                        TakeoffLine.buildertek__Product__c = productFamilyId;
                        TakeoffLine.buildertek__Description__c = productName;
                    } else {
                        TakeoffLine.buildertek__Description__c = productName;
                    }
                    // TakeoffLine.buildertek__Price_Book__c = wrapper.PriceBook;
                    String tempPBphase = wrapper.PriceBook;
                    if (String.isNotBlank(tempPBphase) && PBMap.containsKey(tempPBphase) && productFamilyId != null) {
                        for (PricebookEntry pbe : PBEMap.values()) {
                            if (pbe.Pricebook2Id == PBMap.get(tempPBphase).Id &&
                                pbe.Product2Id == productFamilyId) {
                                TakeoffLine.buildertek__Price_Book__c = PBMap.get(tempPBphase).Id;
                                break;
                            }
                        }
                        productFamilyId = null;
                    }
                    
                    // TakeoffLine.buildertek__Vendor__c = wrapper.Vendor;
                    String vendorName = wrapper.Vendor;
                    if (String.isNotBlank(vendorName) && accountMap.containsKey(vendorName)){
                        TakeoffLine.buildertek__Vendor__c = accountMap.get(vendorName).Id;
                    }
                    TakeoffLine.buildertek__StockKeepingUnit__c = wrapper.ProductSKU;
                    TakeoffLine.buildertek__Product_Code__c = wrapper.ProductCode;
                    // TakeoffLine.buildertek__Build_Phase__c = wrapper.BuildPhase;
                    String buildPhase = wrapper.BuildPhase;
                    if (String.isNotBlank(buildPhase) && buildPhasemap.containsKey(buildPhase)){
                        TakeoffLine.buildertek__Build_Phase__c = buildPhasemap.get(buildPhase).Id;
                    }
                    TakeoffLine.buildertek__Category__c = wrapper.CategoryPL;
                    // TakeoffLine.buildertek__Trade_Type__c = wrapper.TradeType;
                    String tradeType = wrapper.TradeType;
                    if (String.isNotBlank(tradeType) && existingTradeTypeMap.containsKey(tradeType)){
                        TakeoffLine.buildertek__Trade_Type__c = existingTradeTypeMap.get(tradeType).Id;
                    }
                    TakeoffLine.buildertek__Location__c = wrapper.Location;
                    // TakeoffLine.buildertek__Quantity__c = wrapper.Quantity;
                    String quant = wrapper.Quantity;
                    if (String.isNotBlank(quant)){
                        TakeoffLine.buildertek__Quantity__c = Decimal.valueOf(quant);
                    } else {
                        TakeoffLine.buildertek__Quantity__c = 0;
                    }
                    TakeoffLine.buildertek__UOM_PL__c = wrapper.UOM;
                    // TakeoffLine.buildertek__Cost_Code__c = wrapper.CostCode;
                    String codeco = wrapper.CostCode;
                    if (String.isNotBlank(codeco) && existingCostCodeMap.containsKey(codeco)){
                        TakeoffLine.buildertek__Cost_Code__c = existingCostCodeMap.get(codeco).Id;
                    }
                    TakeoffLinesToInsert.add(TakeoffLine);

            }

            if (!TakeoffLinesToInsert.isEmpty()) {
                insert TakeoffLinesToInsert;
                response.isSuccess = true;
                response.strMessage = 'Takeoff Lines inserted Successfully.';
            } else {
                response.isSuccess = false;
                response.strMessage = 'File is empty.';
            }
        } catch (Exception e) {
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if(StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                BT_ExceptionHandler.Store_Exception(e);
            }
            // returnresponse = 'ERROR: ' + e.getMessage();
            System.debug('error-->' + e.getMessage());
            System.debug('error line--->' + e.getLineNumber());
            response.isSuccess = false;
            response.strMessage = e.getMessage();
        }
        
        return response;
    }

    public class fieldWrapper{
        public String Product;
        public String PriceBook;
        public String Vendor;
        public String ProductSKU;
        public String ProductCode;
        public String BuildPhase;
        public String CategoryPL;
        public String TradeType;
        public String Location;
        public String Quantity;
        public String UOM;
        public String CostCode;
       
    }

    // public class WrapperClass{
    //     public List<List<String>> listOfFileContentsAsStrings;
    //     public Set<String> productNames;
    // }
}