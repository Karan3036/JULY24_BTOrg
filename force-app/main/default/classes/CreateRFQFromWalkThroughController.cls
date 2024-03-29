public class CreateRFQFromWalkThroughController {
    @AuraEnabled
    public static ResponseBase createRFQFromWT(String walkThroughId) {
        ResponseBase msg = new ResponseBase();
        try {
            
            List<buildertek__RFQ_Item__c> newRFQLines = new List<buildertek__RFQ_Item__c>();

            List<buildertek__Walk_Through_List__c> walkthroughrec = [SELECT Id, buildertek__Description__c, buildertek__Project__c, (SELECT Id, Name, buildertek__Details__c, buildertek__Description__c FROM buildertek__Walk_Through_Line_Items__r) FROM buildertek__Walk_Through_List__c WHERE Id = :walkThroughId];

            if (!walkthroughrec.isEmpty()) {
                buildertek__Walk_Through_Line_Items__c[] walkthroughlines = walkthroughrec[0].buildertek__Walk_Through_Line_Items__r;

                buildertek__RFQ__c newRFQrecord = new buildertek__RFQ__c();
                newRFQrecord.Name = walkthroughrec[0].buildertek__Description__c;
                newRFQrecord.buildertek__Type__c = 'Standard';
                newRFQrecord.buildertek__Project__c = walkthroughrec[0].buildertek__Project__c;
                
                insert newRFQrecord;

                if (walkthroughlines.size() > 0) {
                    for (buildertek__Walk_Through_Line_Items__c walkthroughline : walkthroughlines) {
                        buildertek__RFQ_Item__c newRFQLine = new buildertek__RFQ_Item__c();
                        newRFQLine.buildertek__RFQ_Package__c = newRFQrecord.Id;
                        newRFQLine.Name = walkthroughline.buildertek__Description__c;
                        newRFQLine.buildertek__Quantity__c = 1;
                        newRFQLine.buildertek__Description__c = walkthroughline.buildertek__Details__c;

                        newRFQLines.add(newRFQLine);
                    }

                    if (newRFQLines.size() > 0) {
                        insert newRFQLines;
                        msg.Status = 'Success';
                        msg.Message = 'RFQ is Created Successfully';
                        msg.newRecordId = newRFQrecord.Id;
                    }
                } else {
                    msg.Status = 'Success';
                    msg.Message = 'RFQ is Created Successfully';
                    msg.newRecordId = newRFQrecord.Id;
                }
            } else {
                msg.Status = 'Failed';
                msg.Message = 'Walkthrough record not found';
            }
            
            return msg;
        } catch (Exception exp) {
            msg.Status = 'Failed';
            msg.Message = exp.getMessage();
            System.debug('error--> ' + exp.getMessage());
            System.debug('error line--> ' + exp.getLineNumber());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(exp);
            }
            return msg;
        }
    }

    
    public virtual class ResponseBase {
        @AuraEnabled
        public String Status {get;set;}
        @AuraEnabled
        public String Message {get;set;}
        @AuraEnabled 
        public String newRecordId;
    }
}