//
//  VerticalTableViewCell.m
//  Trainey
//
//  Created by 福田幸弘 on 2015/05/03.
//  Copyright (c) 2015年 yukihiro fukuda. All rights reserved.
//

#import "VerticalTableViewCell.h"


//スクロールしたら発生するイベントを登録
#define SCROLL_NOTIFICATION @"scrollNotification"
//childHorizontalTableViewの変数
//#define CHILD_HORIZONTAL_TABLEVIEW_ROW_HEIGHT 228.
#define CHILD_HORIZONTAL_TABLEVIEW_ROW_COUNT 10


#pragma mark - VerticalTableViewCell () Category


/*-------------------------------*/
//クラスエクステンション
//追加するメソッドを書く
/*-------------------------------*/
@interface VerticalTableViewCell ()


@end


#pragma mark - VerticalTableViewCell Main


/*-------------------------------*/
//メイン(共通)
/*-------------------------------*/
///////////////////////////////////
///////////implementation//////////
///////////////////////////////////
@implementation VerticalTableViewCell
{
    NSString *menuViewCellIdentifer;
    //行の高さ
    CGFloat CHILD_HORIZONTAL_TABLEVIEW_ROW_HEIGHT;
}


//アクセサメソッドの実装
@synthesize childHorizontalTableView = _childHorizontalTableView;


#pragma mark - Standard Methods

- (void)awakeFromNib
{
    // Initialization code
    
    NSLog(@"呼ばれました (VerticalTableViewCell, awakeFromNib)");
    
    [_childHorizontalTableView reloadData];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


#pragma mark - Private Methods


- (void)loadMenuViewCellXib {
    
    CGRect screenSize = [UIScreen mainScreen].bounds;
    
    //@1xの場合(3G,3GSの場合,ipadのiphoneシミュレータの@1x)
    if (screenSize.size.height == 480) {
        menuViewCellIdentifer = @"MenuViewCell@3.5inch";
        CHILD_HORIZONTAL_TABLEVIEW_ROW_HEIGHT = 167;
    }
    //@2xの場合(5,5s,5cの場合)
    else if (screenSize.size.height == 568){
        menuViewCellIdentifer = @"MenuViewCell@4inch";
        CHILD_HORIZONTAL_TABLEVIEW_ROW_HEIGHT = 187;
    }
    //その他の場合
    else {
        menuViewCellIdentifer = @"MenuViewCell";
        CHILD_HORIZONTAL_TABLEVIEW_ROW_HEIGHT = 228;
    }
    
}


-(void)buildHorizontalTableView
{
    
    NSLog(@"呼ばれました (VerticalTableViewCell, buildHorizontalTableView)");
    
    //読み込むMenuViewCellIdentifer
    [self loadMenuViewCellXib];
    
    CGRect frame = CGRectMake(0,0,CHILD_HORIZONTAL_TABLEVIEW_ROW_HEIGHT, [UIScreen mainScreen].bounds.size.width);
    _childHorizontalTableView = [[UITableView alloc] initWithFrame:frame];
        
    //horizontalTableViewのデリゲートはこのクラス
    _childHorizontalTableView.delegate = self;
    _childHorizontalTableView.dataSource = self;
        
    //横スクロールに変更
    //回転後のtableViewの中心を決める
    _childHorizontalTableView.center = CGPointMake(_childHorizontalTableView.frame.origin.x + _childHorizontalTableView.frame.size.height/2, _childHorizontalTableView.frame.origin.y + _childHorizontalTableView.frame.size.width/2);
    //回転させる
    _childHorizontalTableView.transform = CGAffineTransformMakeRotation(-M_PI / 2);
        
    //ページングさせる
    _childHorizontalTableView.pagingEnabled = YES;
    
    
        
    //セルの再利用の登録(xibファイルから)
    [_childHorizontalTableView registerNib:[UINib nibWithNibName:menuViewCellIdentifer bundle:nil] forCellReuseIdentifier:menuViewCellIdentifer];
        
    //tableViewを追加する
    [self addSubview:_childHorizontalTableView];
        
        
    //スクロールを検知したら、イベントを発生させる
//  NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
//  [center addObserver:self selector:@selector(receiveScrollNotification:) name:SCROLL_NOTIFICATION object:nil];
    
}


#pragma mark - UITableView Methods


//cellの設定
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"呼ばれました　(VerticalTableViewCell, cellForRowAtIndexPath)");
    
    //セルの設定
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:menuViewCellIdentifer];
    
    if (cell) {
        NSLog(@"cellは解放されました (VerticalTableViewCell, cellForRowAtIndexPath)");
    }
    
    
    [self configureCell:(MenuViewCell *)cell atChildrenIndexPath:indexPath];
    
    //trashButtonを削除
    NSMutableArray *items = [[NSMutableArray alloc] initWithArray:[((MenuViewCell *)cell).toolBar items]];
    //1回も削除されていない場合は、toolBarのアイテムのカウントの数は3である
    if ([items count] == 4) {
        [items removeObjectAtIndex:1];
        [((MenuViewCell *)cell).toolBar setItems:items];
    }
    
    //セルの向きを横向きに
    cell.contentView.transform = CGAffineTransformMakeRotation(M_PI / 2);
    return  cell;
}


//行(回転後は列)の数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSInteger numberOfRow = 0;
    
    
    //delegate先によって違う
    if ([self.delegate isKindOfClass:[Date_RecordViewController class]])
    {
        NSLog(@"呼ばれました、%d (VerticalTableViewCell, numberOfRowsInSection, Date)",(int)section);
        
        numberOfRow = (int)[self.delegate numberOfVerticalTableViewCell:self atTableView:((Date_RecordViewController *)self.delegate).verticalTableView];
    
    }else if ([self.delegate isKindOfClass:[Menu_RecordViewController class]])
    {
        NSLog(@"呼ばれました、%d (VerticalTableViewCell, numberOfRowsInSection, Menu)",(int)section);
        
        numberOfRow = (int)[self.delegate numberOfVerticalTableViewCell:self atTableView:((Menu_RecordViewController *)self.delegate).verticalTableView];
        
    }
    
    return numberOfRow;

}


//行の幅
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //iPhone6の場合、375px
    return [UIScreen mainScreen].bounds.size.width;
}


//セルの設定をする
-(void)configureCell:(MenuViewCell *)childrenCell atChildrenIndexPath:(NSIndexPath *)childrenIndexPath
{
    
    //cellにタグをつける(エンティティの保存でつかう)
    [childrenCell setTag:childrenIndexPath.row];
    //デリゲート通知をする
    childrenCell.delegate = (id)self;
    
    //delegate先がDate_RecordViewControllerの場合
    if ([self.delegate isKindOfClass:[Date_RecordViewController class]])
    {
        //各delegate先にセルの設定は任せる
        [self.delegate configureChildrenCellAtVerticalTableView:self atTableView:((Date_RecordViewController *)self.delegate).verticalTableView atChildrenCell:childrenCell atChildrenIndexPath:childrenIndexPath];
        
    }
    //delegate先がMenu_RecordViewControllerの場合
    else if ([self.delegate isKindOfClass:[Menu_RecordViewController class]]){
        
        //各delegate先にセルの設定は任せる
        [self.delegate configureChildrenCellAtVerticalTableView:self atTableView:((Menu_RecordViewController *)self.delegate).verticalTableView atChildrenCell:childrenCell atChildrenIndexPath:childrenIndexPath];
        
    }
    
}


//isTryを保存する
//-(void)saveRecords_dateText_isTry:(MenuViewCell *)cell atCellTag:(NSInteger)cellTag atRowIndex:(NSInteger)index
//{
//    
//    NSLog(@"呼ばれました (VerticalTableViewCell, saveRecords_dateText_isTry)");
//    NSLog(@"indexは、%d (VerticalTableViewCell, saveRecords_dateText_isTry)",(int)index);
//    
//    //delegate先がDate_RecordViewControllerの場合
//    if ([self.delegate isKindOfClass:[Date_RecordViewController class]])
//    {
//        //各delegate先にセルの設定は任せる
//        [self.delegate saveRecords_dateText_isTryAtVerticalTableView:self atTableView:((Date_RecordViewController *)self.delegate).verticalTableView atChildrenCell:cell atChildrenCellTag:cellTag atChildrenRowIndex:index];
//        
//    }
//    //delegate先がMenu_RecordViewControllerの場合
//    else if ([self.delegate isKindOfClass:[Menu_RecordViewController class]]){
//        
//        //各delegate先にセルの設定は任せる
//        [self.delegate saveRecords_dateText_isTryAtVerticalTableView:self atTableView:((Menu_RecordViewController *)self.delegate).verticalTableView atChildrenCell:cell atChildrenCellTag:cellTag atChildrenRowIndex:index];
//        
//    }
//    
//    
//}




//isTryを保存する
-(void)saveRecords_dateText_isTry:(MenuViewCell *)cell atCellTag:(NSInteger)cellTag
{
    
    for (int i=0; i<3; i++) {
        
        //delegate先がDate_RecordViewControllerの場合
        if ([self.delegate isKindOfClass:[Date_RecordViewController class]])
        {
            //各delegate先にセルの設定は任せる
            [self.delegate saveRecords_dateText_isTryAtVerticalTableView:self atTableView:((Date_RecordViewController *)self.delegate).verticalTableView atChildrenCell:cell atChildrenCellTag:cellTag atChildrenRowIndex:i];
            
        }
        //delegate先がMenu_RecordViewControllerの場合
        else if ([self.delegate isKindOfClass:[Menu_RecordViewController class]]){
            
            //各delegate先にセルの設定は任せる
            [self.delegate saveRecords_dateText_isTryAtVerticalTableView:self atTableView:((Menu_RecordViewController *)self.delegate).verticalTableView atChildrenCell:cell atChildrenCellTag:cellTag atChildrenRowIndex:i];
            
        }
    }

}






//textField型(weightとrepeatCount)を保存する
-(void)saveRecords_dateText_textField:(MenuViewCell *)cell atCellTag:(NSInteger)cellTag atRowIndex:(NSInteger)index forKey:(id)key
{
    
    NSLog(@"呼ばれました (VerticalTableViewCell, saveRecords_dateText_textField)");
    
    //delegate先がDate_RecordViewControllerの場合
    if ([self.delegate isKindOfClass:[Date_RecordViewController class]])
    {
        //各delegate先にセルの設定は任せる
        [self.delegate saveRecords_dateText_textFieldAtVerticalTableView:self atTableView:((Date_RecordViewController *)self.delegate).verticalTableView atChildrenCell:cell atChildrenCellTag:cellTag atChildrenRowIndex:index forKey:key];
        
    }
    //delegate先がMenu_RecordViewControllerの場合
    else if ([self.delegate isKindOfClass:[Menu_RecordViewController class]]){
        
        //各delegate先にセルの設定は任せる
        [self.delegate saveRecords_dateText_textFieldAtVerticalTableView:self atTableView:((Menu_RecordViewController *)self.delegate).verticalTableView atChildrenCell:cell atChildrenCellTag:cellTag atChildrenRowIndex:index forKey:key];
        
    }
    
}


-(void)deleteMenuViewCell:(MenuViewCell *)cell atCellTag:(NSInteger)cellTag
{
    
    if ([self.delegate isKindOfClass:[Date_RecordViewController class]]) {
        
        [self.delegate deleteMenuViewCellAtVerticalTableView:self atTableView:((Date_RecordViewController *)self.delegate).verticalTableView atChildrenCell:cell atChildrenCellTag:cellTag];
    }
    else if ([self.delegate isKindOfClass:[Menu_RecordViewController class]]) {
        
        [self.delegate deleteMenuViewCellAtVerticalTableView:self atTableView:((Menu_RecordViewController *)self.delegate).verticalTableView atChildrenCell:cell atChildrenCellTag:cellTag];
    }
}


//childrenTableViewのchildrenCellを更新
-(void)reloadRowsAtIndexPathsAtVerticalTableViewCell:(UITableView *)childrenTableView atChildrenCell:(MenuViewCell *)childrenCell
{
    
    NSLog(@"呼ばれました (VerticalTableViewCell, reloadRowsAtIndexPathsAtVerticalTableView)");
    
    NSIndexPath *childrenIndexPath = [childrenTableView indexPathForCell:childrenCell];
    
    if (childrenIndexPath != nil) {
        
        [childrenTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:childrenIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }else if (childrenIndexPath == nil) {
        
        NSLog(@"childrenIndexPathはnilです (VerticalTableViewCell, reloadRowsAtIndexPathsAtVerticalTableViewCell)");
    }
}


//childrenTableViewのchildrenCellを削除
-(void)deleteRowsAtIndexPathsAtVerticalTableViewCell:(UITableView *)childrenTableView atChildrenCell:(MenuViewCell *)childrenCell
{
    
    NSIndexPath *childrenIndexPath = [childrenTableView indexPathForCell:childrenCell];
    
    
    [childrenTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:childrenIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    
}


@end


#pragma mark - VerticalTableViewCell (Controller) Category


/*-------------------------------*/
//画面上で起こる操作に関するカテゴリ
//カテゴリー名：Control
/*-------------------------------*/
///////////////////////////////////
///////////interface///////////////
///////////////////////////////////
@interface VerticalTableViewCell (Controller)


@end


///////////////////////////////////
///////////implementation//////////
///////////////////////////////////
@implementation VerticalTableViewCell (Controller)


@end