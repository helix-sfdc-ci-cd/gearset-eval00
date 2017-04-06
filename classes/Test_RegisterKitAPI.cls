@isTest 
private class Test_RegisterKitAPI {

    static testMethod void kitTestMethod() {
            
       //Creating HM_Agreement
       HM_Agreement agreement1 = new HM_Agreement();
       agreement1.key = '1' ;
       agreement1.version = '1' ;
       agreement1.agreed = true ;
       HM_Agreement agreement2 = new HM_Agreement();
       agreement2.key = '2' ;
       agreement2.version = '2' ;
       agreement2.agreed = true ;
       List<HM_Agreement> agreements = new List<HM_Agreement>();
       agreements.add(agreement1);
       agreements.add(agreement2);
       
       HM_Contact buyerHMCon = new HM_Contact();
       buyerHMCon.firstName = 'kit';
       buyerHMCon.lastName = 'account';
       buyerHMCon.email = 'fName@lName.com';
       buyerHMCon.userId = '';
       buyerHMCon.phone = '9902944899';
       buyerHMCon.biologicalSex = 'Male';
       buyerHMCon.blackNaturally = 'Yes';
       buyerHMCon.agreements = agreements;
       
       HM_Account buyerHMAcc = new HM_Account();
       buyerHMAcc.contact = buyerHMCon;
       
       HM_Kit hmkit = new HM_Kit();
       hmkit.account = buyerHMAcc ;
       hmkit.kitId = '12345';
       
       OrderItem oi = [select id from OrderItem limit 1];
       hmkit.orderProductId= oi.id;   //'H01258692';
            
       HM_OrderLine orderLine1 = new HM_OrderLine();
       orderLine1.quantity = 2;
       orderLine1.sku = '';
       orderLine1.appId = '654321';
       
       HM_OrderLine orderLine2 = new HM_OrderLine();
       orderLine2.quantity = 3;
       orderLine2.sku = '';
       orderLine2.appId = '123456';
       
       List<HM_OrderLine> lineList = new List<HM_OrderLine>();
       lineList.add(orderLine1);
       lineList.add(orderLine2);
       
       // userid blank
       RegisterKitResponse result = RegisterKitAPI.registerKit(hmKit);
       
       hmkit.Account.contact.userId = '123456';
       result = RegisterKitAPI.registerKit(hmKit);
       
       Account createdAccount = [select Name from Account where Name = 'kit account' limit 1];
       
       System.assertEquals('kit account', createdAccount.Name);
       Account acc = new Account (Name = 'Test Account 1');
       insert acc;
       //added 27-2-2017
       Contact con = new Contact(
           FirstName = 'Test',
           LastName = 'Contact',
           AccountId =  acc.Id,
           userid__c = '456789'
       );
       insert con;
       //End
       DateTime regDate = DateTime.newInstance(2016, 11, 11, 6, 6, 0);
       
       hmKit.registeredDate = regDate;
       hmkit.account.contact.userId = '456789';  
       hmkit.account.contact.firstName = 'Tested';  
       hmkit.account.contact.lastName = 'data'; 
       hmkit.account.contact.userId = '456789';
       hmkit.account.contact.phone = '88888888';
       hmkit.account.contact.biologicalSex = 'Female';
       hmkit.account.contact.blackNaturally = 'Yes';
       
       // helix userId exists and match with existing contact
       result = RegisterKitAPI.registerKit(hmKit);
       
       con = [select LastName , FirstName, Account.Name, Phone, Naturally_Black_Hair__c, Biological_Sex__c 
                           from Contact where id = :con.id];
       System.assertEquals('Tested', con.FirstName);
       System.assertEquals('data', con.LastName);
       System.assertEquals('Tested data',con.account.name);
       System.assertEquals('88888888', con.phone);
       System.assertEquals('Yes', con.Naturally_Black_Hair__c);
       System.assertEquals('Female', con.Biological_Sex__c);
       
       oi = [select Registered_Date__c, registeredBy__c from OrderItem where id = :oi.id];
       System.assertEquals(regDate, oi.Registered_Date__c);
       System.assertEquals(con.id, oi.registeredBy__c);
       
       // helix userId does not match with any existing contact
       hmkit.account.contact.userId = '45678909';  
       result = RegisterKitAPI.registerKit(hmKit);
       // new contact record is created with new helix user id
       System.assertEquals('45678909', [select UserId__c from Contact where UserId__c = '45678909' limit 1].UserId__c);
       
       // trying to register same kit again with same contact, return error message
       result = RegisterKitAPI.registerKit(hmKit);
       System.assertEquals('Register kit API to reject kit registration because the contact is already registered to a kit that doesnot have accessioning cancelled status', result.error.message);
       
    }

    @testSetup static void createProductTestData() {
        // First, set up test price book entries.
        // Insert a test product.
        Product2 prod = new Product2(Name = 'Alpha DNA Kit', Type__c = 'KIT', Prep_Request__c = 'Helix Saliva Extraction',
            Delivery_Mode__c = 'Deliver', Sample_Source__c = 'Customer Saliva');
        insert prod;
        
        // Get standard price book ID.
        // This is available irrespective of the state of SeeAllData.
        Id pricebookId = Test.getStandardPricebookId();
        
        // 1. Insert a price book entry for the standard price book.
        // Standard price book entries require the standard price book ID we got earlier.
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, 
            Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Account acc = new Account(Name = 'Test');
        insert acc;
        Order o = new Order(AccountId = acc.id, EffectiveDate = System.today(), Status = 'Draft', Pricebook2Id = pricebookId);
        insert o;
        List<OrderItem> oiList = new List<OrderItem>();
        for(Integer i = 100; i < 700; i++) {
            OrderItem oi = new OrderItem(OrderId = o.id, Required_Yield__c = 4.5, Project_Name__c = 'TestProject_5-31',
                Analysis_Workflow__c = 'ExomePlusFastq2GvcfV1.0-WFV1.0', Sample_Status__c = 'Ready for Submission',
                PricebookEntryId = standardPrice.id, Quantity = 1, UnitPrice = 100);
            oi.Kit_ID__c = 'AAAAAAA' + String.valueOf(i);
            oiList.add(oi);
        }
        insert oiList;
        System.assertEquals(600, oiList.size());
        // Next, perform some tests with your test price book entries.
    }
}