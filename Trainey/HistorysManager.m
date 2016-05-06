//
//  HistorysManager.m
//  Trainey
//
//  Created by 福田幸弘 on 2015/05/30.
//  Copyright (c) 2015年 yukihiro fukuda. All rights reserved.
//

#import "HistorysManager.h"

@implementation HistorysManager


@synthesize historys = _historys;
@synthesize historys_upper = _historys_upper;
@synthesize historys_under = _historys_under;


//このクラスのインスタンスはシングルトンな扱い
+(HistorysManager *)sharedManager
{
    static HistorysManager *_instance = nil;
    
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
        _historys = [[NSMutableArray alloc] init];
        _historys_upper = [[NSMutableArray alloc] init];
        _historys_under = [[NSMutableArray alloc] init];
    }
    
    return self;
}


//recordを読み込む。
-(void)loadHistorys
{
    
    NSLog(@"呼ばれました (HistorysManager, loadHistorys)");
    
    //databaseからrecord配列を受け取る
    _historys = [[[SQLite sharedSQLite] fetchHistorys] mutableCopy];
    _historys_upper = [[self historys_sectionNameFromHistorys:_historys atSection:0] mutableCopy];
    _historys_under = [[self historys_sectionNameFromHistorys:_historys atSection:1] mutableCopy];
    
    NSLog(@"historysの数は、%d (HistorysManagers, loadHistorys)",(int)[_historys count]);
    NSLog(@"historys_upperの数は、%d (HistorysManagers, loadHistorys)",(int)[_historys_upper count]);
    NSLog(@"historys_underの数は、%d (HistorysManagers, loadHistorys)",(int)[_historys_under count]);
    
}


-(NSMutableArray *)historys_sectionNameFromHistorys:(NSArray *)historys atSection:(NSInteger)section
{
    NSMutableArray *resultArray = [NSMutableArray new];
    
    for(int i=0;i<[historys count];i++){
        
        if ([historys[i][@"menuCategory"] intValue] == section) {
            
            [resultArray addObject:historys[i]];
            
        }
    }
    return resultArray;
}


//実績(isTry, weight, repeatCount)、スコア(実施日、メニューカテゴリー、メニュー名)をrecordに追加する
//mArrayプロパティとmArray_dateTextプロパティを設定する
-(id)addHistory:(int)isTry weight:(double)weight repeatCount:(int)repeatCount date:(id)date menu:(id)menu
{
    //データベースに記録。記録した成績はNSDictionaryにまとめて戻される。
    NSDictionary *history = [[SQLite sharedSQLite] addHistory:isTry weight:weight repeatCount:repeatCount date:date menu:menu];
    
    if ([history[@"menuCategory"] intValue] == 0) {
        
        [_historys_upper insertObject:history atIndex:[_historys_upper count]];
        
    }
    else if ([history[@"menuCategory"] intValue] == 1) {
        
        [_historys_under insertObject:history atIndex:[_historys_under count]];
        
    }
    [_historys insertObject:history atIndex:[_historys count]];
    
    NSLog(@"historysの数は、%d (HistorysManager, addHistory)",(int)[_historys count]);
    
    return history;
    
}


-(void)reloadHistory
{
    _historys = [[[SQLite sharedSQLite] fetchHistorys] mutableCopy];
    _historys_upper = [[self historys_sectionNameFromHistorys:_historys atSection:0] mutableCopy];
    _historys_under = [[self historys_sectionNameFromHistorys:_historys atSection:1] mutableCopy];
}


-(id)setHistoryValue:(id)value forKey:(id)key history:(id)history
{
    int history_pk = [history[@"history_pk"] intValue];
    id result = [[SQLite sharedSQLite] setHistoryValue:value forKey:key history_pk:history_pk];
    
    if (result) { //成功したので_record側も更新する
        NSMutableDictionary *dic = [history mutableCopy];
        
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
        dic[key] = value;
        id newHistory = [dic copy];
        
        NSLog(@"呼ばれました (HistorysManager, setHistoryValue)");
        
        //historysの置き換え
        [_historys replaceObjectAtIndex:[_historys indexOfObject:history] withObject:newHistory];
        
        if ([newHistory[@"menuCategory"] intValue] == 0) {
            
            [_historys_upper replaceObjectAtIndex:[_historys_upper indexOfObject:history] withObject:newHistory];
            
        }
        else if ([newHistory[@"menuCategory"] intValue] == 1) {
            
            [_historys_under replaceObjectAtIndex:[_historys_under indexOfObject:history] withObject:newHistory];
            
        }
        
        NSLog(@"呼ばれませんでした (HistorysManager, setHistoryValue)");
        
        return newHistory;
    }
    
    return nil;
}


-(BOOL)deleteHistory:(id)history
{
    int history_pk = [history[@"history_pk"] intValue];
    
    if ([[SQLite sharedSQLite] deleteHistoryForPK:history_pk]) {
        
        if ([history[@"menuCategory"] intValue] == 0) {
            
            [_historys_upper removeObject:history];
            
        }
        else if ([history[@"menuCategory"] intValue] == 1) {
            
            [_historys_under removeObject:history];
            
        }
        //history_pkで指定したデータベース上のhistoryを削除後、_historysで保持しているhistoryを削除する
        [_historys removeObject:history];
        return YES;
    }
    
    return NO;
}


@end
