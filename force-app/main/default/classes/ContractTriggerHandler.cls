/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved.

Developed By: Sagar
Date:  20-Sep-2017
*/
public without sharing class ContractTriggerHandler{
    //Boolean variable to allow skipping execution of trigger in certain scenarios
    public static Boolean blnSkipContractUpdateTrigger = false;
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    public ContractTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    public void OnBeforeInsert(Contract__c[] newContracts){
        List<buildertek__Contract__c> contractList;
        if (Schema.sObjectType.buildertek__Contract__c.fields.id.isAccessible() && Schema.sObjectType.buildertek__Contract__c.fields.Auto_Number1__c.isAccessible() && Schema.sObjectType.buildertek__Contract__c.fields.Project__c.isAccessible() && Schema.sObjectType.buildertek__Contract__c.fields.CREATEDDATE.isAccessible()){
            
            contractList = [Select Id, buildertek__Auto_Number1__c
                            from buildertek__Contract__c
                            where Project__c = :newContracts[0].Project__c
                            ORDER BY CREATEDDATE DESC
                            LIMIT 1];
            system.debug('contractList -------> ' + contractList);
            
        }
        if (!Test.isRunningTest()){
            BT_Utils.genrateAutoNumber(contractList, newContracts, 'Auto_Number1__c');
        }
    }
    
    public void OnBeforeUpdate(Contract__c[] oldContracts, Contract__c[] updatedContracts, Map<ID, Contract__c> ContractMap){
    }
    
    public void OnBeforeDelete(Contract__c[] ContractToDelete, Map<ID, Contract__c> ContractMap){
        for (buildertek__Contract__c cont : ContractToDelete){
            if (cont.buildertek__Status__c == 'Accepted' || cont.buildertek__Status__c == 'Approved' || cont.buildertek__Status__c == 'Out for Bid' || cont.buildertek__Status__c == 'Out for Signature'){
                cont.adderror('You Cannot be deleted this Contract.Because it has already been ' + cont.buildertek__Status__c);
                
            }
        }
    }
    
    public void OnAfterInsert(Contract__c[] newContracts, Map<ID, Contract__c> newContractsMap){
        SET<Id> projectIds = new SET<Id>();
        RecordType rt;
        // if(Schema.sObjectType.RecordType.fields.id.isAccessible() && Schema.sObjectType.RecordType.fields.Name.isAccessible() && Schema.sObjectType.RecordType.fields.sObjectType.isAccessible()){
        
        rt = [SELECT Id, Name
              FROM RecordType
              WHERE sObjectType = 'buildertek__Contract__c' AND Name = 'Prime Contract'];
        // }
        Map<String, Decimal> contractAmountMap = new Map<String, Decimal>();
        Map<String, Decimal> projectContractAmountMap = new Map<String, Decimal>();
        List<buildertek__Project__c> projectList = new List<buildertek__Project__c>();
        for (buildertek__Contract__c cont : newContracts){
            projectIds.add(cont.buildertek__Project__c);
        }
        if (projectIds.size() > 0){
            List<buildertek__Project__c> projectDetails;
            // if(Schema.sObjectType.buildertek__Project__c.fields.id.isAccessible() && Schema.sObjectType.buildertek__Project__c.fields.buildertek__Contract_Amount__c.isAccessible()){
            projectDetails = [SELECT Id, buildertek__Contract_Amount__c
                              FROM buildertek__Project__c
                              WHERE Id IN :projectIds];
            // }
            for (buildertek__Project__c proj : projectDetails){
                projectContractAmountMap.put(proj.Id, proj.buildertek__Contract_Amount__c);
            }
        }
        for (buildertek__Contract__c cont : newContracts){
            if (cont.RecordTypeId == rt.Id && cont.buildertek__Status__c == 'Approved' && cont.buildertek__Project__c != null){
                system.debug('&&&&&&&&&&&&&&&&&&&'+cont.buildertek__Status__c);
                if (projectContractAmountMap.get(cont.buildertek__Project__c) == null){
                    contractAmountMap.put(cont.Id, cont.buildertek__Revised_Contract_Amount__c);
                } else{
                    decimal finalTotalAmount = projectContractAmountMap.get(cont.buildertek__Project__c)+cont.buildertek__Revised_Contract_Amount__c;
                    contractAmountMap.put(cont.Id, finalTotalAmount);
                }
                buildertek__Project__c proj = new buildertek__Project__c();
                proj.Id = cont.buildertek__Project__c;
                proj.buildertek__Contract_Amount__c = contractAmountMap.get(cont.Id);
                projectList.add(proj);
            }
        }
        if (projectList.size() > 0){
            // if(Schema.sObjectType.buildertek__Project__c.fields.id.isUpdateable() && Schema.sObjectType.buildertek__Project__c.fields.buildertek__Contract_Amount__c.isUpdateable()){
            
            update projectList;
            // }
        }
    }
    
    public void OnAfterUpdate(Contract__c[] oldContracts, Contract__c[] updatedContracts, Map<ID, Contract__c> ContractMap, Map<Id, Contract__c> oldContractsMap){
        system.debug('afterUpdate');
        System.debug(ContractMap);
        System.debug('ContractMap');
        SET<Id> projectIds = new SET<Id>();
        RecordType rt;
        if (Schema.sObjectType.RecordType.fields.id.isAccessible() && Schema.sObjectType.RecordType.fields.Name.isAccessible() && Schema.sObjectType.RecordType.fields.sObjectType.isAccessible()){
            rt = [SELECT Id
                  FROM RecordType
                  WHERE sObjectType = 'buildertek__Contract__c' AND Name = 'Prime Contract'];
        }
        Map<String, Decimal> contractAmountMap = new Map<String, Decimal>();
        Map<String, Decimal> projectContractAmountMap = new Map<String, Decimal>();
        List<buildertek__Project__c> projectList = new List<buildertek__Project__c>();
        for (buildertek__Contract__c cont : updatedContracts){
            projectIds.add(cont.buildertek__Project__c);
        }
        System.debug(projectIds);
        System.debug('projectIds');
        if (projectIds.size() > 0){
            List<buildertek__Project__c> projectDetails;
            projectDetails = [SELECT Id, buildertek__Contract_Amount__c
                              FROM buildertek__Project__c
                              WHERE Id IN :projectIds];
            system.debug('projectDetails--->' + projectDetails);
            for (buildertek__Project__c proj : projectDetails){
                system.debug('projectDetailsamount--->' + proj.buildertek__Contract_Amount__c);
                projectContractAmountMap.put(proj.Id, proj.buildertek__Contract_Amount__c);
            }
        }
        System.debug(updatedContracts);
        System.debug('updatedContracts');
        for (buildertek__Contract__c cont : updatedContracts){
            if (cont.RecordTypeId == rt.Id && cont.buildertek__Status__c == 'Approved' && cont.buildertek__Project__c != null && oldContractsMap.get(cont.Id).buildertek__Status__c != cont.buildertek__Status__c){
                system.debug('%%%%%%%%%%%%%%%%%%%%%----->'+cont.buildertek__Status__c);
                if (projectContractAmountMap.get(cont.buildertek__Project__c) == null){
                    contractAmountMap.put(cont.Id, cont.buildertek__Revised_Contract_Amount__c);
                } else{
                    decimal finalTotalAmount = projectContractAmountMap.get(cont.buildertek__Project__c)+cont.buildertek__Revised_Contract_Amount__c;
                    contractAmountMap.put(cont.Id, finalTotalAmount);
                }
                Boolean projectExists = false;
                    for (buildertek__Project__c existingProj : projectList) {
                        if (existingProj.Id == cont.buildertek__Project__c) {
                            projectExists = true;
                            break;
                        }
                    }
                    if (!projectExists) {
                        buildertek__Project__c proj = new buildertek__Project__c();
                        proj.Id = cont.buildertek__Project__c;
                        proj.buildertek__Contract_Amount__c = contractAmountMap.get(cont.Id);
                        projectList.add(proj);
                        }                
            } else if (cont.RecordTypeId == rt.Id && oldContractsMap.get(cont.Id).buildertek__Status__c == 'Approved' && cont.buildertek__Status__c != 'Approved'){
                if (projectContractAmountMap.get(cont.buildertek__Project__c) != null){
                    System.debug('5');
                    decimal finalTotalAmount = projectContractAmountMap.get(cont.buildertek__Project__c)-cont.buildertek__Revised_Contract_Amount__c;
                    Boolean projectExists = false;
                    for (buildertek__Project__c existingProj : projectList) {
                        if (existingProj.Id == cont.buildertek__Project__c) {
                            projectExists = true;
                            break;
                        }
                    }
                    if (!projectExists) {
                        buildertek__Project__c proj = new buildertek__Project__c();
                        proj.Id = cont.buildertek__Project__c;
                        proj.buildertek__Contract_Amount__c = finalTotalAmount;
                        projectList.add(proj);
                    }
                }
            } else if (cont.RecordTypeId == rt.Id && oldContractsMap.get(cont.Id).buildertek__Status__c == cont.buildertek__Status__c && cont.buildertek__Status__c == 'Approved' && oldContractsMap.get(cont.Id).buildertek__Revised_Contract_Amount__c != cont.buildertek__Revised_Contract_Amount__c){
                if (projectContractAmountMap.get(cont.buildertek__Project__c) != null){
                    System.debug('6');
                    decimal finalTotalAmount = projectContractAmountMap.get(cont.buildertek__Project__c)-oldContractsMap.get(cont.Id).buildertek__Revised_Contract_Amount__c;
                    finalTotalAmount = finalTotalAmount + cont.buildertek__Revised_Contract_Amount__c;
                    
                    Boolean projectExists = false;
                    for (buildertek__Project__c existingProj : projectList) {
                        if (existingProj.Id == cont.buildertek__Project__c) {
                            projectExists = true;
                            break;
                        }
                    }
                    if (!projectExists) {
                        buildertek__Project__c proj = new buildertek__Project__c();
                        proj.Id = cont.buildertek__Project__c;
                        proj.buildertek__Contract_Amount__c = finalTotalAmount;
                        projectList.add(proj);
                    }
                }
            }
        }
        System.debug('projectlist---> '+projectList);
        if (projectList.size() > 0){
            update projectList;
            
        }
    }
    
    public void OnBeforeUpdate(Contract__c[] newContracts, Map<ID, Contract__c> newContractsMap){
    }
    
    public void OnAfterDelete(Contract__c[] oldContracts){
        SET<Id> projectIds = new SET<Id>();
        RecordType rt;
        Map<String, Decimal> contractAmountMap = new Map<String, Decimal>();
        Map<String, Decimal> projectContractAmountMap = new Map<String, Decimal>();
        rt = [SELECT Id
              FROM RecordType
              WHERE sObjectType = 'buildertek__Contract__c' AND Name = 'Prime Contract'];
        List<buildertek__Project__c> projectList = new List<buildertek__Project__c>();
        for (buildertek__Contract__c cont : oldContracts){
            projectIds.add(cont.buildertek__Project__c);
        }
        if (projectIds.size() > 0){
            List<buildertek__Project__c> projectDetails;
            // if(Schema.sObjectType.buildertek__Project__c.fields.id.isAccessible() && Schema.sObjectType.buildertek__Project__c.fields.buildertek__Contract_Amount__c.isAccessible()){
            projectDetails = [SELECT Id, buildertek__Contract_Amount__c
                              FROM buildertek__Project__c
                              WHERE Id IN :projectIds];
            // }
            for (buildertek__Project__c proj : projectDetails){
                projectContractAmountMap.put(proj.Id, proj.buildertek__Contract_Amount__c);
            }
        }
        /*Commented because not used - 07-06-2021*/
       /* for (buildertek__Contract__c cont : oldContracts){
            if (cont.buildertek__Project__c != null){
                decimal finalTotalAmount = projectContractAmountMap.get(cont.buildertek__Project__c)-cont.buildertek__Revised_Contract_Amount__c != null ? cont.buildertek__Revised_Contract_Amount__c : 0;
                contractAmountMap.put(cont.Id, finalTotalAmount);
            }
        }*/
        if (projectList.size() > 0){
            update projectList;
        }
    }
    
    
    public void AfterUpdateRSalesPrice(Contract__c[] newContracts){
                    decimal amount = 0;
            for (buildertek__Contract__c co : newContracts){
                
                if(co.buildertek__Budget__c != null){
                     buildertek__Budget__c po = [SELECT Id, buildertek__Project_Sales_Price__c,buildertek__Sales_Price__c,buildertek__Current_Contract_Amount__c  FROM buildertek__Budget__c WHERE Id = :co.buildertek__Budget__c];
                
                List<buildertek__Contract__c> l_co = [SELECT Id, buildertek__Revised_Contract_Amount__c FROM buildertek__Contract__c WHERE buildertek__Budget__c = :po.Id];
                for(buildertek__Contract__c am_co : l_co) {
                    amount = am_co.buildertek__Revised_Contract_Amount__c;  
                }
                po.buildertek__Project_Sales_Price__c = amount;
                    po.buildertek__Current_Contract_Amount__c = amount;
                update po;
                
                }
               
                
            }
            
        }
      
    // public void updateProjectContractAmount(Contract__c[] newContracts){
    //     SET<Id> projectIds = new SET<Id>();

    //     for (buildertek__Contract__c cont : newContracts){
    //         projectIds.add(cont.buildertek__Project__c);
    //     }
        
    //     AggregateResult[] groupedResults=[SELECT buildertek__Project__c, SUM(buildertek__Contract_Amount__c)contractAmt FROM buildertek__Contract__c WHERE  buildertek__Project__c IN:projectIds AND buildertek__Status__c='Approved' AND  RecordType.Name='Prime Contract' GROUP BY buildertek__Project__c];

    //     // Create a map to store the contractAmt values by project ID
    //     Map<Id, Decimal> projectContractAmtMap = new Map<Id, Decimal>();
    //     for (AggregateResult result : groupedResults) {
    //         Id projectId = (Id)result.get('buildertek__Project__c');
    //         Decimal contractAmt = (Decimal)result.get('contractAmt');
    //         projectContractAmtMap.put(projectId, contractAmt);
    //     }

    //     // Now you can access the contractAmt value for a specific project ID
    //     List<buildertek__Project__c> projectList=[SELECT Id, buildertek__Contract_Amount__c From buildertek__Project__c WHERE Id IN: projectIds];
    //     List<buildertek__Project__c> newProjectList= new List<buildertek__Project__c>();

    //     for(buildertek__Project__c project:projectList){
    //         project.buildertek__Contract_Amount__c=projectContractAmtMap.get(project.Id);
    //         newProjectList.add(project);
    //     }
    //     if(newProjectList.size() > 0){
    //         update newProjectList;
    //     }

    // }

    public void onAfterInsertForProject(List<buildertek__Contract__c> newContractList) {
        try {
            Set<Id> ProjectIds = new Set<Id>();
            for (buildertek__Contract__c contract : newContractList) {
                if(contract.buildertek__Project__c != null) {
                    ProjectIds.add(contract.buildertek__Project__c);
                }
            }
            updateAmountOnProject(ProjectIds);
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(ex);
            }
        }
    }
    
    public void onAfterUpdateForProject(List<buildertek__Contract__c> newContractList, Map<Id, buildertek__Contract__c> oldContractMap) {
        try {
            Set<Id> ProjectIds = new Set<Id>();
    
            for (buildertek__Contract__c contract : newContractList) {
                buildertek__Contract__c oldContract = oldContractMap.get(contract.Id);
    
                if (contract.buildertek__Project__c != oldContract.buildertek__Project__c ||
                    contract.buildertek__Contract_Amount__c != oldContract.buildertek__Contract_Amount__c ||
                    contract.buildertek__Tax_Rate__c != oldContract.buildertek__Tax_Rate__c ||
                    contract.buildertek__Discount_Amount__c != oldContract.buildertek__Discount_Amount__c ||
                    contract.buildertek__Markup_Amount__c != oldContract.buildertek__Markup_Amount__c ||
                    contract.buildertek__Markup__c != oldContract.buildertek__Markup__c ||
                    contract.buildertek__Discount__c != oldContract.buildertek__Discount__c ||
                    contract.buildertek__Status__c != oldContract.buildertek__Status__c ||
                    contract.RecordTypeId != oldContract.RecordTypeId) {
                        if(oldContract.buildertek__Project__c != null){
                            ProjectIds.add(oldContract.buildertek__Project__c);
                        }
                        
                        if(contract.buildertek__Project__c != null){
                            ProjectIds.add(contract.buildertek__Project__c);
                        }
                }
            }
    
            if (!ProjectIds.isEmpty()) {
                updateAmountOnProject(ProjectIds);
            }
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
    
            List<buildertek__Exception_Log_Store_Option__c> storeExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            
            if (!storeExcCustomSetting.isEmpty() && storeExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(ex);
            }
        }
    }    

    public void onAfterDeleteForProject(List<buildertek__Contract__c> oldContractList) {
        try {
            Set<Id> ProjectIds = new Set<Id>();
            for (buildertek__Contract__c contract : oldContractList) {
                if(contract.buildertek__Project__c != null){
                    ProjectIds.add(contract.buildertek__Project__c);
                }
            }
            updateAmountOnProject(ProjectIds);
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(ex);
            }
        }
    }

    public void updateAmountOnProject(Set<Id> ProjectIds) {
        try {
            Map<Id, AggregateResult> totalAmountMap = new Map<Id, AggregateResult>();
            for (AggregateResult aggregatedResult : [SELECT buildertek__Project__c, SUM(buildertek__Contract_Amount_Tax_Discount_SH__c) totalTaxAmount FROM buildertek__Contract__c WHERE buildertek__Project__c IN :ProjectIds AND buildertek__Status__c = 'Approved' AND  RecordType.Name = 'Prime Contract' GROUP BY buildertek__Project__c]){
                Id ProId = (Id)aggregatedResult.get('buildertek__Project__c');
                totalAmountMap.put(ProId, aggregatedResult);
            }
            
            List<buildertek__Project__c> projectToUpdate = new List<buildertek__Project__c>();
            
            for (Id ProjectId :ProjectIds) {
                buildertek__Project__c project = new buildertek__Project__c(Id = ProjectId);
                if(totalAmountMap.containsKey(ProjectId)) {
                    AggregateResult aggregatedResult = totalAmountMap.get(ProjectId);
                    Decimal totalTaxAmount = (Decimal)aggregatedResult.get('totalTaxAmount');

                    project.buildertek__Contract_Amount__c = totalTaxAmount;
                    projectToUpdate.add(project);
                } else {
                    project.buildertek__Contract_Amount__c = 0;
                    projectToUpdate.add(project);
                }
            }
            System.debug('projectToUpdate: ' + projectToUpdate);
            if (!projectToUpdate.isEmpty()) {
                update projectToUpdate;
            }

        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(ex);
            }
        }
    }
   
    
    
    
}