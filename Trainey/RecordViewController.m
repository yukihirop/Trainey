//
//  RecordViewController.m
//  Trainey
//
//  Created by 福田幸弘 on 2015/04/29.
//  Copyright (c) 2015年 yukihiro fukuda. All rights reserved.
//

#import "RecordViewController.h"




#pragma mark - RecordViewController () Category


/*-------------------------------*/
//クラスエクステンション
//追加するメソッドを書く
/*-------------------------------*/
@interface RecordViewController ()


@end



#pragma mark - RecordViewController Main


/*-------------------------------*/
//メイン(共通)
/*-------------------------------*/
///////////////////////////////////
///////////implementation//////////
///////////////////////////////////
@implementation RecordViewController
{
    
    AppDelegate *appDelegate;
    IBOutlet UITextView *textView;
    PickerViewController *pickerViewController;
    
}

//アクセサメソッドの実装
@synthesize segmentedControl = _segmentedControl;
@synthesize contentView = _contentView;
@synthesize currentViewController = _currentViewController;
@synthesize navigationBar = _navigationBar;


#pragma mark - Standard Methods


//iPhoneの画面サイズで読み込むxibを変える
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    CGRect screenSize = [UIScreen mainScreen].bounds;
    
    //@1xの場合(3G,3GSの場合,ipadのiphoneシミュレータの@1x)
    if (screenSize.size.height == 480) {
        nibNameOrNil = @"RecordViewController@3.5inch";
    }
    //@2xの場合(5,5s,5cの場合)
    else if (screenSize.size.height == 568){
        nibNameOrNil = @"RecordViewController@4inch";
    }
    //その他の場合
    else {
        nibNameOrNil = @"RecordViewController";
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
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    //navigationbarのタイトルの設定
    _navigationBar.topItem.title = [SQLite createDate:[NSDate date]];
    
    
    [self settingViewController];
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:NO];
    
    [self settingViewController];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)settingViewController
{
    
    //datesを読み込む
    [[DatesManager sharedManager] loadDates];
    //menusを読み込む
    [[MenusManager sharedManager] loadMenus];
    //records_sorting_dateTextを読み込む
    [[RecordsManager sharedManager] loadRecordsSortingDatePK:[DatesManager sharedManager].dates];
    //records_sorting_menu_pkを読み込む
    [[RecordsManager sharedManager] loadRecordsSortingMenuPK:[MenusManager sharedManager].menus];
    
    
    if ([[DatesManager sharedManager].dates count] != 0) {
        
        
        NSLog(@"呼ばれました (RecordViewController, settingViewController)");
        //セグメンテッドコントロールの値により異なるControllerを取得する
        UIViewController *viewController = [self viewControllerForSegmentIndex:_segmentedControl.selectedSegmentIndex];
        //取得したコントローラを子コントローラとして追加する
        [self addChildViewController:viewController];
        
        //子コントローラのViewを親コントローラのContent表示領域のサイズにする
        //スクロール対応していない場合などは画面から見切れる可能性があるのできおつける
        viewController.view.frame = _contentView.bounds;
        
        [_contentView addSubview:viewController.view];
        _currentViewController = viewController;
    
    }
    else{
        
        [_contentView addSubview:textView];
    }
}


#pragma mark - Private Methods


//セグメンテッドコントロールの値を変更した時に呼ばれる
-(IBAction)segmentChange:(UISegmentedControl *)sender
{
    
    if ([[DatesManager sharedManager].dates count] != 0) {
        
        
        //セグメンテッドコントロールの値により異なるコントローラを取得する
        UIViewController *nextViewController = [self viewControllerForSegmentIndex:sender.selectedSegmentIndex];
        //取得したコントローラを子コントローラとして追加する
        [self addChildViewController:nextViewController];
        //ビューを変更する
        [self transitionFromViewController:_currentViewController toViewController:nextViewController duration:0 options:UIViewAnimationOptionTransitionNone //変更するアニメーションの指定
                                animations:^{
                                    [_currentViewController.view removeFromSuperview];
                                    nextViewController.view.frame = _contentView.bounds;
                                    [_contentView addSubview:nextViewController.view];
                                }completion:^(BOOL finished) {
                                    [nextViewController didMoveToParentViewController:self];
                                    [_currentViewController removeFromParentViewController];
                                    _currentViewController = nextViewController;
                                }];
    }else{
        
        [_contentView addSubview:textView];
    }
}


-(IBAction)settingButtonPushed:(id)sender
{
    
    if ([[DatesManager sharedManager].dates count] <= 1 && _segmentedControl.selectedSegmentIndex == 0) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告"
                                                            message:@"日付がありません。"
                                                           delegate:self
                                                  cancelButtonTitle:@"cancel"
                                                  otherButtonTitles:@"はい", nil];
            
            [alert show];
        
    }
    else if ([[MenusManager sharedManager].menus count] == 0 && _segmentedControl.selectedSegmentIndex == 1){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告"
                                                        message:@"メニューがありません。"
                                                       delegate:self
                                              cancelButtonTitle:@"cancel"
                                              otherButtonTitles:@"はい", nil];
        
        [alert show];
        
    }
    else{
        
        //PickerViewControllerを呼び出す
        pickerViewController = [PickerViewController new];
        //デリゲートの設定
        pickerViewController.delegate = (id)self;
        //設定画面をモーダルとして呼び出す
        [self showModal:pickerViewController.view];
        
    }
    
}


//セグメンテッドコントロール値により異なるコントローラーを取得する
-(UIViewController *)viewControllerForSegmentIndex:(NSInteger)index
{
    UIViewController *viewController;
    switch (index) {
        case 0:
            /*viewControllerをxibからインスタンス化する処理*/
            viewController = appDelegate.date_RecordViewController;
            break;
        case 1:
            //xibファイルからnewMenuViewのインスタンスを得る
            viewController = appDelegate.menu_RecordViewController;
            break;
    }
    return viewController;
}


//設定画面を呼び出すメソッド
-(void)showModal:(UIView *)modalView
{
    
    //モーダル画面として呼び出すための準備
    UIWindow *mainWindow = ((AppDelegate *)[UIApplication sharedApplication].delegate).window;
    //モーダル画面を配置する場所を指定
    CGPoint middleCenter = modalView.center;
    //モーダル画面のサイズを指定
    CGSize offSize = [UIScreen mainScreen].bounds.size;
    //画面外に配置するモーダル画面の中心点を指定
    CGPoint offScreenCenter = CGPointMake(offSize.width / 2.0, offSize.height * 1.5);
    //モーダル画面を配置する(画面外)
    modalView.center = offScreenCenter;
    //メイン画面に設定画面を追加する
    [mainWindow addSubview:modalView];
    //アニメーションの設定
    [UIView beginAnimations:nil context:nil];
    //アニメーションの長さを指定
    [UIView setAnimationDuration:0.5];
    //モーダル画面を配置する(画面内)
    modalView.center = middleCenter;
    //アニメーションんをスタートさせる
    [UIView commitAnimations];
    
}


//設定画面を隠すメソッド
-(void)hideModal:(UIView *)modalView
{
    
    //モーダル画面のサイズを指定
    CGSize offSize = [UIScreen mainScreen].bounds.size;
    //画面外に配置するモーダル画面の中心点を指定
    CGPoint offScreenCenter = CGPointMake(offSize.width / 2.0, offSize.height * 1.5);
    //アニメーションを設定
    [UIView beginAnimations:nil context:(__bridge void *)(modalView)];
    //アニメーションの長さを指定
    [UIView setAnimationDuration:0.3];
    //デリゲートを設定
    [UIView setAnimationDelegate:self];
    //アニメーションをストプすると呼ばれるメソッドを指定する
    [UIView setAnimationDidStopSelector:@selector(hideModalEnded:finished:context:)];
    //画面外にモーダル画面を配置する
    modalView.center = offScreenCenter;
    //アニメーションを開始する
    [UIView commitAnimations];
}


//設定画面が隠された時に呼ばれるメソッド
-(void)hideModalEnded:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    
    UIView *modalView = (__bridge UIView *)context;
    //メインの画面からモーダル画面をリムープする
    [modalView removeFromSuperview];
}


//キャンセルボタンがクリックされた時に呼ばれるメソッド
-(void)didCancelButtonClicked:(SettingViewController *)controller
{
    
    //モーダルビューを隠すメソッドを呼ぶ
    [self hideModal:pickerViewController.view];
    //datePickerを空にする
    pickerViewController = nil;
}


//saveボタンが押された時によ日出されるメソッド
-(void)didOKButtonClicked:(SettingViewController *)controller
{
    
    //日付別かメニュー別で処理を分ける
    switch (((RecordViewController *)appDelegate.tabRecordViewController).segmentedControl.selectedSegmentIndex) {
        
        case 0://日付別
            [((Date_RecordViewController *)appDelegate.date_RecordViewController).verticalTableView scrollToRowAtIndexPath:pickerViewController.indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
            break;
        case 1://メニュー別
            [((Menu_RecordViewController *)appDelegate.menu_RecordViewController).verticalTableView scrollToRowAtIndexPath:pickerViewController.indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
            break;
        default:
            break;
            
    }
    
    
    //モーダルビューを隠すメソッドを呼ぶ
    [self hideModal:pickerViewController.view];
    //datePickerを空にする
    pickerViewController = nil;
}


@end


#pragma mark - RecordViewController (Controller) Category


/*-------------------------------*/
//画面上で起こる操作に関するカテゴリ
//カテゴリー名：Control
/*-------------------------------*/
///////////////////////////////////
///////////interface///////////////
///////////////////////////////////
@interface RecordViewController (Controller)


@end


///////////////////////////////////
///////////implementation//////////
///////////////////////////////////
@implementation RecordViewController (Controller)


@end
