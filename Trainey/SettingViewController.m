//
//  SettingViewController.m
//  Trainey
//
//  Created by 福田幸弘 on 2015/04/29.
//  Copyright (c) 2015年 yukihiro fukuda. All rights reserved.
//

#import "SettingViewController.h"
#import "MessageUI/MessageUI.h"

//SettingTableViewの変数
#define SETTING_TABLEVIEW_SECTION_HEIGHT 30.
#define SETTING_TABLEVIEW_SECTION_COUNT 4
#define SETTING_TABLEVIEW_ROW_HEIGHT 53.
#define SETTING_TABLEVIEW_NAMEPLATEROW_HEIGHT 132.
#define SETTING_TABLEVIEW_CONFIGURE_COUNT 3
#define SETTING_TABLEVIEW_SUPPORT_COUNT 3
#define SETTING_TABLEVIEW_SPACE_COUNT 1



#pragma mark - SettingViewController () Category


/*-------------------------------*/
//クラスエクステンション
//追加するメソッドを書く
/*-------------------------------*/
@interface SettingViewController ()


@end


#pragma mark - SettingViewController Main


/*-------------------------------*/
//メイン(共通)
/*-------------------------------*/
///////////////////////////////////
///////////implementation//////////
///////////////////////////////////
@implementation SettingViewController
{
    AppDelegate *appDelegate;
    NSUserDefaults *defaults;
    //読み込むcustomCellのxib
    NSString *switchButtonCellIdentifier;
    NSString *viewCellIdentifier;
    NSString *namePlateCellIdentifier;
    NSString *normalCellIdentifier;
    NSString *themeViewCellIdentifier;
    //読み込むDetailViewControllerのxib
    NSString *detailViewControllerIdentifer;
}


//アクセサメソッドの実装
@synthesize tableView = _tableView;


#pragma mark - Standard Methods


//iPhoneの画面サイズで読み込むxibを変える
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    CGRect screenSize = [UIScreen mainScreen].bounds;
    
    //@1xの場合(3G,3GSの場合,ipadのiphoneシミュレータの@1x)
    if (screenSize.size.height == 480) {
        nibNameOrNil = @"SettingViewController@3.5inch";
        detailViewControllerIdentifer = @"DetailViewController@3.5inch";
    }
    //@2xの場合(5,5s,5cの場合)
    else if (screenSize.size.height == 568){
        nibNameOrNil = @"SettingViewController@4inch";
        detailViewControllerIdentifer = @"DetailViewController@4inch";
    }
    //その他の場合
    else {
        nibNameOrNil = @"SettingViewController";
        detailViewControllerIdentifer = @"DetailViewController";
    }
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //navigationbarのタイトルの設定
    _navigationBar.topItem.title = [SQLite createDate:[NSDate date]];
    
    //インスタンスを生成
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    defaults = [NSUserDefaults standardUserDefaults];
    
    //delegateとdataSourceの設定
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    //読み込むCunstomCellのxibを選ぶ
    [self loadCustomCellXib];
    
    //tableViewのセルを設定する
    //ViewCell
    [_tableView registerNib:[UINib nibWithNibName:viewCellIdentifier bundle:nil] forCellReuseIdentifier:viewCellIdentifier];
    //NamePlateCell
    [_tableView registerNib:[UINib nibWithNibName:namePlateCellIdentifier bundle:nil] forCellReuseIdentifier:namePlateCellIdentifier];
    //NormalCell
    [_tableView registerNib:[UINib nibWithNibName:normalCellIdentifier bundle:nil] forCellReuseIdentifier:normalCellIdentifier];
    //ThemeViewCell
    [_tableView registerNib:[UINib nibWithNibName:themeViewCellIdentifier bundle:nil] forCellReuseIdentifier:themeViewCellIdentifier];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:NO];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Private Methods


- (void)loadCustomCellXib {
    
    CGRect screenSize = [UIScreen mainScreen].bounds;
    
    //@1xの場合(3G,3GSの場合,ipadのiphoneシミュレータの@1x)
    if (screenSize.size.height == 480) {
        viewCellIdentifier = @"ViewCell@3.5inch";
        namePlateCellIdentifier = @"NamePlateCell@3.5inch";
        normalCellIdentifier = @"NormalCell@3.5inch";
        themeViewCellIdentifier = @"ThemeViewCell@3.5inch";
    }
    //@2xの場合(5,5s,5cの場合)
    else if (screenSize.size.height == 568){
        viewCellIdentifier = @"ViewCell@4inch";
        namePlateCellIdentifier = @"NamePlateCell@4inch";
        normalCellIdentifier = @"NormalCell@4inch";
        themeViewCellIdentifier = @"ThemeViewCell@4inch";
    }
    //その他の場合
    else {
        viewCellIdentifier = @"ViewCell";
        namePlateCellIdentifier = @"NamePlateCell";
        normalCellIdentifier = @"NormalCell";
        themeViewCellIdentifier = @"ThemeViewCell";
    }
    
    
}


-(NSString *)reminderText
{
    NSString *result;
    if ([defaults stringForKey:@"notificationSwitchValue"] == Nil) {
        //初期値
        [defaults setValue:@"設定なし" forKey:@"reminderText"];
    }
    //defaultsから取り出す
    result = [defaults stringForKey:@"reminderText"];
    
    return result;
}


//<戻るボタンが押された時の処理
-(IBAction)tapCancelButton:(id)sender
{
    
    //0番目はnavigationControllerである。
    //InsertNewObjectViewControllerの画面からSettingViewControllerに遷移した後、
    //このメソッドを実行すると、InitialViewControllerの画面にもどる
    [appDelegate switchTabBarController:0];
    
    
}


//書き出すデータをカンマと改行区切りのNSStringに整形
-(NSString *)transformCSVString:(NSArray *)records
{
    
    //1行目だけ先に追加
    NSMutableArray *allRecords = [@[@"No.,日付,メニューカテゴリー,メニューネーム,実行,負荷(kg),反復回数(回)"] mutableCopy];
    
    //カンマ区切りで追加
    for (int i=0; i<records.count; i++) {
        
        id record = [records objectAtIndex:i];
        
        //menuCategoryを変換
        NSString *menuCategory;
        if ([[record valueForKey:@"menuCategory"] integerValue] == 0) {
            menuCategory = @"上半身";
        }
        else{
            menuCategory = @"下半身";
        }
        
        //isTryを変換
        NSString *isTry;
        if ([[record valueForKey:@"isTry"] integerValue] == 0) {
            isTry = @"未";
        }
        else{
            isTry = @"済";
        }
        
        //weightを変換
        NSString *weight;
        weight = [NSString stringWithFormat:@"%.1f",[record[@"weight"] floatValue]];
        
        
        //出力する配列の作成
        NSArray *addingRecord = @[
                                  [record valueForKey:@"record_pk"],
                                  [record valueForKey:@"dateText"],
                                  menuCategory,
                                  [record valueForKey:@"menuName"],
                                  isTry,
                                  weight,
                                  [record valueForKey:@"repeatCount"]
                                  ];
        
        NSString *str  = [addingRecord componentsJoinedByString:@","];
        [allRecords addObject:str];
        
    }
    
    // CRLFで区切ったNSStringを返す
    return [allRecords componentsJoinedByString:@"\r\n"];
    
}


//MFMailComposeViewControllerにデータをセット、表示
-(void)exportCSVFile
{
    if (![MFMailComposeViewController canSendMail]) {
        
        return;
    }
    
    //メールのインスタンス
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
    [controller setMailComposeDelegate:(id)self];
    
    //題名
    [controller setSubject:@"Traineyの出力データ"];
    
    //本文
    [controller setMessageBody:@"お役立てください。\r\n\n 例) Excelでメニュー別にグラフ化する。" isHTML:NO];
    
    //取得したNSStringをNSDataに変換
    NSData *data = [[self transformCSVString:[[SQLite sharedSQLite] fetchRecords]] dataUsingEncoding:NSUTF8StringEncoding];
    
    //mimeTypeはtext/csv
    [controller addAttachmentData:data mimeType:@"text/csv" fileName:@"Trainey.csv"];
    
    //barの色
    controller.navigationBar.tintColor = [UIColor whiteColor];
    
    
    //表示
    [self.navigationController presentViewController:controller animated:YES completion:nil];
    
    
    
}


//メール送信処理完了時の処理（あった方が無難）
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error {
    
    switch (result){
        case MFMailComposeResultCancelled:  //キャンセル
            break;
        case MFMailComposeResultSaved:      //保存
            break;
        case MFMailComposeResultSent:       //送信成功
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"送信しました"
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"OK", nil];
            [alert show];
            break;
        }
        case MFMailComposeResultFailed:     //送信失敗
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"送信が失敗しました"
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"OK", nil];
            [alert show];
            break;
        }
        default:
            break;
    }
    
    [self dismissModalViewControllerAnimated:YES];
}



#pragma mark - UITableView Methods


//セクションの数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"呼ばれました (SettingViewController, numberOfSectionsInTableView)");
    
    //4
    return SETTING_TABLEVIEW_SECTION_COUNT;
}


//セクションタイトル
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    //カスタマイズしたい場合でもとりあえず、このメソッドを実装する必要が有るようである
    return @" ";
}


//セクションタイトルの高さ
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //30
    return SETTING_TABLEVIEW_SECTION_HEIGHT;
}


//セクションをカスタマイズしたい場合
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //viewのインスタンスを生成
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor colorWithRed:74.f/255.f green:74.f/255.f blue:74.f/255.f alpha:1];
    //viewに追加したいラベルのインスタンスを準備
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, SETTING_TABLEVIEW_SECTION_HEIGHT)];
    //ラベルの色は白色
    label.textColor = [UIColor whiteColor];
    
    if ([UIScreen mainScreen].bounds.size.width == 320) {
    
    //ラベルフォントサイズを変更
    label.font = [UIFont systemFontOfSize:14];
        
    }
    
    //名前はセクションごとに分ける
    switch (section)
    {
        case 0:
            label.text = @"  設定";
            break;
        case 1:
            label.text = @"  サポート";
            break;
        case 2:
            label.text = @"   ";
            break;
        case 3:
            label.text = @"   ";
            break;
    }
    
    //viewに追加
    [view addSubview:label];
    
    return view;
    
}


//行数を返す
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"呼ばれました (SettigViewController, numberOfRowsInSection)");
    
    //適当に初期化
    NSInteger numberOfRows = 0;
    
    //セクションごとに行数は変える
    switch (section) {
        case 0:
            //3
            numberOfRows = SETTING_TABLEVIEW_CONFIGURE_COUNT;
            break;
        case 1:
            //3
            numberOfRows = SETTING_TABLEVIEW_SUPPORT_COUNT;
            break;
        case 2:
            //1
            numberOfRows = SETTING_TABLEVIEW_SPACE_COUNT;
            break;
        case 3:
            //1
            numberOfRows = SETTING_TABLEVIEW_SPACE_COUNT;
            break;
    }
    return numberOfRows;
}


//セルの設定
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //セルの識別子（セクションと行によって様々である）
    NSString *CellIdentifier;
    switch (indexPath.section) {//セクションで場合分け
        case 0://設定
            if (indexPath.row == 0) {
                CellIdentifier = themeViewCellIdentifier;
            }else if (indexPath.row == 1) {
                CellIdentifier = viewCellIdentifier;
            } else if (indexPath.row == 2) {
                CellIdentifier = normalCellIdentifier;
            }
            break;
        case 1://サポート
            CellIdentifier = normalCellIdentifier;
            break;
        case 2://データリセット
            CellIdentifier = normalCellIdentifier;
            break;
        case 3://ネームプレート
            CellIdentifier = namePlateCellIdentifier;
            break;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // Configure the cell...
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    
    
    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}


//Cellの高さの調整
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight;
    
    //ネームプレートなら
    if (indexPath.section == 3 && indexPath.row == 0) {
        //132.
        cellHeight = SETTING_TABLEVIEW_NAMEPLATEROW_HEIGHT;
        
    } else if (indexPath.section == 0 && indexPath.row == 0) {
        //106
        cellHeight = 2*SETTING_TABLEVIEW_ROW_HEIGHT;
        
    }else {
        //53.
        cellHeight = SETTING_TABLEVIEW_ROW_HEIGHT;
    }
    return cellHeight;
}


//フッターのサイズを０にする(効き目ない)
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}


// セルが選択された時に呼び出される
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    DetailViewController *detailViewController = [[DetailViewController alloc]initWithNibName:detailViewControllerIdentifer bundle:nil ];
    
    //テーマカラーなら
    if ((indexPath.section == 0 && indexPath.row == 0)){
        //何もしない
    }
    else if ((indexPath.section == 0 && indexPath.row == 2)){
        
        //Trainey.csvをメールで送信
        [self exportCSVFile];
        
    }
    else{
        //indexPathを遷移先のクラスのプロパティに渡す
        [detailViewController setSettingTableViewIndexPath:indexPath];
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
    
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
    if ([UIScreen mainScreen].bounds.size.width == 320) {
        
        //ラベルフォントサイズを変更
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        
    }
    
    
    //テキストの設定
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"";
                break;
            case 1:
                cell.textLabel.text = @"リマインダー";
                ((ViewCell *)cell).reminderLabel.text = self.reminderText;
                break;
            case 2:
                cell.textLabel.text = @"データ出力";
                break;
        }
    }
    else if (indexPath.section == 1) { //サポート
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"よくある質問";
                break;
            case 1:
                cell.textLabel.text = @"お知らせ";
                break;
            case 2:
                cell.textLabel.text = @"Twitter(サポートページ)";
                break;
        }
    }
    else if (indexPath.section == 2) { //AppleStore
        cell.textLabel.text = @"AppleStore(Traineyアプリへ)";
    }
    
    
}


@end


#pragma mark - SettingViewController (Controller) Category


/*-------------------------------*/
//画面上で起こる操作に関するカテゴリ
//カテゴリー名：Control
/*-------------------------------*/
///////////////////////////////////
///////////interface///////////////
///////////////////////////////////
@interface SettingViewController (Controller)


@end


///////////////////////////////////
///////////implementation//////////
///////////////////////////////////
@implementation SettingViewController (Controller)


@end