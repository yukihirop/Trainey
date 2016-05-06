//
//  InsertNewObjectViewController.h
//  Trainey
//
//  Created by 福田幸弘 on 2015/04/27.
//  Copyright (c) 2015年 yukihiro fukuda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewMenuConfigureViewController.h"
#import "HomeViewController.h"
#import "HistoryMenuViewController.h"
#import "AppDelegate.h"


@interface InsertNewObjectViewController:UIViewController


//セグメンテッドコントローラ
@property (nonatomic, weak)IBOutlet UISegmentedControl *segmentedControl;
//切り替えるコンテンツを表示させる領域
@property (nonatomic, weak)IBOutlet UIView *contentView;
//現在のViewControllerを保持しておく変数
@property (nonatomic, strong) UIViewController *currentViewController;
//navigationbar
@property (nonatomic, weak) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *rightBarButtonItem;


//セグメンテッドコントロールの値を変更した時に呼ばれる
-(IBAction)segmentChange:(UISegmentedControl *)sender;


@end
