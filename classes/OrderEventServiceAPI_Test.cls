@isTest
private class OrderEventServiceAPI_Test {

	@testSetup
	static void testSetup() {
		Product2 kitProd = new Product2(Name = 'KIT Product', ProductCode = '4172', Type__c = 'KIT',
            Prep_Request__c = 'Helix Saliva Extraction', Delivery_Mode__c = 'Deliver', Sample_Source__c = 'Customer Saliva', IsCancellationAllowed__c = true);

        Product2 appProd = new Product2(Name = 'APP Product', ProductCode = 'APP-001', Type__c = 'APP',
            Prep_Request__c = 'Helix Saliva Extraction', Delivery_Mode__c = 'Deliver', Sample_Source__c = 'Customer Saliva',
            Processing_Fee__c = 250, App_Content_Value__c = 250, Partner_Revenue_Share_PCT__c = 20, IsCancellationAllowed__c = true);

        Product2 refFeeProd = new Product2(Name = 'Referral Fee', ProductCode = System.Label.Helix_Referral_Fee, Type__c = 'HELIX REFERRAL FEE',
            Prep_Request__c = 'Helix Saliva Extraction', Delivery_Mode__c = 'Deliver', Sample_Source__c = 'Customer Saliva', IsCancellationAllowed__c = true);

        Product2 seqRevProd = new Product2(Name = 'Sequence Revenue', ProductCode = System.Label.Helix_Sequence_Revenue, Type__c = 'HELIX SEQUENCE REVENUE',
            Prep_Request__c = 'Helix Saliva Extraction', Delivery_Mode__c = 'Deliver', Sample_Source__c = 'Customer Saliva', IsCancellationAllowed__c = true);

        Product2 revShareProd = new Product2(Name = 'Revenue Share', ProductCode = System.Label.Partner_Revenue_Share, Type__c = 'PARTNER REVENUE SHARE',
            Prep_Request__c = 'Helix Saliva Extraction', Delivery_Mode__c = 'Deliver', Sample_Source__c = 'Customer Saliva', IsCancellationAllowed__c = true);

        Product2 kitRevProd = new Product2(Name = 'Kit Revenue', ProductCode = System.Label.Kit_Revenue, Type__c = 'OTHER',
            Prep_Request__c = 'Helix Saliva Extraction', Delivery_Mode__c = 'Deliver', Sample_Source__c = 'Customer Saliva', IsCancellationAllowed__c = true);

        Id shippingRTId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('S&H RT').getRecordTypeId();
        Product2 shipProd = new Product2(Name = 'Shipping Product', ProductCode = 'Shipping Product', Type__c = 'S&H',
            Prep_Request__c = 'Helix Saliva Extraction', Delivery_Mode__c = 'Deliver', Sample_Source__c = 'Customer Saliva',
            RecordTypeId = shippingRTId, IsCancellationAllowed__c = true);
        //create Sales Tax SKU
        Id otherRTId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Other RT').getRecordTypeId();
        Product2 salesTaxProd = new Product2(Name = 'Sales Tax', ProductCode = System.Label.Sales_Tax_Product_Code, Type__c = 'SALES TAX',
            RecordTypeId = otherRTId, IsCancellationAllowed__c = true);
        List<Product2> prodList = new List<Product2>();
        prodList.add(kitProd);
        prodList.add(appProd);
        prodList.add(refFeeProd);
        prodList.add(seqRevProd);
        prodList.add(revShareProd);
        prodList.add(kitRevProd);
        prodList.add(shipProd);
        prodList.add(salesTaxProd);
        insert prodList;

        Id pricebookId = Test.getStandardPricebookId();

        PricebookEntry standardPriceKit = new PricebookEntry(Pricebook2Id = pricebookId,
            Product2Id = kitProd.Id, UnitPrice = 10000, IsActive = true);
        PricebookEntry standardPriceApp = new PricebookEntry(Pricebook2Id = pricebookId,
            Product2Id = appProd.Id, UnitPrice = 20000, IsActive = true);
        PricebookEntry standardPriceRefFee = new PricebookEntry(Pricebook2Id = pricebookId,
            Product2Id = refFeeProd.Id, UnitPrice = 30000, IsActive = true);
        PricebookEntry standardPriceSeqRev = new PricebookEntry(Pricebook2Id = pricebookId,
            Product2Id = seqRevProd.Id, UnitPrice = 40000, IsActive = true);
        PricebookEntry standardPriceRevShare = new PricebookEntry(Pricebook2Id = pricebookId,
            Product2Id = revShareProd.Id, UnitPrice = 50000, IsActive = true);
        PricebookEntry standardPriceKitRev = new PricebookEntry(Pricebook2Id = pricebookId,
            Product2Id = kitRevProd.Id, UnitPrice = 60000, IsActive = true);
        PricebookEntry standardPriceShipProd = new PricebookEntry(Pricebook2Id = pricebookId,
            Product2Id = shipProd.Id, UnitPrice = 70000, IsActive = true);
        PricebookEntry standardPriceSalesTaxProd = new PricebookEntry(Pricebook2Id = pricebookId,
            Product2Id = salesTaxProd.Id, UnitPrice = 70000, IsActive = true);
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        pbeList.add(standardPriceKit);
        pbeList.add(standardPriceApp);
        pbeList.add(standardPriceRefFee);
        pbeList.add(standardPriceSeqRev);
        pbeList.add(standardPriceRevShare);
        pbeList.add(standardPriceKitRev);
        pbeList.add(standardPriceShipProd);
        pbeList.add(standardPriceSalesTaxProd);
        insert pbeList;

        Account acc = new Account(Name = 'Test', Partner_ID__c = System.Label.Helix_Partner_Id);
        insert acc;
        Contact con = new Contact(LastName = 'Test', AccountId = acc.id, Email = 'test@test.com', UserId__c = System.Label.Helix_Partner_Id, Sourcing_Partner__c = acc.id);
        insert con;

        Partner_Shipping_Option__c shipOption = new Partner_Shipping_Option__c(Carrier__c = 'Fedex', Service_Level__c = 'standard_overnight',
                    Partner_Account__c = acc.id, Shipping_Product__c = shipProd.id, Default_Price__c = 100, Rate_1_kit__c = 20,
                    Rate_2_kits__c = 30, Rate_3_kits__c = 48, Rate_4_kits__c = 120, Rate_5_kits__c = 200);
        insert shipOption;
	}

	@isTest
	static void test_cancelandrefund() {

		Account hxAccount = new Account(Name = 'Helix');
		insert hxAccount;
		Account account = new Account(Name = 'New Account');
		insert account;
		System.assertNotEquals(null, account.Id);

		SuperOrder__c so = new SuperOrder__c();
		insert so;

		Order order = new Order();
		order.AccountId = account.Id;
		order.Partner_Channel__c = hxAccount.Id;
		order.SuperOrder__c = so.Id;
		order.Pricebook2Id = Test.getStandardPricebookId();
		order.EffectiveDate = System.today();
		order.Status = 'Draft';
		insert order;
		System.assertNotEquals(null, order.Id);

		List<OrderItem> oiList = new List<OrderItem>();
		for (PricebookEntry pe : [SELECT Id FROM PricebookEntry]) {
			OrderItem orderItem1 = new OrderItem();
			orderItem1.OrderId = order.Id;
			orderItem1.Quantity = 1;
			orderItem1.PricebookentryId = pe.Id;
			orderItem1.UnitPrice = 50.00;
			oiList.add(orderItem1);
		}
		insert oilist;

		Test.startTest();

		Integer result = [SELECT Count() FROM Order_Event__c WHERE Order__c = :order.Id];
		System.assertEquals(0, result);

		String request = '{"orderId": "' + order.Id + '",';
		request += '"cancelOrder": true,';
		request += '"cancellationReason": "Service Issue",';
		request += '"refundOrder": true,';
		request += '"refundType": "Full",';
		request += '"refundReason": "Service Issue"}';

		RestRequest restRequest = new RestRequest();
		restRequest.requestBody = Blob.valueOf(request);

		RestContext.request = restRequest;
		RestContext.response = new RestResponse();

		OrderEventService.CancelOrRefundResponseModel response = OrderEventServiceAPI.cancelOrrefund();
		System.assertEquals('Refund and/or cancellation complete.', response.status, 'Test failed to complete cancellation or refund flow for test order.');

		Order_Event__c orderEvent = [SELECT Id, Type__c FROM Order_Event__c WHERE Order__c = :order.Id LIMIT 1];
		System.assertEquals('Cancel & Refund', orderEvent.Type__c, 'Failed to find expected order event of type "Cancel & Refund" related to test order.');

		Test.stopTest();

	}

	@isTest
	static void test_cancel() {

		Account hxAccount = new Account(Name = 'Helix');
		insert hxAccount;
		Account account = new Account(Name = 'New Account');
		insert account;
		System.assertNotEquals(null, account.Id);

		SuperOrder__c so = new SuperOrder__c();
		insert so;

		Order order = new Order();
		order.AccountId = account.Id;
		order.Partner_Channel__c = hxAccount.Id;
		order.SuperOrder__c = so.Id;
		order.Pricebook2Id = Test.getStandardPricebookId();
		order.EffectiveDate = System.today();
		order.Status = 'Draft';
		insert order;
		System.assertNotEquals(null, order.Id);

		List<OrderItem> oiList = new List<OrderItem>();
		for (PricebookEntry pe : [SELECT Id FROM PricebookEntry]) {
			OrderItem orderItem1 = new OrderItem();
			orderItem1.OrderId = order.Id;
			orderItem1.Quantity = 1;
			orderItem1.PricebookentryId = pe.Id;
			orderItem1.UnitPrice = 50.00;
			oiList.add(orderItem1);
		}
		insert oilist;

		Test.startTest();

		Integer result = [SELECT Count() FROM Order_Event__c WHERE Order__c = :order.Id];
		System.assertEquals(0, result);

		String request = '{"orderId": "' + order.Id + '",';
		request += '"cancelOrder": true,';
		request += '"cancellationReason": "Service Issue",';
		request += '"refundOrder": false,';
		request += '"refundType": "",';
		request += '"refundReason": ""}';

		RestRequest restRequest = new RestRequest();
		restRequest.requestBody = Blob.valueOf(request);

		RestContext.request = restRequest;
		RestContext.response = new RestResponse();

		OrderEventService.CancelOrRefundResponseModel response = OrderEventServiceAPI.cancelOrrefund();
		System.assertEquals('Refund and/or cancellation complete.', response.status, 'Test failed to complete cancellation flow for test order.');

		Order_Event__c orderEvent = [SELECT Id, Type__c FROM Order_Event__c WHERE Order__c = :order.Id LIMIT 1];
		System.assertEquals('Cancel', orderEvent.Type__c, 'Failed to find expected order event of type "Cancel" related to test order.');

		Test.stopTest();

	}

	@isTest
	static void test_refund() {

		Account hxAccount = new Account(Name = 'Helix');
		insert hxAccount;
		Account account = new Account(Name = 'New Account');
		insert account;
		System.assertNotEquals(null, account.Id);

		SuperOrder__c so = new SuperOrder__c();
		insert so;

		Order order = new Order();
		order.AccountId = account.Id;
		order.Partner_Channel__c = hxAccount.Id;
		order.SuperOrder__c = so.Id;
		order.Pricebook2Id = Test.getStandardPricebookId();
		order.EffectiveDate = System.today();
		order.Status = 'Draft';
		insert order;
		System.assertNotEquals(null, order.Id);

		List<OrderItem> oiList = new List<OrderItem>();
		for (PricebookEntry pe : [SELECT Id FROM PricebookEntry]) {
			OrderItem orderItem1 = new OrderItem();
			orderItem1.OrderId = order.Id;
			orderItem1.Quantity = 1;
			orderItem1.PricebookentryId = pe.Id;
			orderItem1.UnitPrice = 50.00;
			oiList.add(orderItem1);
		}
		insert oilist;

		Test.startTest();

		Integer result = [SELECT Count() FROM Order_Event__c WHERE Order__c = :order.Id];
		System.assertEquals(0, result);

		String request = '{"orderId": "' + order.Id + '",';
		request += '"cancelOrder": false,';
		request += '"cancellationReason": "",';
		request += '"refundOrder": true,';
		request += '"refundType": "Full",';
		request += '"refundReason": "Service Issue"}';

		RestRequest restRequest = new RestRequest();
		restRequest.requestBody = Blob.valueOf(request);

		RestContext.request = restRequest;
		RestContext.response = new RestResponse();

		OrderEventService.CancelOrRefundResponseModel response = OrderEventServiceAPI.cancelOrrefund();
		System.assertEquals('Refund and/or cancellation complete.', response.status, 'Test failed to complete refund flow for test order.');

		Order_Event__c orderEvent = [SELECT Id, Type__c FROM Order_Event__c WHERE Order__c = :order.Id LIMIT 1];
		System.assertEquals('Refund', orderEvent.Type__c, 'Failed to find expected order event of type "Refund" related to test order.');

		Test.stopTest();
	}
}