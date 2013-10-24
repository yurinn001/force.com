// Schedulable : バッチ処理を呼び出すクラス
global class AccountBatchSchedulable implements Schedulable{
   global void execute(SchedulableContext sc)
   {
        AccountBatch b = new AccountBatch(); 
        b.query = 'select name from account';
        database.executebatch(b);
   }
}