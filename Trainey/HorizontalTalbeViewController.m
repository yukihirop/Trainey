//
//  HorizontalTalbeViewController.m
//  Trainey
//
//  Created by 福田幸弘 on 2015/05/03.
//  Copyright (c) 2015年 yukihiro fukuda. All rights reserved.
//

#import "HorizontalTalbeViewController.h"


//horizontalTableViewの変数
//#define HORIZONTAL_TABLEVIEW_ROW_HEIGHT 228.
#define HORIZONTAL_TABLEVIEW_ROW_COUNT 10
#define CONTENT_SIZE 3


#pragma mark - HorizontalTableViewController () Category


/*-------------------------------*/
//クラスエクステンション
//追加するメソッドを書く
/*-------------------------------*/
@interface HorizontalTalbeViewController ()


@end


#pragma mark - HorizontalTableViewController Main


/*-------------------------------*/
//メイン(共通)
/*-------------------------------*/
///////////////////////////////////
///////////implementation//////////
///////////////////////////////////
@implementation HorizontalTalbeViewController
{
    
    AppDelegate *appDelegate;
    NSArray *records_dateText;
//    NSInteger rowIndex;
    CGFloat HORIZONTAL_TABLEVIEW_ROW_HEIGHT;
    //読み込むMenuViewCellのxib
    NSString *menuViewCellIdentifer;
}


@synthesize horizontalTableView = _horizontalTableView;
@synthesize record_dateText = _record_dateText;


#pragma mark - Standard Methods


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"呼ばれました (HorizontalTableViewController, viewDidLoad)");
    
    //appDelegate
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    //一番新しい日付のデータを取得する
//    rowIndex = [[DatesManager sharedManager].dates count]-1;
    
    if ([[DatesManager sharedManager].dates count] != 0) {
        
        //読み込むMenuViewCellのxib
        [self loadMenuViewCellXib];
        
        records_dateText = [[NSArray alloc] init];
//        [self reloadrecords_dateText];
    
        CGRect frame = CGRectMake(0, 0, HORIZONTAL_TABLEVIEW_ROW_HEIGHT, [UIScreen mainScreen].bounds.size.width);
        _horizontalTableView = [[UITableView alloc] initWithFrame:frame];
    
        // horizontalセルのdelegate等を設定
        _horizontalTableView.delegate = (id)self;
        _horizontalTableView.dataSource = (id)self;
    
        // 横スクロールに変更
        _horizontalTableView.center = CGPointMake(_horizontalTableView.frame.origin.x + _horizontalTableView.frame.size.height / 2, _horizontalTableView.frame.origin.y + _horizontalTableView.frame.size.width / 2);
        _horizontalTableView.transform = CGAffineTransformMakeRotation(-M_PI / 2);
        
        
    
        // セルの再利用登録
        [_horizontalTableView registerNib:[UINib nibWithNibName:menuViewCellIdentifer bundle:nil] forCellReuseIdentifier:menuViewCellIdentifer];
    
        //ページングをYESにする
        _horizontalTableView.pagingEnabled = YES;
    
        [self.view addSubview:_horizontalTableView];
        
    }
    else{
    
        [((Date_RecordViewController *)appDelegate.date_RecordViewController) addTextView];
        
    }
    
}


-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"呼ばれました (HorizotalTableViewController, viewWillAppear)");
    
    [super viewWillAppear:NO];
    
    if ([[RecordsManager sharedManager].records_dateText count] == 0) {
        
        [((Date_RecordViewController *)appDelegate.date_RecordViewController) addTextView];
    }
    
    records_dateText = [[NSArray alloc] init];
//    [self reloadrecords_dateText];
    [_horizontalTableView reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Private Methods

- (void)loadMenuViewCellXib {
    
    
    CGRect screenSize = [UIScreen mainScreen].bounds;
    
    //@1xの場合(3G,3GSの場合,ipadのiphoneシミュレータの@1x)
    if (screenSize.size.height == 480) {
        menuViewCellIdentifer = @"MenuViewCell@3.5inch";
        HORIZONTAL_TABLEVIEW_ROW_HEIGHT = 167;
    }
    //@2xの場合(5,5s,5cの場合)
    else if (screenSize.size.height == 568){
        menuViewCellIdentifer = @"MenuViewCell@4inch";
        HORIZONTAL_TABLEVIEW_ROW_HEIGHT = 187;
    }
    //その他の場合
    else {
        menuViewCellIdentifer = @"MenuViewCell";
        HORIZONTAL_TABLEVIEW_ROW_HEIGHT = 228;
    }
    
}


//-(void)reloadrecords_dateText
//{
//    records_dateText = [[RecordsManager sharedManager] records_dateText:[DatesManager sharedManager].dates[rowIndex][@"dateText"]];
//}


#pragma mark - UITableView Methods


//cellの設定
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"呼ばれました (HorizontalTableViewController, cellForRowAtIndexPath)");
    
    // horizontalのセルを生成
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:menuViewCellIdentifer];
    
    [self configureCell:(MenuViewCell *)cell atIndexPath:indexPath];
    
    // セルの向きを横向きに
    cell.contentView.transform = CGAffineTransformMakeRotation(M_PI / 2);
    return  cell;
}


//行の数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSLog(@"呼ばれました、%d (HorizontalTableViewController, numberOfRowsInSection)",(int)section);
    
//    return [records_dateText count]/CONTENT_SIZE;
    
    return [[RecordsManager sharedManager].records_dateText count]/CONTENT_SIZE;
}


//行の高さ
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //windowの幅、iPhone6なら375.px
    return [UIScreen mainScreen].bounds.size.width;
}


-(void)configureCell:(MenuViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"呼ばれました (HorizontalTableViewController, configureCell)");
    
    //cellにタグをつける(エンティティの保存でつかう)
    [cell setTag:indexPath.row];
    
    cell.delegate = (id)self;
    
    
    //NSArray *records_dateText =[[RecordsManager sharedManager] records_dateText:[DatesManager sharedManager].dates[rowIndex][@"dateText"]];
    _record_dateText = [RecordsManager sharedManager].records_dateText[3*indexPath.row];
    
    
    //menuName
    NSString *menuNameWithNumber = [NSString stringWithFormat:@"%d. %@",(int)(indexPath.row +1), _record_dateText[@"menuName"]];
    //menuCategoryを取得、0なら上半身を表す上を下半身なら下半身を表す下を
    if ([_record_dateText[@"menuCategory"] intValue] == 0) {
        menuNameWithNumber = [NSString stringWithFormat:@"%@ (上)",menuNameWithNumber];
    }else if ([_record_dateText[@"menuCategory"] intValue] == 1) {
        menuNameWithNumber = [NSString stringWithFormat:@"%@ (下)",menuNameWithNumber];
    }
    //((UIBarButtonItem *)cell.toolBar.items[0]).title = menuNameWithNumber;
    ((UILabel *)cell.menuNameLabel).text = menuNameWithNumber;
    
    
    for (int i=0; i<CONTENT_SIZE;i++) {
        
        
        _record_dateText = [RecordsManager sharedManager].records_dateText[3*indexPath.row+i];
        
        //isTry
        [cell.isTrainingSwitchs[i] setOn:[_record_dateText[@"isTry"] boolValue] animated:NO];
        
        //weight
        ((UITextField *)cell.weightFields[i]).text = [NSString stringWithFormat:@"%.1f",[_record_dateText[@"weight"] floatValue]];
        
        //repeatCount
        ((UITextField *)cell.repeatCountFields[i]).text = [NSString stringWithFormat:@"%d",[_record_dateText[@"repeatCount"] intValue]];
        
        
    }
    
    
    
}


//isTryを保存する
//-(void)saveRecords_dateText_isTry:(MenuViewCell *)cell atCellTag:(NSInteger)cellTag atRowIndex:(NSInteger)index
//{
//    
//    
//    _record_dateText = [RecordsManager sharedManager].records_dateText[3*cellTag+index];
//    
//    //現在セットされているisTrainingSwitchsの値を保存する。(onプロパティが大事)
//    int setisTry = [[NSNumber numberWithBool:((UISwitch *)cell.isTrainingSwitchs[index]).on] intValue];
//    
//    id newRecord = [[RecordsManager sharedManager] setRecordValue:@(setisTry) forKey:@"isTry" record:_record_dateText forTag:@"records_dateText"];
//    //newRecordがnilでないなら
//    if (newRecord) {
//        //更新に成功したので、_recordを差し替える
//        _record_dateText = newRecord;
//    }
//    
////    [self reloadrecords_dateText];
//    
//    //テーブルビューのセルを更新
//    NSIndexPath *indexPath = [_horizontalTableView indexPathForCell:cell];
//    [_horizontalTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    
//}




//isTryを保存する
-(void)saveRecords_dateText_isTry:(MenuViewCell *)cell atCellTag:(NSInteger)cellTag
{
    
    for (int i=0; i<3; i++) {
        
        //念のために_recordを再取得しておく
        _record_dateText = [RecordsManager sharedManager].records_dateText[(int)(3*cellTag+i)];
        
        //現在セットされているisTrainingSwitchsの値を保存する。(onプロパティが大事)
        int setisTry = [[NSNumber numberWithBool:((UISwitch *)cell.isTrainingSwitchs[i]).on] intValue];
        
        id newRecord = [[RecordsManager sharedManager] setRecordValue:@(setisTry) forKey:@"isTry" record:_record_dateText forTag:@"records_dateText"];
        
        //newRecordがnilでないなら
        if (newRecord) {
            
            //更新に成功したので、_recordを差し替える
            _record_dateText = newRecord;
        }
        
    }
    
    //テーブルビューのセルを更新
    NSIndexPath *indexPath = [_horizontalTableView indexPathForCell:cell];
    [_horizontalTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
}





//textField型(weightとrepeatCount)を保存する
-(void)saveRecords_dateText_textField:(MenuViewCell *)cell atCellTag:(NSInteger)cellTag atRowIndex:(NSInteger)index forKey:(id)key
{
    
    
    _record_dateText = [RecordsManager sharedManager].records_dateText[3*cellTag+index];
    
    //現在セットされているweightの値を取り出す
    float setWeight = [((UITextField *)cell.weightFields[index]).text floatValue];
    //現在セットされているrepeatCountの値を取り出す
    int setRepeatCount = [((UITextField *)cell.repeatCountFields[index]).text intValue];
    
    
    if ([key isEqualToString:@"weight"]) {
        
        //weightの設定、現在の値と違えば
        if ([_record_dateText[@"weight"] floatValue] != setWeight) {
            
            
            id newRecord = [[RecordsManager sharedManager] setRecordValue:@(setWeight) forKey:@"weight" record:_record_dateText forTag:@"records_dateText"];
            //newRecordがnilでないなら
            if (newRecord) {
                //更新に成功したので、_recordを差し替える
                _record_dateText = newRecord;
            }
        }
    }else if ([key isEqualToString:@"repeatCount"]) {
        
        //repeatCountの設定、現在の値と違えば、
        if ([_record_dateText[@"repeatCount"] intValue] != setRepeatCount) {
            
            id newRecord = [[RecordsManager sharedManager] setRecordValue:@(setRepeatCount) forKey:@"repeatCount" record:_record_dateText forTag:@"records_dateText"];
            //newRecordがnilでないなら
            if (newRecord) {
                //更新に成功したので、_recordを差し替える
                _record_dateText = newRecord;
            }
        }
        
    }
    
//    [self reloadrecords_dateText];
    
    //テーブルビューのセルを更新
    NSIndexPath *indexPath = [_horizontalTableView indexPathForCell:cell];
    [_horizontalTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    
}


//行を削除する。
-(void)deleteMenuViewCell:(MenuViewCell *)cell atCellTag:(NSInteger)cellTag
{
    
    NSIndexPath *indexPath = [_horizontalTableView indexPathForCell:cell];
    
    
    //データベースからデータを削除
    for (int i=0; i<CONTENT_SIZE; i++) {
        Records *deleteRecord = [RecordsManager sharedManager].records_dateText[(int)(3*indexPath.row+i-(i-1)-1)];
        [[RecordsManager sharedManager] deleteRecord:deleteRecord atDate:[NSDate date]];
    }
    
//    [self reloadrecords_dateText];
    
    //テーブルビューから削除
    [_horizontalTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    //PerformanceCheckingViewControllerのtableViewからも削除しておかないとエラーになる。
    [((PerformanceCheckingViewController *)appDelegate.performanceCheckingViewController).currentTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    //HomeViewControllerのtableViewからも削除しておかないとエラーになる。
    [((HomeViewController *)appDelegate.homeViewController).insertedMenuTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    
    
    if ([[RecordsManager sharedManager].records_dateText count] == 0) {
        
        NSLog(@"呼ばれました　(HorizontalTableViewController, deleteMenuViewCell)");
        
        [((Date_RecordViewController *)appDelegate.date_RecordViewController) addTextView];
        
    }
    
}


@end


#pragma mark - HorizontalTableViewController (Controller) Category


/*-------------------------------*/
//画面上で起こる操作に関するカテゴリ
//カテゴリー名：Control
/*-------------------------------*/
///////////////////////////////////
///////////interface///////////////
///////////////////////////////////
@interface HorizontalTalbeViewController (Controller)


@end


///////////////////////////////////
///////////implementation//////////
///////////////////////////////////
@implementation HorizontalTalbeViewController (Controller)


@end