global class AccountService{
    webservice static void addAandC(String aName, String clName){
        Account a = new Account(name = aName);
        insert a;
        Contact c = new Contact(accountid = a.id, lastName = clName);
        insert c;
    }
}