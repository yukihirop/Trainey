//
//  DatesManager.h
//  Trainey
//
//  Created by 福田幸弘 on 2015/06/05.
//  Copyright (c) 2015年 yukihiro fukuda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Dates.h"

@interface DatesManager : NSObject


//datesプロパティ
@property (nonatomic, strong) NSMutableArray *dates;


//このクラスのインスタンスはシングルトン
+(DatesManager *)sharedManager;

//datesを読み込む。
-(void)loadDates;

//dateTextをdatesに追加する
-(id)addDate:(NSString *)dateText;

//datesを再度読み込む
-(void)reloadDates;

//keyで指定される値を設定する。失敗したらnilを戻す。
-(id)setDateValue:(id)value forKey:(id)key date:(id)date;

//dateを削除する。失敗したらNOを戻す。
-(BOOL)deleteDate:(id)date;


@end
