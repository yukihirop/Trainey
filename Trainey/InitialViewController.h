//
//  InitialViewController.h
//  Trainey
//
//  Created by 福田幸弘 on 2015/05/01.
//  Copyright (c) 2015年 yukihiro fukuda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InsertNewObjectViewController.h"
#import "MenuViewCell.h"
#import "AppDelegate.h"


@class HomeViewController;
@class PerformanceCheckingViewController;


/*-------------------------------*/
//メイン(共通)
/*-------------------------------*/
@interface InitialViewController : UIViewController


//切り替えるコンテンツを表示させるview
@property (nonatomic, weak) IBOutlet UIView *contentView;
//現在のViewControllerを保持しておく変数
@property (nonatomic, strong) UIViewController *currentViewController;
//現在のtimeControlViewを保持しておく変数
@property (nonatomic, strong) UIView *currentTimeControlView;
@property (nonatomic, weak) IBOutlet UINavigationBar *navigationBar;
//homeViewController
@property (nonatomic, strong) HomeViewController *homeViewController;
//performanceCheckingViewController
@property (nonatomic, strong) PerformanceCheckingViewController *performanceCheckingViewController;
//CONCEPT_COLOR
@property (nonatomic, strong) NSString *CONCEPT_COLOR;
//一時停止＆再開
@property (nonatomic, weak) IBOutlet UILabel *temporarystopRestartLabel;
//キャンセル＆開始
@property (nonatomic, weak) IBOutlet UILabel *startCancelLabel;
//一時停止&再開ボタン
@property (nonatomic, weak) IBOutlet UIButton *temporarystopRestartButton;


@end







