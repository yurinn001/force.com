trigger PositionSharingTrg on Position__c (after insert, after update) {
/**
 * 募集担当者(hiring manager)に募集職種(Position)のStage（ステージ）にあわせて共有をあたえていきたいという
 * Universal Containers社の要求を満たすために実装するトリガーです。
 * その他の共有ルールは、組織全体のオブジェクトごとの共有設定は宣言的に設定します。
 **/
/** 
 * 募集職種(Position)が変更可能なのは以下の状況に基づいている 
 * status （ステータス）項目:
 *   もし、 Status/sub-status = open/approved
 *      - 募集担当者（Hiring Manager） = Edit
 *      - その他の組織全体のメンバー = Read
 *   それ以外の場合
 *      - 募集担当者（Hiring Manager） = Read
 *      - その他の組織全体のメンバー = No Access
 * NOTE: 募集担当者（Hiring Manager）が変更されることもあるので、募集担当者が変更された場合
 * 旧募集担当者の共有モデルを削除する必要がある。
*/
	
	// Mapを作成する。キーはPositionのID、値は新募集担当者のIDを入れる
	Map<ID,ID> posIdToNewMgrIdMap = new Map<ID,ID>();
	// データベースに入れるデータを累積しておくためのListを用意する（sObject型）
	List<sObject> sharesToInsert = new List<sObject>(); 
	
	//TODO: 以下のアルゴリズムを実装しなさい:
	//TODO:   トリガーに渡されたレコード数分繰り返すLoopを作成
	//TODO:     もしUpdateの場合で、
	//TODO:         もし、募集担当者が変更されていた場合
	//TODO:           posIdtoNewMgrIdMapという名前のMapに key = position record id, value = new hiring manager idをputする
	//TODO:     もしinsert もしくはstatus項目かsubstatus項目が変更されている、または募集担当者が変更されていた場合
	//TODO:         Position__share型でpositionShareというオブジェクトを生成し、募集担当者の情報および以下の情報でで初期化します。: 
	//TODO:             parentId項目 は募集職種（Position ）のID
	//TODO:             userOrGroupId項目は は募集担当者のID
	//TODO:             rowCause 項目は Schema.Position__Share.RowCause.Hiring_Manager__c
	//TODO:         もし Status/sub-status = open/approved
	//TODO:             Position__ShareのaccessLevel項目に、Editを設定
	//TODO:         それ以外の場合
	//TODO:             Position__ShareのaccessLevel 項目はReadに設定
	//TODO:         Position__Share のレコードをsharestToInsertリストに追加
     
	for (Position__c position:Trigger.new){
		// レコード更新時は募集担当者が変更されているのかを確認する
		if (Trigger.isUpdate){
			// 募集担当者の変更Mapを
			if(position.Hiring_Manager__c != Trigger.oldMap.get(position.Id).Hiring_Manager__c){
				posIdToNewMgrIdMap.put(position.Id,position.Hiring_Manager__c);
			}
		}
		// 必要に応じて新しいShareオブジェクトを生成する
		if (Trigger.isInsert 
             || position.Status__c != Trigger.oldMap.get(position.Id).Status__c 
             || position.Sub_Status__c != Trigger.oldMap.get(position.Id).Sub_Status__c
             || position.Hiring_Manager__c != Trigger.oldMap.get(position.Id).Hiring_Manager__c) {
            Position__Share positionShare = new Position__Share(parentId = position.Id
                                                 , userOrGroupId = position.Hiring_Manager__c
                                                 , rowCause = Schema.Position__Share.RowCause.Hiring_Manager__c);
                                                 //事前登録したApex共有の理由名前Hiring Manager＝「rowCause = Schema.Position__Share.RowCause.Hiring_Manager__c」
                                                 //あるいは、rowCauseは代入しなければデフォルトの文言	「Apex・・・」がデフォルトで代入される。
			if ((position.Status__c == 'Open') && (position.Sub_Status__c=='Approved')){
				positionShare.accesslevel = 'Edit';
			} else {
				positionShare.accesslevel = 'Read';
			}
			sharesToInsert.add(positionShare);
		}
	}
	//募集担当者が変更されていた場合は、究担当者からの共有モデルを削除するため、削除メソッドを呼び出す
	if (posIdToNewMgrIdMap!=null && posIdToNewMgrIdMap.size() > 0 ) {
		PositionSharingClass.deletePositionSharingByRowCause(posIdToNewMgrIdMap, 'Hiring_Manager__c');
	}
	// DBのShareオブジェクトに新しい共有情報を挿入する 
	Database.insert(sharesToInsert);		
}