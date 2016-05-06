//
//  NSDate+Extras.m
//  Trainey
//
//  Created by 福田幸弘 on 2015/07/16.
//  Copyright (c) 2015年 yukihiro fukuda. All rights reserved.
//

#import "NSDate+Extras.h"


@implementation NSDate (Extras)


- (NSDateComponents*)dateAndTimeComponents
{
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    return [cal components:( NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit ) fromDate:self];
}

- (NSArray *)oneWeekDateWithEnableWeekdayType:(YSWeekdayType)type
{
    if (type == 0) {
        return nil;
    }
    // selfを含むその日からの1週間を取得
    NSUInteger oneWeekNum = 7;
    NSMutableDictionary *oneWeekDict = [NSMutableDictionary dictionaryWithCapacity:oneWeekNum];
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    for (int i = 0; i < oneWeekNum; i++) {
        NSDateComponents *comp = [self dateAndTimeComponents];
        [comp setDay:comp.day + i];
        NSDate *newDate = [cal dateFromComponents:comp];
        NSDateComponents * newComp = [newDate dateAndTimeComponents];
        [oneWeekDict setObject:newComp forKey:[NSString stringWithFormat:@"%d", newComp.weekday]];
    }
    
    // 取得した1週間から有効な曜日のみを抜き出す
    NSMutableArray *resultArr= [NSMutableArray array];
    YSWeekdayType compType = type;
    // NSDateComponentsのweekdayの値は1〜7(日〜土)
    for (int i = 1; i <= oneWeekNum; i++) {
        if (compType % 2 == 1) {
            NSDateComponents *comp = [oneWeekDict objectForKey:[NSString stringWithFormat:@"%d", i]];
            [resultArr addObject:[cal dateFromComponents:comp]];
        }
        compType >>= 1;
    }
    return resultArr;
}


@end