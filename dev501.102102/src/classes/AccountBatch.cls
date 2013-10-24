global class AccountBatch implements Database.Batchable<sObject>{
    global String query;
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        for(sObject s : scope){
            Account a = (Account) s;
            a.name = a.name + '★';
        } 
        update scope;
    }
    global void finish(Database.BatchableContext BC){
    }
}