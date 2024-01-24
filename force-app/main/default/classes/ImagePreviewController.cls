public with sharing class ImagePreviewController {
    @AuraEnabled
    public String status;

    @AuraEnabled
    public List<ContentDocumentLink> contentLink;

    @AuraEnabled
    public List<buildertek__Question_Group__c> selectionCategory;

    public class ContentInfo {
        @AuraEnabled public String Id;
        @AuraEnabled public String contentDocumentId;
        @AuraEnabled public String title;
    
        public ContentInfo(String Id, String contentDocumentId, String title) {
            this.Id = Id;
            this.contentDocumentId = contentDocumentId;
            this.title = title;
        }
    }

    public class ApexCalloutWrapper {
        @AuraEnabled
        public Map<String, List<ContentDocumentLink>> productFilesMap { get; set; }
        @AuraEnabled
        public List<buildertek__Question_Group__c> questionGroupDetails { get; set; }
    
        public ApexCalloutWrapper(Map<String, List<ContentDocumentLink>> productFilesMap, List<buildertek__Question_Group__c> questionGroupDetails) {
            this.productFilesMap = productFilesMap;
            this.questionGroupDetails = questionGroupDetails;
        }
    }
    
    @AuraEnabled
    public static ApexCalloutWrapper getData(String recordId) {
        ApexCalloutWrapper result = new ApexCalloutWrapper(new Map<String, List<ContentDocumentLink>>(), new List<buildertek__Question_Group__c>());

        try {
            // Call your existing methods and populate the result instance
            result.productFilesMap = getProductFilesMap(recordId);
            result.questionGroupDetails = selectionTypeDetail(recordId);
        } catch (Exception e) {
            System.debug('Error => ' + e.getMessage());
        }

        return result;
    }

    public class FilesWrapper {
        @AuraEnabled
        public Map<String, List<ContentDocumentLink>> resultMap { get; set; }
        @AuraEnabled
        public String status { get; set; }
    
        public FilesWrapper(Map<String, List<ContentDocumentLink>> resultMap, String status) {
            this.resultMap = resultMap;
            this.status = status;
        }
    }
    
    @AuraEnabled
    public static FilesWrapper getProductFilesMap(String recordId) {
        Map<String, List<ContentDocumentLink>> resultMap = new Map<String, List<ContentDocumentLink>>();
        String status = 'Success';        
        
        try {  
            // Collect buildertek__Question__c Ids
            Set<Id> questionIds = new Set<Id>();
            List<buildertek__Question__c> options = [SELECT Id, Name, buildertek__Question_Group__c, buildertek__Product__c FROM buildertek__Question__c WHERE buildertek__Question_Group__c =: recordId];
            for (buildertek__Question__c option : options) {
                questionIds.add(option.buildertek__Product__c);
            }

            // Perform ContentDocumentLink query outside of the loop
            List<ContentDocumentLink> contentLinkList = [SELECT Id, ContentDocumentId, ContentDocument.title, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :questionIds];

            for (buildertek__Question__c option : options) {
                List<ContentDocumentLink> contentLinks = new List<ContentDocumentLink>();

                for (ContentDocumentLink link : contentLinkList) {
                    if (link.LinkedEntityId == option.buildertek__Product__c) {
                        contentLinks.add(link);
                    }
                }

                // Merge option Name and Id with a symbol for the key
                String optionKey = option.Name + '__' + option.Id;
                resultMap.put(optionKey, contentLinks);
            }
        } catch (Exception e) {
            System.debug('Error => ' + e.getMessage());
            status = 'Fail';
            resultMap = new Map<String, List<ContentDocumentLink>>();
        }

        return new FilesWrapper(resultMap, status);
    }


    // @AuraEnabled
    public static List<buildertek__Question_Group__c> selectionTypeDetail(String recordId) {
        try {  
            List<buildertek__Question_Group__c> selecttype = [SELECT Id, Name FROM buildertek__Question_Group__c WHERE Id =: recordId];
            if (selecttype != null && !selecttype.isEmpty()) {
                return selecttype;
            } else {
                return null;
            }
        } catch (Exception e) {
            System.debug('Error => ' + e.getMessage());
            return null;
        }
    }
    

    @AuraEnabled
    public static ImagePreviewController getSelectionCategoryFiles(String recordId) {
        try {   
            List<ContentDocumentLink> contentLinkList = [SELECT Id,ContentDocument.Title, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId = '0691K00000wF73bQAC'];
            List<buildertek__Question_Group__c> selectionCategoryList = [SELECT Id,Name,buildertek__Section__c FROM buildertek__Question_Group__c WHERE buildertek__Section__c =: recordId];
            System.debug('contentLinkList => '+contentLinkList);

            if (selectionCategoryList.size() > 0) {
                ImagePreviewController files = new ImagePreviewController();
                files.status = 'success';
                files.contentLink = contentLinkList;
                files.selectionCategory = selectionCategoryList;
                return files;
            } else{
                System.debug('There Are No Files');
                ImagePreviewController files = new ImagePreviewController();
                files.status = 'There Are No Files.';
                files.contentLink = null;
                files.selectionCategory = null;
                return files;
            }
        } catch (Exception e) {
            System.debug('Exception-->'+e);
            System.debug('Exception-->'+e.getMessage());
            System.debug('Exception-->'+e.getLineNumber());
            System.debug('Exception-->'+e.getStackTraceString());
            ImagePreviewController files = new ImagePreviewController();
                files.status = 'error';
                files.contentLink = null;
                files.selectionCategory = null;
                return files;
        }
    }
    @AuraEnabled
    public static List<Map<String, String>> getSelectionCategories(String recordId) {
        List<Map<String, String>> categories = new List<Map<String, String>>();
        List<buildertek__Section__c> categoryList = [SELECT Id, Name, buildertek__Selection__c FROM buildertek__Section__c WHERE  buildertek__Selection__c =: recordId ];

        for (buildertek__Section__c category : categoryList) {
            Map<String, String> categoryMap = new Map<String, String>();
            categoryMap.put('Id', category.Id);
            categoryMap.put('Name', category.Name);
            categories.add(categoryMap);
        }

        return categories;
    }
    
    
}