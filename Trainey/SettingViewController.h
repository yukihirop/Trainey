//
//  SettingViewController.h
//  Trainey
//
//  Created by 福田幸弘 on 2015/04/29.
//  Copyright (c) 2015年 yukihiro fukuda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "DetailViewController.h"
#import "ViewCell.h"


@interface SettingViewController : UIViewController
//プロトコルの導入
<UITableViewDelegate,UITableViewDataSource>


@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UINavigationBar *navigationBar;


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;


@end
