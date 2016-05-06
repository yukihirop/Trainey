//
//  VerticalTableViewCell.h
//  Trainey
//
//  Created by 福田幸弘 on 2015/05/03.
//  Copyright (c) 2015年 yukihiro fukuda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuViewCell.h"
#import "Menu_RecordViewController.h"
#import "Date_RecordViewController.h"


@class VerticalTableViewCell;
@class MenuViewCell;


@protocol VerticalTableViewCellDelegate <NSObject>


//parentCellあたりのchildrenCellの数
-(NSInteger)numberOfVerticalTableViewCell:(VerticalTableViewCell *)parentCell atTableView:(UITableView *)tableView;

//childrenCellの設定
-(void)configureChildrenCellAtVerticalTableView:(UITableViewCell *)parentCell atTableView:(UITableView *)tableView atChildrenCell:(MenuViewCell *)childrenCell atChildrenIndexPath:(NSIndexPath *)childrenIndexPath;

//childrenCellの保存(isTryの場合)
-(void)saveRecords_dateText_isTryAtVerticalTableView:(UITableViewCell *)parentCell atTableView:(UITableView *)tableView atChildrenCell:(MenuViewCell *)childrenCell atChildrenCellTag:(NSInteger)cellTag atChildrenRowIndex:(NSInteger)childrenIndex;

//childrenCellの保存(textFieldの場合)
-(void)saveRecords_dateText_textFieldAtVerticalTableView:(UITableViewCell *)parentCell atTableView:(UITableView *)tableView atChildrenCell:(MenuViewCell *)childrenCell atChildrenCellTag:(NSInteger)cellTag atChildrenRowIndex:(NSInteger)childrenIndex forKey:(id)key;

//childrenCellの削除
-(void)deleteMenuViewCellAtVerticalTableView:(UITableViewCell *)parentCell atTableView:(UITableView *)tableView atChildrenCell:(MenuViewCell *)childrenCell atChildrenCellTag:(NSInteger)cellTag;


@end


@interface VerticalTableViewCell : UITableViewCell
//プロトコルの導入
<UITableViewDelegate,UITableViewDataSource>


@property (nonatomic, strong) UITableView *childHorizontalTableView;
@property (nonatomic, weak) id <VerticalTableViewCellDelegate> delegate;


//HorizontalTableViewの設定
-(void)buildHorizontalTableView;

//childrenTableViewのchildrenCellを更新
-(void)reloadRowsAtIndexPathsAtVerticalTableViewCell:(UITableView *)childrenTableView atChildrenCell:(MenuViewCell *)childrenCell;

//childrenTableViewのchildrenCellを削除
-(void)deleteRowsAtIndexPathsAtVerticalTableViewCell:(UITableView *)childrenTableView atChildrenCell:(MenuViewCell *)childrenCell;


@end