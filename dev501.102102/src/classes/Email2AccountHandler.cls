/**
 * Email services are automated processes that use Apex classes
 * to process the contents, headers, and attachments of inbound
 * email.
 */
global class Email2AccountHandler implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        Account a = new Account();
        a.name = email.subject;
        insert a;
            Messaging.SingleEmailMessage emailOut = new Messaging.SingleEmailMessage(); 
            emailOut.setSubject('メール送信ありがとうございます！');
            String [] toAddresses = new String[] {email.fromAddress};
            emailOut.setToAddresses(toAddresses);
            emailOut.setPlainTextBody('取引先を登録しました(レコードID:' + a.id + ')。');
            Messaging.SendEmailResult[] mailResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailOut});
        return result;
    }
}