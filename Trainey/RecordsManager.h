//
//  RecordsManager.h
//  Trainey
//
//  Created by 福田幸弘 on 2015/05/24.
//  Copyright (c) 2015年 yukihiro fukuda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Records.h"

@interface RecordsManager : NSObject


//recordsに対しmenu_pkを指定して取得した配列を格納している配列records_sorting_menu_pk
@property (nonatomic, strong) NSMutableArray *records_sorting_menu_pk;
//recordsに対しdateTextを指定して取得した配列を格納している配列records_sorting_dateText
@property (nonatomic, strong) NSMutableArray *records_sorting_date_pk;
//records_dateTextプロパティ
@property (nonatomic, strong) NSMutableArray *records_dateText;
//records_menu_pkプロパティ
@property (nonatomic, strong) NSMutableArray *records_menu_pk;


//このクラスのインスタンスはシングルトン
+(RecordsManager *)sharedManager;

//dateで指定されるrecordを読み込む。
-(void)loadRecordsFordate:(NSDate *)date;

//menu_pkで指定されるrecordを読み込む。
-(void)loadRecordsForMenuPK:(int)menu_pk;

//menusの数だけのmenu_pkで指定して配列をとってきて、配列に格納して返す。
-(void)loadRecordsSortingMenuPK:(NSMutableArray *)menus;

//datesの数だけのdateTextで指定して配列をとってきて、配列に格納して返す。
-(void)loadRecordsSortingDatePK:(NSMutableArray *)dates;

//実績(isTry, weight, repeatCount)、スコア(実施日、メニューカテゴリー、メニュー名)をrecordに追加する
-(id)addRecord:(int)isTry weight:(double)weight repeatCount:(int)repeatCount date:(id)date menu:(id)menu;

//recordのkeyで指定される値を設定する。失敗したらnilを戻す。
-(id)setRecordValue:(id)value forKey:(id)key record:(id)record forTag:(id)tag;

//dateTextと一致する日付のrecordを削除する。
-(BOOL)deleteRecord:(id)record atDate:(NSDate *)date;

//recrods_dateTextの変則ゲッタ
-(NSArray *)records_dateText:(NSString *)dateText;

//recrods_dateTextの変則ゲッタ
-(NSArray *)records_menu_pk:(int)menu_pk;


@end
