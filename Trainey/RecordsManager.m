//
//  RecordsManager.m
//  Trainey
//
//  Created by 福田幸弘 on 2015/05/24.
//  Copyright (c) 2015年 yukihiro fukuda. All rights reserved.
//

#import "RecordsManager.h"

@implementation RecordsManager


@synthesize records_sorting_menu_pk = _records_sorting_menu_pk;
@synthesize records_sorting_date_pk = _records_sorting_date_pk;
@synthesize records_dateText = _records_dateText;
@synthesize records_menu_pk = _records_menu_pk;


//このクラスのインスタンスはシングルトンな扱い
+(RecordsManager *)sharedManager
{
    static RecordsManager *_instance = nil;
    
    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }
    
    return _instance;
}


-(id)init
{
    self = [super init];
    if(self){
        //Initialize Code
        _records_sorting_menu_pk = [[NSMutableArray alloc] init];
        _records_sorting_date_pk = [[NSMutableArray alloc] init];
        _records_dateText = [[NSMutableArray alloc] init];
        _records_menu_pk = [[NSMutableArray alloc] init];
    }
    return self;
}


//dateで指定されるrecordsを読み込む。
-(void)loadRecordsFordate:(NSDate *)date
{
    NSLog(@"呼ばれました (RecordsManager, loadRecordsFordate)");
    _records_dateText = [[[SQLite sharedSQLite] fetchRecordsFordateText:[SQLite createDate:date]] mutableCopy];
    NSLog(@"records_dateTextの数は、%d (Records, loadRecordsFordate)",(int)[_records_dateText count]);
}


//menu_pkで指定されるrecordを読み込む。
-(void)loadRecordsForMenuPK:(int)menu_pk
{
    NSLog(@"呼ばれました (RecordsManager, loadRecordsForMenuPK)");
    _records_menu_pk = [[[SQLite sharedSQLite] fetchRecordsForMenuPK:menu_pk] mutableCopy];
    NSLog(@"records_menu_pkの数は、%d (Records, loadRecordsForMenuPK)",(int)[_records_menu_pk count]);
}


//menusの数だけのmenu_pkで指定して配列をとってきて、配列に格納して返す。
-(void)loadRecordsSortingMenuPK:(NSMutableArray *)menus
{
    NSLog(@"呼ばれました (RecordsManager, loadRecordsSortingMenuPK)");
    _records_sorting_menu_pk = [[SQLite sharedSQLite] fetchRecordsSortingMenuPK:menus];
    NSLog(@"records_sorting_menu_pkの数は、%d (Records, loadRecordsSortingMenuPK)",(int)[_records_sorting_menu_pk count]);
}


//menusの数だけのmenu_pkで指定して配列をとってきて、配列に格納して返す。
-(void)loadRecordsSortingDatePK:(NSMutableArray *)dates
{
    NSLog(@"呼ばれました (RecordsManager, loadRecordsSortingDatePK)");
    _records_sorting_date_pk = [[SQLite sharedSQLite] fetchRecordsSortingDatePK:dates];
    NSLog(@"records_sorting_date_pkの数は、%d (Records, loadRecordsSortingMenuPK)",(int)[_records_sorting_date_pk count]);
}


//recrods_dateTextの変則ゲッタ
-(NSArray *)records_dateText:(NSString *)dateText
{
    NSLog(@"呼ばれました (RecordsManager, records_dateText)");
    NSArray *records_dateText = [[SQLite sharedSQLite] fetchRecordsFordateText:dateText];
    NSLog(@"records_dateTextの数は、%d (RecordsManager, records_dateText)",(int)[records_dateText count]);
    
    return records_dateText;
}


//recrods_menu_pkの変則ゲッタ
-(NSArray *)records_menu_pk:(int)menu_pk
{
    NSLog(@"呼ばれました (RecordsManager, records_menu_pk)");
    NSArray *records_menu_pk = [[SQLite sharedSQLite] fetchRecordsForMenuPK:menu_pk];
    NSLog(@"records_menu_pkの数は、%d (RecordsManager, records_menu_pk)",(int)[records_menu_pk count]);
    
    return records_menu_pk;
}


//実績(isTry, weight, repeatCount)、スコア(実施日、メニューカテゴリー、メニュー名)をrecordに追加する
-(id)addRecord:(int)isTry weight:(double)weight repeatCount:(int)repeatCount date:(id)date menu:(id)menu
{
    NSDictionary *record = [[SQLite sharedSQLite] addRecord:isTry weight:weight repeatCount:repeatCount date:date menu:menu];
    [_records_dateText insertObject:record atIndex:[_records_dateText count]];
    NSLog(@"records_dateTextの数は、%d (RecordsManager, addRecord)",(int)[_records_dateText count]);
    
    return record;
}


-(void)reloadRecordFordate:(NSDate *)date
{
    _records_dateText = [[[SQLite sharedSQLite] fetchRecordsFordateText:[SQLite createDate:date]] mutableCopy];
}


-(id)setRecordValue:(id)value forKey:(id)key record:(id)record forTag:(id)tag
{
    NSLog(@"呼ばれました (RecordsManager, setRecordValue)");
    
    int record_pk = [record[@"record_pk"] intValue];
    id result = [[SQLite sharedSQLite] setRecordValue:value forKey:key record_pk:record_pk];
    
    if (result) { //成功したので_record側も更新する
        NSMutableDictionary *dic = [record mutableCopy];
        
        if ([key isEqualToString:@"menu_pk"]) {
            
            if ([value intValue] != 0) {
                
                dic[@"menuCategory"] = result[@"menuCategory"];
                dic[@"menuName"] = result[@"menuName"];
            
            }
            else {
                
                [dic removeObjectForKey:@"menuName"];
                dic[@"menuCategory"] =@(-1);
            
            }
        }
        else if ([key isEqualToString:@"date_pk"]){
            
            if ([value intValue] != 0) {
                
                dic[@"dateText"] = result[@"dateText"];
                
            }
            else{
                
                [dic removeObjectForKey:@"dateText"];
            
            }
        }
        
        dic[key] = value;
        id newRecord = [dic copy];
        
        if ([tag isEqualToString:@"records_dateText"]){
            
             NSLog(@"呼ばれました (RecordsManager, setRecordValue, records_dateText)");
            
            int menu_pk = [record[@"menu_pk"] intValue];
            int date_pk = [record[@"date_pk"] intValue];
            
            [_records_dateText replaceObjectAtIndex:[_records_dateText indexOfObject:record] withObject:newRecord];
            [_records_sorting_menu_pk[menu_pk-1] replaceObjectAtIndex:[_records_sorting_menu_pk[menu_pk-1] indexOfObject:record] withObject:newRecord];
            [_records_sorting_date_pk[date_pk-1] replaceObjectAtIndex:[_records_sorting_date_pk[date_pk-1] indexOfObject:record] withObject:newRecord];
        
        }
        else if ([tag isEqualToString:@"records_sorting_menu_pk"]){
            
            NSLog(@"呼ばれました (RecordsManager, setRecordValue, records_sorting_menu_pk)");
            
            int menu_pk = [record[@"menu_pk"] intValue];
            int date_pk = [record[@"date_pk"] intValue];
            
            [_records_sorting_menu_pk[menu_pk-1] replaceObjectAtIndex:[_records_sorting_menu_pk[menu_pk-1] indexOfObject:record] withObject:newRecord];
            [_records_sorting_date_pk[date_pk-1] replaceObjectAtIndex:[_records_sorting_date_pk[date_pk-1] indexOfObject:record] withObject:newRecord];
            
            //編集して保存されるデータが今日の日付ならば
            if ([newRecord[@"dateText"] isEqualToString:[SQLite createDate:[NSDate date]]]){
                
                [_records_dateText replaceObjectAtIndex:[_records_dateText indexOfObject:record] withObject:newRecord];
                
            }
            
            
        }
        else if ([tag isEqualToString:@"records_sorting_date_pk"]){
            
            NSLog(@"呼ばれました (RecordsManager, setRecordValue, records_sorting_date_pk)");
            
            int date_pk = [record[@"date_pk"] intValue];
            int menu_pk = [record[@"menu_pk"] intValue];
            
            [_records_sorting_date_pk[date_pk-1] replaceObjectAtIndex:[_records_sorting_date_pk[date_pk-1] indexOfObject:record] withObject:newRecord];
            [_records_sorting_menu_pk[menu_pk-1] replaceObjectAtIndex:[_records_sorting_menu_pk[menu_pk-1] indexOfObject:record] withObject:newRecord];
            
            //編集して保存されるデータが今日の日付ならば
            if ([newRecord[@"dateText"] isEqualToString:[SQLite createDate:[NSDate date]]]){
                
                [_records_dateText replaceObjectAtIndex:[_records_dateText indexOfObject:record] withObject:newRecord];
                
            }
            
        }
        
        return newRecord;
    }
    return nil;
}


//dateTextと一致する日付のrecordを削除する。
-(BOOL)deleteRecord:(id)record atDate:(NSDate *)date
{
    int record_pk = [record[@"record_pk"] intValue];
    int date_pk = [record[@"date_pk"] intValue];
    int menu_pk = [record[@"menu_pk"] intValue];
    
    if ([[SQLite sharedSQLite] deleteRecordAtdateText:[SQLite createDate:date] forPK:record_pk]) {
        
        [_records_dateText  removeObject:record];
        [_records_sorting_date_pk[date_pk-1] removeObject:record];
        [_records_sorting_menu_pk[menu_pk-1] removeObject:record];
        
        return YES;
    }
    return NO;
}


@end
