public with sharing class ImagePreviewController {

    @AuraEnabled
    public static Map<String, List<String>> getProductFilesMap(String recordId) {
        Map<String, List<String>> resultMap = new Map<String, List<String>>();          
        try {  
            List<buildertek__Question__c> options = [SELECT Id, Name, buildertek__Question_Group__c, buildertek__Product__c FROM buildertek__Question__c WHERE buildertek__Question_Group__c =: recordId];
            System.debug('options => '+options);

            if (options.size() > 0) {
                for (buildertek__Question__c option : options) {
                    List<String> contentDocumentIds = new List<String>();
                    List<ContentDocumentLink> contentLinkList = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: option.buildertek__Product__c];
                    System.debug('contentLinkList => '+contentLinkList);

                    if (contentLinkList.size() > 0) {
                        for (ContentDocumentLink link : contentLinkList) {
                            contentDocumentIds.add(link.ContentDocumentId);
                        }
                        resultMap.put(option.Name, contentDocumentIds);
                    } else {
                        System.debug('There Are No Files for Option: ' + option.Name);
                        resultMap.put(option.Name, new List<String>());
                    }
                }
            } else {
                System.debug('There Are No Options');
            }

        } catch (Exception e) {
            System.debug('Error => '+e.getMessage());
        }

        return resultMap;
    }
}
