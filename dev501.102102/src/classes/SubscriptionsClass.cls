public with sharing class SubscriptionsClass {
	/*
	 * 募集担当者（hiring manager）が担当する募集職種(Position)をフォローするクラスを作成
	 */
	public static void HiringManagerSubscribeNewPosition(List <Position__c> positions) {
		System.Debug('HiringManagerSubscribeNewPosition: Entering');
		//TODO: EntitySubscriptionオブジェクトのlistを subscriptionsという変数名で作成
		List <EntitySubscription> subscriptions = new List <EntitySubscription>();		
		//TODO: 引数で渡された募集職種を１レコードづつ確認するループを作成：
		for (Position__c pos :positions) {
		//TODO:   EntitySubscriptionオブジェクト eSubs変数を作成し、
		//TODO:   EntitySubscriptionレコードのParentIdと
		//TODO:   フォローする募集担当者のIDをSubscriberIdにsetする
			EntitySubscription eSubs = new EntitySubscription(parentid = pos.id, subscriberid = pos.Hiring_Manager__c);
		//TODO:   subscriptions変数に値をSetした eSubs変数を追加
			subscriptions.add(eSubs);
		}
		try {
			Database.insert(subscriptions);
		}
		catch (DMLException dmlEx) {
			// ユーザが既にこのPositionをフォロー済みであればエラーが発生。その場合は問題なし。
			if (dmlEx.getDmlType(0) == statusCode.DUPLICATE_VALUE) {
				System.Debug('HiringManagerSubscribeNewPosition: 既にフォロー済みです');
			} else {
				// それ以外の例外だと問題あり。例外を投げる。
				throw dmlEx;
			}
		}
	}
}