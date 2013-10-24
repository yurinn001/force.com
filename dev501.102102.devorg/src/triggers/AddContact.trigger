trigger AddContact on Candidate__c (after insert) {
    List<Contact> newContacts = new List<Contact>();
    for (Candidate__c cand : Trigger.new){
        Contact newContact = new Contact(
        LastName=cand.Last_Name__c, 
        FirstName=cand.First_Name__c,
        Email=cand.Email__c);
        newContacts.add(newContact);
    }
    database.insert(newContacts);
}