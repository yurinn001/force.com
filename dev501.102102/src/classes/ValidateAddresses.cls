public class ValidateAddresses {
    public static Boolean AsyncValidationFlag = false;
    
    @Future(callout=true) 
    public static void validateAddressSOAP(Set<ID> ids) {
        try {
            // 検証対象の住所リストを取得
            Map<ID, Candidate__c> mapCands = findCandidates(ids);
            List<validateAddressSOAP.addressSOAP> listAddress = new List<validateAddressSOAP.addressSOAP>();
            for (Candidate__c cand : mapCands.values()) {
                validateAddressSOAP.addressSOAP address = new validateAddressSOAP.addressSOAP();
                address.id = cand.id;
                address.line1 = cand.Street_Address_1__c;
                address.line2 = cand.Street_Address_2__c;
                address.city = cand.city__c;
                address.state = cand.state_Province__c;
                address.country = cand.country__c;
                address.zipCode = cand.zip_postal_code__c;
                listAddress.add(address);
            }
                        
            // TODO: ValidateAddressSOAP.ValidateAddressesPort型の変数portを宣言、デフォルトコンストラクタを使用してインスタンスを代入
			ValidateAddressSOAP.ValidateAddressesPort port = new ValidateAddressSOAP.ValidateAddressesPort();
            
			// TODO: ValidateAddressSOAP.validationResultSOAP型の変数listResultを宣言
			List<ValidateAddressSOAP.validationResultSOAP> listResult;

			// TODO: port変数のValidateAddressesメソッドを呼び出し、実行結果を上記変数に代入する。引数にはlistAddressを渡す
			listResult = port.ValidateAddresses(listAddress);

            // 結果の検証
            for (ValidateAddressSOAP.validationResultSOAP result : listResult) {
                Candidate__c cand = mapCands.get(result.testAddress.id);
                if (result.isValid) {
                    cand.Valid_Address__c = true;
                    cand.Address_Error__c = null;
                } else {
                    cand.Valid_Address__c = false;
                    cand.Address_Error__c = '住所不正';
                }
            }
            
            // Candidateの更新
            AsyncValidationFlag = true;
            update mapCands.values();
        } catch (Exception ex) {
            // 例外処理
            System.debug('ERROR: '+ ex);
            Error_Log__c log = new Error_Log__c();
            log.trace__c = ex.getCause() + '\n' + ex.getMessage();
            insert log;        
        }
    }
       
    private static Map<ID, Candidate__c> findCandidates(Set<ID> ids) {
        Map<ID, Candidate__c> output;
        output = new Map<ID, Candidate__c>([SELECT ID, Street_Address_1__c, Street_Address_2__c, city__c,
                                                state_Province__c, country__c, zip_postal_code__c
                                            FROM candidate__c
                                            WHERE id in :ids]);
        return output;
    }
}