trigger AccountCanceled on Account (after update) {
    Set<Id> setAccId = new Set<Id>();
    for (Account acc : Trigger.new) {
        String oldMissionStatus = Trigger.oldMap.get(acc.Id).MissionStatus__c;
        String newMissionStatus = Trigger.newMap.get(acc.Id).MissionStatus__c;
        if (oldMissionStatus != newMissionStatus && newMissionStatus == 'canceled') {
            setAccId.add(acc.Id);
        }
    }

    if (!setAccId.isEmpty()) {
        AccountHandler handler = new AccountHandler();
        handler.updateCanceledDate(setAccId);
        List<Id> setContactId = handler.updateStatusContact(setAccId);    
        if (!setContactId.isEmpty()) {
            AccountHandler.synchronizeStatusContact(setContactId);
        }
    }
}