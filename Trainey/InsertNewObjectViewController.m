//
//  InsertNewObjectViewController.m
//  Trainey
//
//  Created by 福田幸弘 on 2015/04/27.
//  Copyright (c) 2015年 yukihiro fukuda. All rights reserved.
//

#import "InsertNewObjectViewController.h"


#pragma mark - InsertNewObjectViewController () Category


/*-------------------------------*/
//クラスエクステンション
//追加するメソッドを書く
/*-------------------------------*/
@interface InsertNewObjectViewController()


@end


#pragma mark - InsertNewObjectViewController Main


/*-------------------------------*/
//メイン(共通)
/*-------------------------------*/
///////////////////////////////////
///////////implementation//////////
///////////////////////////////////
@implementation InsertNewObjectViewController
{
    AppDelegate *appDelegate;
    //読み込むxibを選ぶ
    NSString *newMenuConfigureViewControllerIdentifer;
    
}


@synthesize navigationBar = _navigationBar;
@synthesize rightBarButtonItem = _rightBarButtonItem;


#pragma mark - Standard Methods


//iPhoneの画面サイズで読み込むxibを変える
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    CGRect screenSize = [UIScreen mainScreen].bounds;
    
    //@1xの場合(3G,3GSの場合,ipadのiphoneシミュレータの@1x)
    if (screenSize.size.height == 480) {
        nibNameOrNil = @"InsertNewObjectViewController@3.5inch";
    }
    //@2xの場合(5,5s,5cの場合)
    else if (screenSize.size.height == 568){
        nibNameOrNil = @"InsertNewObjectViewController@4inch";
    }
    //その他の場合
    else {
        nibNameOrNil = @"InsertNewObjectViewController";
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
    
    
    
    
    //セグメンテッドコントロールの値により異なるControllerを取得する
    UIViewController *viewController = [self viewControllerForSegmentIndex:self.segmentedControl.selectedSegmentIndex];
    //取得したコントローラを子コントローラとして追加する
    [self addChildViewController:viewController];
    
    //子コントローラのViewを親コントローラのContent表示領域のサイズにする
    //スクロール対応していない場合などは画面から見切れる可能性があるのできおつける
    viewController.view.frame = self.contentView.bounds;
    
    [self.contentView addSubview:viewController.view];
    self.currentViewController = viewController;
    
    if (self.segmentedControl.selectedSegmentIndex == 1) {
        
        //OKボタンを隠す
        [_rightBarButtonItem setEnabled:NO];
        _rightBarButtonItem.tintColor = [UIColor colorWithWhite:0 alpha:0];
        
    }
    else{
        
        [_rightBarButtonItem setEnabled:YES];
        _rightBarButtonItem.tintColor = [UIColor whiteColor];
        
    }
    

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:NO];
    
    if (self.segmentedControl.selectedSegmentIndex == 1) {
        
        //OKボタンを隠す
        [_rightBarButtonItem setEnabled:NO];
        _rightBarButtonItem.tintColor = [UIColor colorWithWhite:0 alpha:0];
        
    }
    else{
        
        [_rightBarButtonItem setEnabled:YES];
        _rightBarButtonItem.tintColor = [UIColor whiteColor];
        
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Private Methods


//読み込むNewMenuConfigureViewControllerのxibを選ぶ
- (void)loadNewMenuConfigureViewControllerXib {
    
    
    CGRect screenSize = [UIScreen mainScreen].bounds;
    
    //@1xの場合(3G,3GSの場合,ipadのiphoneシミュレータの@1x)
    if (screenSize.size.height == 480) {
        newMenuConfigureViewControllerIdentifer = @"NewMenuConfigureViewController@3.5inch";
    }
    //@2xの場合(5,5s,5cの場合)
    else if (screenSize.size.height == 568){
        newMenuConfigureViewControllerIdentifer = @"NewMenuConfigureViewController@4inch";
    }
    //その他の場合
    else {
        newMenuConfigureViewControllerIdentifer = @"NewMenuConfigureViewController";
    }

}


//セグメンテッドコントロール値により異なるコントローラーを取得する
-(UIViewController *)viewControllerForSegmentIndex:(NSInteger)index
{
    UIViewController *viewController;
    switch (index) {
        case 0:
            /*viewControllerをxibからインスタンス化する処理*/
            viewController = (HistoryMenuViewController *)appDelegate.historyMenuViewController;
            break;
        case 1:
            //読み込むNewMenuConfigureViewControllerのxibを選ぶ
            [self loadNewMenuConfigureViewControllerXib];
            //xibファイルからnewMenuViewのインスタンスを得る
            viewController = [[NewMenuConfigureViewController alloc] initWithNibName:newMenuConfigureViewControllerIdentifer bundle:nil];
            break;
    }
    return viewController;
}


//セグメンテッドコントロールの値を変更した時に呼ばれる
-(IBAction)segmentChange:(UISegmentedControl *)sender
{
    
    if (self.segmentedControl.selectedSegmentIndex == 1) {
        
        //OKボタンを隠す
        [_rightBarButtonItem setEnabled:NO];
        _rightBarButtonItem.tintColor = [UIColor colorWithWhite:0 alpha:0];
        
    }
    else{
        
        [_rightBarButtonItem setEnabled:YES];
        _rightBarButtonItem.tintColor = [UIColor whiteColor];
        
    }
    
    
    //セグメンテッドコントロールの値により異なるコントローラを取得する
    UIViewController *nextViewController = [self viewControllerForSegmentIndex:sender.selectedSegmentIndex];
    //取得したコントローラを子コントローラとして追加する
    [self addChildViewController:nextViewController];
    //ビューを変更する
    [self transitionFromViewController:self.currentViewController toViewController:nextViewController duration:0.5 options:UIViewAnimationOptionTransitionNone //変更するアニメーションの指定
        animations:^{
            [self.currentViewController.view removeFromSuperview];
            nextViewController.view.frame = self.contentView.bounds;
            [self.contentView addSubview:nextViewController.view];
        }completion:^(BOOL finished) {
            [nextViewController didMoveToParentViewController:self];
            [self.currentViewController removeFromParentViewController];
            self.currentViewController = nextViewController;
        }];
}


//OKボタンが押されたら、
-(IBAction)okButtonPushed:(UIBarButtonItem *)sender
{
    
    //delegateを呼び出し、
    [(HistoryMenuViewController *)appDelegate.historyMenuViewController insertedMenuViewCellFromHistoryViewController];
    
}


@end


#pragma mark - InsertNewObjectViewController (Controller) Category


/*-------------------------------*/
//画面上で起こる操作に関するカテゴリ
//カテゴリー名：Control
/*-------------------------------*/
///////////////////////////////////
///////////interface///////////////
///////////////////////////////////
@interface InsertNewObjectViewController (Controller)


//<戻るボタンが押された時の処理
-(IBAction)backButtonPushed:(id)sender;


@end


///////////////////////////////////
///////////implementation//////////
///////////////////////////////////
@implementation InsertNewObjectViewController (Controller)


//<戻るボタンが押された時の処理
-(IBAction)backButtonPushed:(id)sender
{
    //InitialViewControllerへnavigationControllerを介して移動する
    [self.navigationController popViewControllerAnimated:YES];
    
}


@end
