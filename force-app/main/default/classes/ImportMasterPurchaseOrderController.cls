public with sharing class ImportMasterPurchaseOrderController {

    @AuraEnabled
    public static object getMasterPO(){
        try {
            list<buildertek__Purchase_Order__c> masterPOList;

            masterPOList = [SELECT Id, Name, buildertek__Type__c, buildertek__PO_Total__c , buildertek__Description__c FROM buildertek__Purchase_Order__c 
                                                WHERE buildertek__PO_Type__c = 'Master'
                                                ORDER BY Name
                                                ASC limit 50000]; 
                                                                            
            List<MasterPOClass> MasterPOClassList = new List<MasterPOClass>();
            for(buildertek__Purchase_Order__c masterPO : masterPOList){
                MasterPOClass MasterPOClassRecord = new MasterPOClass(); 
                MasterPOClassRecord.masterPORecord = masterPO;
                MasterPOClassRecord.poCheck = false;
                MasterPOClassList.add(MasterPOClassRecord);
            }

            return  MasterPOClassList;   
        } catch (Exception e) {
            System.debug('Error--> '+e.getMessage());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                BT_ExceptionHandler.Store_Exception(e);
            }
            return null;
        }                                      
    }
    
    @AuraEnabled
    public static MessageClass importMasterPOLines(List<String> poIds, String recordId){
        MessageClass msg = new MessageClass();
        try{
            List<buildertek__Purchase_Order_Item__c> insplinelst = [SELECT Id, Name, buildertek__Purchase_Order__c, buildertek__Quantity__c, buildertek__Description__c, buildertek__Tax__c, buildertek__Cost_Code__c FROM buildertek__Purchase_Order_Item__c WHERE buildertek__Purchase_Order__c =: poIds];

            List<buildertek__Purchase_Order_Item__c> newinslst = new List<buildertek__Purchase_Order_Item__c>();
            for (buildertek__Purchase_Order_Item__c ins : insplinelst) {
                buildertek__Purchase_Order_Item__c newinsp = new buildertek__Purchase_Order_Item__c();
                newinsp.buildertek__Purchase_Order__c = recordId;
                newinsp.Name = ins.Name;
                newinsp.buildertek__Quantity__c = ins.buildertek__Quantity__c;
                newinsp.buildertek__Description__c = ins.buildertek__Description__c;
                newinsp.buildertek__Tax__c = ins.buildertek__Tax__c;
                newinsp.buildertek__Cost_Code__c = ins.buildertek__Cost_Code__c;
                newinslst.add(newinsp);
            }
            if (newinslst.size() > 0) {
                insert newinslst;
                msg.Status = 'Success';
                msg.Message = 'PO Lines Imported Successfully';
            } else{
                msg.Status = 'Failed';
                msg.Message = 'There were no PO Lines for the selected PO';    
            }
            return msg;
        }catch(Exception exp){
            msg.Status = 'Failed';
            msg.Message = exp.getMessage();  
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                BT_ExceptionHandler.Store_Exception(exp);
            }
            return msg;
        }                                             
    }
    
    public class MasterPOClass{
         @AuraEnabled
         public buildertek__Purchase_Order_Item__c poRecord {get;set;}
         @AuraEnabled
         public buildertek__Purchase_Order__c masterPORecord {get;set;}
         @AuraEnabled
         public boolean poCheck {get;set;}
    }
    
    public class MessageClass{
        @AuraEnabled
        public String Status {get;set;}
         @AuraEnabled
        public string Message {get;set;}
        
    } 

    @AuraEnabled
    public static string getcurrency(){
       return UserInfo.getDefaultCurrency();
    }
}