//
//  ViewController.m
//  Trainey
//
//  Created by 福田幸弘 on 2015/04/26.
//  Copyright (c) 2015年 yukihiro fukuda. All rights reserved.
//

#import "HomeViewController.h"


//タイマーの変数
#define MINUTE_SIZE 10
#define SECOND_SIZE 7
//タイマーピッカービューの変数
#define TIMER_PICKERVIEW_SIZE 10
//コンテントサイズ
#define CONTENT_SIZE 3
//#define INSERTEDMENU_TABLEVIEW_ROW_COUNT 10
//contentの変数
#define CONTENT_SIZE 3
//マクロ
#define LogReferenceCount(obj) NSLog(@"[%@] reference count = %ld", [obj class], CFGetRetainCount((__bridge void*)obj))



#pragma mark - HomeViewController () Category


/*-------------------------------*/
//クラスエクステンション
//追加するメソッドを書く
/*-------------------------------*/
@interface HomeViewController ()
{
    
}


@end


#pragma mark - HomeViewController Main


/*-------------------------------*/
//メイン(共通)
/*-------------------------------*/
///////////////////////////////////
///////////implementation//////////
///////////////////////////////////
@implementation HomeViewController
{
    //分
    IBOutlet UILabel *minutesLabel;
    //秒
    IBOutlet UILabel *secondsLabel;
    //pickerView
    IBOutlet UIPickerView *pickerView;
    //tabBar
    //IBOutlet UITabBar *tabBar;
    //contentView
    IBOutlet UIView *contentView;
    //textView
    IBOutlet UITextView *textView;
    //timeView
    IBOutlet UIView *timeView;
    //soundNameLabel
    IBOutlet UILabel *soundNameLabel;
    //バイブレーションを鳴らすか？
    BOOL isVivrate;
    //タイマー
    NSTimer *timer;
    //ユーザーデフォルト
    NSUserDefaults *defaults;
    //BGMマネジャー
    BGMManager *sounndManager;
    //appDelegate
    AppDelegate *appDelegate;
    //読み込むmenuViewCellのxib
    NSString *menuViewCellIdentifer;
    //insertedMenuTableViewを挿入する場所
    CGFloat INSERTEDMENU_TABLEVIEW_ROW_HEIGHT;
    //pickerViewの縦横の比率
    CGFloat PICKER_VIEW_X_RATE;
    CGFloat PICKER_VIEW_Y_RATE;
}


//アクセサメソッドの実装
@synthesize insertedMenuTableView = _insertedMenuTableView;
@synthesize record = _record;
@synthesize minutes = _minutes;
@synthesize seconds = _seconds;


#pragma mark - Custom Getter Methods

-(NSString *)soundText
{
    
    NSString *result;
    
    if ([defaults stringForKey:@"soundText"] == Nil) {
        //初期値
        [defaults setValue:@"ピンポーン" forKey:@"soundText"];
    }
    //defaultsから取り出す
    result = [defaults stringForKey:@"soundText"];
    
    return result;
}


#pragma mark - Standard Methods


//iPhoneの画面サイズで読み込むxibを変える
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    CGRect screenSize = [UIScreen mainScreen].bounds;
    
    //@1xの場合(3G,3GSの場合,ipadのiphoneシミュレータの@1x)
    if (screenSize.size.height == 480) {
        nibNameOrNil = @"HomeViewController@3.5inch";
        PICKER_VIEW_X_RATE = 0.662;
        PICKER_VIEW_Y_RATE = 0.662;
    }
    //@2xの場合(5,5s,5cの場合)
    else if (screenSize.size.height == 568){
        nibNameOrNil = @"HomeViewController@4inch";
        PICKER_VIEW_X_RATE = 0.821;
        PICKER_VIEW_Y_RATE = 0.821;
    }
    //その他の場合
    else {
        nibNameOrNil = @"HomeViewController";
        PICKER_VIEW_X_RATE = 1;
        PICKER_VIEW_Y_RATE = 1;
    }
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    
    return self;
}


- (void)viewDidLoad
{
    
    NSLog(@"呼ばれました (HomeViewController, viewDidLoad)");
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //タイマーを初期化する
    _seconds = 0;
    _minutes = 0;
    secondsLabel.text = @"00";
    minutesLabel.text = @"00";
    
    //pickerViewのデリゲートをこのクラスにする
    pickerView.delegate = self;
    pickerView.dataSource = self;
    
    //pickerViewのサイズを変える
    pickerView.transform = CGAffineTransformMakeScale(PICKER_VIEW_X_RATE, PICKER_VIEW_Y_RATE);
    
    //appDelegateインスタンスの生成
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    //tableViewの設定
    [self settingInsertedMenuTableViewController];
    
    //タイマーのボタンのラベルの設定
    defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:@"開始" forKey:@"startCancelText"];
    [defaults setValue:@"一時停止" forKey:@"temporarystopRestartText"];
    
    //BGMを扱うマネージャー
    sounndManager = [BGMManager new];
    //soundNameLabelを設定する
    soundNameLabel.text = self.soundText;
}


-(void)viewWillAppear:(BOOL)animated
{
    
    NSLog(@"呼ばれました (HomeViewController, viewWillAppear)");
    
    [super viewWillAppear:NO];
    
    //soundNameLabelの設定
    soundNameLabel.text = self.soundText;
    
    
    if ([[RecordsManager sharedManager].records_dateText count] / CONTENT_SIZE != 0) {
        
        [textView removeFromSuperview];
        [_insertedMenuTableView reloadData];
        
        
    }
    else if ([[RecordsManager sharedManager].records_dateText count] / CONTENT_SIZE == 0){
        
        [contentView addSubview:textView];
        [contentView bringSubviewToFront:textView];
        
    }
    
    //タイマーの操作ラベルの設定
    appDelegate.tabInitialViewController.startCancelLabel.text = appDelegate.startCancelText;
    appDelegate.tabInitialViewController.temporarystopRestartLabel.text = appDelegate.temporarystopRestartText;
    
    //temporarystopRestartLabelのenable
    appDelegate.tabInitialViewController.temporarystopRestartButton.enabled = [defaults boolForKey:@"temporarystopRestartEnabled"];
    
    
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
        INSERTEDMENU_TABLEVIEW_ROW_HEIGHT = 167;
        
    }
    //@2xの場合(5,5s,5cの場合)
    else if (screenSize.size.height == 568){
        menuViewCellIdentifer = @"MenuViewCell@4inch";
        INSERTEDMENU_TABLEVIEW_ROW_HEIGHT = 187;
    }
    //その他の場合
    else {
        menuViewCellIdentifer = @"MenuViewCell";
        INSERTEDMENU_TABLEVIEW_ROW_HEIGHT = 228;
    }
    
}


//InsertedMenuTableViewControllerを追加するメソッド
-(void)settingInsertedMenuTableViewController
{
    
    NSLog(@"呼ばれました (HomeViewController, settingInsertedMenuTableViewController)");
    
    //読み込むMenuViewCellのxibと行の高さを決める
    [self loadMenuViewCellXib];
    
        
    CGRect frame = CGRectMake(0, 0, INSERTEDMENU_TABLEVIEW_ROW_HEIGHT, [UIScreen mainScreen].bounds.size.width);
    _insertedMenuTableView = [[UITableView alloc] initWithFrame:frame];
        
    // 横スクロールに変更
    _insertedMenuTableView.center = CGPointMake(_insertedMenuTableView.frame.origin.x + _insertedMenuTableView.frame.size.height / 2, _insertedMenuTableView.frame.origin.y + _insertedMenuTableView.frame.size.width / 2);
    _insertedMenuTableView.transform = CGAffineTransformMakeRotation(-M_PI / 2);
        
    // horizontalセルのdelegate等を設定
    _insertedMenuTableView.delegate = (id)self;
    _insertedMenuTableView.dataSource = (id)self;
    
    
        
    // セルの再利用登録
    [_insertedMenuTableView registerNib:[UINib nibWithNibName:menuViewCellIdentifer bundle:nil] forCellReuseIdentifier:menuViewCellIdentifer];
        
    //ページングをYESにする
    _insertedMenuTableView.pagingEnabled = YES;
    
    
    
    //テーブルビューを今クラスのviewに加える
    [contentView addSubview:_insertedMenuTableView];
     
        
    if([[RecordsManager sharedManager].records_dateText count] == 0){
        
        NSLog(@"records_dateTextの数は、%d (HomeViewController, viewDidLoad, count=0) ", (int)[[RecordsManager sharedManager].records_dateText count]);
        
        [contentView addSubview:textView];
        
    }

}


////isTryを保存する
//-(void)saveRecords_dateText_isTry:(MenuViewCell *)cell atCellTag:(NSInteger)cellTag atRowIndex:(NSInteger)index
//{
//    //念のために_recordを再取得しておく
//    _record = [RecordsManager sharedManager].records_dateText[(int)(3*cellTag+index)];
//    
//    //現在セットされているisTrainingSwitchsの値を保存する。(onプロパティが大事)
//    int setisTry = [[NSNumber numberWithBool:((UISwitch *)cell.isTrainingSwitchs[index]).on] intValue];
//    
//    id newRecord = [[RecordsManager sharedManager] setRecordValue:@(setisTry) forKey:@"isTry" record:_record forTag:@"records_dateText"];
//    
//    //newRecordがnilでないなら
//    if (newRecord) {
//        //更新に成功したので、_recordを差し替える
//        _record = newRecord;
//    }
//    
//    
//    //
//    
//    
//    
//    
//    //テーブルビューのセルを更新
//    NSIndexPath *indexPath = [_insertedMenuTableView indexPathForCell:cell];
//    [_insertedMenuTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    
//    
//    //PerformanceCheckingViewControllerのtableViewもリロードしておく必要が有る
//    [((PerformanceCheckingViewController *)appDelegate.performanceCheckingViewController).currentTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    
//}


//isTryを保存する
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
    NSIndexPath *indexPath = [_insertedMenuTableView indexPathForCell:cell];
    [_insertedMenuTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    //PerformanceCheckingViewControllerのtableViewもリロードしておく必要が有る
    [((PerformanceCheckingViewController *)appDelegate.performanceCheckingViewController).currentTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
}


//weightとrepeatCountを保存する
-(void)saveRecords_dateText_textField:(MenuViewCell *)cell atCellTag:(NSInteger)cellTag atRowIndex:(NSInteger)index forKey:(id)key
{
    
    NSLog(@"呼ばれました. (HomeViewController, saveRecords_dateText_textField)");
    
    
    //念のために_recordを再取得しておく
    _record = [RecordsManager sharedManager].records_dateText[(int)(3*cellTag+index)];
    
    
    NSLog(@"record_pkは、%d (HomeViewController, saveRecords_dateText_textField)",[_record[@"record_pk"] intValue]);
    
    
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
    NSIndexPath *indexPath = [_insertedMenuTableView indexPathForCell:cell];
    [_insertedMenuTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    
    //PerformanceCheckingViewControllerのtableViewからも削除しておかないとエラーになる。
    [((PerformanceCheckingViewController *)appDelegate.performanceCheckingViewController).currentTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    
    
}





//タイマーのキャンセルor開始処理
-(void)startCancelInterval:(UILabel *)startCancelLabel
{
    
    if ([startCancelLabel.text isEqualToString:@"キャンセル"])
    {
        NSLog(@"キャンセルでした (HomeViewController, startCancelInterval)");
        //timerを初期化処理
        [timer invalidate];
        timer = nil;
        //removeSuperView処理
        [timeView removeFromSuperview];
        
        
    }
    //開始が表示されているなら
    else if ([startCancelLabel.text isEqualToString:@"開始"])
    {
        NSLog(@"開始でした (HomeViewController, startCancelInterval)");
        
        //addSubView処理
        [self.view addSubview:timeView];
        
        
        //タイマーの設定
        //分の設定
        _minutes = [pickerView selectedRowInComponent:0];
        //分のラベルをセットする
        minutesLabel.text =[NSString stringWithFormat:@"0%d", (int)_minutes];
        //秒の設定
        _seconds = [pickerView selectedRowInComponent:1]*15;
        if (_seconds == 1)
        {
            //秒のラベルをセットする
            secondsLabel.text = [NSString stringWithFormat:@"0%d", (int)_seconds];
            
        }
        else if (_seconds != 1)
        {
            //秒のラベルをセットする
            secondsLabel.text = [NSString stringWithFormat:@"%d", (int)_seconds];
            
        }
        
        //timerをスタート処理
        //1秒戻す(startTimerが呼び出されたら1秒たたずに１秒減るため)
        _seconds++;
        [self startTimer];
        
    }
    
}


//タイマーの再開or停止処理
-(void)stopRestartInterval:(UILabel *)temporarystopRestartLabel
{
    
    //一時停止が表示されているなら
    if ([temporarystopRestartLabel.text isEqualToString:@"一時停止"])
    {
        NSLog(@"一時停止でした (HomeViewController, stopRestartInterval)");
        //timerを停止する処理
        [timer invalidate];
        
    }
    //再開が表示されているなら
    else if ([temporarystopRestartLabel.text isEqualToString:@"再開"])
    {
        NSLog(@"再開でした (HomeViewController, stopRestartInterval)");
        //timerを再開する処理
        //1秒戻す(startTimerが呼び出されたら1秒たたずに１秒減るため)
        _seconds++;
        [self startTimer];
    }
    
}


//タイマーをスタートする処理
-(void)startTimer
{
    
    
    
    //タイマーを作成
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                             target:self
                                           selector:@selector(time:)
                                           userInfo:nil
                                            repeats:YES];
    [timer fire];
    
    
}


//タイマー用メソッド
-(void)time:(NSTimer *)aTimer
{
    
    
    
    //0秒でないなら
    if (_seconds != 0)
    {
        //1秒減らす、それが10以下なら
        if((_seconds--) <= 10)
        {
            //秒のラベルを設定する
            secondsLabel.text = [NSString stringWithFormat:@"0%d", (int)_seconds];
        }
        else {
            //秒のラベルを設定する
            secondsLabel.text = [NSString stringWithFormat:@"%d", (int)_seconds];
            
        }
    }
    //0秒になったら
    else if ( _seconds == 0)
    {
        //0分でないなら
        if (_minutes != 0)
        {
            //1分減らす
            _minutes--;
            minutesLabel.text = [NSString stringWithFormat:@"0%d", (int)_minutes];
            //59秒に戻す
            _seconds = 59;
            //1秒減らす
            secondsLabel.text = [NSString stringWithFormat:@"%d", (int)_seconds];
        }
        //0分なら
        else if (_minutes == 0)
        {
            
            [aTimer invalidate];
            
            //removeSuperView処理
            [timeView removeFromSuperview];
            
            //startCancelLabelのテキストを開始に書き換える
            appDelegate.tabInitialViewController.startCancelLabel.text = @"開始";
            
            
            //効果音再生
            [sounndManager startBGM:[NSString stringWithFormat:@"%@.mp3",soundNameLabel.text]];
            //バイブ再生
            isVivrate = YES;
            AudioServicesAddSystemSoundCompletion (
                                                   kSystemSoundID_Vibrate,
                                                   NULL,
                                                   NULL,
                                                   MyAudioServicesSystemSoundCompletionProc,
                                                   (__bridge void *) self
                                                   );
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            
            
            
            //アラートを出す(アラーム停止)
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"タイマー終了"
                                      message:nil
                                      delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil, nil];
            
            //デリゲート
            alertView.delegate = self;
            
            //alertViewを出現させる
            [alertView show];
            
            
        }
    }
    
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"呼ばれました (HomeViewController, clickedButtonAtIndex)");
    
    //BGMを止める
    [sounndManager stopBGM];
    //バイブを止める
    isVivrate = NO;
    
    
    //押せないようにする
    appDelegate.tabInitialViewController.temporarystopRestartButton.enabled = NO;
    //ユーザーデフォルトの設定をする
    [defaults setValue:@"開始" forKey:@"startCancelText"];
    [defaults setValue:@"一時停止" forKey:@"temporarystopRestartText"];
    
}


//アラーム音を選択する
-(IBAction)selectSound:(id)sender
{
    NSLog(@"呼ばれました (HomeViewController, selectSound)");
    
    //SoundSelectViewControllerへ移動する
    SoundSelectViewController *soundSelectViewController = [[SoundSelectViewController alloc]initWithNibName:@"SoundSelectViewController" bundle:nil];
    //navigationControllerを介して画面遷移
    [self.navigationController pushViewController:soundSelectViewController animated:YES];
    
    
}


//バイブレーションを発生させる
void MyAudioServicesSystemSoundCompletionProc (
                                               SystemSoundID ssID,
                                               void *clientData
                                               );


void MyAudioServicesSystemSoundCompletionProc (
                                               SystemSoundID ssID,
                                               void *clientData
                                               )
{
    
    
    
    if (((__bridge HomeViewController *)clientData)->isVivrate)
    {
        
        NSTimeInterval elapsedTime = 0.7; // 秒間隔
        [NSThread sleepForTimeInterval:(NSTimeInterval)elapsedTime];
        
        // バイブ
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        
    }
    else
    {
        AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate);
    }
    
}


#pragma mark - UITableView Methods


//行を削除する。
-(void)deleteMenuViewCell:(MenuViewCell *)cell atCellTag:(NSInteger)cellTag
{
    
    //テーブルビューから削除
    NSIndexPath *indexPath = [_insertedMenuTableView indexPathForCell:cell];
    
    //データベースからデータを削除
    for (int i=0; i<CONTENT_SIZE; i++) {
        Records *deleteRecord = [RecordsManager sharedManager].records_dateText[(int)(3*indexPath.row+i-(i-1)-1)];
        [[RecordsManager sharedManager] deleteRecord:deleteRecord atDate:[NSDate date]];
    }
    
    
    [_insertedMenuTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    
    //PerformanceCheckingViewControllerのtableViewからも削除しておかないとエラーになる。
    [((PerformanceCheckingViewController *)appDelegate.performanceCheckingViewController).currentTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    

    if ([[RecordsManager sharedManager].records_dateText count] == 0) {
        
        
        NSLog(@"呼ばれました　(HomeViewController, deleteMenuViewCell)");
        
        [contentView addSubview:textView];
        //最前面に持ってくる
        [contentView bringSubviewToFront:textView];
        
        
        }
}

//セルの設定をする
-(void)configureCell:(MenuViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"呼ばれました (HomeViewController, configureCell)");
    
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
        }
        else if ([_record[@"menuCategory"] intValue] == 1) {
            menuNameWithNumber = [NSString stringWithFormat:@"%@ (下)",menuNameWithNumber];
        }
        
        //テキストの設定
        //((UIBarButtonItem *)cell.toolBar.items[0]).title = menuNameWithNumber;
        ((UILabel *)cell.menuNameLabel).text = menuNameWithNumber;
        
        //isTry
        [cell.isTrainingSwitchs[i] setOn:[_record[@"isTry"] boolValue] animated:NO];
        
        //weight
        ((UITextField *)cell.weightFields[i]).text = [NSString stringWithFormat:@"%.1f",[_record[@"weight"] floatValue]];
        
        //repeatCount
        ((UITextField *)cell.repeatCountFields[i]).text = [NSString stringWithFormat:@"%d",[_record[@"repeatCount"] intValue]];
        
        
    }
    
    //accessoryTypeの設定（上書き）
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    // セルの向きを横向きに
    cell.contentView.transform = CGAffineTransformMakeRotation(M_PI / 2);
    
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"呼ばれました (HomeViewController, numberOfSectionsInTableView)");
    
    return 1;
}


//行数を返す
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"呼ばれました、%d (HomeViewController,numberOfRowsInSection)",(int)section);
    
    return [[RecordsManager sharedManager].records_dateText count]/CONTENT_SIZE;
}


//セルの設定
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //セルの再利用
    MenuViewCell *cell = [tableView dequeueReusableCellWithIdentifier:menuViewCellIdentifer];
    
    //セルの設定をする
    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}


//行の高さ
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //470
    return [UIScreen mainScreen].bounds.size.width;
}


#pragma mark - UIPickerView Methods


//PickerViewの列の数を指定
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView
{
    //分と秒
    return 2;
}


//カラムの要素数を指定
- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component
{
    /*
     component == 0: 0〜10までの数、行数11
     component == 1: 0〜90@±5までの数、行数19
     */
    
    if (component == 0) {
        //10
        return MINUTE_SIZE;
    }
    else if (component == 1) {
        //4
        return SECOND_SIZE;
    }
    else {
        //返り値が存在するので、関係がない場合もとりあえず0を返す。
        return 0;
    }
}


//選択肢要素の表示文字列
- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    
    /*
     component == 0: 0〜10までの数、行数11
     component == 1: 0〜90@±5までの数、行数18
     */
    
    if (component == 0) {
        return [NSString stringWithFormat:@"%d",(int)row];
    }
    else if (component == 1) {
        return [NSString stringWithFormat:@"%d",(int)(15*row)];
    }
    else {
        //返り値が存在するので、関係がない場合もとりあえず@""を返す。
        return @"";
    }
    
}


//列と行のサイズの変更
-(CGFloat)pickerView:(UIPickerView *)pickerView withForComponent:(NSInteger)component
{
    //10
    return TIMER_PICKERVIEW_SIZE;
    
}


//選択肢が変更された際の処理
- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            //分
            _minutes = row;
            //分のラベルをセットする
            minutesLabel.text =[NSString stringWithFormat:@"0%d", (int)_minutes];
            break;
        case 1:
            //秒
            _seconds = 15*row;
            if (row == 0)
            {
                //秒のラベルをセットする
                secondsLabel.text = [NSString stringWithFormat:@"0%d", (int)_seconds];
                
            }
            else if (row != 0)
            {
                //秒のラベルをセットする
                secondsLabel.text = [NSString stringWithFormat:@"%d", (int)_seconds];
                
            }
            break;
        default:
            break;
    }
}



@end


#pragma mark - HomeViewController (View_Model) Category


/*-------------------------------*/
//画面の表示・遷移に関するカテゴリ
//カテゴリー名：Display
/*-------------------------------*/
///////////////////////////////////
///////////interface///////////////
///////////////////////////////////
@interface HomeViewController (View_Model)


@end


///////////////////////////////////
///////////implementation//////////
///////////////////////////////////
@implementation HomeViewController (View_Model)


@end


#pragma mark - HomeViewController (Controller) Category


/*-------------------------------*/
//画面上で起こる操作に関するカテゴリ
//カテゴリー名：Control
/*-------------------------------*/
///////////////////////////////////
///////////interface///////////////
///////////////////////////////////
@interface HomeViewController (Controller)


@end


///////////////////////////////////
///////////implementation//////////
///////////////////////////////////
@implementation HomeViewController (Controller)


@end