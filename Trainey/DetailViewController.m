//
//  QuestionViewController.m
//  Trainey
//
//  Created by 福田幸弘 on 2015/06/23.
//  Copyright (c) 2015年 yukihiro fukuda. All rights reserved.
//

#import "DetailViewController.h"



#define DETAIL_VIEW_POSITION_Y 64
#define DETAIL_VIEW_HEIGHT 559
#define PICKER_HEIGHT 200
#define REPEAT_DAY_COUNT 8


@interface DetailViewController ()


@end


@implementation DetailViewController
{
    //プロパティにしたらinputViewにできない
    UIDatePicker *datePicker;
    UIPickerView *repeatSettingPicker;
    NSUserDefaults *defaults;
    NSArray *dateArray;
    AppDelegate *appDelegate;
    
}


@synthesize navigationBar = _navigationBar;
@synthesize settingTableViewIndexPath = _settingTableViewIndexPath;
@synthesize textView = _textView;
@synthesize notificationView = _notificationView;
@synthesize dateSettingTextField = _dateSettingTextField;
@synthesize repeatSettingTextField = _repeatSettingTextField;
@synthesize notificationSwitch = _notificationSwitch;
@synthesize memotextView = _memotextView;


#pragma mamrk - Standard Methods


//iPhoneの画面サイズで読み込むxibを変える
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    CGRect screenSize = [UIScreen mainScreen].bounds;
    
    //@1xの場合(3G,3GSの場合,ipadのiphoneシミュレータの@1x)
    if (screenSize.size.height == 480) {
        nibNameOrNil = @"DetailViewController@3.5inch";
    }
    //@2xの場合(5,5s,5cの場合)
    else if (screenSize.size.height == 568){
        nibNameOrNil = @"DetailViewController@4inch";
    }
    //その他の場合
    else {
        nibNameOrNil = @"DetailViewController";
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
    
    //navigationbarのタイトルの設定
    _navigationBar.topItem.title = [SQLite createDate:[NSDate date]];
    
    //NSUserDefaultsの設定
    defaults = [NSUserDefaults standardUserDefaults];
    appDelegate = [UIApplication sharedApplication].delegate;
    
    //各textView,UISwitchの設定
    _dateSettingTextField.text = self.dateSettingText;
    _repeatSettingTextField.text = self.repeatSettingText;
    [_notificationSwitch setOn:self.notificationSwitchValue];
    _memotextView.text = self.memoText;
    
    
    //dateArrayの準備
    dateArray = @[
                  @"しない",
                  @"毎週日曜日",
                  @"毎週月曜日",
                  @"毎週火曜日",
                  @"毎週水曜日",
                  @"毎週木曜日",
                  @"毎週金曜日",
                  @"毎週土曜日",
                  ];
    
    
    //delegateとtagの設定
    _dateSettingTextField.delegate = self;
    _repeatSettingTextField.delegate = self;
    _dateSettingTextField.tag = 1;
    _repeatSettingTextField.tag = 2;
    
    
    //dataPickerの設定
    datePicker = [[UIDatePicker alloc] init];
    datePicker.tag = 1;
    datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    datePicker.minuteInterval = 1;
    [datePicker addTarget:self
                   action:@selector(datePickerValueChanged:)
         forControlEvents:UIControlEventValueChanged];
    

    //repeatSettingPickerの設定
    repeatSettingPicker = [[UIPickerView alloc] init];
    repeatSettingPicker.tag = 2;
    repeatSettingPicker.showsSelectionIndicator = YES;
    repeatSettingPicker.delegate = self;
    repeatSettingPicker.dataSource = self;
    
    
    //各textViewのinputViewの設定
    _dateSettingTextField.inputView = datePicker;
    _repeatSettingTextField.inputView = repeatSettingPicker;
    
    //各textViewのinputAccessoryViewの設定
    _dateSettingTextField.inputAccessoryView = _keyboradToolBar;
    _repeatSettingTextField.inputAccessoryView = _keyboradToolBar;
    
    
    //indexPathに応じてviewの設定をする
    [self addView:_settingTableViewIndexPath];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    
    //キーボードは表示させる
    return YES;
}


#pragma mark - Custom Getter Methods


-(NSString *)dateSettingText
{
    NSString *result;
    if ([defaults stringForKey:@"dateSettingText"] == Nil) {
        //初期値
        [defaults setValue:@"" forKey:@"dateSettingText"];
    }
    //defaultsから取り出す
    result = [defaults stringForKey:@"dateSettingText"];
    
    return result;
}


-(NSString *)repeatSettingText
{
    NSString *result;
    if ([defaults stringForKey:@"repeatSettingText"] == Nil) {
        //初期値
        [defaults setValue:@"" forKey:@"repeatSettingText"];
    }
    //defaultsから取り出す
    result = [defaults stringForKey:@"repeatSettingText"];
    
    return result;
}


-(BOOL)notificationSwitchValue
{
    BOOL result;
    if ([defaults stringForKey:@"notificationSwitchValue"] == Nil) {
        //初期値
        [defaults setValue:@NO forKey:@"notificationSwitchValue"];
    }
    //defaultsから取り出す
    result = [defaults boolForKey:@"notificationSwitchValue"];
    
    return result;
}


-(NSString *)memoText
{
    NSString *result;
    if ([defaults stringForKey:@"memoText"] == Nil) {
        //初期値
        [defaults setValue:@"筋トレの時間です。" forKey:@"memoText"];
    }
    //defaultsから取り出す
    result = [defaults stringForKey:@"memoText"];
    
    return result;
    
}


#pragma mark - Private Methods


//日付ピッカーの値が変更されたとき
- (void)datePickerValueChanged:(id)sender
{
    datePicker = sender;
    
    // 日付の表示形式を設定
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    df.dateFormat = @"yyyy/MM/dd(EEE) HH:mm";
    
    _dateSettingTextField.text = [df stringFromDate:datePicker.date];
    // ログに日付を表示
    //NSLog(@"%@", [df stringFromDate:datePicker.date]);
    
}


//<戻るボタンが押された時の処理
-(IBAction)backButtonPushed:(id)sender
{
    
    //InitialViewControllerへnavigationControllerを介して移動する
    [self.navigationController popViewControllerAnimated:YES];
    
}


-(IBAction)okButtonPushed:(id)sender
{
    
    NSArray *oneweekDate = [NSArray array];
    
    //セットされている値をNSUserDefaultsに保存する
    [defaults setValue:_dateSettingTextField.text forKey:@"dateSettingText"];
    [defaults setValue:_repeatSettingTextField.text forKey:@"repeatSettingText"];
    [defaults setValue:@(_notificationSwitch.on) forKey:@"notificationSwitchValue"];
    [defaults setValue:_memotextView.text forKey:@"memoText"];
    if (_notificationSwitch.on == YES) {
        [defaults setValue:@"設定あり" forKey:@"reminderText"];
    }
    else{
        [defaults setValue:@"設定なし" forKey:@"reminderText"];
    }
    
    //configureCellを実行
    [((SettingViewController *)appDelegate.tabSettingViewController) configureCell:[((SettingViewController *)appDelegate.tabSettingViewController).tableView cellForRowAtIndexPath:_settingTableViewIndexPath] atIndexPath:_settingTableViewIndexPath];
    

    //通知の設定
    if (_notificationSwitch.on == YES) {//通知がonなら通知設定
        
        YSWeekdayType ySWeekdayType = [self notificationDay:[repeatSettingPicker selectedRowInComponent:0]];
        
        //繰り返す場合
        if ([repeatSettingPicker selectedRowInComponent:0] != 0) {
            
            oneweekDate = [datePicker.date oneWeekDateWithEnableWeekdayType:ySWeekdayType];
            
            // 取得した日付を順次ローカル通知に登録
            for (NSDate *date in oneweekDate) {
                
                [self configureNotificationWithDate:date];
            
            }
            
        }
        else{
            
            NSLog(@"繰り返しなしが呼ばれました (DetailViewController,okButtonPushed)");
            
            //繰り返しなし
            [self configureNotificationWithDate:datePicker.date];
        }
        
    }
    
    
    //InitialViewControllerへnavigationControllerを介して移動する
    [self.navigationController popViewControllerAnimated:YES];
    
}


//keyboradtoolbarのボタンが押されたら
-(IBAction)toolBarButtonPushed:(UIBarButtonItem *)sender
{
    switch (sender.tag) {
        case 1://cancel
            [_dateSettingTextField resignFirstResponder];
            _dateSettingTextField.text = self.dateSettingText;
            [_repeatSettingTextField resignFirstResponder];
            _repeatSettingTextField.text = self.repeatSettingText;
            break;
        case 2://OK
            [_dateSettingTextField resignFirstResponder];
            [_repeatSettingTextField resignFirstResponder];
            break;
        default:
            break;
    }
}


-(YSWeekdayType)notificationDay:(long)repeatSettingRowNumber
{
    YSWeekdayType ySWeekdayType;
    
    switch (repeatSettingRowNumber) {
        case 0://しない
            NSLog(@"呼ばれました (notificationDay, YSWeekdayTypeNone)");
            ySWeekdayType = YSWeekdayTypeNone;
        case 1://毎週日曜日
            ySWeekdayType = YSWeekdayTypeSunday;
            break;
        case 2://毎週月曜日
            ySWeekdayType = YSWeekdayTypeMonday;
            break;
        case 3://毎週火曜日
            ySWeekdayType = YSWeekdayTypeTuesday;
            break;
        case 4://毎週水曜日
            ySWeekdayType = YSWeekdayTypeWednesday;
            break;
        case 5://毎週木曜日
            ySWeekdayType = YSWeekdayTypeThursday;
            break;
        case 6://毎週金曜日
            ySWeekdayType = YSWeekdayTypeFriday;
            break;
        case 7://毎週土曜日
            ySWeekdayType = YSWeekdayTypeSaturday;
            break;
        default:
            break;
    }
    return ySWeekdayType;
}


//ローカル通知設定
- (void)configureNotificationWithDate:(NSDate*)date
{
    
    NSLog(@"呼ばれました");
    
    //すべての通知を削除する
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    // 通志する日付
    [notification setFireDate:date];
    // 使用するカレンダー
    notification.repeatCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    // 毎週繰り返す
    notification.repeatInterval = NSWeekCalendarUnit;
    // タイムゾーン
    [notification setTimeZone:[NSTimeZone localTimeZone]];
    // 通知する本文
    [notification setAlertBody:_memotextView.text];
    // 通知音(デフォルトを指定)
    [notification setSoundName:UILocalNotificationDefaultSoundName];
    // アラートタイプ(ダイアログ)の通知の場合に使用する決定ボタンの文字列
    [notification setAlertAction:@"アプリを起動"];
    // ローカル通知の登録
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
    
}


//contentViewにtextViewを追加する
-(void)addView:(NSIndexPath *)indexPath
{
    UIView *view = [UIView new];
    
    _textView.font = [UIFont systemFontOfSize:15];
    
    switch (indexPath.section) {
        case 0://設定
            switch (indexPath.row) {
                case 0://テーマカラー
                    break;
                case 1://リマインダー
                    view = _notificationView;
                    view.frame = CGRectMake(0,61, view.bounds.size.width, view.bounds.size.height);
                    break;
                case 2://データ出力
                default:
                    break;
            }
            break;
        case 1://サポート
            switch (indexPath.row) {
                case 0://よくある質問
                    _textView.text = @"まだ質問はありません。";
                    view = _textView;
                    break;
                case 1://お知らせ
                    _textView.text = @"まだお知らせはありません。";
                    view = _textView;
                    break;
                case 2://Twitter
                    [self makeRequestTwitter];
                    break;
                default:
                    break;
            }
            
            break;
        case 2://AppleStore
            //[self makeRequestAppleStore];
            _textView.text = @"工事中です。";
            view = _textView;
            break;
        default:
            break;
    
    }
    
    [self.contentView addSubview:view];
    
}


//webページを要求・表示
-(void)makeRequestTwitter
{
    
    // UIWebViewのインスタンス化
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, DETAIL_VIEW_POSITION_Y, [UIScreen mainScreen].bounds.size.width, DETAIL_VIEW_HEIGHT)];
    
    // Webページの大きさを自動的に画面にフィットさせる
    webView.scalesPageToFit = YES;
    
    // デリゲートを指定
    webView.delegate = (id)self;
    
    //webページ(Traineyのサポートページ、Twitterのこと)を呼び出す
    NSURLRequest *urlReq = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://twitter.com/Trainey_Support"]];
    [webView loadRequest:urlReq];
    
    // UIWebViewのインスタンスをビューに追加
    [self.view addSubview:webView];
    
}


//webページのロード時にインジケータを動かす
- (void)webViewDidStartLoad:(UIWebView*)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}


//webページのロード完了時にインジケータを非表示にする
- (void)webViewDidFinishLoad:(UIWebView*)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


//AppleStoreに遷移する
-(void)makeRequestAppleStore
{
    NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/ja/app/trainey/id1022841669?l=ja&ls=1&mt=8"];
    [[UIApplication sharedApplication] openURL:url];
}



#pragma mark - UIPickerView Methods


//pickerviewの列の数の指定
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}


//カラム列の指定
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    //しない,月火水木金土日
    return REPEAT_DAY_COUNT;
}


//選択肢要素の表示文字列
- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    
    return [NSString stringWithFormat:@"%@",dateArray[row]];
}


//選択肢が変更された際の処理
- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
  
    _repeatSettingTextField.text = [NSString stringWithFormat:@"%@",dateArray[row]];
    
}


@end