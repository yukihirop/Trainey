//
//  PerformanceCheckingViewController.h
//  Trainey
//
//  Created by 福田幸弘 on 2015/05/01.
//  Copyright (c) 2015年 yukihiro fukuda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuViewCell.h"
#import "InitialViewController.h"
#import "AppDelegate.h"


@class MenuViewCell;


@interface PerformanceCheckingViewController : UIViewController
//プロトコルの導入
<UITableViewDelegate,UITableViewDataSource,MenuViewCellDelegate>


@property (nonatomic, strong) UITableView *currentTableView;
@property (nonatomic, weak) id record;


@end