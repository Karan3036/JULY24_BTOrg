public without sharing class AggregatedChildDocsController {

    @AuraEnabled
    public static  List<String> getChildObectName(String projectId){
        List<String> childObjeNameList = new  List<String>();
        List<String> chilRelationName = new  List<String>();
        List<sObject> sobj= new List<sObject>();
        List<String> sObjectNameList =new List<String>();

        for (ChildRelationship relation : SObjectType.buildertek__Project__c.getChildRelationships())
        {
            SObjectType childType = relation.getChildSObject();
            childObjeNameList.add(String.valueOf(childType));
        }

        // List<AggregateResult> aggregateAttachmentParent = [SELECT COUNT(Id) recordsCount, Parent.Type parentType FROM Attachment  GROUP BY Parent.Type];   
        // for (AggregateResult aggParentObjName : aggregateAttachmentParent) {
        //     for (ChildRelationship relationship : SObjectType.buildertek__Project__c.getChildRelationships()) {
        //         String convSobjToString= (String)aggParentObjName.get('parentType');
        //         SObjectType childType = relationship.getChildSObject();
        //         if (String.valueOf(childType) == convSobjToString) {
        //                 String relationshipName  = relationship.getRelationshipName();
        //                 chilRelationName.add(relationshipName);
        //                 break;
        //         }
        //     }
        // }

        List<AggregateResult> aggregateAttachmentParent = [SELECT COUNT(Id) recordsCount, Parent.Type parentType FROM Attachment GROUP BY Parent.Type]; 
        Map<String, String> parentTypeToRelationMap = new Map<String, String>();

        for (ChildRelationship relationship : SObjectType.buildertek__Project__c.getChildRelationships()) {
            parentTypeToRelationMap.put(relationship.getChildSObject().getDescribe().getName(), relationship.getRelationshipName());
        }

        System.debug(parentTypeToRelationMap);
        for (AggregateResult aggParentObjName : aggregateAttachmentParent) {
            String parentType = (String) aggParentObjName.get('parentType');
            if (parentTypeToRelationMap.containsKey(parentType)) {
                chilRelationName.add(parentTypeToRelationMap.get(parentType));
            }
        }

        List<String> dynamicQueries = new List<String>();
        for (String s : chilRelationName) {
            String dynamicQuery = 'SELECT Id, Name, (SELECT Id, Name FROM ' + s + ') FROM buildertek__Project__c WHERE Id = \'' + projectId + '\'';
            dynamicQueries.add(dynamicQuery);
        }

        System.debug(dynamicQueries);


        

        System.debug(chilRelationName);
        

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
    public static  List<objDocumentWrap> getAttachement(String objectName){
        List<objDocumentWrap> documentWrapList = new List<objDocumentWrap>();
        List<Attachment> aatachmentList=[Select Id, Name, ContentType, ParentId, BodyLength , Parent.Type ,  Parent.Name  FROM Attachment WHERE ParentId!= null AND Parent.Type=:objectName];

        for(Attachment att : aatachmentList){
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