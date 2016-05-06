//
//  PerformanceCheckingViewController.m
//  Trainey
//
//  Created by 福田幸弘 on 2015/05/01.
//  Copyright (c) 2015年 yukihiro fukuda. All rights reserved.
//

#import "PerformanceCheckingViewController.h"

//PerformanceTableViewの変数
#define PERFORMANCE_TABLEVIEW_SIZE 10
//#define PERFORMANCE_TABLEVIEW_HEIGHT 480
#define PERFORMANCE_TABLEVIEW_POSITION_Y 30
//contentの変数
#define CONTENT_SIZE 3
//notificationcenterのIdentifier
#define SAVE_CONTEXT_NOTIFICATION @"SaveContextNotification"


#pragma mark - PerformanceCheckingViewController () Category


/*-------------------------------*/
//クラスエクステンション
//追加するメソッドを書く
/*-------------------------------*/
@interface PerformanceCheckingViewController ()


//セルの設定をする
-(void)configureCell:(MenuViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;


@end


/*-------------------------------*/
//メイン(共通)
/*-------------------------------*/
///////////////////////////////////
///////////implementation//////////
///////////////////////////////////
@implementation PerformanceCheckingViewController
{
    //contentView
    IBOutlet UIView *contentView;
    //textView
    IBOutlet UITextView *textView;
    //AppDelegateのインスタンスを用意しておく
    AppDelegate *appDelegate;
    //読み込むmenuViewCellIdentiferのxibの名前
    NSString *menuViewCellIdentifer;
    //行の高さ
    CGFloat MENUVIEWCELL_HEIGHT;
    //tableViewの高さ
    CGFloat PERFORMANCE_TABLEVIEW_HEIGHT;
    
}


@synthesize currentTableView = _currentTableView;
@synthesize record = _record;


#pragma mark - Standard Methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    CGRect screenSize = [UIScreen mainScreen].bounds;
    
    //@1xの場合(3G,3GSの場合,ipadのiphoneシミュレータの@1x)
    if (screenSize.size.height == 480) {
        nibNameOrNil = @"PerformanceCheckingViewController@3.5inch";
    }
    //@2xの場合(5,5s,5cの場合)
    else if (screenSize.size.height == 568){
        nibNameOrNil = @"PerformanceCheckingViewController@4inch";
    }
    //その他の場合
    else {
        nibNameOrNil = @"PerformanceCheckingViewController";
    }
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    
    return self;
    
}


- (void)viewDidLoad
{
    
    NSLog(@"呼ばれました (PerformanceCheckingViewController, viewDidLoad)");
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //AppDelegateの設定
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    
    //tableViewの設定
    [self settingPerformanceCheckingViewController];

}


-(void)viewWillAppear:(BOOL)animated
{
    
     NSLog(@"呼ばれました (PerformanceCheckingViewController, viewWillAppear)");
    
    [super viewWillAppear:NO];
    
    if ([[RecordsManager sharedManager].records_dateText count] / CONTENT_SIZE != 0) {
        
        [textView removeFromSuperview];
        [_currentTableView reloadData];
        
    }else if ([[RecordsManager sharedManager].records_dateText count] / CONTENT_SIZE == 0) {
        
        NSLog(@"呼ばれました (PerformanceCheckingViewController, viewWillAppear, count=0)");
        [contentView addSubview:textView];
        //最前面に
        [contentView bringSubviewToFront:textView];
        
    }
}


-(void)viewDidDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:NO];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Private Methods

- (void)loadMenuViewCell {
    
    CGRect screenSize = [UIScreen mainScreen].bounds;
    
    //@1xの場合(3G,3GSの場合,ipadのiphoneシミュレータの@1x)
    if (screenSize.size.height == 480) {
        menuViewCellIdentifer = @"MenuViewCell@3.5inch";
        MENUVIEWCELL_HEIGHT = 167;
        PERFORMANCE_TABLEVIEW_HEIGHT = 293;
        
    }
    //@2xの場合(5,5s,5cの場合)
    else if (screenSize.size.height == 568){
        menuViewCellIdentifer = @"MenuViewCell@4inch";
        MENUVIEWCELL_HEIGHT = 187;
        PERFORMANCE_TABLEVIEW_HEIGHT = 376;
    }
    //その他の場合
    else {
        menuViewCellIdentifer = @"MenuViewCell";
        MENUVIEWCELL_HEIGHT = 228;
        PERFORMANCE_TABLEVIEW_HEIGHT = 480;
    }

}


-(void)settingPerformanceCheckingViewController
{
    
    NSLog(@"呼ばれました (PerformanceCheckingViewController, settingPerformanceCheckingViewController)");
    
    
    //読み込むMenuViewCellのxibを選ぶ
    [self loadMenuViewCell];
    
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, PERFORMANCE_TABLEVIEW_HEIGHT);
    _currentTableView = [[UITableView alloc] initWithFrame:frame];
    
    //delegateとdataSorceの設定
    _currentTableView.delegate = self;
    _currentTableView.dataSource = self;
    
    
    //NewMenuViewCell
    [_currentTableView registerNib:[UINib nibWithNibName:menuViewCellIdentifer bundle:nil]forCellReuseIdentifier:menuViewCellIdentifer];
    
    
    [contentView addSubview:_currentTableView];
    
}


//isTryを保存する
//-(void)saveRecords_dateText_isTry:(MenuViewCell *)cell atCellTag:(NSInteger)cellTag atRowIndex:(NSInteger)index
//{
//    //念のために_recordを再取得しておく
//    _record = [RecordsManager sharedManager].records_dateText[(int)(3*cellTag+index)];
//    
//    //現在セットされているisTrainingSwitchsの値を保存する。(onプロパティが大事)
//    int setisTry = [[NSNumber numberWithBool:((UISwitch *)cell.isTrainingSwitchs[index]).on] intValue];
//    
//    id newRecord = [[RecordsManager sharedManager] setRecordValue:@(setisTry) forKey:@"isTry" record:_record forTag:@"records_dateText"];
//    //newRecordがnilでないなら
//    if (newRecord) {
//        //更新に成功したので、_recordを差し替える
//        _record = newRecord;
//    }
//    
//    //テーブルビューのセルを更新
//    NSIndexPath *indexPath = [_currentTableView indexPathForCell:cell];
//    [_currentTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    
//    
//    //HomeViewControllerのtableViewからも削除しておかないとエラーになる。
//    [((HomeViewController *)appDelegate.homeViewController).insertedMenuTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//}


//isTryを全て保存する
-(void)saveRecords_dateText_isTry:(MenuViewCell *)cell atCellTag:(NSInteger)cellTag
{
    for (int i=0; i<3; i++) {
        
        //念のために_recordを再取得しておく
        _record = [RecordsManager sharedManager].records_dateText[(int)(3*cellTag+i)];
        
        //現在セットされているisTrainingSwitchsの値を保存する。(onプロパティが大事)
        int setisTry = [[NSNumber numberWithBool:((UISwitch *)cell.isTrainingSwitchs[i]).on] intValue];
        
        id newRecord = [[RecordsManager sharedManager] setRecordValue:@(setisTry) forKey:@"isTry" record:_record forTag:@"records_dateText"];
        //newRecordがnilでないなら
        if (newRecord) {
            //更新に成功したので、_recordを差し替える
            _record = newRecord;
        }
        
    }
    
    //テーブルビューのセルを更新
    NSIndexPath *indexPath = [_currentTableView indexPathForCell:cell];
    [_currentTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    
    //HomeViewControllerのtableViewからも削除しておかないとエラーになる。
    [((HomeViewController *)appDelegate.homeViewController).insertedMenuTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
}


//weightとrepeatCountを保存する
-(void)saveRecords_dateText_textField:(MenuViewCell *)cell atCellTag:(NSInteger)cellTag atRowIndex:(NSInteger)index forKey:(id)key
{
    //念のために_recordを再取得しておく
    _record = [RecordsManager sharedManager].records_dateText[(int)(3*cellTag+index)];
    
    //現在セットされているweightの値を取り出す
    float setWeight = [((UITextField *)cell.weightFields[index]).text floatValue];
    //現在セットされているrepeatCountの値を取り出す
    int setRepeatCount = [((UITextField *)cell.repeatCountFields[index]).text intValue];
    
    
    if ([key isEqualToString:@"weight"]) {
        
        //weightの設定、現在の値と違えば
        if ([_record[@"weight"] floatValue] != setWeight) {
            
            id newRecord = [[RecordsManager sharedManager] setRecordValue:@(setWeight) forKey:@"weight" record:_record forTag:@"records_dateText"];
            //newRecordがnilでないなら
            if (newRecord) {
                //更新に成功したので、_recordを差し替える
                _record = newRecord;
            }
        }
    }else if ([key isEqualToString:@"repeatCount"]) {
        
        //repeatCountの設定、現在の値と違えば、
        if ([_record[@"repeatCount"] intValue] != setRepeatCount) {
            
            id newRecord = [[RecordsManager sharedManager] setRecordValue:@(setRepeatCount) forKey:@"repeatCount" record:_record forTag:@"records_dateText"];
            //newRecordがnilでないなら
            if (newRecord) {
                //更新に成功したので、_recordを差し替える
                _record = newRecord;
            }
        }
        
    }
    
    //テーブルビューのセルを更新
    NSIndexPath *indexPath = [_currentTableView indexPathForCell:cell];
    [_currentTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    
    //HomeViewControllerのtableViewからも削除しておかないとエラーになる。
    [((HomeViewController *)appDelegate.homeViewController).insertedMenuTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}


#pragma mark - UITableView Methods


//セルの設定をする
-(void)configureCell:(MenuViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"呼ばれました (PerformanceCheckingViewController, configureCell)");
    
    //cellにタグをつける(エンティティの保存でつかう)
    [cell setTag:indexPath.row];
    //デリゲート通知をする
    cell.delegate = self;
    
    //指定された日付のrecords配列だけを取り出す。
    
    for (int i=0; i<CONTENT_SIZE;i++) {
        
        //recordsからrecordを取り出す
        _record = [RecordsManager sharedManager].records_dateText[(int)((3*indexPath.row)+i)];
        
        //menuName
        NSString *menuNameWithNumber = [NSString stringWithFormat:@"%d. %@",(int)(indexPath.row +1), _record[@"menuName"]];
        //menuCategoryを取得、0なら上半身を表す上を下半身なら下半身を表す下を
        if ([_record[@"menuCategory"] intValue] == 0) {
            menuNameWithNumber = [NSString stringWithFormat:@"%@ (上)",menuNameWithNumber];
        }else if ([_record[@"menuCategory"] intValue] == 1) {
            menuNameWithNumber = [NSString stringWithFormat:@"%@ (下)",menuNameWithNumber];
        }
        
        //タイトル
        //((UIBarButtonItem *)cell.toolBar.items[0]).title = menuNameWithNumber;
        ((UILabel *)cell.menuNameLabel).text = menuNameWithNumber;
        
        //isTry
        [cell.isTrainingSwitchs[i] setOn:[_record[@"isTry"] boolValue] animated:NO];
        
        //weight
        ((UITextField *)cell.weightFields[i]).text = [NSString stringWithFormat:@"%.1f",[_record[@"weight"] floatValue]];
        
        //repeatCount
        ((UITextField *)cell.repeatCountFields[i]).text = [NSString stringWithFormat:@"%d",[_record[@"repeatCount"] intValue]];
        
    }
}


//行を削除する。
-(void)deleteMenuViewCell:(MenuViewCell *)cell atCellTag:(NSInteger)cellTag
{
    
    //テーブルビューから削除
    NSIndexPath *indexPath = [_currentTableView indexPathForCell:cell];
    
    
    //データベースからデータを削除
    for (int i=0; i<CONTENT_SIZE; i++) {
        Records *deleteRecord = [RecordsManager sharedManager].records_dateText[(int)(3*indexPath.row+i-(i-1)-1)];
        [[RecordsManager sharedManager] deleteRecord:deleteRecord atDate:[NSDate date]];
    }
    
    
    [_currentTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    
    //HomeViewControllerのtableViewからも削除しておかないとエラーになる。
    [((HomeViewController *)appDelegate.homeViewController).insertedMenuTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    
    if ([[RecordsManager sharedManager].records_dateText count] == 0) {
        
        NSLog(@"呼ばれました　(PerformanceCheckingViewController, deleteMenuViewCell)");
        
       
        [contentView addSubview:textView];
        
        //最前面に
        [contentView bringSubviewToFront:textView];
        
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    NSLog(@"呼ばれました (PerformanceCheckingViewController, numberOfSectionInTableView)");
    
    return 1;
}


//行数を返す
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSLog(@"呼ばれました (PerformanceCheckingViewController, numberOfRowsInSection)");
    
    return [[RecordsManager sharedManager].records_dateText count]/CONTENT_SIZE;
}


//セルの設定
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"呼ばれました (PerformanceCheckingViewController, cellForRowAtIndexPath)");
    
    //セルの再利用
    MenuViewCell *cell = [tableView dequeueReusableCellWithIdentifier:menuViewCellIdentifer];
    
    
    // Configure the cell...
    if (nil == cell) {
        cell = [[MenuViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:menuViewCellIdentifer];
    }
    
    //セルの設定をする
    [self configureCell:cell atIndexPath:indexPath];
    
    //accessoryTypeの設定（上書き）
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    
    return cell;
}


//行の高さ
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //228
    return MENUVIEWCELL_HEIGHT;
}


@end


#pragma mark - PerformanceCheckingViewController (CoreData) Category


/*-------------------------------*/
//SQLite関連を扱うカテゴリ
//カテゴリー名：SQLite
/*-------------------------------*/
///////////////////////////////////
///////////interface///////////////
///////////////////////////////////
@interface PerformanceCheckingViewController (SQLite)


@end


///////////////////////////////////
///////////implementation//////////
///////////////////////////////////
@implementation PerformanceCheckingViewController (SQLite)


@end