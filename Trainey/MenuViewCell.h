//
//  MenuViewCell.h
//  Trainey
//
//  Created by 福田幸弘 on 2015/05/06.
//  Copyright (c) 2015年 yukihiro fukuda. All rights reserved.
//

#import <UIKit/UIKit.h>


@class MenuViewCell;


//独自のプロトコロルを定義
@protocol MenuViewCellDelegate <NSObject>


//MenuViewCellを削除する
-(void)deleteMenuViewCell:(MenuViewCell *)cell  atCellTag:(NSInteger)cellTag;

//isTryを保存する
-(void)saveRecords_dateText_isTry:(MenuViewCell *)cell atCellTag:(NSInteger)cellTag atRowIndex:(NSInteger)index;

//textField型(weightとrepeatCount)を保存する
-(void)saveRecords_dateText_textField:(MenuViewCell *)cell atCellTag:(NSInteger)cellTag atRowIndex:(NSInteger)index forKey:(id)key;

//全て保存する(isTryだけ)
-(void)saveRecords_dateText_isTry:(MenuViewCell *)cell atCellTag:(NSInteger)cellTag;


@end


@interface MenuViewCell : UITableViewCell
<UIAlertViewDelegate,UITextFieldDelegate>


//toolBar
@property (nonatomic, weak) IBOutlet UIToolbar *toolBar;
//menuNameLabel
@property (nonatomic, weak) IBOutlet UILabel *menuNameLabel;
//isTry（トレーニングしたかどうか）
@property (nonatomic, strong) IBOutletCollection(UISwitch) NSArray *isTrainingSwitchs;
//負荷(kg)
@property (nonatomic, strong) IBOutletCollection(UITextField) NSArray *weightFields;
//反復回数(回)
@property (nonatomic, strong) IBOutletCollection(UITextField) NSArray *repeatCountFields;
//デリゲートプロパティー
@property (nonatomic, weak) id <MenuViewCellDelegate> delegate;


@end
