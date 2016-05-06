//
//  InitialViewController.m
//  Trainey
//
//  Created by 福田幸弘 on 2015/05/01.
//  Copyright (c) 2015年 yukihiro fukuda. All rights reserved.
//

#import "InitialViewController.h"

//コンテントの定数
#define CONTENT_SIZE 3




#pragma mark - HomeViewController () Category


/*-------------------------------*/
//クラスエクステンション
//追加するメソッドを書く
/*-------------------------------*/
@interface InitialViewController ()


@end


#pragma mark - InitialViewController Main


/*-------------------------------*/
//メイン(共通)
/*-------------------------------*/
///////////////////////////////////
///////////implementation//////////
///////////////////////////////////
@implementation InitialViewController
{
    //タイムアップアローボタン
    IBOutlet UIButton *timeArrowButton;
    //HomeViewControllerかどうか
    BOOL isHomeViewController;
    //TimeControlViewがDownしているか？
    BOOL isTimeControlViewDown;
    //appDelegateのインスタンス
    AppDelegate *appDelegate;
    //NSUserDefaults
    NSUserDefaults *defaults;
    //読み込むTimeControlUpViewのxibの名前
    NSString *timeControlUpViewIdentifer;
    //読み込むTimeControlDownViewのxibの名前
    NSString *timeControlDownViewIdentifer;
    //遷移するInserNewObjectViewControllerのxibの名前
    NSString *insertNewObjectViewControllerIdentifer;
    //高さと位置
    CGFloat TIME_CONTROL_UPVIEW_HEIGHT;
    CGFloat TIME_CONTROL_UPVIEW_POSITION_Y;
    CGFloat TIME_CONTROL_DOWNVIEW_HEIGHT;
    CGFloat TIME_CONTROL_DOWNVIEW_POSITION_Y;
}


//アクセサメソッドの実装
@synthesize contentView = _contentView;
@synthesize currentTimeControlView = _currentTimeControlView;
@synthesize currentViewController = _currentViewController;
@synthesize navigationBar = _navigationBar;
@synthesize startCancelLabel = _startCancelLabel;
@synthesize temporarystopRestartLabel = _temporarystopRestartLabel;
@synthesize temporarystopRestartButton = _temporarystopRestartButton;
//カスタムゲッタメソッドを実装する
@synthesize  homeViewController;
@synthesize  performanceCheckingViewController;
@synthesize  CONCEPT_COLOR;


#pragma mark - Custom getter Methods


//homeViewControllerゲッタ
-(HomeViewController *)homeViewController
{
    //appDelegateインスタンスの設定
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return (HomeViewController *)appDelegate.homeViewController;
}


//performanceCheckingViewControllerゲッタ
-(PerformanceCheckingViewController *)performanceCheckingViewController
{
    //appDelegateインスタンスの設定
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return (PerformanceCheckingViewController *)appDelegate.performanceCheckingViewController;
}


//CONCEPT_COLORゲッタ
-(NSString *)CONCEPT_COLOR
{
    //appDelegateインスタンスの設定
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return appDelegate.CONCEPT_COLOR;
    
}


#pragma mark - Standard Methods


//iPhoneの画面サイズで読み込むxibを変える
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    CGRect screenSize = [UIScreen mainScreen].bounds;
    
    //@1xの場合(3G,3GSの場合,ipadのiphoneシミュレータの@1x)
    if (screenSize.size.height == 480) {
        nibNameOrNil = @"InitialViewController@3.5inch";
        insertNewObjectViewControllerIdentifer = @"InsertNewObjectViewControllerIdentifer@3.5inch";
    }
    //@2xの場合(5,5s,5cの場合)
    else if (screenSize.size.height == 568){
        nibNameOrNil = @"InitialViewController@4inch";
        insertNewObjectViewControllerIdentifer = @"InsertNewObjectViewControllerIdentifer@4inch";
    }
    //その他の場合
    else {
        nibNameOrNil = @"InitialViewController";
        insertNewObjectViewControllerIdentifer = @"InsertNewObjectViewControllerIdentifer";
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
    
    NSLog(@"呼ばれました (InitialViewController, viewDidLoad)");
    
    //navigationbarのタイトルの設定
    _navigationBar.topItem.title = [SQLite createDate:[NSDate date]];
    
    //appDelegateインスタンスの設定
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    //NSUserDefaults
    defaults = [NSUserDefaults standardUserDefaults];
    
    //records_dateTextを読み込む
    [[RecordsManager sharedManager] loadRecordsFordate:[NSDate date]];
    
    
    //historys_upperとhistorys_underを読み込む
    [[HistorysManager sharedManager] loadHistorys];
    
    //menusを読み込む
    [[MenusManager sharedManager] loadMenus];
    //datesを読み込む
    [[DatesManager sharedManager] loadDates];
    
    //records_sorting_dateTextを読み込む
    [[RecordsManager sharedManager] loadRecordsSortingDatePK:[DatesManager sharedManager].dates];
    //records_sorting_menu_pkを読み込む
    [[RecordsManager sharedManager] loadRecordsSortingMenuPK:[MenusManager sharedManager].menus];
    
    
    //画面が表示れた時は、HomeViewControllerを表示する
    UIViewController *viewController = self.homeViewController;
    //取得したコントローラを子コントローラとして追加する
    [self addChildViewController:viewController];
    
    //子コントローラのViewを親コントローラのContent表示領域のサイズにする
    //スクロール対応していない場合などは画面から見切れる可能性があるのできおつける
    viewController.view.frame = _contentView.bounds;
    
    [_contentView addSubview:viewController.view];
    //現在のビューコントローラーに設定する
    _currentViewController = viewController;
    
    
    //TimeControlViewの設定を行う
    [self setTimeControlView];
    
    
    //現在のviewを追加する
    [self.view addSubview:_currentTimeControlView];
    //YESにする
    isHomeViewController = YES;
    //NOにする
    isTimeControlViewDown = YES;
    
    //押せないようにする
    [defaults setBool:NO forKey:@"temporarystopRestartEnabled"];
    _temporarystopRestartButton.enabled = NO;
    
    
    _startCancelLabel.text = @"開始";
    _temporarystopRestartLabel.text = @"一時停止";
    
    
}


-(void)viewWillAppear:(BOOL)animated
{
    
    NSLog(@"呼ばれました (InitialViewController, viewWillAppear)");
    
    [super viewWillAppear:NO];
    
    //menusを読み込む
    [[MenusManager sharedManager] loadMenus];
    //datesを読み込む
    [[DatesManager sharedManager] loadDates];
    
    _temporarystopRestartButton.enabled = [defaults boolForKey:@"temporarystopRestartEnabled"];
    
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Private Methods


//iPhoneの画面サイズで読み込むTimeControlUpViewを変える
- (void)loadTimeViewControlXib {
    
    CGRect screenSize = [UIScreen mainScreen].bounds;
    
    //@1xの場合(3G,3GSの場合,ipadのiphoneシミュレータの@1x)
    if (screenSize.size.height == 480) {
        timeControlUpViewIdentifer = @"TimeControlUpView@3.5inch";
        timeControlDownViewIdentifer = @"TimeControlDownView@3.5inch";
    
    }
    //@2xの場合(5,5s,5cの場合)
    else if (screenSize.size.height == 568){
        timeControlUpViewIdentifer = @"TimeControlUpView@4inch";
        timeControlDownViewIdentifer = @"TimeControlDownView@4inch";
    }
    //その他の場合
    else {
        timeControlUpViewIdentifer = @"TimeControlUpView";
        timeControlDownViewIdentifer = @"TimeControlDownView";
    }
    
    
}


//読み込むTimeControlUpViewの高さと位置を変える
- (void)loatTimeViewControlProperty {
    
    CGRect screenSize = [UIScreen mainScreen].bounds;
    
    //@1xの場合(3G,3GSの場合,ipadのiphoneシミュレータの@1x)
    if (screenSize.size.height == 480) {
        
        TIME_CONTROL_UPVIEW_HEIGHT = 49;
        TIME_CONTROL_UPVIEW_POSITION_Y = 215;
        TIME_CONTROL_DOWNVIEW_HEIGHT = 44;
        TIME_CONTROL_DOWNVIEW_POSITION_Y = 387;
        
    }
    //@2xの場合(5,5s,5cの場合)
    else if (screenSize.size.height == 568){
        
        TIME_CONTROL_UPVIEW_HEIGHT = 90;
        TIME_CONTROL_UPVIEW_POSITION_Y = 241;
        TIME_CONTROL_DOWNVIEW_HEIGHT = 44;
        TIME_CONTROL_DOWNVIEW_POSITION_Y = 475;
        
    }
    //その他の場合
    else {
        
        TIME_CONTROL_UPVIEW_HEIGHT = 120;
        TIME_CONTROL_UPVIEW_POSITION_Y = 270;
        TIME_CONTROL_DOWNVIEW_HEIGHT = 44;
        TIME_CONTROL_DOWNVIEW_POSITION_Y = 574;
    }
}


//TimeControlViewの設定を行う
-(void)setTimeControlView
{
    
    //iPhoneの画面サイズで読み込むTimeControlUpViewを変える
    [self loadTimeViewControlXib];
    
    //読み込むTimeControlUpViewの高さと位置を変える
    [self loatTimeViewControlProperty];
    
    
    //TimeControllViewにxibファイルから生成したviewをセットする
    appDelegate.timeControlView = [[NSBundle mainBundle] loadNibNamed:timeControlUpViewIdentifer owner:self options:nil][0] ;
    //
    appDelegate.timeControlView.frame = CGRectMake(0,TIME_CONTROL_UPVIEW_POSITION_Y, [UIScreen mainScreen].bounds.size.width, TIME_CONTROL_UPVIEW_HEIGHT);
    //
    appDelegate.timeControlView.backgroundColor = [UIColor colorWithHexString:self.CONCEPT_COLOR alpha:1.0f];
    
    //現在のViewに設定する
    _currentTimeControlView = appDelegate.timeControlView;
    
    //現在のviewを追加する
    [self.view addSubview:_currentTimeControlView];
    
}


@end


#pragma mark - InitialViewController (View_Model) Category


/*-------------------------------*/
//画面の表示・遷移に関するカテゴリ
//カテゴリー名：Display
/*-------------------------------*/
///////////////////////////////////
///////////interface///////////////
///////////////////////////////////
@interface InitialViewController (View_Model)


//新規メニューを追加するメソッド
-(IBAction)insertNewObject:(id)sender;
//HomeViewControllerからPerformanceCheckingViewControllerへ移動するメソッド
-(void)moveToNextViewController;


@end


///////////////////////////////////
///////////implementation//////////
///////////////////////////////////
@implementation InitialViewController (View_Model)

//新規メニューを追加する
-(IBAction)insertNewObject:(id)sender
{
    
    //InserNewObjectViewControllerへ移動する
    InsertNewObjectViewController *insertNewObjectViewController = [[InsertNewObjectViewController alloc] initWithNibName:insertNewObjectViewControllerIdentifer bundle:nil ];
    
    //navigationControllerを介して画面遷移する時の定石
    [self.navigationController pushViewController: insertNewObjectViewController animated:YES];
    
    
}


//HomeViewControllerからPerformanceCheckingViewControllerへ移動するメソッド
-(void)moveToNextViewController
{
    
    //遷移先のViewControllerを設定する
    UIViewController *nextViewController;
    
    if (isHomeViewController) {
        //PerformanceCheckingViewControllerを設定する
        nextViewController = self.performanceCheckingViewController;
    }else {
        //HomeViewControllerを設定する
        nextViewController = self.homeViewController;
        
    }
    //フラグを反転させる。
    isHomeViewController = !isHomeViewController;
    
    
    //取得したコントローラを子コントローラーとして追加する
    [self addChildViewController:nextViewController];
    //ビューを変更する
    [self transitionFromViewController:_currentViewController  toViewController:nextViewController duration:0 options:UIViewAnimationOptionOverrideInheritedDuration
                            animations:^{
                                [_currentViewController.view removeFromSuperview];
                                nextViewController.view.frame = _contentView.bounds;
                                [_contentView addSubview:nextViewController.view];
                            }completion:^(BOOL finished) {
                                [nextViewController didMoveToParentViewController:self];
                                [_currentViewController removeFromParentViewController];
                                _currentViewController = nextViewController;
                            }];
    
    
}


@end


#pragma mark - InitialViewController (Controller) Category


/*-------------------------------*/
//画面上で起こる操作に関するカテゴリ
//カテゴリー名：Control
/*-------------------------------*/
///////////////////////////////////
///////////interface///////////////
///////////////////////////////////
@interface InitialViewController (Controller)


//TimeUpAroowButtonば押されたら、ボタンをアニメーションさせるメソッド
-(IBAction)tappedTimeArrowButton:(id)sender;
//TimeControlViewをアニメーションさせるメソッド
-(void)timeControlViewAnimation;
//timerControllerView上にあるボタンのテキストを変更させるメソッド
-(IBAction)eachButtonLabelChange:(UIButton *)sender;


@end


///////////////////////////////////
///////////implementation//////////
///////////////////////////////////
@implementation InitialViewController (Controller)


//TimeUpAroowButtonば押されたら、ボタンをアニメーションさせるメソッド
-(IBAction)tappedTimeArrowButton:(id)sender
{
    
    //ボタンが置かれているview全体をアニメーションさせるメソッド
    [self timeControlViewAnimation];
    
    //画面を遷移させるメソッド
    [self moveToNextViewController];
    
    
}


//TimeControlViewをアニメーションさせる
-(void)timeControlViewAnimation
{
    /*ボタンの見た目を遷移させる*/
    if (isTimeControlViewDown) {
        
        //nextViewはTimeControlUpView
        appDelegate.timeControlView = [[NSBundle mainBundle] loadNibNamed:timeControlDownViewIdentifer owner:self options:nil][0];
        //frameを指定する
        appDelegate.timeControlView.frame = CGRectMake(0, TIME_CONTROL_DOWNVIEW_POSITION_Y, [UIScreen mainScreen].bounds.size.width, TIME_CONTROL_DOWNVIEW_HEIGHT);
        //色の設定
        appDelegate.timeControlView.backgroundColor = [UIColor colorWithHexString:self.CONCEPT_COLOR alpha:1.0f];
        
    }
    else {
        //nextViewはTimeControlDownView
        appDelegate.timeControlView = [[NSBundle mainBundle] loadNibNamed:timeControlUpViewIdentifer owner:self options:nil][0];
        //frameを指定する
        appDelegate.timeControlView.frame = CGRectMake(0, TIME_CONTROL_UPVIEW_POSITION_Y, [UIScreen mainScreen].bounds.size.width, TIME_CONTROL_UPVIEW_HEIGHT);
        //色の設定
        appDelegate.timeControlView.backgroundColor = [UIColor colorWithHexString:self.CONCEPT_COLOR alpha:1.0f];
    }
    
    
    [UIView transitionFromView:_currentTimeControlView toView:appDelegate.timeControlView duration:1 options:UIViewAnimationOptionTransitionNone
                    completion:^(BOOL finished){
                        //
                        [_currentTimeControlView removeFromSuperview];
                        //現在のviewに設定する
                        _currentTimeControlView = appDelegate.timeControlView;
                        //現在のviewを追加する
                        [self.view addSubview:_currentTimeControlView];
                        
                    }];
    
    //ブールを反転させる
    isTimeControlViewDown = !isTimeControlViewDown;
    
}


//timerControllerView上にあるボタンのテキストを変更させるメソッド
-(IBAction)eachButtonLabelChange:(UIButton *)sender
{
    
    //tag == 0 の場合
    if (sender.tag == 0) {
        
        //タイマーのキャンセルor開始処理
        [self.homeViewController startCancelInterval:_startCancelLabel];
        
        
        //キャンセルが表示されているなら
        if ([_startCancelLabel.text isEqualToString:@"キャンセル"]){
            
            [defaults setValue:@"開始" forKey:@"startCancelText"];
            _startCancelLabel.text = @"開始";
            [defaults setValue:@"一時停止" forKey:@"temporarystopRestartText"];
            _temporarystopRestartLabel.text = @"一時停止";
            
            
            //一時停止&再開を押せないようにする
            [defaults setBool:NO forKey:@"temporarystopRestartEnabled"];
            _temporarystopRestartButton.enabled = NO;
        }
        //開始が表示されているなら
        else if ([_startCancelLabel.text isEqualToString:@"開始"]){
            
            [defaults setValue:@"キャンセル" forKey:@"startCancelText"];
            _startCancelLabel.text = @"キャンセル";
            
            //一時停止&再開を押せるようにする
            [defaults setBool:YES forKey:@"temporarystopRestartEnabled"];
            _temporarystopRestartButton.enabled = YES;
            
        }
        
    }
    //tag == 1の場合
    else if (sender.tag == 1) {
        
        if (_temporarystopRestartButton.enabled == YES) {
            
            //タイマーの再開or一時停止処理
            [self.homeViewController stopRestartInterval:_temporarystopRestartLabel];
            
            
            //一時停止が表示されているなら
            if ([_temporarystopRestartLabel.text isEqualToString:@"一時停止"]){
                [defaults setValue:@"再開" forKey:@"temporarystopRestartText"];
                _temporarystopRestartLabel.text = @"再開";
            }
            //再開が表示されているなら
            else if ([_temporarystopRestartLabel.text isEqualToString:@"再開"]){
                [defaults setValue:@"一時停止" forKey:@"temporarystopRestartText"];
                _temporarystopRestartLabel.text = @"一時停止";
            }
        }
    }
}


@end