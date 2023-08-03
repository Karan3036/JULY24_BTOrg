public without sharing class NewScheduleItemController {
        
    @AuraEnabled
    public static WorkOrder getPurchaseOrderData(String recordId){
        WorkOrder pur= [select Id, buildertek__Project__c, buildertek__Project__r.Name, ContactId from WorkOrder where Id =: recordId];
        return pur;     
    }
    
    @AuraEnabled
    public static List<ScheduleWrap> getSchedulelist(String recordId){
        list<Schedule__c> getSchedulesList = [select id, Name, buildertek__Description__c from Schedule__c where buildertek__Project__c =: recordId];
        system.debug('getSchedulesList ---------> '+getSchedulesList);
        list<ScheduleWrap> ScheduleWrapList = new list<ScheduleWrap>(); 
        for(Schedule__c sch : getSchedulesList){
            ScheduleWrap ScheduleWrapRec = new ScheduleWrap();
            ScheduleWrapRec.getSchedulesList = sch;
            ScheduleWrapRec.scheduleCheckbox = false;
            ScheduleWrapList.add(ScheduleWrapRec);
        }
        return ScheduleWrapList;    
    }
    
    
    @AuraEnabled
    public static String insertScheduleTask(String task, String scheduleId, String dependency, Date startdate, String project, String contactorResource){
            buildertek__Project_Task__c projectTask = new buildertek__Project_Task__c();
    
            if (!String.isBlank(task)) {
                projectTask.Name = task; 
            }
            if (!String.isBlank(project)) {
                projectTask.buildertek__Project__c = project;
            }
            if (!String.isBlank(scheduleId)) {
                projectTask.buildertek__Schedule__c = scheduleId;
            }
            if (startdate != null) {
                projectTask.buildertek__Start__c = startdate;
            }
            if (!String.isBlank(contactorResource)) {
                projectTask.buildertek__Contractor_Resource__c = contactorResource;
            }
            if (!String.isBlank(dependency)) {
                projectTask.buildertek__Dependency__c = dependency;
            }
    
            System.debug('projectTask :: '+projectTask);
            insert projectTask; 
            System.debug('projectTask id :: '+projectTask.Id);

            return projectTask.Id;
        
    }
    
    

    @AuraEnabled
    public static  Map<String,String> getPredecessorList(String scheduleId) {
        List<buildertek__Project_Task__c> schduleItemList= [Select Id , Name , buildertek__Schedule__c From buildertek__Project_Task__c  WHERE buildertek__Schedule__c=:scheduleId];
        Map<String,String> predecessorMap= new Map<String, String>();
        for(buildertek__Project_Task__c scheduleItem: schduleItemList){
            predecessorMap.put(scheduleItem.Id , scheduleItem.Name);
        }
        return predecessorMap;

    }

    public Class ScheduleWrap{
       @AuraEnabled public boolean scheduleCheckbox;
       @AuraEnabled public Schedule__c getSchedulesList;
   }
}