public without sharing class AggregatedChildDocsController {

    @AuraEnabled
    public static  List<String> getChildObectName(String projectId){
        List<String> childObjeNameList = new  List<String>();
        List<String> chilRelationName = new  List<String>();
        List<sObject> sobj= new List<sObject>();
        List<String> sObjectNameList =new List<String>();
        List<AggregateResult> aggregateAttachmentParent = [SELECT COUNT(Id) recordsCount, Parent.Type parentType FROM Attachment  GROUP BY Parent.Type];   
        Map<String, String> parentTypeToRelationMap = new Map<String, String>();

        for (ChildRelationship relationship : SObjectType.buildertek__Project__c.getChildRelationships()) {

            childObjeNameList.add(relationship.getChildSObject().getDescribe().getName());
            parentTypeToRelationMap.put(relationship.getChildSObject().getDescribe().getName(), relationship.getRelationshipName());
        }

        // System.debug(parentTypeToRelationMap);

        // for (AggregateResult aggParentObjName : aggregateAttachmentParent) {
        //     String parentType = (String) aggParentObjName.get('parentType');
        //     if (parentTypeToRelationMap.containsKey(parentType)) {-
        //         chilRelationName.add(parentTypeToRelationMap.get(parentType));
        //     }
        // }


        
        // List<String> dynamicQueries = new List<String>();
        // for (String s : chilRelationName) {
        //     String dynamicQuery = 'SELECT Id, Name, (SELECT Id, Name FROM ' + s + ') FROM buildertek__Project__c WHERE Id = \'' + projectId + '\'';
        //     dynamicQueries.add(dynamicQuery);
        // }

        List<AggregateResult> aggregatedResults = [SELECT COUNT(Id) recordsCount, Parent.Type parentType FROM Attachment  WHERE Parent.Type IN :childObjeNameList GROUP BY Parent.Type];   
        for (AggregateResult result : aggregatedResults) {
            System.debug((String) result.get('parentType'));
            sObjectNameList.add((String) result.get('parentType'));
        }
        return sObjectNameList; 
    }
    
    public class objDocumentWrap {
        @AuraEnabled
        public String name;
        @AuraEnabled
        public DateTime fileDate;
        @AuraEnabled
        public String fileId;
        @AuraEnabled
        public String fileType;
        @AuraEnabled
        public String parentId;
        @AuraEnabled
        public String parentName;

    
    } 
    
    @AuraEnabled
    public static  List<objDocumentWrap>  getAttachement(String objectName , String projectId){

        System.debug(objectName);
        List<Attachment> aatachmentList=[Select Id, Name, ContentType, ParentId, BodyLength , Parent.Type ,  Parent.Name  FROM Attachment WHERE ParentId!= null AND Parent.Type=:objectName];

        Map<String, String> parentTypeToRelationMap = new Map<String, String>();
        String chilRelationName = '';

        for (ChildRelationship relationship : SObjectType.buildertek__Project__c.getChildRelationships()){
            parentTypeToRelationMap.put(relationship.getChildSObject().getDescribe().getName(), relationship.getRelationshipName());
            
        }

        for(Attachment att : aatachmentList){
           if(parentTypeToRelationMap.containsKey(att.Parent.Type)){
                chilRelationName =parentTypeToRelationMap.get(att.Parent.Type);
            }
        }

       

        // System.debug(chilRelationName);
        // System.debug(parentTypeToRelationMap);

        String dynamicQuery = 'SELECT Id, Name, (SELECT Id, Name FROM ' + chilRelationName + ') FROM buildertek__Project__c WHERE Id = \'' + projectId + '\'';
        System.debug(dynamicQuery);

       


        // Execute the query
        List<buildertek__Project__c> projectRecords = Database.query(dynamicQuery);

        // Organize child records into a map
        Map<String, List<SObject>> childRecordsMap = new Map<String, List<SObject>>();
        // for (String relationshipName : chilRelationName) {
        childRecordsMap.put(chilRelationName, new List<SObject>());
        // }

        for (buildertek__Project__c project : projectRecords) {
            // for (String relationshipName : chilRelationName) {
                List<SObject> childRecords = project.getSObjects(chilRelationName);
                childRecordsMap.get(chilRelationName).addAll(childRecords);
            // }
        }

        // System.debug(childRecordsMap);

        List<Id> childIdSet= new List<Id>();
        for (String relationshipName : childRecordsMap.keySet()) {
            List<SObject> childRecords = childRecordsMap.get(relationshipName);
            for (SObject childRecord : childRecords) {
                Id childId = (Id) childRecord.get('Id');
                if(!childIdSet.contains(childId)){
                    childIdSet.add(childId);
                }
            }
        }
        System.debug(childIdSet.size());
        System.debug(childIdSet);


        List<objDocumentWrap> documentWrapList = new List<objDocumentWrap>();
        List<Attachment> attachmentList=[Select Id, Name, ContentType, ParentId, BodyLength , Parent.Type ,  Parent.Name  FROM Attachment WHERE ParentId=:childIdSet AND Parent.Type=:objectName];

        System.debug(attachmentList);
        for(Attachment att : attachmentList){
            objDocumentWrap vDoc = new objDocumentWrap();
            vDoc.fileId = att.Id;
            vDoc.name = att.Name;
            vDoc.fileType = att.ContentType;    
            vDoc.parentId = att.ParentId;    
            vDoc.parentName = att.Parent.Name;    
            documentWrapList.add(vDoc);
        }
    
        System.debug('### vDocs : ' + documentWrapList);
    
        return documentWrapList;

    }
   
}