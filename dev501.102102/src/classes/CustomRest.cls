@RestResource(urlMapping='/contact/v1/*')
global class CustomRest {
  @HttpPost 
  global static id addAandC(String aName, String cLastName){
    Account a = new Account(name = aName);
    insert a;
    Contact c = new Contact(lastName = cLastName, accountid = a.id);
    insert c;
    return c.id;
  }
}