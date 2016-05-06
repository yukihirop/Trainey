//
//  DatesManager.m
//  Trainey
//
//  Created by 福田幸弘 on 2015/06/05.
//  Copyright (c) 2015年 yukihiro fukuda. All rights reserved.
//

#import "DatesManager.h"

@implementation DatesManager


@synthesize dates = _dates;


//DatesManagerのシングルトンなインスタンスを返すクラスメソッド
+(DatesManager *)sharedManager
{
    static DatesManager *_instance = nil;
    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }
    return _instance;
}


//イニシャライザ
-(id)init
{
    self = [super init];
    if(self){
        //Initializa Code
        _dates = [[NSMutableArray alloc] init];
    }
    return self;
}


//datesを読み込むメソッド
-(void)loadDates
{
    
    NSLog(@"呼ばれました (DatesManager, loadDates)");
    
    _dates = [[[SQLite sharedSQLite] fetchDates] mutableCopy];
    
    NSLog(@"datesの数は%d (Dates, loadDates)",(int)[_dates count]);
    
}


//datesを再度読み込むメソッド
-(void)reloadDates
{
    _dates = [[[SQLite sharedSQLite] fetchDates] mutableCopy];
}


//menuCategory、menuNameをmenuに追加する
-(id)addDate:(NSString *)dateText
{
    //データベースに記録。記録したmenuはNSDictionaryにまとめて戻される。
    NSDictionary *date = [[SQLite sharedSQLite] addDate:dateText];
    [_dates insertObject:date atIndex:[_dates count]];
    
    NSLog(@"datesの数は%d (Dates, addDate)",(int)[_dates count]);
    
    return date;
}



//menuのkeyで指定される値を設定する。失敗したらnilを戻す。
-(id)setDateValue:(id)value forKey:(id)key date:(id)date
{
    int date_pk = [date[@"date_pk"] intValue];
    id result = [[SQLite sharedSQLite]setDateValue:value forKey:key date_pk:date_pk];
    if (result) { //成功したので_menu側も更新する
        NSMutableDictionary *dic = [date mutableCopy];
        if ([key isEqualToString:@"date_pk"]) {
            if ([value intValue] != 0) {
                dic[@"dateText"] = result[@"dateText"];
            }else{
                [dic removeObjectForKey:@"dateText"];
                 dic[@"dateText"]=@(-1);
            }
        }
        dic[key] = value;
        id newDate = [dic copy];
        [_dates replaceObjectAtIndex:[_dates indexOfObject:date] withObject:newDate];
        return newDate;
    }
    return nil;
}


//menuを削除する。失敗したらNOを戻す。
-(BOOL)deleteDate:(id)date
{
    int date_pk = [date[@"date_pk"] intValue];
    if ([[SQLite sharedSQLite] deleteDateForPK:date_pk]) {
        //menu_pkで指定したデータベース上のmenuを削除後、_menusで保持しているmenuを削除する
        [_dates removeObject:date];
        return YES;
    }
    return NO;
}


@end
