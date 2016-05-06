//
//  HistoryMenuViewController.m
//  Trainey
//
//  Created by 福田幸弘 on 2015/04/30.
//  Copyright (c) 2015年 yukihiro fukuda. All rights reserved.
//

#import "HistoryMenuViewController.h"


//HistroyTableViewの変数
#define HISTORY_TABLEVIEW_UPPERBODY_SIZE 10
#define HISTORY_TABLEVIEW_LOWERBODY_SIZE 10
#define HISTORY_TABLEVIEW_SECTION_HEIGHT 30
#define HISTORY_TABLEVIEW_ROW_HEIGHT 52
//#define HISTORY_TABLEVIEW_HEIGHT 493
//CustomCellの変数
#define CONTENT_SIZE 3



#pragma mark - HistoryMenuViewController () Category


/*-------------------------------*/
//クラスエクステンション
//追加するメソッドを書く
/*-------------------------------*/
@interface HistoryMenuViewController ()


//セルの設定
-(void)configureCell:(HistoryMenuViewCell *)cell atIndexPath:indexPath;


@end


#pragma mark - HistoryMenuViewController Main


/*-------------------------------*/
//メイン(共通)
/*-------------------------------*/
///////////////////////////////////
///////////implementation//////////
///////////////////////////////////
@implementation HistoryMenuViewController
{
    
    //contentView
    IBOutlet UIView *contentView;
    //textView
    IBOutlet UITextView *textView;
    BOOL isAddRecords;
    //チェクマークで選択されたcheckMarkDictionaryを格納する配列
    NSMutableArray *checkMarkArray;
    NSMutableArray *indexPaths;
    //appDelegate
    AppDelegate *appDelegate;
    //読み込むHistoryMenuViewCellのxib
    NSString *historyMenuViewCellIdentifer;
    //tableViewの高さ
    CGFloat HISTORY_TABLEVIEW_HEIGHT;
}


@synthesize historyMenuTableView = _historyMenuTableView;
@synthesize history = _history;


#pragma mark - Standard Methods


//iPhoneの画面サイズで読み込むxibを変える
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    CGRect screenSize = [UIScreen mainScreen].bounds;
    
    //@1xの場合(3G,3GSの場合,ipadのiphoneシミュレータの@1x)
    if (screenSize.size.height == 480) {
        nibNameOrNil = @"HistoryMenuViewController@3.5inch";
    }
    //@2xの場合(5,5s,5cの場合)
    else if (screenSize.size.height == 568){
        nibNameOrNil = @"HistoryMenuViewController@4inch";
    }
    //その他の場合
    else {
        nibNameOrNil = @"HistoryMenuViewController";
    }
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //appDelegateのインスタンスを生成
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    //HistroyMenuTableViewをセットする
    [self settingHistroyMenuTableView];
    
    
    isAddRecords = NO;
    
    
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    
    [_historyMenuTableView deselectRowAtIndexPath:[_historyMenuTableView indexPathForSelectedRow] animated:NO];
    
    //HistoryMenuTableViewをセットする
    [self settingHistroyMenuTableView];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Private Methods


- (void)loadHistoryMenuViewCellXib {
    
    
    CGRect screenSize = [UIScreen mainScreen].bounds;
    
    //@1xの場合(3G,3GSの場合,ipadのiphoneシミュレータの@1x)
    if (screenSize.size.height == 480) {
        historyMenuViewCellIdentifer = @"HistoryMenuViewCell@3.5inch";
        HISTORY_TABLEVIEW_HEIGHT = 306;
    }
    //@2xの場合(5,5s,5cの場合)
    else if (screenSize.size.height == 568){
        historyMenuViewCellIdentifer = @"HistoryMenuViewCell@4inch";
        HISTORY_TABLEVIEW_HEIGHT = 394;
    }
    //その他の場合
    else {
        historyMenuViewCellIdentifer = @"HistoryMenuViewCell";
        HISTORY_TABLEVIEW_HEIGHT = 493;
    }
}


-(void)settingHistroyMenuTableView
{
    
    
    if ([[HistorysManager sharedManager].historys count] != 0) {
        
        //読み込むHistoryMenuViewCellのxibと行の高さを決める
        [self loadHistoryMenuViewCellXib];
        
        
        //historys_upperとhistorys_underを準備
        [self settingHistorys];
        
        CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, HISTORY_TABLEVIEW_HEIGHT);
        UITableView *tableView = [[UITableView alloc] initWithFrame:frame];
        
        //delegateとdataSorceの設定
        tableView.delegate = self;
        tableView.dataSource = self;
        
        
        //カスタムセルの登録(xibファイルから)
        [tableView registerNib:[UINib nibWithNibName:historyMenuViewCellIdentifer bundle:nil] forCellReuseIdentifier:historyMenuViewCellIdentifer];
        
        //更新
        [tableView reloadData];
        
        
        _historyMenuTableView = tableView;
        
        [contentView addSubview:_historyMenuTableView];
        
        
    }else{
        
        [contentView addSubview:textView];
        
    }
    
}


-(void)settingHistorys
{
    
    indexPaths = [NSMutableArray new];
    checkMarkArray = [NSMutableArray new];
    
}


//tableViewを各ViewControllerに追加
-(void)insertedMenuViewCellFromHistoryViewController
{
    
    NSIndexPath *addIndexPath;
    //適当に初期化
    BOOL isAdd_addIndexPath = NO;
    
    //addIndexPathを一つづつ取り出す(addIndexPath.rowはcheckMarkArrayのindexに相当する)
    
    NSLog(@"checkMarkArrayの数は、%dです",(int)[checkMarkArray count]);
    
    
    //addIndexPath.sectionは常に０
    for (int i=0; i<[checkMarkArray count]; i++) {
            
            if (((NSIndexPath *)checkMarkArray[i]).section == 0)
            {
                
                NSLog(@"呼ばれました、%d (HistoryMenuViewController, insertedMenuViewCellFromHistoryViewController)",i);
                
                addIndexPath = [NSIndexPath indexPathForRow:[indexPaths count] inSection:0];
                
                isAdd_addIndexPath = [self saveMenuViewCellAtHistoryMenuViewController:(NSIndexPath *)checkMarkArray[i]];
            
            
            }else if (((NSIndexPath *)checkMarkArray[i]).section == 1) {
                
                NSLog(@"呼ばれました、%d (HistoryMenuViewController, insertedMenuViewCellFromHistoryViewController)",i);
                
                addIndexPath = [NSIndexPath indexPathForRow:[indexPaths count] inSection:0];
                
                isAdd_addIndexPath = [self saveMenuViewCellAtHistoryMenuViewController:(NSIndexPath *)checkMarkArray[i]];
                
                
            }
        
        
        if (addIndexPath != nil) {
            
             NSLog(@"呼ばれました、%d (HistoryMenuViewController, insertedMenuViewCellFromHistoryViewController,!nil)",i);
            
            
            if (isAdd_addIndexPath == YES) {
                
                NSLog(@"呼ばれました、%d (HistoryMenuViewController, insertedMenuViewCellFromHistoryViewController)",i);
                
                //addIndexPathを格納
                [indexPaths addObject:addIndexPath];
            }
        }
    }
    
    
    
    NSLog(@"indexPathsの数は、%d (HistoryMnuViewController, inserteMenuViewCellFromHistroyViewController)",(int)[indexPaths count]);
    
    
    if ([indexPaths count] != 0) {
        
        
        //HomeViewControllerに対して
        [((HomeViewController *)appDelegate.homeViewController).insertedMenuTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
            
        //PerformanceCheckingViewControllerに対して
        [((PerformanceCheckingViewController *)appDelegate.performanceCheckingViewController).currentTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        
        
        //[((Date_RecordViewController *)appDelegate.date_RecordViewController).verticalTableView reloadData];
        
        
            
        [indexPaths removeAllObjects];
        
        
        //画面遷移の実行
        [appDelegate.firstNavigationController popToRootViewControllerAnimated:NO];
        
        
    }else if ([indexPaths count] == 0) {
        
        
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告"
                                                        message:@"\"履歴\"からメニューを選択してください.\n(もしくは全て追加されています。)"
                                                       delegate:self
                                              cancelButtonTitle:@"cancel"
                                              otherButtonTitles:@"はい", nil];
        
        [alert show];
        
    }
    
}


//MenuViewCellを追加するかどうかを判定する処理、追加の場合はrecordsに保存する
-(BOOL)saveMenuViewCellAtHistoryMenuViewController:(NSIndexPath *)indexPath
{
    
    BOOL result=NO;
    
    
    //sectionが０の時
    if (indexPath.section == 0) {
        
        
        //newRecordを追加するかしないかを判定する
        result = [self saveMenuViewCell:[HistorysManager sharedManager].historys_upper atPath:indexPath];
    
    
    }else if (indexPath.section == 1){
        
        //newRecordを追加するかしないかを判定する
        result = [self saveMenuViewCell:[HistorysManager sharedManager].historys_under atPath:indexPath];
    }
    
    return  result;
}


//newRecordを追加するかしないかを判定する
-(BOOL)saveMenuViewCell:(NSMutableArray *)saveHistorys atPath:(NSIndexPath *)indexPath
{
    
    BOOL result = YES;
    id history;
    id newMenu;
    id newDate;
    id newRecord;
    
    
    //newRecordを追加するかしないかを判定する
    for (int i=0; i<[[RecordsManager sharedManager].records_dateText count]; i++) {
        if ([saveHistorys[(int)(3*indexPath.row)][@"menuName"] isEqualToString:[RecordsManager sharedManager].records_dateText[i][@"menuName"]])
        {
            
            NSLog(@"menuNameは、%@",[RecordsManager sharedManager].records_dateText[i][@"menuName"]);
            
            result = NO;
        }
        
    }
    
    NSLog(@"checkMarkArrayの数は、%dです (HistoryMenuViewController, saveMenuViewCell)",(int)[checkMarkArray count]);
    
    
    
    if (result == YES) {
            
            
            NSLog(@"呼ばれました (HistoryMenuViewController, saveMenuViewCellAtHistoryMenuViewController,section=0)");
            
            for (int i=0; i<CONTENT_SIZE; i++) {
                
                history = saveHistorys[(int)(3*indexPath.row)];
                
                newDate = [self saveDatesAtHistoryMenuViewController];
                
                newMenu = @{@"menu_pk":@([history[@"menu_pk"] intValue]),
                            @"menuCategory":@([history[@"menuCategory"] intValue]),
                            @"menuName":history[@"menuName"]};
                
                newRecord = [[RecordsManager sharedManager] addRecord:0 weight:[history[@"weight"] floatValue] repeatCount:[history[@"repeatCount"] intValue] date:newDate menu:newMenu];
                
                
                //再取得
                [[RecordsManager sharedManager] loadRecordsSortingDatePK:[DatesManager sharedManager].dates];
                [[RecordsManager sharedManager] loadRecordsSortingMenuPK:[MenusManager sharedManager].menus];
            }
    }
    
    
    NSLog(@"checkMarkArrayの数は、%dです (HistoryMenuViewController, saveMenuViewCell,end)",(int)[checkMarkArray count]);
    
    return result;
    
    
}


//UIAlertViewでOKが押されたら、weightとrepeatCountを保存する
-(void)saveHistorys_textField:(HistoryMenuViewCell *)cell forKey:(id)key
{
    
    
    //indexPathを取得する
    NSIndexPath *indexPath = [_historyMenuTableView indexPathForCell:cell];
    

    
    if (indexPath.section == 0) {
        
        
        [self saveHistorys_historys:[HistorysManager sharedManager].historys_upper atCell:cell forKey:key];
        
        
    }else if (indexPath.section == 1){
    
        
        [self saveHistorys_historys:[HistorysManager sharedManager].historys_under atCell:cell forKey:key];
    
    }
    
    //tableViewのデータを再仕分け
    
    
    //テーブルビューのセルを更新
    [_historyMenuTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    //PerformanceCheckingViewControllerのtableViewからも削除しておかないとエラーになる。
    [_historyMenuTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    //再取得
    [[RecordsManager sharedManager] loadRecordsSortingDatePK:[DatesManager sharedManager].dates];
    [[RecordsManager sharedManager] loadRecordsSortingMenuPK:[MenusManager sharedManager].menus];
    
}


//saveHistorys配列のcellを保存する処理(saveHistroys_textFieldで呼ばれる)
-(void)saveHistorys_historys:(NSMutableArray *)saveHistorys atCell:(HistoryMenuViewCell *)cell forKey:(id)key
{
    
    NSIndexPath *indexPath = [_historyMenuTableView indexPathForCell:cell];
    
    //現在セットされているweightの値を取り出す
    float setWeight = [((UITextField *)cell.weightField).text floatValue];
    //現在セットされているrepeatCountの値を取り出す
    int setRepeatCount = [((UITextField *)cell.repeatCountField).text intValue];
    
    
    //念のために_recordを再取得しておく
    for (int i=0; i<CONTENT_SIZE; i++) {
        
        _history = saveHistorys[(int)3*indexPath.row+i];
        
        
        if ([key isEqualToString:@"weight"]) {
            
            //weightの設定、現在の値と違えば
            if ([_history[@"weight"] floatValue] != setWeight) {
                
                
                id newHistory = [[HistorysManager sharedManager] setHistoryValue:@(setWeight) forKey:@"weight" history:_history];
                //newRecordがnilでないなら
                if (newHistory) {
                    
                    //更新に成功したので、_recordを差し替える
                    _history = newHistory;
                }
            }
            
        }else if ([key isEqualToString:@"repeatCount"]) {
            
            //repeatCountの設定、現在の値と違えば、
            if ([_history[@"repeatCount"] intValue] != setRepeatCount) {
                
                id newHistory = [[HistorysManager sharedManager] setHistoryValue:@(setRepeatCount) forKey:@"repeatCount" history:_history];
                //newRecordがnilでないなら
                if (newHistory) {
                    //更新に成功したので、_recordを差し替える
                    _history = newHistory;
                }
            }
        }
    }
}


//HistoryMenuViewController上でmenusを保存する処理(historysに追加するかどうかも判定する)
-(id)saveDatesAtHistoryMenuViewController
{
    //0以上の数でなければなんでもいい
    NSInteger index = -1;
    NSString *dateText = [SQLite createDate:[NSDate date]];
    
    id newDate;
    //menusに追加するか、どうかの処理
    if ([[DatesManager sharedManager].dates count] == 0) {
        
        newDate = [[DatesManager sharedManager] addDate:dateText];
        
        //isAddDates = YES;
        
    }else{
        
        //同じメニュー名を持つ場合はmenusに追加しない。
        for (int i=0; i<[[DatesManager sharedManager].dates count]; i++) {
            
            //名前が同じ場合
            if ([dateText isEqualToString:[DatesManager sharedManager].dates[i][@"dateText"]]){index = i;}//indexに保存
            
        }
        
        
        if (index >= 0) {
            
            newDate = @{@"date_pk":@([[DatesManager sharedManager].dates[index][@"date_pk"] intValue]),
                        @"dateText":[DatesManager sharedManager].dates[index][@"dateText"]};
        }else{
            
            newDate = [[DatesManager sharedManager] addDate:dateText];
            
            //isAddDates = YES;
            
        }
    }
    
    return newDate;
}


#pragma mark - UITableView Methods


// セルが選択された時に呼び出される
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [_historyMenuTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 選択されたセルを取得
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        
        NSLog(@"呼ばれました (HistoryMenuViewController, didSelectRowAtIndexPath,None)");
        
        // セルのアクセサリにチェックマークを指定
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        //セルのアクセサリーにチェックマークがはいったindexPathだけ追加
        [checkMarkArray addObject:indexPath];
        
    }
    else if (cell.accessoryType == UITableViewCellAccessoryCheckmark){
        
        NSLog(@"呼ばれました (HistoryMenuViewController, didSelectRowAtIndexPath,Checkmark)");
        
        NSLog(@"checkMarkArrayの数は、%luです",(unsigned long)[checkMarkArray count]);
        
        for (int i=0; i<[checkMarkArray count]; i++) {
            
//            if (checkMarkArray[i] == indexPath) {
                
                NSLog(@"通りました");
                
                // セルのアクセサリにチェックマークを指定
                cell.accessoryType = UITableViewCellAccessoryNone;
                [checkMarkArray removeObject:checkMarkArray[i]];
                
//            }
        }
        
    }
    
}


//セルの設定をする
-(void)configureCell:(HistoryMenuViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
    //cellにタグをつける(エンティティの保存でつかう)
    [cell setTag:indexPath.row];
    //デリゲート通知をする
    cell.delegate = self;
    
    id history;
    
    switch (indexPath.section) {
        case 0://上半身
            history = [HistorysManager sharedManager].historys_upper[(int)(3*indexPath.row)];
            break;
        case 1://下半身
            history = [HistorysManager sharedManager].historys_under[(int)(3*indexPath.row)];
            break;
        default:
            break;
            
    }
    
    //menuNameLabel
    ((UILabel *)cell.menuNameLabel).text = history[@"menuName"];
    //weightField
    ((UITextField *)cell.weightField).text = [NSString stringWithFormat:@"%.1f",[history[@"weight"] floatValue]];
    //repeatCountField
    ((UITextField *)cell.repeatCountField).text = [NSString stringWithFormat:@"%d",[history[@"repeatCount"] intValue]];

    
}


//セクションの数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    //上半身と下半身
    return 2;
}


//セクションの高さ
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //30
    return HISTORY_TABLEVIEW_SECTION_HEIGHT;
}


//セクションをカスタマイズしたい場合
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //viewのインスタンスを生成
    UIView *view = [UIView new];
    //黒
    view.backgroundColor = [UIColor colorWithRed:74.f/255.f green:74.f/255.f blue:74.f/255.f alpha:1];
    //viewに追加したいラベルのインスタンスを準備
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, HISTORY_TABLEVIEW_SECTION_HEIGHT)];
    //ラベルの色は白色
    label.textColor = [UIColor whiteColor];
    
    if ([UIScreen mainScreen].bounds.size.width == 320) {
        
        //ラベルフォントサイズを変更
        label.font = [UIFont systemFontOfSize:14];
        
    }
    
    //名前はセクションごとに分ける
    switch (section)
    {
        case 0://上半身
            label.text = @"  上半身";
            break;
        case 1://下半身
            label.text = @"  下半身";
            break;
    }
    
    //viewに追加
    [view addSubview:label];
    
    return view;
    
}


//行数を返す
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
     //Return the number of rows in the section.
    
    //適当に初期化
    NSInteger numberOfRows = 0;
    
    
    
    //セクションごとに行数は変える
    switch (section) {
        case 0:
            //10
            numberOfRows = [[HistorysManager sharedManager].historys_upper count]/CONTENT_SIZE; //HISTORY_TABLEVIEW_UPPERBODY_SIZE;
            break;
        case 1:
            //10
            numberOfRows = [[HistorysManager sharedManager].historys_under count]/CONTENT_SIZE; //HISTORY_TABLEVIEW_LOWERBODY_SIZE;
            break;
    }
    
    return numberOfRows;
    

}


//セルの設定
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    HistoryMenuViewCell *cell = [tableView dequeueReusableCellWithIdentifier:historyMenuViewCellIdentifer];
    // Configure the cell...
    if (nil == cell) {
        cell = [[HistoryMenuViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:historyMenuViewCellIdentifer];
    }
    
    //セルの設定
    [self configureCell:cell atIndexPath:indexPath];
    
    
    return cell;
}


//行の高さ
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //windowの幅、iPhone6なら375.px
    return HISTORY_TABLEVIEW_ROW_HEIGHT;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([checkMarkArray count] == 0) {
        if (editingStyle == UITableViewCellEditingStyleDelete)
        {
            if (indexPath.section == 0) {
                //データベースからデータを削除
                for (int i=0; i<CONTENT_SIZE; i++) {
                    //historys_upperから削除
                    Historys *deleteHistory = [HistorysManager sharedManager].historys_upper[(int)3*indexPath.row];
                    [[HistorysManager sharedManager] deleteHistory:deleteHistory];
                    
                }
            }else if (indexPath.section == 1){
                //データベースからデータを削除
                for (int i=0; i<CONTENT_SIZE; i++) {
                    Historys *deleteHistory = [HistorysManager sharedManager].historys_under[(int)3*indexPath.row];
                    [[HistorysManager sharedManager] deleteHistory:deleteHistory];
                }
            }
            NSLog(@"historysの数は、%d (HistoryMenuViewController, commitEditingStyle)",(int)[[HistorysManager sharedManager].historys count]);
            [_historyMenuTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            if ([[HistorysManager sharedManager].historys count] == 0) {
                [contentView addSubview:textView];
            }
        }
    }else if ([checkMarkArray count] != 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告"
                                                        message:@"全てのチェックを外してください。"
                                                       delegate:self
                                              cancelButtonTitle:@"cancel"
                                              otherButtonTitles:@"はい", nil];
        [alert show];
    }
}


@end


#pragma mark - HistoryMenuViewController (SQLite) Category


/*-------------------------------*/
//SQLite操作に関するカテゴリ
//カテゴリー名：SQLite
/*-------------------------------*/
///////////////////////////////////
///////////interface///////////////
///////////////////////////////////
@interface HistoryMenuViewController (SQLite)


@end


///////////////////////////////////
///////////implementation//////////
///////////////////////////////////
@implementation HistoryMenuViewController (SQLite)

@end

