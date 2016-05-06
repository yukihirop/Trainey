//
//  HistoryMenuViewCell.h
//  Trainey
//
//  Created by 福田幸弘 on 2015/05/07.
//  Copyright (c) 2015年 yukihiro fukuda. All rights reserved.
//

#import <UIKit/UIKit.h>


@class  HistoryMenuViewCell;


//独自のプロトコロルを定義
@protocol HistoryMenuViewCellDelegate <NSObject>


//UIAlertViewでOKが押されたら、weightとrepeatCountを保存する
-(void)saveHistorys_textField:(HistoryMenuViewCell *)cell forKey:(id)key;


@end


@interface HistoryMenuViewCell : UITableViewCell
<UITextFieldDelegate,UIAlertViewDelegate>


//カテゴリー(上半身・下半身)
@property (nonatomic ,strong) NSNumber *categoryNumber;
//メニュー名
@property (nonatomic, weak) IBOutlet UILabel *menuNameLabel;
//負荷(kg)
@property (nonatomic, weak) IBOutlet UITextField *weightField;
//反復回数(回)
@property (nonatomic, weak) IBOutlet UITextField *repeatCountField;
//delegate
@property (nonatomic, weak) id <HistoryMenuViewCellDelegate> delegate;


@end
