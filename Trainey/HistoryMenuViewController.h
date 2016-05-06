//
//  HistoryMenuViewController.h
//  Trainey
//
//  Created by 福田幸弘 on 2015/04/30.
//  Copyright (c) 2015年 yukihiro fukuda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HistoryMenuViewCell.h"
#import "InsertNewObjectViewController.h"
#import "HistorysManager.h"
#import "Records.h"
#import "Menus.h"
#import "AppDelegate.h"


@interface HistoryMenuViewController : UIViewController
//プロトコルの導入
<UITableViewDelegate,UITableViewDataSource,HistoryMenuViewCellDelegate>


@property (nonatomic, weak) id history;
@property (nonatomic, strong) UITableView *historyMenuTableView;


-(void)insertedMenuViewCellFromHistoryViewController;


@end
