/**
 * @description : this class is used to manager all account operations related to the trigger. 
 * @group : AccountHandlerTest.cls, AccountCanceled.trigger
 **/
public with sharing class AccountHandler {

    /**
     * @description : this method is used to update the canceled date of the account.
     * @param : Set<Id> setAccId : set of account Ids.
     * @return : void
     */
    public void updateCanceledDate(Set<Id> setAccId) {
        list<Account> lstAcc = [SELECT Id, MissionCanceledDate__c FROM Account WHERE Id IN :setAccId];
        for (Account acc : lstAcc) {
            acc.MissionCanceledDate__c = system.today();
        }
        update lstAcc;
    }
  
    /**
     * @description : this method is used to get the related contact and the account.
     * @param : Set<Id> setContactId : set of contact Ids.
     * @return : Map<Id, List<Id>>
     */
    private Map<Id, List<Id>> getContactAccounts(set<Id> setContactId) {
        List<AccountContactRelation> lstRelation = [SELECT ContactId, AccountId FROM AccountContactRelation WHERE ContactId IN :setContactId];
        Map<Id, List<Id>> mapContactAccount = new Map<Id, List<Id>>();
        for (AccountContactRelation relation : lstRelation) {
            if (mapContactAccount.containsKey(relation.ContactId)){
                List<Id> lstAccount = mapContactAccount.get(relation.ContactId);
                lstAccount.add(relation.AccountId);
                mapContactAccount.put(relation.contactId, lstAccount);
            }else{
                mapContactAccount.put(relation.ContactId, new List<Id>{relation.AccountId});
            }
        }
        System.debug(mapContactAccount);
        return mapContactAccount;
    }
    

    /**
     * @description : this method is used to get the account information.
     * @param : List<List<Id>> lstAccountIds : list of list of account Ids.
     * @return : Map<Id, Account>
     */
    private Map<Id, Account> getAccountInfo(List<List<Id>> lstAccountIds){
        Set<Id> setAccountId = new Set<Id>();
        for (List<Id> lstId : lstAccountIds){
            setAccountId.addAll(lstId);
        }
        Map<Id, Account> mapAccount = new Map<Id, Account>([SELECT Id, MissionStatus__c FROM Account WHERE Id IN :setAccountId]);
        return mapAccount;
    }

    /**
     * @description : this method is used to update the status of the related contact.
     * @param : List<Id> lstContactId : list of contact Ids.
     * @return : void
     */
    private void updateConctactStatus(List<Id> lstContactId){
        List<Contact> lstContact = new List<Contact>();
        for (Id contactId : lstContactId){
            lstContact.add(new Contact(Id = contactId, IsActive__c = false));
        }
        update lstContact;
    }

    /**
     * @description : this method is used to update the status of the related contact.
     * @param : Set<Id> setAccId : set of account Ids.
     * @return : Set<Id>
     */
    public List<Id> updateStatusContact(Set<Id> setAccId) {
        // Get all active contacts related to the account
        List<Contact> lstContact = [SELECT Id FROM Contact WHERE AccountId IN :setAccId AND IsActive__c = true];
        if (lstContact.isEmpty()){
            System.debug('There is not related contact');
            return new List<Id>();
        }

        Set<Id> setContactId = (new Map<Id, Contact>(lstContact)).keySet();
        Map<Id,List<Id>> mapContactAccounts = getContactAccounts(setContactId);
        Map<Id, Account> mapAccount = getAccountInfo(mapContactAccounts.values());
        
        List<Id> lstContactToUpdate = new List<Id>();
        for (Id contactId : mapContactAccounts.keySet()) {
            List<Id> lstAccountId = mapContactAccounts.get(contactId);
            Boolean isActive  = false;
            // If the account is active, then the contact must be active
            for (Id accId : lstAccountId) {
                Account acc = mapAccount.get(accId);
                if (acc.MissionStatus__c  == 'active') {
                   isActive = true;
                   break;
                }
            }

            if (!isActive){
                lstContactToUpdate.add(contactId);
            }        
        }

        if (!lstContactToUpdate.isEmpty()){
            updateConctactStatus(lstContactToUpdate);
        }
        
        return lstContactToUpdate;
    }    

    /**
     * @description : this method is used to send the status of the contact with the external system.
     * @param : List<Id> setContactId : list of contact Ids.
     * @return : void
     */
    @future(callout=true)
    public static void synchronizeStatusContact(List<Id> setContactId) {
        // Generate body in format json
        List<ContactWrapper> lstContactWrapper = new List<ContactWrapper>();
        for (Id contactId : setContactId) {
            lstContactWrapper.add(new ContactWrapper(contactId, false));
        }
        String body = JSON.serialize(lstContactWrapper);

        HttpRequest awsRequest = new HttpRequest();    
        awsRequest.setEndpoint('callout:TESTAWS');
        awsRequest.setMethod('POST');
        awsRequest.setBody(body);

        Http httpProtocol = new Http();    
        HttpResponse awsResponse = httpProtocol.send(awsRequest);
        Integer code = awsResponse.getStatusCode();

        switch on code {
            when  200 {
                System.debug(LoggingLevel.INFO, 'Success');
                System.debug(LoggingLevel.INFO, awsResponse.getBody());
            }
            when  500 {
                System.debug(LoggingLevel.ERROR, 'Internal Server Error');
            }
            when 400 {
                System.debug(LoggingLevel.ERROR, 'Errors in parameters: must be an array of objects with two properties id:string and is_active:boolean');
            }
            when 401 {
                System.debug(LoggingLevel.ERROR, 'Bad authorization');
            }
            when 404 {
                System.debug(LoggingLevel.ERROR, 'Not Found');
            }
            when else {
                System.debug(LoggingLevel.ERROR, 'ERROR ' + code);
                System.debug(LoggingLevel.ERROR, 'Status: ' + awsResponse.getStatus());
                System.debug(LoggingLevel.ERROR, 'Body:' + awsResponse.getBody());
            }
        }
    }

    /**
     * @description : this class contains all elements about Request body.
     */
    public  class ContactWrapper {
        public String id;
        public Boolean is_active;    
        
        public ContactWrapper(String contactId, Boolean isActive) {
            id = contactId;
            is_active = isActive;
        }
    }
}