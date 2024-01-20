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
    
    @AuraEnabled
    public static Map<String, Map<String, List<ContentInfo>>> getProductFilesMap(String recordId) {
        Map<String, Map<String, List<ContentInfo>>> resultMap = new Map<String, Map<String, List<ContentInfo>>>();          
    
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
                Map<String, List<ContentInfo>> optionMap = new Map<String, List<ContentInfo>>();
                List<ContentInfo> contentInfos = new List<ContentInfo>();
    
                for (ContentDocumentLink link : contentLinkList) {
                    if (link.LinkedEntityId == option.buildertek__Product__c) {
                        contentInfos.add(new ContentInfo(link.Id, link.ContentDocumentId, link.ContentDocument.title));
                    }
                }
    
                optionMap.put(option.Name, contentInfos);
                resultMap.put(option.Id, optionMap);
            }
        } catch (Exception e) {
            System.debug('Error => ' + e.getMessage());
        }
    
        return resultMap;
    }

    @AuraEnabled
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
            List<ContentDocumentLink> contentLinkList = [SELECT Id,ContentDocument.Title, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: recordId LIMIT 1];
            List<buildertek__Question_Group__c> selectionCategoryList = [SELECT Id,Name,buildertek__Section__c FROM buildertek__Question_Group__c WHERE buildertek__Section__c =: recordId];
            System.debug('contentLinkList => '+contentLinkList);

            if (contentLinkList.size() > 0 && selectionCategoryList.size() > 0) {
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
}