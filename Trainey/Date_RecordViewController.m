//
//  Record_MenuViewController.m
//  Trainey
//
//  Created by 福田幸弘 on 2015/05/04.
//  Copyright (c) 2015年 yukihiro fukuda. All rights reserved.
//

#import "Date_RecordViewController.h"


//VerticalTableViewの変数
#define VERTICAL_TABLEVIEW_SECTION_COUNT 10
#define VERTICAL_TABLEVIEW_SECTION_HEIGHT 30.
//#define VERTICAL_TABLEVIEW_ROW_HEIGHT 228.
#define CONTENT_SIZE 3


//カスタムセルの識別子
static NSString *VerticalTableViewCellIdentifier = @"VerticalTableViewCell";


#pragma mark - Menu_RecordViewController () Category


/*-------------------------------*/
//クラスエクステンション
//追加するメソッドを書く
/*-------------------------------*/
@interface Date_RecordViewController ()


@end


#pragma mark - Menu_RecordViewController Main


/*-------------------------------*/
//メイン(共通)
/*-------------------------------*/
///////////////////////////////////
///////////implementation//////////
///////////////////////////////////
@implementation Date_RecordViewController
{
    //textView
    IBOutlet UITextView *textView;
    IBOutlet UITextView *parentTextView;
    //contentViewUnder;
    IBOutlet UIView *contentViewUnder;
    //records_sorting_date_pk_Count
    NSInteger records_sorting_date_pk_Count;
    NSInteger index;
    NSInteger sectionCount;
    //読み込むNoRecordTableViewCellのxib
    NSString *noRecordTableViewCellIdentifer;
    //行の高さ
    CGFloat VERTICAL_TABLEVIEW_ROW_HEIGHT;
    
}


@synthesize verticalTableView = _verticalTableView;
@synthesize contentView = _contentView;
@synthesize sectionTitleLabel = _sectionTitleLabel;
@synthesize record_dateText = _record_dateText;


#pragma mark - Standard Methods



//iPhoneの画面サイズで読み込むxibを変える
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    CGRect screenSize = [UIScreen mainScreen].bounds;
    
    //@1xの場合(3G,3GSの場合,ipadのiphoneシミュレータの@1x)
    if (screenSize.size.height == 480) {
        nibNameOrNil = @"Date_RecordViewController@3.5inch";
    }
    //@2xの場合(5,5s,5cの場合)
    else if (screenSize.size.height == 568){
        nibNameOrNil = @"Date_RecordViewController@4inch";
    }
    //その他の場合
    else {
        nibNameOrNil = @"Date_RecordViewController";
    }
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    
    return self;
}




- (void)viewDidLoad
{
    
    NSLog(@"呼ばれました (Date_RecordViewController, viewDidLoad)");
    
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //表示するtableviewの数
    records_sorting_date_pk_Count = [[DatesManager sharedManager].dates count];
    
    //tableViewの設定
    [self settingTableView];
    [self addTextView];

    
}


-(void)viewWillAppear:(BOOL)animated
{
    
    NSLog(@"呼ばれました (Date_RecordViewController, viewWillAppear)");
    
    [super viewWillAppear:NO];
    
    //表示するtableviewの数
    records_sorting_date_pk_Count = [[DatesManager sharedManager].dates count];
    //tableViewの設定
    [self settingTableView];
    [self addTextView];
    //tableviewの更新
    [_verticalTableView reloadData];
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Private Methods


- (void)loadNoRecordTableViewCellXib {
    
    CGRect screenSize = [UIScreen mainScreen].bounds;
    
    //@1xの場合(3G,3GSの場合,ipadのiphoneシミュレータの@1x)
    if (screenSize.size.height == 480) {
        noRecordTableViewCellIdentifer = @"NoRecordTableViewCell@3.5inch";
        VERTICAL_TABLEVIEW_ROW_HEIGHT = 167;
        //ページングをYESにする
        _verticalTableView.pagingEnabled = NO;
    }
    //@2xの場合(5,5s,5cの場合)
    else if (screenSize.size.height == 568){
        noRecordTableViewCellIdentifer = @"NoRecordTableViewCell@4inch";
        VERTICAL_TABLEVIEW_ROW_HEIGHT = 187;
        //ページングをYESにする
        _verticalTableView.pagingEnabled = NO;
    }
    //その他の場合
    else {
        noRecordTableViewCellIdentifer = @"NoRecordTableViewCell";
        VERTICAL_TABLEVIEW_ROW_HEIGHT = 228;
        //ページングをYESにする
        _verticalTableView.pagingEnabled = YES;
    }
    
    
}


-(void)settingTableView
{
    
    //一番新しい日付のデータを取得する
    index = records_sorting_date_pk_Count-1;
    
    if (index >= 0) {
        
        NSLog(@"呼ばれました (Date_RecordViewController, settingTableView)");
        
        //delegateとdataSorceの設定
        _verticalTableView.delegate = self;
        _verticalTableView.dataSource = self;
        
        
        //カスタムセルの登録(クラスで登録)
        [_verticalTableView registerClass:[VerticalTableViewCell class] forCellReuseIdentifier:VerticalTableViewCellIdentifier];
        
        //読み込むNoRecordTableViewCellを決める
        [self loadNoRecordTableViewCellXib];
        
        [_verticalTableView registerNib:[UINib nibWithNibName:noRecordTableViewCellIdentifer bundle:nil] forCellReuseIdentifier:noRecordTableViewCellIdentifer];
        
        //VerticalTableViewControllerから生成
        UIViewController *viewController = [HorizontalTalbeViewController new];
        //子のviewControllerとして追加
        [self addChildViewController:viewController];
        //viewControllerのサイズをcontentViewのサイズと同じにする
        viewController.view.frame = _contentView.bounds;
        //contentViewに追加
        [_contentView addSubview:viewController.view];
        
        //sectionLabelを設定する
        //_sectionTitleLabel.text = [NSString stringWithFormat:@"   %@",[DatesManager sharedManager].dates[index][@"dateText"]];
        _sectionTitleLabel.text = [NSString stringWithFormat:@"   %@",[SQLite createDate:[NSDate date]]];
        
        
    }
    
}


-(void)addTextView
{
    
    NSLog(@"呼ばれました (Date_RecordViewController, addTextView)");
    
    if ([[DatesManager sharedManager].dates count] == 0) {
        
        [_contentView addSubview:textView];
        [_contentView bringSubviewToFront:textView];
        
    }
    else if ([[DatesManager sharedManager].dates count] == 1){
        
        NSLog(@"呼ばれました (Date_RecordViewController,addTextView,1)");
        
        if ([[RecordsManager sharedManager].records_dateText count] != 0) {
            [textView removeFromSuperview];
        }
        else{
            
            NSLog(@"呼ばれました (Date_RecordViewController,addTextView,1,!0)");
            
            [_contentView addSubview:textView];
            [_contentView bringSubviewToFront:textView];
        }
        
        //2015/11/15追加分
        if ([_sectionTitleLabel.text isEqualToString:[NSString stringWithFormat:@"   %@",[DatesManager sharedManager].dates[records_sorting_date_pk_Count-1][@"dateText"]]]) {
            
            [contentViewUnder addSubview:parentTextView];
            [contentViewUnder bringSubviewToFront:parentTextView];
        }
        
    }
    else{
        //records_dateTextがないなら
        if ([[RecordsManager sharedManager].records_dateText count]/CONTENT_SIZE == 0) {
            
            [_contentView addSubview:textView];
            [_contentView bringSubviewToFront:textView];
            
        }
        
        [parentTextView removeFromSuperview];
        //[_verticalTableView reloadData];
        
    }
    
}


#pragma mark - UITableView Methods


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"呼ばれました (Date_RecordViewController, cellForRowAtIndexPath)");
    
    UITableViewCell *cell;
    
    
    if ([[RecordsManager sharedManager].records_sorting_date_pk[(int)indexPath.section] count]/CONTENT_SIZE != 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:VerticalTableViewCellIdentifier];
        
        ((VerticalTableViewCell *)cell).delegate = (id)self;
        
        //セルの設定(TableViewを回転したものがセル)
        [(VerticalTableViewCell *)cell buildHorizontalTableView];
        
        //horizontalTableView(VerticalTableViewCellのプロパティー)にタグをつける
        ((VerticalTableViewCell *)cell).childHorizontalTableView.tag = indexPath.row + 1;
        
    }else {
        
        cell = [tableView dequeueReusableCellWithIdentifier:noRecordTableViewCellIdentifer];
    }
    
    
    return cell;
}


//1セクションあたりの行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSLog(@"呼ばれました、%d (Date_RecordViewController, numberOfRowsInSection)",(int)section);
    
    //必ず１行
    return 1;
}


//セクションの数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    NSLog(@"呼ばれました (Date_RecordViewController, numberOfSectionsInTableView)");
    
    //日付配列の最初の要素が現在の日付と同じなら
    if ([_sectionTitleLabel.text isEqualToString:[NSString stringWithFormat:@"   %@",[DatesManager sharedManager].dates[records_sorting_date_pk_Count-1][@"dateText"]]]) {
        sectionCount = records_sorting_date_pk_Count-1;
    }
    else{
        sectionCount = records_sorting_date_pk_Count;
    }
    
    return sectionCount;
}


//セクションの名前
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    NSLog(@"呼ばれました (Date_RecordViewController, titleForHeaderInSection)");
    
    return [DatesManager sharedManager].dates[sectionCount-(int)section-1][@"dateText"];
}


-(NSInteger)numberOfVerticalTableViewCell:(VerticalTableViewCell *)parentCell atTableView:(UITableView *)tableView
{
    
    NSIndexPath *parentIndexPath = [tableView indexPathForCell:parentCell];
    
    NSLog(@"呼ばれました、%d (Date_RecordViewController, numberOfVerticalTableViewCell)",(int)parentIndexPath.section);
    
    NSLog(@"childrenCellの数は、%d (Date_RecordViewController, numberOfVerticalTableViewCell)",(int)[[RecordsManager sharedManager].records_sorting_date_pk[(int)parentIndexPath.section] count]/CONTENT_SIZE);
    
    return[[RecordsManager sharedManager].records_sorting_date_pk[(int)parentIndexPath.section] count]/CONTENT_SIZE;
    
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
    
    NSLog(@"呼ばれました (Date_RecordViewController, configureChildrenCellAtVerticalTableView)");
    
    NSIndexPath *parentIndexPath = [tableView indexPathForCell:parentCell];
    
    //cellにタグをつける
    [parentCell setTag:parentIndexPath.row];
    
    //recordsからrecordを取り出す
    _record_dateText = [RecordsManager sharedManager].records_sorting_date_pk[(int)parentIndexPath.section][3*childrenIndexPath.row];
    
    
    //menuName
    NSString *menuNameWithNumber = [NSString stringWithFormat:@"%d. %@",(int)(childrenIndexPath.row +1), _record_dateText[@"menuName"]];
    //menuCategoryを取得、0なら上半身を表す上を下半身なら下半身を表す下を
    if ([_record_dateText[@"menuCategory"] intValue] == 0) {
        menuNameWithNumber = [NSString stringWithFormat:@"%@ (上)",menuNameWithNumber];
    }else if ([_record_dateText[@"menuCategory"] intValue] == 1) {
        menuNameWithNumber = [NSString stringWithFormat:@"%@ (下)",menuNameWithNumber];
    }
    
    //メニュー名
    //((UIBarButtonItem *)childrenCell.toolBar.items[0]).title = menuNameWithNumber;
    ((UILabel *)childrenCell.menuNameLabel).text = menuNameWithNumber;
    
    
    for (int i=0; i<CONTENT_SIZE;i++) {
        
        //recordsからrecordを取り出す
        _record_dateText = [RecordsManager sharedManager].records_sorting_date_pk[sectionCount-(int)parentIndexPath.section-1][3*childrenIndexPath.row+i];
        
        //isTry
        [childrenCell.isTrainingSwitchs[i] setOn:[_record_dateText[@"isTry"] boolValue] animated:NO];
        
        //weight
        ((UITextField *)childrenCell.weightFields[i]).text = [NSString stringWithFormat:@"%.1f",[_record_dateText[@"weight"] floatValue]];
        
        //repeatCount
        ((UITextField *)childrenCell.repeatCountFields[i]).text = [NSString stringWithFormat:@"%d",[_record_dateText[@"repeatCount"] intValue]];
        
        
        
    }
    
    
}


//childrenCellの保存(isTryの場合)
-(void)saveRecords_dateText_isTryAtVerticalTableView:(UITableViewCell *)parentCell atTableView:(UITableView *)tableView atChildrenCell:(MenuViewCell *)childrenCell atChildrenCellTag:(NSInteger)cellTag atChildrenRowIndex:(NSInteger)childrenIndex
{
    
    NSLog(@"indexは、%d (Date_RecordViewController, saveRecords_dateText_isTryAtVerticalTableView)",(int)childrenIndex);
    
    NSIndexPath *parentIndexPath = [tableView indexPathForCell:parentCell];
    
    //保存する_record_dateTextを取得
    _record_dateText = [RecordsManager sharedManager].records_sorting_date_pk[(int)parentIndexPath.section][(int)(3*cellTag+childrenIndex)];
    
    //保存するisTryを準備
    int setisTry = [[NSNumber numberWithBool:((UISwitch *)childrenCell.isTrainingSwitchs[childrenIndex]).on] intValue];
    
    id newRecord = [[RecordsManager sharedManager] setRecordValue:@(setisTry) forKey:@"isTry" record:_record_dateText forTag:@"records_sorting_date_pk"];
    
    //newRecordがnilでないなら
    if (newRecord) {
        //更新に成功したので、_recordを差し替える
        _record_dateText = newRecord;
    }
    
    //childrenHorizontalTableView(child)の更新はデリゲートで行う
    [(VerticalTableViewCell *)parentCell reloadRowsAtIndexPathsAtVerticalTableViewCell:((VerticalTableViewCell *)parentCell).childHorizontalTableView atChildrenCell:childrenCell];
    
    
}


//childrenCellの保存(textFieldの場合)
-(void)saveRecords_dateText_textFieldAtVerticalTableView:(UITableViewCell *)parentCell atTableView:(UITableView *)tableView atChildrenCell:(MenuViewCell *)childrenCell atChildrenCellTag:(NSInteger)cellTag atChildrenRowIndex:(NSInteger)childrenIndex forKey:(id)key
{
    
    NSLog(@"indexは、%d (Date_RecordViewController, saveRecords_dateText_isTryAtVerticalTableView)",(int)childrenIndex);
    
    NSIndexPath *parentIndexPath = [tableView indexPathForCell:parentCell];
    
    //保存する_record_dateTextを取得
    _record_dateText = [RecordsManager sharedManager].records_sorting_date_pk[(int)parentIndexPath.section][(int)(3*cellTag+childrenIndex)];
    
    //現在セットされているweightの値を取り出す
    float setWeight = [((UITextField *)childrenCell.weightFields[childrenIndex]).text floatValue];
    //現在セットされているrepeatCountの値を取り出す
    int setRepeatCount = [((UITextField *)childrenCell.repeatCountFields[childrenIndex]).text intValue];
    
    
    if ([key isEqualToString:@"weight"]) {
        
        //weightの設定、現在の値と違えば
        if ([_record_dateText[@"weight"] floatValue] != setWeight) {
            
            
            id newRecord = [[RecordsManager sharedManager] setRecordValue:@(setWeight) forKey:@"weight" record:_record_dateText forTag:@"records_sorting_date_pk"];
            //newRecordがnilでないなら
            if (newRecord) {
                //更新に成功したので、_recordを差し替える
                _record_dateText = newRecord;
            }
        }
    }else if ([key isEqualToString:@"repeatCount"]) {
        
        //repeatCountの設定、現在の値と違えば、
        if ([_record_dateText[@"repeatCount"] intValue] != setRepeatCount) {
            
            id newRecord = [[RecordsManager sharedManager] setRecordValue:@(setRepeatCount) forKey:@"repeatCount" record:_record_dateText forTag:@"records_sorting_date_pk"];
            //newRecordがnilでないなら
            if (newRecord) {
                //更新に成功したので、_recordを差し替える
                _record_dateText = newRecord;
            }
        }
        
    }
    
    //childrenHorizontalTableView(child)の更新
    [(VerticalTableViewCell *)parentCell reloadRowsAtIndexPathsAtVerticalTableViewCell:((VerticalTableViewCell *)parentCell).childHorizontalTableView atChildrenCell:childrenCell];
    
    
}


@end


#pragma mark - Menu_RecordViewController (Controller) Category


/*-------------------------------*/
//画面上で起こる操作に関するカテゴリ
//カテゴリー名：Control
/*-------------------------------*/
///////////////////////////////////
///////////interface///////////////
///////////////////////////////////
@interface Date_RecordViewController (Controller)


@end


///////////////////////////////////
///////////implementation//////////
///////////////////////////////////
@implementation Date_RecordViewController (Controller)


@end
