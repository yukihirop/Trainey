//
//  NewMenuConfigureView.m
//  Trainey
//
//  Created by 福田幸弘 on 2015/04/27.
//  Copyright (c) 2015年 yukihiro fukuda. All rights reserved.
//

@import GoogleMobileAds;

#import "NewMenuConfigureViewController.h"


//NewMenuConfigureViewの変数
//#define NEW_MENUVIEW_CONFIGUREVIEW_HEIGHT 357
#define CONTENT_SIZE 3


#pragma mark - NewMenuConfigureViewController () Category


/*-------------------------------*/
//クラスエクステンション
//追加するメソッドを書く
/*-------------------------------*/
@interface NewMenuConfigureViewController ()


@end


#pragma mark - NewMenuConfigureViewController Main


/*-------------------------------*/
//メイン(共通)
/*-------------------------------*/
///////////////////////////////////
///////////implementation//////////
///////////////////////////////////
@implementation NewMenuConfigureViewController
{
    //historysに追加するか決める
    BOOL isAddHistorys;
    //records_dateTextに追加するか決める
    BOOL isAddRecords;
    //datesに追加するか決める
    BOOL isAddDates;
    //sender.Tagの保管
    NSInteger senderTag;
    //NSMutableArray
    NSMutableArray *menusArray;
    NSMutableArray *datesArray;
    //appDelegateのインスタンス
    AppDelegate *appDelegate;
    //
    NSString *newMenuConfigureViewIdentifer;
    //NewMenuConfigureViewの高さ
    CGFloat NEW_MENUVIEW_CONFIGUREVIEW_HEIGHT;
    
    
}


@synthesize  nMenuConfigureView = _nMenuConfigureView;
@synthesize  okButton = _okButton;
@synthesize menuCategorySegment = _menuCategorySegment;
@synthesize menuNameField = _menuNameField;
@synthesize weightField = _weightField;
@synthesize repeatCountField = _repeatCountField;


#pragma mark - Standard Methods

//iPhoneの画面サイズで読み込むxibを変える
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    CGRect screenSize = [UIScreen mainScreen].bounds;
    
    //@1xの場合(3G,3GSの場合,ipadのiphoneシミュレータの@1x)
    if (screenSize.size.height == 480) {
        nibNameOrNil = @"NewMenuConfigureViewController@3.5inch";
    }
    //@2xの場合(5,5s,5cの場合)
    else if (screenSize.size.height == 568){
        nibNameOrNil = @"NewMenuConfigureViewController@4inch";
    }
    //その他の場合
    else {
        nibNameOrNil = @"NewMenuConfigureViewController";
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
    
    //
    [self loadNewMenuConfigureViewXib];
    
    //xibファイルから読み込んでnMenuConfigureViewにセットする。
    [[NSBundle mainBundle] loadNibNamed:newMenuConfigureViewIdentifer owner:self options:nil];
    _nMenuConfigureView.frame = CGRectMake(0,0, [UIScreen mainScreen].bounds.size.width, NEW_MENUVIEW_CONFIGUREVIEW_HEIGHT);
    [self.view addSubview:_nMenuConfigureView];
    
    
    menusArray = [NSMutableArray new];
    menusArray = [MenusManager sharedManager].menus;
    
    datesArray = [NSMutableArray new];
    datesArray = [DatesManager sharedManager].dates;
    
    
    _menuNameField.delegate = self;
    _weightField.delegate = self;
    _repeatCountField.delegate = self;
    
    
    isAddHistorys = NO;
    isAddRecords = NO;
    isAddDates = NO;
    
    //広告を表示
    // Replace this ad unit ID with your own ad unit ID.
    self.bannerView.adUnitID = @"ca-app-pub-6097032842986149/2966422515";
    self.bannerView.rootViewController = self;
    
    GADRequest *request = [GADRequest request];
    // Requests test ads on devices you specify. Your test device ID is printed to the console when
    // an ad request is made. GADBannerView automatically returns test ads when running on a
    // simulator.
    //request.testDevices = @[@"2077ef9a63d2b398840261c8221a0c9a"];
    [self.bannerView loadRequest:request];
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    
    [self showAlertView:textField];
    
    return NO;
}


#pragma mark - Private Methods


//読み込むNewMenuConfigureViewのxibを選ぶ
- (void)loadNewMenuConfigureViewXib {
    
    CGRect screenSize = [UIScreen mainScreen].bounds;
    
    //@1xの場合(3G,3GSの場合,ipadのiphoneシミュレータの@1x)
    if (screenSize.size.height == 480) {
        newMenuConfigureViewIdentifer = @"NewMenuConfigureView@3.5inch";
        NEW_MENUVIEW_CONFIGUREVIEW_HEIGHT = 278;
    }
    //@2xの場合(5,5s,5cの場合)
    else if (screenSize.size.height == 568){
        newMenuConfigureViewIdentifer = @"NewMenuConfigureView@4inch";
        NEW_MENUVIEW_CONFIGUREVIEW_HEIGHT = 278;
    }
    //その他の場合
    else {
        newMenuConfigureViewIdentifer = @"NewMenuConfigureView";
        NEW_MENUVIEW_CONFIGUREVIEW_HEIGHT = 333;
    }
}


-(void)showAlertView:(UITextField *)sender
{
    UIAlertView *alert = [UIAlertView new];
    
    //デリゲートの設定
    alert.delegate = self;
    
    //senderTagに設定
    senderTag = sender.tag;
    
    //sender.tagで場合分け
    switch (senderTag) {
        case 1:
            alert.message = @"メニュー名を入力して下さい。";
            break;
        case 2:
            alert.message = @"負荷(kg)を入力して下さい。";
            break;
        case 3:
            alert.message = @"反復回数を入力して下さい。";
            break;
    }
    
    [alert addButtonWithTitle:@"cancel"];
    [alert addButtonWithTitle:@"OK"];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [alert textFieldAtIndex:0].clearButtonMode = UITextFieldViewModeWhileEditing;
    [alert textFieldAtIndex:0].keyboardType = UIKeyboardTypeDecimalPad;
    
    if (senderTag == 1) {
        [alert textFieldAtIndex:0].keyboardType = UIKeyboardTypeDefault;
    }
    
    [alert show];
    
    
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == 1) {
        
        switch (senderTag) {
            case 1:
                if ([[[alertView textFieldAtIndex:0] text] isEqualToString:@""]) {
                    
                    _menuNameField.text = @"NO NAME";
                    
                }else{
                    
                _menuNameField.text = [[alertView textFieldAtIndex:0] text];
                
                }
                break;
            case 2://負荷(kg)
                if ([[[alertView textFieldAtIndex:0] text] isEqualToString:@""]) {
                    
                    _weightField.text = @"-1";
                    
                }else{
                    
                    _weightField.text = [[alertView textFieldAtIndex:0] text];
                    
                }
                break;
            case 3://反復回数(回)
                if ([[[alertView textFieldAtIndex:0] text] isEqualToString:@""]) {
                    
                    _repeatCountField.text = @"-1";
                    
                }else{
                    
                    _repeatCountField.text = [[alertView textFieldAtIndex:0] text];
                    
                }

        }
    }
    
}


//NewMenuConfigureViewでokが押されたら実行
-(IBAction)okButtonPushedAtNewMenuConfigureView:(id)sender
{
    
    //NSMutableDictionaryにnilを入れないために
    if ([_menuNameField.text isEqualToString:@""]) {
        _menuNameField.text = @"NO NAME";
    }
    if ([_weightField.text isEqualToString:@""]) {
        _weightField.text = @"-1";
    }
    if ([_repeatCountField.text isEqualToString:@""]) {
        _repeatCountField.text = @"-1";
    }
    
    //recordsやmenusやhistorysにnew**を追加するかなどを決め、実行する部分
    if ([_menuNameField.text isEqualToString:@"NO NAME"])
    {
        
        //メインスレッドで表示させる
        dispatch_async(dispatch_get_main_queue(), ^{
        
        //アラートを表示する
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"エラー"
                                                        message:@"名前を正しく入力してください。"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"はい", nil];
            [alert show];
        });
        
        return;
        
        
    } else {//データベースに追加する
        
        id newDate = [self saveDatesAtNewMenuConfigureViewController];
        
        //menusを保存して、保存したnewMenuを返す
        id newMenu = [self saveMenusAtNewMenuConfigureViewController];
        
        
        //newMenuをわたし、recordsやhistorysの保存するかどうかを決める処理をおこなう
        [self saveRecordsAtNewConfigureViewController:newDate menu:newMenu];
        
        //newMenuをわたし、recordsやhistorysの保存するかどうかを決める処理をおこなう
        [self saveHistorysAtNewConfigureViewController:newDate menu:newMenu];
        
    
    }
    
    
    
    //保存処理
    if ([[RecordsManager sharedManager].records_dateText count]/CONTENT_SIZE != 0){
        
        if (isAddRecords == YES) {
            
            //アイテムの挿入位置
            NSInteger rowNumber = [[RecordsManager sharedManager].records_dateText count]/CONTENT_SIZE-1;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowNumber inSection:0];
        
            //各tableViewに要素を追加
            NSLog(@"indexPathは、%d (NewMenuConfigureViewController, okButtonPushudeAtNewConfigureView)",(int)rowNumber);
        
            //HomeViewControllerに対して
            [((HomeViewController *)appDelegate.homeViewController).insertedMenuTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
            //PerformanceCheckingViewControllerに対して
            [((PerformanceCheckingViewController *)appDelegate.performanceCheckingViewController).currentTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            
            //HorizontalTableViewControllerに対して
            [((HorizontalTalbeViewController *)appDelegate.horizontalTableViewController).horizontalTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            
            //[((Date_RecordViewController *)appDelegate.date_RecordViewController).verticalTableView reloadData];
            
            
            //records_sorting_dateTextを読み込む
            [[RecordsManager sharedManager] loadRecordsSortingDatePK:[DatesManager sharedManager].dates];
            //records_sorting_menu_pkを読み込む
            [[RecordsManager sharedManager] loadRecordsSortingMenuPK:[MenusManager sharedManager].menus];
            
        }
    }
    
    
    
    
    isAddRecords = NO;
    isAddHistorys = NO;
    
    //画面遷移の実行
    [appDelegate.firstNavigationController popToRootViewControllerAnimated:NO];
    
    

}


//NewMenuConfigureViewController上でmenusを保存する処理(historysに追加するかどうかも判定する)
-(id)saveDatesAtNewMenuConfigureViewController
{
    //0以上の数でなければなんでもいい
    NSInteger index = -1;
    NSString *dateText = [SQLite createDate:[NSDate date]];
    
    id newDate;
    //menusに追加するか、どうかの処理
    if ([datesArray count] == 0) {
        
        newDate = [[DatesManager sharedManager] addDate:dateText];
        
        isAddHistorys = YES;
        
    }else{
        
        //同じメニュー名を持つ場合はmenusに追加しない。
        for (int i=0; i<[datesArray count]; i++) {
            
            //名前が同じ場合
            if ([dateText isEqualToString:datesArray[i][@"dateText"]]){index = i;}//indexに保存
            
        }
        
        
        if (index >= 0) {
            
            newDate = @{@"date_pk":@([datesArray[index][@"date_pk"] intValue]),
                        @"dateText":datesArray[index][@"dateText"]};
        }else{
            
            newDate = [[DatesManager sharedManager] addDate:dateText];
            
            isAddHistorys = YES;
            
        }
    }
    
    return newDate;
}


//NewMenuConfigureViewController上でmenusを保存する処理(historysに追加するかどうかも判定する)
-(id)saveMenusAtNewMenuConfigureViewController
{
    //0以上の数でなければなんでもいい
    NSInteger index = -1;
    
    id newMenu;
    //menusに追加するか、どうかの処理
    if ([menusArray count] == 0) {
        
        newMenu = [[MenusManager sharedManager] addMenu:(int)_menuCategorySegment.selectedSegmentIndex menuName:_menuNameField.text];
        
        isAddHistorys = YES;
        
    }else{
        
        //同じメニュー名を持つ場合はmenusに追加しない。
        for (int i=0; i<[menusArray count]; i++) {
            
            //名前が同じ場合
            if ([_menuNameField.text isEqualToString:menusArray[i][@"menuName"]]){index = i;}//indexに保存
            
        }
        
        
        if (index >= 0) {
            
            newMenu = @{@"menu_pk":@([menusArray[index][@"menu_pk"] intValue]),
                        @"menuCategory":@([menusArray[index][@"menuCategory"] intValue]),
                        @"menuName":menusArray[index][@"menuName"]};
        }else{
            
            newMenu = [[MenusManager sharedManager] addMenu:(int)_menuCategorySegment.selectedSegmentIndex menuName:_menuNameField.text];
            
            isAddHistorys = YES;
            
        }
    }

    return newMenu;
}


//NewMenuConfigureViewControllerViewController上でhistorysを保存する処理
-(void)saveHistorysAtNewConfigureViewController:(id)newDate menu:(id)newMenu
{
    
    NSInteger index=-1;
    
    if ([[HistorysManager sharedManager].historys count]/CONTENT_SIZE == 0)
    {isAddHistorys = YES;}
    else{
        
        //同じメニュー名を持つ場合はrecords_dateTextに追加しない
        for (int i=0; i<[[HistorysManager sharedManager].historys count]; i++) {
            
            if ([_menuNameField.text isEqualToString:[HistorysManager sharedManager].historys[i][@"menuName"]]) {
                
                NSLog(@"呼ばれました (NewMenuConfigureViewController, okButtonPushedAtNewMenuConfigureView)");
                
                index = i;}
            
        }
        if (index >= 0) {}else{isAddHistorys = YES;}
        
    }
    
    
    //recordを記録する
    for (int i=0; i<CONTENT_SIZE; i++) {
        
        
        if (isAddHistorys == YES) {
            
            //historysに記録
            id newHistory = [[HistorysManager sharedManager] addHistory:0 weight:[_weightField.text doubleValue] repeatCount:[_repeatCountField.text intValue] date:newDate menu:newMenu];
            newHistory = nil;
            
            
        }
    }
}


//NewMenuConfigureViewController上でrecordsとhistorysを保存する処理
-(void)saveRecordsAtNewConfigureViewController:(id)newDate menu:(id)newMenu
{
    
    NSInteger index=-1;
    
    if ([[RecordsManager sharedManager].records_dateText count]/CONTENT_SIZE == 0)
    {isAddRecords = YES;}
    else{
        
        //同じメニュー名を持つ場合はrecords_dateTextに追加しない
        for (int i=0; i<[[RecordsManager sharedManager].records_dateText count]; i++) {
            
            if ([_menuNameField.text isEqualToString:[RecordsManager sharedManager].records_dateText[i][@"menuName"]]) {
                
                NSLog(@"呼ばれました (NewMenuConfigureViewController, okButtonPushedAtNewMenuConfigureView)");
                
                index = i;}
            
        }
        if (index >= 0) {}else{isAddRecords = YES;}
        
    }
    
    
    //recordを記録する
    for (int i=0; i<CONTENT_SIZE; i++) {
        
        if (isAddRecords == YES) {
            
            //recordsに記録
            id newRecord = [[RecordsManager sharedManager] addRecord:0 weight:[_weightField.text doubleValue] repeatCount:[_repeatCountField.text intValue] date:newDate menu:newMenu];
            newRecord = nil;
            
            
        }
    }
}


@end

