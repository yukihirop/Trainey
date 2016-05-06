//
//  HistorysManager.h
//  Trainey
//
//  Created by 福田幸弘 on 2015/05/30.
//  Copyright (c) 2015年 yukihiro fukuda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Historys.h"

@interface HistorysManager : NSObject


//historysプロパティ
@property (nonatomic, strong) NSMutableArray *historys;
//historys_upperプロパティ
@property (nonatomic, strong) NSMutableArray *historys_upper;
//historys_underプロパティ
@property (nonatomic, strong) NSMutableArray *historys_under;


//このクラスのインスタンスはシングルトン
+(HistorysManager *)sharedManager;

//historysを読み込む。
-(void)loadHistorys;

//実績(isTry, weight, repeatCount)、スコア(実施日、メニューカテゴリー、メニュー名)をhistorysに追加する
-(id)addHistory:(int)isTry weight:(double)weight repeatCount:(int)repeatCount date:(id)date menu:(id)menu;

//historysを再度読み込む。
-(void)reloadHistory;

//keyで指定される値を設定する。失敗したらnilを戻す。
-(id)setHistoryValue:(id)value forKey:(id)key history:(id)history;

//historyを削除する
-(BOOL)deleteHistory:(id)history;


@end
