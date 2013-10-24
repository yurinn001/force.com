trigger CandidateAddressValidation on Candidate__c (before insert, after insert, before update, after update) {
    // AsyncValidationFlagをチェックしてfutureメソッドから呼ばれたのかを確認する
    if (!ValidateAddresses.AsyncValidationFlag) {
        Set<ID> ids = new Set<ID>();
        for (Candidate__c newCand : trigger.new) {
            Candidate__c oldCand;
            
            // insertトリガではtrigger.oldは使用できない
            if (Trigger.isInsert) {
                oldCand = new Candidate__c();
            } else {
                oldCand = Trigger.oldMap.get(newCand.ID);
            }
            
            // 住所チェックの必要があるか?（住所情報が変更されたか?）
            if ((Trigger.isInsert) ||
                (newCand.Street_Address_1__c != oldCand .Street_Address_1__c) ||
                (newCand.Street_Address_2__c != oldCand .Street_Address_2__c) ||
                (newCand.City__c != oldCand .City__c) ||
                (newCand.State_Province__c != oldCand .State_Province__c) ||
                (newCand.Country__c != oldCand .Country__c) ||
                (newCand.Zip_Postal_Code__c != oldCand .Zip_Postal_Code__c)) {
                
                if (trigger.isBefore) {
                    newCand.Valid_Address__c = false;
                    newCand.Address_Error__c = '--- しばらくお待ちください... 住所情報検証中 --- ';
                } else {
                    ids.add(newCand.id);                
                }
            }
        }
        
        // 非同期メソッドを呼び出して住所情報を検証する
        if ((trigger.isAfter) && (ids.size() > 0)) {
            //TODO: idsを渡してvalidateAddressSOAPメソッドを呼び出す
			ValidateAddresses.validateAddressSOAP(ids);
			//ValidateAddresses.validateAddressREST(ids);
         }
    }
}