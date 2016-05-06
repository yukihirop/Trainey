//
//  Date_RecordViewController.m
//  Trainey
//
//  Created by 福田幸弘 on 2015/05/04.
//  Copyright (c) 2015年 yukihiro fukuda. All rights reserved.
//

#import "Menu_RecordViewController.h"


//VerticalTableViewの変数
#define VERTICAL_TABLEVIEW_SECTION_COUNT 10
#define VERTICAL_TABLEVIEW_SECTION_HEIGHT 30.
//#define VERTICAL_TABLEVIEW_ROW_HEIGHT 228.
#define CONTENT_SIZE 3


//カスタムセルの識別子
static NSString *VerticalTableViewCellIdentifier = @"VerticalTableViewCell";


#pragma mark - Date_RecordViewController () Category


/*-------------------------------*/
//クラスエクステンション
//追加するメソッドを書く
/*-------------------------------*/
@interface Menu_RecordViewController ()


@end



#pragma mark - Date_RecordViewController Main


/*-------------------------------*/
//メイン(共通)
/*-------------------------------*/
///////////////////////////////////
///////////implementation//////////
///////////////////////////////////
@implementation Menu_RecordViewController
{
    NSString *noRecordTableViewCellIdentifer;
    //行の高さ
    CGFloat VERTICAL_TABLEVIEW_ROW_HEIGHT;
}


@synthesize verticalTableView = _verticalTableView;
@synthesize record_menu_pk = _record_menu_pk;


//iPhoneの画面サイズで読み込むxibを変える
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    CGRect screenSize = [UIScreen mainScreen].bounds;
    
    //@1xの場合(3G,3GSの場合,ipadのiphoneシミュレータの@1x)
    if (screenSize.size.height == 480) {
        nibNameOrNil = @"Menu_RecordViewController@3.5inch";
        //ページングをYESにする
        _verticalTableView.pagingEnabled = NO;
    
    }
    //@2xの場合(5,5s,5cの場合)
    else if (screenSize.size.height == 568){
        nibNameOrNil = @"Menu_RecordViewController@4inch";
        //ページングをYESにする
        _verticalTableView.pagingEnabled = NO;
    }
    //その他の場合
    else {
        nibNameOrNil = @"Menu_RecordViewController";
        //ページングをYESにする
        _verticalTableView.pagingEnabled = YES;
    }
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //delegateとdataSorceの設定
    _verticalTableView.delegate = self;
    _verticalTableView.dataSource = self;
    
    //カスタムセルの登録(クラスで登録)
    [_verticalTableView registerClass:[VerticalTableViewCell class] forCellReuseIdentifier:VerticalTableViewCellIdentifier];
    
    //読み込むNoRecordTableViewCellを決める
    [self loadNoRecordTableViewCellXib];
    
    [_verticalTableView registerNib:[UINib nibWithNibName:noRecordTableViewCellIdentifer bundle:nil] forCellReuseIdentifier:noRecordTableViewCellIdentifer];
    
    
    
    
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:NO];
    [_verticalTableView reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableView Methods


- (void)loadNoRecordTableViewCellXib {
    
    CGRect screenSize = [UIScreen mainScreen].bounds;
    
    //@1xの場合(3G,3GSの場合,ipadのiphoneシミュレータの@1x)
    if (screenSize.size.height == 480) {
        noRecordTableViewCellIdentifer = @"NoRecordTableViewCell@3.5inch";
        VERTICAL_TABLEVIEW_ROW_HEIGHT = 167.;
    }
    //@2xの場合(5,5s,5cの場合)
    else if (screenSize.size.height == 568){
        noRecordTableViewCellIdentifer = @"NoRecordTableViewCell@4inch";
        VERTICAL_TABLEVIEW_ROW_HEIGHT = 187.;
    }
    //その他の場合
    else {
        noRecordTableViewCellIdentifer = @"NoRecordTableViewCell";
        VERTICAL_TABLEVIEW_ROW_HEIGHT = 228.;
    }
    
    
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"呼ばれました (Date_RecordViewController, cellForRowAtIndexPath)");
    
    UITableViewCell *parentCell;
    
    if ([[RecordsManager sharedManager].records_sorting_menu_pk[(int)indexPath.section] count]/CONTENT_SIZE != 0)
    {
        parentCell = [tableView dequeueReusableCellWithIdentifier:VerticalTableViewCellIdentifier];
        
        ((VerticalTableViewCell *)parentCell).delegate = (id)self;
        
        //セルの設定(TableViewを回転したものがセル)
        [(VerticalTableViewCell *)parentCell buildHorizontalTableView];
        
        //horizontalTableView(VerticalTableViewCellのプロパティー)にタグをつける
        ((VerticalTableViewCell *)parentCell).childHorizontalTableView.tag = indexPath.row + 1;
        
        
        
    }else {
        
        parentCell = [tableView dequeueReusableCellWithIdentifier:noRecordTableViewCellIdentifer];
        
    }
    
    return parentCell;
}


//childrenCellの数
-(NSInteger)numberOfVerticalTableViewCell:(UITableViewCell *)parentCell atTableView:(UITableView *)tableView
{
    
    NSIndexPath *parentIndexPath = [tableView indexPathForCell:parentCell];
    
    NSLog(@"呼ばれました、%d (Menu_RecordViewController, numberOfVerticalTableViewCell)",(int)parentIndexPath.section);
    
    NSLog(@"childrenCellの数は、%d (Menu_RecordViewController, numberOfVerticalTableViewCell)",(int)[[RecordsManager sharedManager].records_sorting_menu_pk[(int)parentIndexPath.section] count]/CONTENT_SIZE);
    
    return [[RecordsManager sharedManager].records_sorting_menu_pk[(int)parentIndexPath.section] count]/CONTENT_SIZE;
}


//1セクションあたりの行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //必ず１行
    return 1;
}


//セクションの数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //10
    return [[MenusManager sharedManager].menus count];
}


//セクションの名前
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *menuNameWithNumber = [NSString stringWithFormat:@"%d. %@", (int)(section+1),[MenusManager sharedManager].menus[(int)section][@"menuName"]];
    
    if ([[MenusManager sharedManager].menus[(int)section][@"menuCategory"] intValue] == 0) {
        menuNameWithNumber = [NSString stringWithFormat:@"%@ (上)",menuNameWithNumber];
    }else if ([[MenusManager sharedManager].menus[(int)section][@"menuCategory"] intValue] == 1) {
        menuNameWithNumber = [NSString stringWithFormat:@"%@ (下)",menuNameWithNumber];
    }
    
    return menuNameWithNumber;
}


//セクションの高さ
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //30.
    return VERTICAL_TABLEVIEW_SECTION_HEIGHT;
}


//行の高さ
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //228.
    return VERTICAL_TABLEVIEW_ROW_HEIGHT;
}


-(void)configureChildrenCellAtVerticalTableView:(UITableViewCell *)parentCell atTableView:(UITableView *)tableView atChildrenCell:(MenuViewCell *)childrenCell atChildrenIndexPath:(NSIndexPath *)childrenIndexPath
{
    
    NSLog(@"呼ばれました (Menu_RecordViewController, configureChildrenCellAtVerticalTableView)");
    
    NSIndexPath *indexPath = [tableView indexPathForCell:(UITableViewCell *)parentCell];
    
    //cellにタグをつける
    [parentCell setTag:indexPath.row];
    
    NSArray *records_menu_pk = [RecordsManager sharedManager].records_sorting_menu_pk[(int)indexPath.section];
    
    //dateText
    _record_menu_pk = records_menu_pk[3*childrenIndexPath.row];
    //((UIBarButtonItem *)childrenCell.toolBar.items[0]).title = [NSString stringWithFormat:@"%@",_record_menu_pk[@"dateText"]];
    ((UILabel *)childrenCell.menuNameLabel).text = [NSString stringWithFormat:@"%@",_record_menu_pk[@"dateText"]];
    
    
    for (int i=0; i<CONTENT_SIZE;i++) {
        
        //records_menu_pkからrecord_menu_pkを取り出す
        _record_menu_pk = records_menu_pk[3*childrenIndexPath.row+i];
        
        //isTry
        [childrenCell.isTrainingSwitchs[i] setOn:[_record_menu_pk[@"isTry"] boolValue] animated:NO];
        
        //weight
        ((UITextField *)childrenCell.weightFields[i]).text = [NSString stringWithFormat:@"%.1f",[_record_menu_pk[@"weight"] floatValue]];
        
        //repeatCount
        ((UITextField *)childrenCell.repeatCountFields[i]).text = [NSString stringWithFormat:@"%d",[_record_menu_pk[@"repeatCount"] intValue]];
        
        
    }
    
}


//childrenCellの保存(isTryの場合)
-(void)saveRecords_dateText_isTryAtVerticalTableView:(UITableViewCell *)parentCell atTableView:(UITableView *)tableView atChildrenCell:(MenuViewCell *)childrenCell atChildrenCellTag:(NSInteger)cellTag atChildrenRowIndex:(NSInteger)childrenIndex
{
    
    NSLog(@"呼ばれました (Menu_RecordViewController, saveRecords_dateText_isTryAtVerticalTableView)");
    NSLog(@"childIndexは、%d (Menu_RecordViewController, saveRecords_dateText_isTryAtVerticalTableView)",(int)childrenIndex);
    
    
    NSIndexPath *parentIndexPath = [tableView indexPathForCell:parentCell];
    
    //保存する_record_dateTextを取得
    _record_menu_pk = [RecordsManager sharedManager].records_sorting_menu_pk[(int)parentIndexPath.section][(int)(3*cellTag+childrenIndex)];
    
    //保存するisTryを準備
    int setisTry = [[NSNumber numberWithBool:((UISwitch *)childrenCell.isTrainingSwitchs[childrenIndex]).on] intValue];
    
    id newRecord = [[RecordsManager sharedManager] setRecordValue:@(setisTry) forKey:@"isTry" record:_record_menu_pk forTag:@"records_sorting_menu_pk"];
    
    //newRecordがnilでないなら
    if (newRecord) {
        
        NSLog(@"保存に成功しました (Menu_RecordViewController, saveRecords_dateText_isTryAtVerticalTableView)");
        //更新に成功したので、_recordを差し替える
        _record_menu_pk = newRecord;
        
        
    }
    
    //childrenHorizontalTableView(child)の更新はデリゲートで行う
    [(VerticalTableViewCell *)parentCell reloadRowsAtIndexPathsAtVerticalTableViewCell:((VerticalTableViewCell *)parentCell).childHorizontalTableView atChildrenCell:childrenCell];
    
    
}


//childrenCellの保存(textFieldの場合)
-(void)saveRecords_dateText_textFieldAtVerticalTableView:(UITableViewCell *)parentCell atTableView:(UITableView *)tableView atChildrenCell:(MenuViewCell *)childrenCell atChildrenCellTag:(NSInteger)cellTag atChildrenRowIndex:(NSInteger)childrenIndex forKey:(id)key
{
    
    NSLog(@"childIndexは、%d (Menu_RecordViewController, saveRecords_dateText_isTryAtVerticalTableView)",(int)childrenIndex);
    
    
    NSIndexPath *parentIndexPath = [tableView indexPathForCell:parentCell];
    
    //保存する_record_dateTextを取得
    _record_menu_pk = [RecordsManager sharedManager].records_sorting_menu_pk[(int)parentIndexPath.section][(int)(3*cellTag+childrenIndex)];
    
   
    //現在セットされているweightの値を取り出す
    float setWeight = [((UITextField *)childrenCell.weightFields[childrenIndex]).text floatValue];
    //現在セットされているrepeatCountの値を取り出す
    int setRepeatCount = [((UITextField *)childrenCell.repeatCountFields[childrenIndex]).text intValue];
    
    if ([key isEqualToString:@"weight"]) {
        
        //weightの設定、現在の値と違えば
        if ([_record_menu_pk[@"weight"] floatValue] != setWeight) {
            
            
            id newRecord = [[RecordsManager sharedManager] setRecordValue:@(setWeight) forKey:@"weight" record:_record_menu_pk forTag:@"records_sorting_menu_pk"];
            //newRecordがnilでないなら
            if (newRecord) {
                //更新に成功したので、_recordを差し替える
                _record_menu_pk = newRecord;
            }
        }
    }else if ([key isEqualToString:@"repeatCount"]) {
        
        //repeatCountの設定、現在の値と違えば、
        if ([_record_menu_pk[@"repeatCount"] intValue] != setRepeatCount) {
            
            id newRecord = [[RecordsManager sharedManager] setRecordValue:@(setRepeatCount) forKey:@"repeatCount" record:_record_menu_pk forTag:@"records_sorting_menu_pk"];
            
            //newRecordがnilでないなら
            if (newRecord) {
                //更新に成功したので、_recordを差し替える
                _record_menu_pk = newRecord;
            }
        }
        
    }
    
    //childrenHorizontalTableView(child)の更新
    [(VerticalTableViewCell *)parentCell reloadRowsAtIndexPathsAtVerticalTableViewCell:((VerticalTableViewCell *)parentCell).childHorizontalTableView atChildrenCell:childrenCell];
    
}


@end


#pragma mark - Date_RecordViewController (Controller) Category


/*-------------------------------*/
//画面上で起こる操作に関するカテゴリ
//カテゴリー名：Control
/*-------------------------------*/
///////////////////////////////////
///////////interface///////////////
///////////////////////////////////
@interface Menu_RecordViewController (Controller)


@end


///////////////////////////////////
///////////implementation//////////
///////////////////////////////////
@implementation Menu_RecordViewController (Controller)


@end