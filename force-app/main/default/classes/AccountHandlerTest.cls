/**
 * @description : AccountHandlerTest is used to test all the methods in AccountHandler class.
 * @group : AccountHandlerMock.cls, AccountHandler.cls
 */
@isTest
private class AccountHandlerTest {
    @TestSetup
    static void makeData(){
        List<Account> lstAcc = new List<Account>();
        for (Integer i = 0; i < 200; i++){
            Account acc = new Account(Name = 'Account' + i, MissionStatus__c = 'active');
            lstAcc.add(acc);
        }
        insert lstAcc;

        List<Contact> lstContact = new List<Contact>();
        Integer index = 0;
        for(Account acc : lstAcc){
            Contact con = new Contact(LastName = 'LastName' + index, FirstName = 'FirstName' + index, 
                            AccountId = acc.Id, IsActive__c = true);
            lstContact.add(con);
            index++;
        }
        insert lstContact;
   
        // contact0 -> account0, account1
        // contact1 -> account1
        // contact2 -> account1, account2
        List<AccountContactRelation> lstRelation = new List<AccountcontactRelation>();
        lstRelation.add(new AccountContactRelation(AccountId = lstAcc[1].Id, ContactId = lstContact[0].Id, isActive = true));
        lstRelation.add(new AccountContactRelation(AccountId = lstAcc[1].Id, ContactId = lstContact[2].Id, isActive = true));
        insert lstRelation;
    }
  
  
    @isTest
    static void testUpdateCanceledDate(){
        AccountHandler handler = new AccountHandler();
        Map<Id, Account> mapAccount = new Map<Id, Account>([SELECT Id FROM Account]);
        Set<Id> setAccId = mapAccount.keySet();

        Test.startTest();
        handler.updateCanceledDate(setAccId);
        Test.stopTest();

        List<Account> lstAcc = [SELECT Id, MissionCanceledDate__c FROM Account];
        for (Account acc :lstAcc) {
            System.Assert.areEqual(acc.MissionCanceledDate__c, System.today());
        }
    }

    @IsTest
    static void testUpdateStatusContact(){
        Test.setMock(HttpCalloutMock.class, new AccountHandlerMock());
        AccountHandler handler = new AccountHandler();
        List<Account> lstAcc = [SELECT Id, MissionStatus__c FROM Account WHERE Name != 'Account0'];
        for (Account acc : lstAcc) {
            acc.MissionStatus__c = 'canceled';
        }
        update lstAcc;

        // Because we canceled all accounts without Account0 so only contact0 is active 
        List<Contact> lstContact = [SELECT id, LastName, IsActive__c FROM Contact WHERE LastName = 'LastName0'];
        System.assert.areEqual(true, lstContact[0].IsActive__c);

        lstContact = [SELECT id, LastName, IsActive__c FROM Contact WHERE LastName != 'LastName0'];
        for (Contact con : lstContact) {
            System.assert.areEqual(false, con.IsActive__c);
        }
    }

    @IsTest
    static void testUpdateStatusContact2(){
        Test.setMock(HttpCalloutMock.class, new AccountHandlerMock());
        AccountHandler handler = new AccountHandler();
        List<Account> lstAcc = [SELECT Id, MissionStatus__c FROM Account WHERE Name != 'Account0' AND  Name != 'Account1'];
        for (Account acc : lstAcc) {
            acc.MissionStatus__c = 'canceled';
        }
        update lstAcc;

        List<Contact> lstContact = [SELECT id, LastName, IsActive__c FROM Contact WHERE IsActive__c = true];
        System.assert.areEqual(3, lstContact.size(), 'There must be 3 active contacts');
    }

}