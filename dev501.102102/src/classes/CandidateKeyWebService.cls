global class CandidateKeyWebService {

	 webService static Boolean submitEmployeeReferral(String posId, Candidate__c c){
		// このWebサービスはPositionのidとCandidateを受け取り、JobApplicationを作成する
		// 必要に応じて（既存レコードがなければ）Candidateも作成する
		
		// Candidateの作成が必要かどうかチェックする
		boolean cCreate = true; // デフォルトはtrue
		if (c.Email__c != null){
			String uKey = c.Last_Name__c.toLowerCase()+ c.Email__c.toLowerCase();
			// 重複チェック用のクエリ
			if ([select count() from Candidate__c where unique_key__c = :uKey] >= 1) {
				cCreate=false;
				// 後でidを使用するため、既存のCandidateを変数cに代入
				c = [select Id from Candidate__c where unique_key__c = :uKey limit 1];
			}
		}

		// Boolean型の変数を作成して、エラー発生時にロールバック可能にする
		boolean err = false;
		
		// Candidateの作成が必要な場合
		if (cCreate){
			try{
				insert c;
			} catch (System.DmlException e) {
				// エラーフラグの更新
				err = true;
				System.debug('新規Candidateレコード作成時のエラー');
				for (Integer k = 0; k < e.getNumDml(); k++) {
					// 例外処理
					System.debug(e.getDmlMessage(k));
				}
			}
		}
		
		// ここまででエラーがない場合、Job Applicationを生成
		if (!err){
			Job_Application__c j = new Job_Application__c();
			j.Status__c = 'Open';
			j.Stage__c = 'New';
			j.Position__c = posId;
			j.Candidate__c = c.Id;
			
			try{
				insert j;
			} catch (System.DmlException e) {
				System.debug('新規Job Application作成時のエラー');
				for (Integer k = 0; k < e.getNumDml(); k++) {
					// 例外処理
					System.debug(e.getDmlMessage(k));
				}
			}
		}
		
		// エラーフラグを確認して、成功フラグ（戻り値）を返す
		if (!err) {
			return true;
		} else {
		// さらにエラー処理があれば以下に記述
			return false;
		}	
	}
}