//
//  NewMenuConfigureView.h
//  Trainey
//
//  Created by 福田幸弘 on 2015/04/27.
//  Copyright (c) 2015年 yukihiro fukuda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenusManager.h"
#import "RecordsManager.h"
#import "HistorysManager.h"
#import "AppDelegate.h"

@class GADBannerView;

@interface NewMenuConfigureViewController : UIViewController
<UIAlertViewDelegate,UITextFieldDelegate>

//プロパティー名はnewで始めることができない
@property (nonatomic, weak) IBOutlet UIView *nMenuConfigureView;
//OK
@property (nonatomic, weak) IBOutlet UIButton *okButton;
//セグメンテッドコントロール
@property (nonatomic, weak) IBOutlet UISegmentedControl *menuCategorySegment;
//トレーニングメニュー名
@property (nonatomic, weak) IBOutlet UITextField *menuNameField;
//負荷(kg)
@property (nonatomic, weak) IBOutlet UITextField *weightField;
//回数(回)
@property (nonatomic, weak) IBOutlet UITextField *repeatCountField;

//バーナービュー
@property (nonatomic, weak) IBOutlet GADBannerView *bannerView;


//AlertViewを表示する
-(IBAction)showAlertView:(UITextField *)sender;


@end


/*-------------------------------*/
//CoreDataを扱うカテゴリ
//!!!!!使用するプロパティーはメインに定義
//カテゴリー名：Core Data
/*-------------------------------*/
///////////////////////////////////
///////////interface///////////////
///////////////////////////////////
@interface NewMenuConfigureViewController (CoreData)


//NewMenuConfigureViewでokが押されたら実行
-(IBAction)okButtonPushedAtNewMenuConfigureView:(id)sender;


@end



