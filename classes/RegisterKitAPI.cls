/*
    @author: Shirish Goel (Thirdwave Analytics)
    @Date: 3/20/2016
    @Purpose: This is the registerkit api
*/
@RestResource(urlMapping='/RegisterKit/*')
global with sharing class RegisterKitAPI {   
    
@HttpPost
global static RegisterKitResponse registerKit( HM_Kit hmKit) {
    try{
    
        Id accId , conId, buyerAccId;
        Contact contact;
        List<OrderItem> orderItemList;
        String userId = hmKit.account.contact.userId;
        
        if(userId == null || userId == ''){
            accId = HMAPI_SFDC_IntegrationUtil.createNewAccount(hmKit.account);
            conId = HMAPI_SFDC_IntegrationUtil.createNewContact(hmKit.account.contact, accId);
        }else{
            //getExistingContact(hmKit.account);
            //When userId is not null, get Contact
            contact = HMAPI_SFDC_IntegrationUtil.getExistingContact(userId);
            
            //checking if the Contact is under Non-Buyer Account
            if(contact != null ){
               // Added to check that contact is already registered for kit then reject the Register kit Api Added on 24-2-20117
               List<OrderItem> oliList = new List<OrderItem>([Select id ,  Kit_Order_Status__c  
                                       from OrderItem Where registeredBy__c  = :contact.Id 
                                       AND Accessioning_Status__c != 'Cancelled']) ;
               if(!oliList.isEmpty()){
                   RegisterKitResponse res = generateResponse('Register kit API to reject kit registration because the contact is already registered to a kit that doesnot have accessioning cancelled status','110',false);
                   return res;
               } 
               Account acc;
               if(contact.AccountId != null){
                   acc = new Account(
                       Id = contact.AccountId
                   );
               }
               
               
               if(hmKit.account.contact != null && hmKit.account.contact.firstName != null){
                   contact.FirstName = hmKit.account.contact.firstName;
                   acc.Name = hmKit.account.contact.firstName+' ';
               }
               if(hmKit.account.contact != null && hmKit.account.contact.lastName != null){    
                   contact.lastName = hmKit.account.contact.lastName; 
                   if(acc.Name != null)
                    acc.Name = acc.Name + hmKit.account.contact.lastName; 
                   else
                    acc.Name =  hmKit.account.contact.lastName;  
               }
               update acc;
               //Added 24-2-2017 ENDED
                                      
               contact.phone = hmKit.account.contact.phone; 
               contact.Naturally_Black_Hair__c = hmKit.account.contact.blackNaturally; 
               contact.Biological_Sex__c = hmKit.account.contact.biologicalSex;
               contact.Birthdate = hmKit.account.contact.dateOfBirth;
               update contact;
               HMAPI_SFDC_IntegrationUtil.createAgreement(hmKit.account.contact, contact.Id);
           
            }else{
            // This scenario covers for new users. Create new account/contact and set user id on the contact
                
                accId = HMAPI_SFDC_IntegrationUtil.createNewAccount(hmKit.account);
                conId = HMAPI_SFDC_IntegrationUtil.createNewContact(hmKit.account.contact, accId);
                
            }
        }
        Id cId = conId != null ? conId : contact.Id;
        try{
            OrderItem oli = new OrderItem(Id = hmKit.orderProductId, registeredBy__c = cId, Kit_Order_Status__c = 'Registered');
            if(hmKit.registeredDate != null) {
                oli.Registered_Date__c = hmKit.registeredDate;
            } else {
                oli.Registered_Date__c = System.now();
            }
            update oli;
        }catch(DMLException dml1){
            RegisterKitResponse res = generateResponse('Invalid Order Product','110',false);
            return res;
        }
        orderItemList = [select Orderid, Order.Registered_By__c  from OrderItem where id = :hmKit.orderProductId];
        
        if(orderItemList.size() > 0){
            OrderItem line = orderItemList[0];
            try{
                    Order o = new Order(Id = line.orderId, Registered_By__c = cId);
                    update o;
                }catch(DMLException dml1){
                    RegisterKitResponse res = generateResponse('Invalid Order Number','105',false);
                    return res;
                }
            
        }
        RegisterKitResponse res = generateResponse(null, null, true);
        return res;
   
    }
      catch(DmlException e){
         //System.debug('The following exception has occurred: ' + e.getMessage());
         RegisterKitResponse response = generateResponse(e.getDMLMessage(0),'101',false);
         return response;
      }
      catch(Exception e){
         //System.debug('DmlException caught: ' + e.getMessage()); 
         RegisterKitResponse response = generateResponse(e.getMessage(),'102',false);
         return response;
      }
    return null;
}
    global static RegisterKitResponse generateResponse(String msg, String code, Boolean registered){
        RegisterKitResponse res = new RegisterKitResponse();
        res.isKitRegistered = registered;
        if(msg != null){
            HMAPIError error = new HMAPIError();
            error.message = msg;
            error.errorCode = code;
            res.error = error;
        }
        return res;
    }
    
}