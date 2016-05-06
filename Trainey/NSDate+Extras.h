//
//  NSDate+Extras.h
//  Trainey
//
//  Created by 福田幸弘 on 2015/07/16.
//  Copyright (c) 2015年 yukihiro fukuda. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
    YSWeekdayTypeNone = 1 << 7,
    YSWeekdayTypeSunday = 1 << 0,
    YSWeekdayTypeMonday = 1 << 1,
    YSWeekdayTypeTuesday = 1 << 2,
    YSWeekdayTypeWednesday = 1 << 3,
    YSWeekdayTypeThursday = 1 << 4,
    YSWeekdayTypeFriday = 1 << 5,
    YSWeekdayTypeSaturday = 1 << 6,
} YSWeekdayType;


@interface NSDate (Extras)


- (NSDateComponents*)dateAndTimeComponents;

- (NSArray*)oneWeekDateWithEnableWeekdayType:(YSWeekdayType)type;


@end
