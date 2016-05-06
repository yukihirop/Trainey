//
//  AppDelegate.h
//  Trainey
//
//  Created by 福田幸弘 on 2015/04/26.
//  Copyright (c) 2015年 yukihiro fukuda. All rights reserved.
//



#import <UIKit/UIKit.h>
#import "InitialViewController.h"
#import "InsertNewObjectViewController.h"
#import "SettingViewController.h"
#import "HomeViewController.h"
#import "PerformanceCheckingViewController.h"
#import "RecordViewController.h"
#import "Menu_RecordViewController.h"
#import "Date_RecordViewController.h"
#import "DatesManager.h"
#import "HorizontalTalbeViewController.h"

//Hexの定数
/*
 ・露草色：007BC3
 ・躑躅色：CF4078
 ・菫色：714C99
 ・青緑：008E94
 ・山吹色：F8A900
 ・墨：343434
 
 */
#define TUYUKUSAIRO @"007BC3"
#define TUTUJIIRO @"CF4078"
#define SUMIREIRO @"714C99"
#define AOMIDORI @"008E94"
#define YAMABUKIIRO @"F8A900"
#define SUMI @"343434"


@interface UIColor (Hex)

+ (id)colorWithHexString:(NSString *)hex alpha:(CGFloat)a;

@end


@class InitialViewController;
@class RecordViewController;
@class SettingViewController;


@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    //起点となるrootTabBarControllerのインスタンスを生成
    UITabBarController *rootTabBarController;
    UIView *addStatusBar;
}


@property (nonatomic, strong) UIViewController *homeViewController;
@property (nonatomic, strong) UIViewController *performanceCheckingViewController;
@property (nonatomic, strong) UIViewController *insertedMenuTableViewController;
@property (nonatomic, strong) UIViewController *historyMenuViewController;
@property (nonatomic, strong) UIViewController *date_RecordViewController;
@property (nonatomic, strong) UIViewController *menu_RecordViewController;
@property (nonatomic, strong) UIViewController *horizontalTableViewController;
@property (nonatomic, strong) UINavigationController *firstNavigationController;
@property (nonatomic, strong) UINavigationController *thirdNavigationController;
@property (nonatomic, strong) NSString *CONCEPT_COLOR;
@property (nonatomic, strong) UIView *timeControlView;
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UITabBarController *rootTabBarController;
@property (nonatomic, strong) InitialViewController *tabInitialViewController;
@property (nonatomic, strong) RecordViewController  *tabRecordViewController;
@property (nonatomic, strong) SettingViewController *tabSettingViewController;


//タブを切り替える
-(void)switchTabBarController:(NSInteger)selectedViewIndex;

//appearanceによる各パーツの色の設定
-(void)settingPartsColor:(NSString *)NEW_CONCEPT_COLOR;

-(NSString *)startCancelText;

-(NSString *)temporarystopRestartText;


@end



