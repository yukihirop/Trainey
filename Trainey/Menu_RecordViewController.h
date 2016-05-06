//
//  Date_RecordViewController.h
//  Trainey
//
//  Created by 福田幸弘 on 2015/05/04.
//  Copyright (c) 2015年 yukihiro fukuda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VerticalTableViewCell.h"
#import "DatesManager.h"
#import "RecordsManager.h"
#import "MenusManager.h"


@interface Menu_RecordViewController : UIViewController
//プロトコルの導入
<UITableViewDataSource,UITableViewDelegate>


@property (nonatomic, weak) IBOutlet UITableView *verticalTableView;
@property (nonatomic, weak) id record_menu_pk;


@end
