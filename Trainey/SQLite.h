//
//  SQLite.h
//  Trainey
//
//  Created by 福田幸弘 on 2015/05/10.
//  Copyright (c) 2015年 yukihiro fukuda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import  <sqlite3.h>

@interface SQLite : NSObject


//共有するSQLiteを戻すクラスメソッド
+(SQLite *)sharedSQLite;

//日付を受け取り、指定されたフォーマットで返すクラスメソッド
+(NSString *)createDate:(NSDate *)date;

//利用するデータベース用ファイルのフルパスを戻す
+(NSString *)path;


/******************Record関連関数********************/


//実績(isTry, weight, repeatCount)、スコア(実施日、メニューカテゴリー、メニュー名)をrecordに追加する
-(id)addRecord:(int)isTry weight:(double)weight repeatCount:(int)repeatCount date:(id)date menu:(id)menu;

//データベースへのrecord追加とrecord用NSDictionaryの作成
-(NSDictionary *)addRecordWithDatabase:(sqlite3 *)database date_pk:(int)date_pk dateText:(NSString *)dateText menu_pk:(int)menu_pk menuCategory:(int)menuCategory menuName:(NSString *)menuName isTry:(int)isTry weight:(double)weight repeatCount:(int)repeatCount;

//record_pkで指定されるRecordsテーブルのレコードのレコードを削除する。失敗したらNOを戻す。
-(BOOL)deleteRecordForPK:(long long)record_pk;

//record_pkを利用してレコードを消す
-(BOOL)deleteRecordAtdateText:(NSString *)dateText forPK:(long long)record_pk;

//record_pk行目のkey値のカラム値を設定するメソッド
-(id)setRecordValue:(id)value forKey:(id)key record_pk:(long long)record_pk;


/******************History関連関数********************/


//実績(isTry, weight, repeatCount)、スコア(実施日、メニューカテゴリー、メニュー名)をhistoryに追加する
-(id)addHistory:(int)isTry weight:(double)weight repeatCount:(int)repeatCount date:(id)date menu:(id)menu;

//データベースへの成績追加と成績用NSDictionaryの作成
-(NSDictionary *)addHistoryWithDatabase:(sqlite3 *)database date_pk:(int)date_pk dateText:(NSString *)dateText menu_pk:(int)menu_pk menuCategory:(int)menuCategory menuName:(NSString *)menuName isTry:(int)isTry weight:(double)weight repeatCount:(int)repeatCount;

//history_pk行目のkey値のカラム値を設定するメソッド
-(id)setHistoryValue:(id)value forKey:(id)key history_pk:(long long)history_pk;

//history_pkを利用してレコードを消す
-(BOOL)deleteHistoryForPK:(long long)history_pk;


/******************Menu関連関数**************************/


//menuCategory、menuNameをmenuに追加する
-(id)addMenu:(int)menuCategory menuName:(NSString *)menuName;

//データベースへのmenu追加とmenu用NSDictionaryの作成
-(NSDictionary *)addMenuWithDatabase:(sqlite3 *)database menuCategory:(int)menuCategory menuName:(NSString *)menuName;

//menu_pkで指定されるMenusテーブルのレコードを削除する。失敗したらNOを戻す。
-(BOOL)deleteMenuForPK:(long long)menu_pk;

//menu_pk行目のkey値のカラム値を設定するメソッド
-(id)setMenuValue:(id)value forKey:(id)key menu_pk:(long long)menu_pk;


/******************Date関連関数**************************/


//dateTextをdateに追加する
-(id)addDate:(NSString *)dateText;

//データベースへのdate追加とdate用NSDictionaryの作成
-(NSDictionary *)addDateWithDatabase:(sqlite3 *)database dateText:(NSString *)dateText;

//menu_pkで指定されるMenusテーブルのレコードを削除する。失敗したらNOを戻す。
-(BOOL)deleteDateForPK:(long long)date_pk;

//menu_pk行目のkey値のカラム値を設定するメソッド
-(id)setDateValue:(id)value forKey:(id)key date_pk:(long long)date_pk;


/**************fetch<Tables>メソッド********************/


//Recordsテーブルから記録を１件づつNSDictionaryにしNSArrayに収納して戻す
-(NSArray *)fetchRecords;

//dateTextと一致したrecordsを全て取り出す。
-(NSArray *)fetchRecordsFordateText:(NSString *)dateText;

//menu_pkと一致したrecordsを全て取り出す。
-(NSArray *)fetchRecordsForMenuPK:(int)menu_pk;

//menusの数だけのmenu_pkで指定して配列をとってきて、配列に格納して返す。
-(NSMutableArray *)fetchRecordsSortingMenuPK:(NSMutableArray *)menus;

//datesの数だけのdate_pkで指定して配列をとってきて、配列に格納して返す。
-(NSMutableArray *)fetchRecordsSortingDatePK:(NSMutableArray *)dates;

//recordsを全て取り出す
-(NSArray *)fetchHistorys;

//recordsを全て取り出す
-(NSArray *)fetchMenus;

//recordsを全て取り出す
-(NSArray *)fetchDates;


/*************************getter******************************/


//menu変則ゲッタ
-(id)menu:(sqlite3 *)database menu_pk:(int)menu_pk;

//menu変則ゲッタ
-(id)date:(sqlite3 *)database date_pk:(int)date_pk;


/*******************************************************/


@end
