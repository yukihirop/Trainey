//
//  PickerViewController.h
//  Trainey
//
//  Created by 福田幸弘 on 2015/07/17.
//  Copyright (c) 2015年 yukihiro fukuda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"


@class PickerViewController;


//デリゲート用のプロトコルを宣言
@protocol PickerViewControllerDelegate <NSObject>


//saveボタンが押された時に呼び出すメソッド
-(void)didOKButtonClicked:(PickerViewController *)controller;
//キャンセルボタンが押された時に呼び出すメソッド
-(void)didCancelButtonClicked:(PickerViewController *)controller;


@end


@interface PickerViewController : UIViewController
<UIPickerViewDelegate,UIPickerViewDataSource>


@property (nonatomic, weak) IBOutlet UIPickerView *pickerView;
@property (nonatomic, weak) IBOutlet UIToolbar *toolBar;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, weak) id<PickerViewControllerDelegate> delegate;


@end
