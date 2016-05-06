//
//  ViewController.h
//  Trainey
//
//  Created by 福田幸弘 on 2015/04/26.
//  Copyright (c) 2015年 yukihiro fukuda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "MenuViewCell.h"
#import "InitialViewController.h"
#import "SoundSelectViewController.h"
#import "RecordsManager.h"
#import "MenusManager.h"
#import "AppDelegate.h"
#import "BGMManager.h"


@class MenuViewCell;


@interface HomeViewController : UIViewController
//プロトコルの導入
<UIPickerViewDelegate,UIPickerViewDataSource,MenuViewCellDelegate>


@property (nonatomic, strong) UITableView *insertedMenuTableView;
@property NSInteger minutes;
@property NSInteger seconds;
//id型のrecord
@property (nonatomic, weak) id record;


//タイマーのキャンセルor開始処理
-(void)startCancelInterval:(UILabel *)startCancelLabel;

//タイマーの再開or停止処理
-(void)stopRestartInterval:(UILabel *)temporarystopRestartLabel;


@end