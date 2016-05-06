//
//  SoundSelectViewController.h
//  Trainey
//
//  Created by 福田幸弘 on 2015/06/21.
//  Copyright (c) 2015年 yukihiro fukuda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SoundSelectViewCell.h"
#import "AppDelegate.h"
#import "BGMManager.h"


@interface SoundSelectViewController : UIViewController


//navigationbar
@property (nonatomic, weak) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, weak) IBOutlet UITableView *tableView;


@end
