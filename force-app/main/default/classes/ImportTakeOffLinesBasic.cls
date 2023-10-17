public with sharing class ImportTakeOffLinesBasic{
	public virtual class ResponseBase{
		@AuraEnabled
		public Boolean isSuccess;
		@AuraEnabled
		public String strMessage;
		@AuraEnabled
		public String strRecordId;
	}

	@AuraEnabled
	public static ResponseBase importRecords(Id takeOffId, String fileData){
		ResponseBase response = new ResponseBase();
		response.isSuccess = true;
		WrapperClass wrapper = new WrapperClass();
		Set<String> productNames = new Set<String>();
		Set<String> buildPhase = new Set<String>();
		Set<String> tradeType = new Set<String>();
		Set<String> costCode = new Set<String>();
		try{
			if (fileData != null){
				List<List<String>> listCSVData;
				String strFileData;
				Blob fileContent = EncodingUtil.base64Decode(fileData);
				try{
					//strFileData = EncodingUtil.base64Encode(EncodingUtil.base64Decode(fileData));
					strFileData = fileContent.toString();
				} catch (Exception ex){
					try{
						strFileData = EncodingUtil.base64Encode(fileContent);
						System.debug('Message:0:' + ex.getMessage());
						System.debug('Line:0:' + ex.getLineNumber());
					} catch (Exception iex){
						response.isSuccess = false;
						response.strMessage = iex.getMessage();
						System.debug('Message:1:' + iex.getMessage());
						System.debug('Line:1:' + iex.getLineNumber());
					}
				}

				if (!String.isBlank(strFileData) && response.isSuccess){
					List<buildertek__Project_Takeoff_Lines__c> schItemToInsert = new List<buildertek__Project_Takeoff_Lines__c>();
					wrapper = getListOfFileContentsAsStrings(strFileData);
					listCSVData = wrapper.listOfFileContentsAsStrings;
					productNames = wrapper.productNames;
					buildPhase = wrapper.buildPhase;
					tradeType = wrapper.tradeType;
					costCode = wrapper.costCode;
					Map<String, Product2> existingProductMap = new Map<String, Product2>();
					Map<String, Product2> newProductMap = new Map<String, Product2>();
					for (Product2 prod : [Select Id, Name FROM Product2 Limit 1]){
						existingProductMap.put(prod.Name, prod);
					}
					for (String prodName : productNames){
						if (!existingProductMap.containsKey(prodName)){
							Product2 newProd = new Product2();
							newProd.Name = prodName;
							newProductMap.put(prodName, newProd);
						}
					}
					if (newProductMap.size() > 0){
						insert newProductMap.values();
					}
					Map<String, buildertek__Build_Phase__c> buildPhasemap = new Map<String, buildertek__Build_Phase__c>();
					Map<String, buildertek__Build_Phase__c> newbuildPhasemap = new Map<String, buildertek__Build_Phase__c>();
					for (buildertek__Build_Phase__c buildpase : [Select Id, Name FROM buildertek__Build_Phase__c]){
						buildPhasemap.put(buildpase.Name, buildpase);
					}
					for (String buildphas : buildPhase){
						if (!buildPhasemap.containsKey(buildphas)){
							buildertek__Build_Phase__c newbp = new buildertek__Build_Phase__c();
							newbp.Name = buildphas;
							newbuildPhasemap.put(buildphas, newbp);
						}
					}
					if (newbuildPhasemap.size() > 0){
						insert newbuildPhasemap.values();
					}
					Map<String, buildertek__Trade_Type__c> existingtradetype = new Map<String, buildertek__Trade_Type__c>();
					Map<String, buildertek__Trade_Type__c> newtradetype = new Map<String, buildertek__Trade_Type__c>();
					for (buildertek__Trade_Type__c prod : [Select Id, Name FROM buildertek__Trade_Type__c]){
						existingtradetype.put(prod.Name, prod);
					}
					for (String prodName : tradeType){
						if (!existingtradetype.containsKey(prodName)){
							buildertek__Trade_Type__c newProd = new buildertek__Trade_Type__c();
							newProd.Name = prodName;
							newtradetype.put(prodName, newProd);
						}
					}
					if (newtradetype.size() > 0){
						insert newtradetype.values();
					}
					Map<String, buildertek__Cost_Codes__c> existingcostCode = new Map<String, buildertek__Cost_Codes__c>();
					Map<String, buildertek__Cost_Codes__c> newcostCode = new Map<String, buildertek__Cost_Codes__c>();
					for (buildertek__Cost_Codes__c prod : [Select Id, Name FROM buildertek__Cost_Codes__c]){
						existingcostCode.put(prod.Name, prod);
					}
					for (String prodName : costCode){
						if (!existingcostCode.containsKey(prodName)){
							buildertek__Cost_Codes__c newProd = new buildertek__Cost_Codes__c();
							newProd.Name = prodName;
							newcostCode.put(prodName, newProd);
						}
					}
					if (newcostCode.size() > 0){
						insert newcostCode.values();
					}

					for (Integer intIndex = 1; intIndex < listCSVData.size(); intIndex++){
						buildertek__Project_Takeoff_Lines__c takeoffLines = new buildertek__Project_Takeoff_Lines__c(buildertek__Project_Takeoff__c = takeOffId);

						for (Integer intInnerIndex = 0; intInnerIndex < listCSVData.get(intIndex).size(); intInnerIndex++){
							switch on listCSVData.get(0).get(intInnerIndex){
								when 'Product'{
									if (String.isNotBlank(listCSVData.get(intIndex).get(intInnerIndex))){
										String tempProductNames  = listCSVData.get(intIndex).get(intInnerIndex).replace('\n', '');
										if (existingProductMap.containsKey(tempProductNames)){
											takeoffLines.buildertek__Product__c = existingProductMap.get(tempProductNames).Id;
										} else if (newProductMap.containsKey(listCSVData.get(intIndex).get(intInnerIndex))){
											takeoffLines.buildertek__Product__c = newProductMap.get(tempProductNames).Id;
										}
									}
									
								}

								when 'Product SKU'{
									if (String.isNotBlank(listCSVData.get(intIndex).get(intInnerIndex))){
                                        takeoffLines.buildertek__StockKeepingUnit__c = listCSVData.get(intIndex).get(intInnerIndex);
									}
								}

								when 'Product Code'{
									if (String.isNotBlank(listCSVData.get(intIndex).get(intInnerIndex))){
										takeoffLines.buildertek__Product_Code__c = listCSVData.get(intIndex).get(intInnerIndex);
									}
								}

								when 'Build Phase'{
									if (String.isNotBlank(listCSVData.get(intIndex).get(intInnerIndex))){
										String tempbuildphase = listCSVData.get(intIndex).get(intInnerIndex);
										if (buildPhasemap.containsKey(tempbuildphase)){
											takeoffLines.buildertek__Build_Phase__c = buildPhasemap.get(tempbuildphase).Id;
										} else if (newbuildPhasemap.containsKey(listCSVData.get(intIndex).get(intInnerIndex))){
											takeoffLines.buildertek__Build_Phase__c = newbuildPhasemap.get(tempbuildphase).Id;
										}
									}
								}

								when 'CategoryPL'{
                                    if (String.isNotBlank(listCSVData.get(intIndex).get(intInnerIndex))){
									    takeoffLines.buildertek__Category__c = listCSVData.get(intIndex).get(intInnerIndex);
                                    }
								}

								when 'Trade Type'{
									if (String.isNotBlank(listCSVData.get(intIndex).get(intInnerIndex))){
										String temptradetype = listCSVData.get(intIndex).get(intInnerIndex);
										if (existingtradetype.containsKey(temptradetype)){
											takeoffLines.buildertek__Trade_Type__c = existingtradetype.get(temptradetype).Id;
										} else if (newtradetype.containsKey(listCSVData.get(intIndex).get(intInnerIndex))){
											takeoffLines.buildertek__Trade_Type__c = newtradetype.get(temptradetype).Id;
										}
									}
								}

								when 'Location'{
                                    if (String.isNotBlank(listCSVData.get(intIndex).get(intInnerIndex))){
									    takeoffLines.buildertek__Location__c = listCSVData.get(intIndex).get(intInnerIndex);
                                    }
								}

								when 'Quantity'{
                                    if (String.isNotBlank(listCSVData.get(intIndex).get(intInnerIndex))){
									    takeoffLines.buildertek__Quantity__c = Decimal.valueOf(listCSVData.get(intIndex).get(intInnerIndex));
                                    }
								}

								when 'UOM'{
                                    if (String.isNotBlank(listCSVData.get(intIndex).get(intInnerIndex))){
									    takeoffLines.buildertek__UOM_PL__c = listCSVData.get(intIndex).get(intInnerIndex);
                                    }
								}

                                when 'Cost Code'{
									if (String.isNotBlank(listCSVData.get(intIndex).get(intInnerIndex))){
										String tempcostcode = listCSVData.get(intIndex).get(intInnerIndex);
										if (existingcostCode.containsKey(tempcostcode)){
											takeoffLines.buildertek__Cost_Code__c = existingcostCode.get(tempcostcode).Id;
										} else if (newcostCode.containsKey(listCSVData.get(intIndex).get(intInnerIndex))){
											takeoffLines.buildertek__Cost_Code__c = newcostCode.get(tempcostcode).Id;
										}
									}
								}

								when else {
                                    response.isSuccess = false;
                                }
							}
						}
						schItemToInsert.add(takeoffLines);
					}
					if (!schItemToInsert.isEmpty()){
						if (response.isSuccess) {
                            insert schItemToInsert;
                            response.strMessage = 'TakeOff lines inserted successfully.';
                        }
                        else {   
                            response.isSuccess = false;
                            response.strMessage = 'Please check the header.';
                        }
					} else{
						response.isSuccess = false;
						response.strMessage = 'No takeoff lines present.';
					}
				} else{
					response.isSuccess = false;
					response.strMessage = 'Please select valid CSV file.';
				}
			}
		} catch (Exception ex){
			response.isSuccess = false;
			response.strMessage = ex.getMessage();
			System.debug('Message:2:' + ex.getMessage());
			System.debug('Line:2:' + ex.getLineNumber());
		}
		return response;
	}

	/*
	 @ Purpose     : Parse each row and column value into the element of List.
	 @ Parameters  : String [ Contents of CSV file ].
	 @ Return Type : List<List<String>> [ List of rows and Each row will have the list of columns ].
	 */
	public static WrapperClass getListOfFileContentsAsStrings(String strContents){
		WrapperClass wrapper = new WrapperClass();
		List<List<String>> listOfFileContentsAsStrings;
		Set<String> productNames = new Set<String>();
		Set<String> buildPhase = new Set<String>();
		Set<String> tradeType = new Set<String>();
		Set<String> costCode = new Set<String>();
		if (String.isNotBlank(strContents)){
			List<String> listLines;

			if (strContents.contains('\r')){
				// Split up the file contents into List of rows [ Using new line ].
				listLines = strContents.split('\r');
			} else if (strContents.contains('\n')){
				// Split up the file contents into List of rows [ Using new line ].
				listLines = strContents.split('\n');
			}

			if (listLines != Null && !listLines.isEmpty()){
				// Appending cell values separated by New Lines.
				listLines = appendCellValuesSeparatedByNewLines(listLines);
				if (listLines != Null && !listLines.isEmpty()){

					// Split up the each element of the list into List of columns [ Using comma ].
					List<String> listRowContents;
					listOfFileContentsAsStrings = new List<List<String>>();
					for (String line : listLines){

						if (line.contains(',')){
							listRowContents = line.split(',');
							if (listRowContents != Null && !listRowContents.isEmpty()){

								// Appending cell values separated by Commas.
								listRowContents = appendCellValuesSeparatedByCommas(listRowContents);
								if (listRowContents != Null && !listRowContents.isEmpty()){
									listOfFileContentsAsStrings.add(listRowContents);
									productNames.add(listRowContents[0].replace('\n',''));
								}
							}
						}
					}
				}
			}
		}

		wrapper.listOfFileContentsAsStrings = listOfFileContentsAsStrings;
		wrapper.productNames = productNames;
		wrapper.buildPhase = buildPhase;
		wrapper.tradeType = tradeType;
		wrapper.costCode = costCode;
		return wrapper;
	}

	/*
	 @ Purpose     : Appends the CSV cells which are separated by New Line.
	 @ Parameters  : List<String> [ List holds the strings separated by New Line ].
	 @ Return Type : List<String> [ List appends the strings belong to same CSV cell ].
	 */
	public Static List<String> appendCellValuesSeparatedByNewLines(List<String> listValues){

		List<String> listToAppendCellValues;
		if (listValues != Null && !listValues.isEmpty()){

			Boolean isNewLineFound = False;
			String strValueToBeMerged = '';
			listToAppendCellValues = new List<String>();
			Integer intCountDoubleQuotes;

			for (String strValue : listValues){

				if (!isNewLineFound){
					intCountDoubleQuotes = strValue.countMatches('\"');
					if (intCountDoubleQuotes == 1){
						isNewLineFound = True;
					}
				}

				if (isNewLineFound){
					strValueToBeMerged += strValue + '\n';
					if (strValue.contains('\",')){

						intCountDoubleQuotes = strValue.countMatches('\"');
						if (Math.mod(intCountDoubleQuotes, 2) != 0){

							isNewLineFound = False;
							listToAppendCellValues.add(strValueToBeMerged);
							strValueToBeMerged = '';
						}
					}
				} else{
					listToAppendCellValues.add(strValue);
				}
			}
		}
		return listToAppendCellValues;
	}

	/*
	 @ Purpose     : Appends the CSV cells which are separated by Commas.
	 @ Parameters  : List<String> [ List holds the strings separated by Commas ].
	 @ Return Type : List<String> [ List appends the strings belong to same CSV cell ].
	 */
	public static List<String> appendCellValuesSeparatedByCommas(List<String> listValues){

		List<String> listToAppendCellValues;
		if (listValues != Null && !listValues.isEmpty()){

			Boolean isCommaFoundInTheValue;
			listToAppendCellValues = new List<String>();
			String strValueToBeMerged = '';
			Integer intCountDoubleQuotes = 0;

			for (String strValue : listValues){

				if (isCommaFoundInTheValue == Null){
					if (strValue.startsWith('\"')){
						isCommaFoundInTheValue = True;
						if (strValue.endsWith('\"')){
							if (strValue.contains('\n') || strValue.contains('\r')){
								isCommaFoundInTheValue = False;
							} else{
								intCountDoubleQuotes = strValue.countMatches('\"');
								if (Math.mod(intCountDoubleQuotes, 2) == 0){
									isCommaFoundInTheValue = False;
								}
							}
						}
					}
				} else if (strValue.endsWith('\"')){
					intCountDoubleQuotes = strValue.countMatches('\"');
					if (Math.mod(intCountDoubleQuotes, 2) != 0){
						isCommaFoundInTheValue = False;
					}
				}

				if (isCommaFoundInTheValue != Null){
					if (isCommaFoundInTheValue){
						strValueToBeMerged += strValue + ',';
					} else{
						strValueToBeMerged += strValue;
						if (strValueToBeMerged.contains('\"')){
							strValueToBeMerged = strValueToBeMerged.replaceAll('\\\"+', '"');
						}
						listToAppendCellValues.add(strValueToBeMerged);
						strValueToBeMerged = '';
						isCommaFoundInTheValue = Null;
					}
				} else{
					listToAppendCellValues.add(strValue);
				}
			}
		}
		return listToAppendCellValues;
	}

	public class WrapperClass{
		public List<List<String>> listOfFileContentsAsStrings;
		public Set<String> productNames;
		public Set<String> buildPhase;
		public Set<String> tradeType;
		public Set<String> costCode;
	}
}