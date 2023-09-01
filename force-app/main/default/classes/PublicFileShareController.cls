public with sharing class PublicFileShareController {

    @AuraEnabled
    public static List<ContentDocumentLink> getContentDocuments( Id recordId){
        try {
            List<ContentDocumentLink> cdlist = new List<ContentDocumentLink>();
            cdlist = [SELECT Id, ContentDocument.Title 
                            FROM ContentDocumentLink
                            WHERE LinkedEntityId = :recordId];

            return cdlist;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<buildertek__Public_Folder__c> getFolderList(){
        try {
            List<buildertek__Public_Folder__c> publicfolders = new List<buildertek__Public_Folder__c>();
            
            publicfolders = [SELECT Id, buildertek__File_Count__c, Name, buildertek__Description__c FROM buildertek__Public_Folder__c];

            return publicfolders;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String createPublicFolder(String Fname, String Fdesc){
        try {
            buildertek__Public_Folder__c publicfol = new buildertek__Public_Folder__c();
            publicfol.Name = Fname;
            publicfol.buildertek__Description__c = Fdesc;

            insert publicfol;

            return 'Success';
            // List<buildertek__Public_Folder__c> publicfolders = new List<buildertek__Public_Folder__c>();
            
            // publicfolders = [SELECT Id, buildertek__File_Count__c, Name, buildertek__Description__c FROM buildertek__Public_Folder__c];

            // return publicfolders;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}