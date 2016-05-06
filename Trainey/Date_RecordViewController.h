//
//  Record_MenuViewController.h
//  Trainey
//
//  Created by 福田幸弘 on 2015/05/04.
//  Copyright (c) 2015年 yukihiro fukuda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VerticalTableViewCell.h"
#import "HorizontalTalbeViewController.h"
#import "DatesManager.h"


@interface Date_RecordViewController : UIViewController
//プロトコルの導入
<UITableViewDataSource,UITableViewDelegate>


@property (nonatomic, weak) IBOutlet UITableView *verticalTableView;
@property (nonatomic, weak) IBOutlet UIView *contentView;
@property (nonatomic, weak) IBOutlet UILabel *sectionTitleLabel;
@property (nonatomic, weak) id record_dateText;


-(void)addTextView;


@end
