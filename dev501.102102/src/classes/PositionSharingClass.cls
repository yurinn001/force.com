/**
 * 募集職種（Positon)レコードに関連するメソッドをもつユーティリティクラス
 * 
 **/
public with sharing class PositionSharingClass {
	//このメソッドは有る特定のデータの共有を削除します
	//- objectIdToNewUserIdMap - Userフィールドが変更されたため削除が必要と認識します
	//- rowCauseToFind - 共有の理由を確認する
	public static void deletePositionSharingByRowCause(Map<ID,ID> objectIdToNewUserIdMap, String rowCauseToFind){
		List<Position__Share> deleteShares = new List<Position__Share>();

		for (Position__Share posShare : [SELECT UserOrGroupId, RowCause, ParentId, Id, AccessLevel 
                                           FROM Position__Share 
                                           WHERE ParentId IN :objectIdToNewUserIdMap.keySet()
                                             AND RowCause = :rowCauseToFind]){
			if (ObjectIdToNewUserIdMap.get(posShare.ParentId) != posShare.UserOrGroupId){
				deleteShares.add(posShare);
			}
		}
		if (!deleteShares.isEmpty()) {
			delete deleteShares;
		}          
	}
}