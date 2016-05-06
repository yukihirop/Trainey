//
//  HorizontalTalbeViewController.h
//  Trainey
//
//  Created by 福田幸弘 on 2015/05/03.
//  Copyright (c) 2015年 yukihiro fukuda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecordsManager.h"
#import "DatesManager.h"
#import "MenuViewCell.h"
#import "AppDelegate.h"


@class MenuViewCell;


@interface HorizontalTalbeViewController : UIViewController


@property (nonatomic, strong) UITableView *horizontalTableView;
@property (nonatomic, weak) id record_dateText;


-(void)configureCell:(MenuViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;


@end
