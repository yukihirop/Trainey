//
//  QuestionViewController.h
//  Trainey
//
//  Created by 福田幸弘 on 2015/06/23.
//  Copyright (c) 2015年 yukihiro fukuda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SQLite.h"
#import "NSDate+Extras.h"
#import "AppDelegate.h"


@interface DetailViewController : UIViewController
<UIAlertViewDelegate,UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource>


@property (nonatomic, weak) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, weak) IBOutlet UIView *contentView;
@property (nonatomic, weak) IBOutlet UIView *notificationView;
@property (nonatomic, weak) IBOutlet UITextField *dateSettingTextField;
@property (nonatomic, weak) IBOutlet UITextField *repeatSettingTextField;
@property (nonatomic, weak) IBOutlet UISwitch *notificationSwitch;
@property (nonatomic, weak) IBOutlet UITextView *memotextView;
@property (nonatomic, weak) IBOutlet UIToolbar *keyboradToolBar;
@property (nonatomic, strong) NSIndexPath *settingTableViewIndexPath;


-(void) addView:(NSIndexPath *)indexPath;


@end
