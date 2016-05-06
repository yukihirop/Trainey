//
//  AppDelegate.m
//  Trainey
//
//  Created by 福田幸弘 on 2015/04/26.
//  Copyright (c) 2015年 yukihiro fukuda. All rights reserved.
//

#import "AppDelegate.h"


//アプリのID
static NSString *const kAppleStoreID = @"1022841669";


@interface AppDelegate ()

@end


//16進数からUIColorを作成
@implementation UIColor (Hex)
+ (id)colorWithHexString:(NSString *)hex alpha:(CGFloat)a {
    NSScanner *colorScanner = [NSScanner scannerWithString:hex];
    unsigned int color;
    if (![colorScanner scanHexInt:&color]) return nil;
    CGFloat r = ((color & 0xFF0000) >> 16)/255.0f;
    CGFloat g = ((color & 0x00FF00) >> 8) /255.0f;
    CGFloat b =  (color & 0x0000FF) /255.0f;
    //NSLog(@"HEX to RGB >> r:%f g:%f b:%f a:%f\n",r,g,b,a);
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
}
@end


@implementation AppDelegate


//外部クラスからアクセスするためのアクセサメソッド
@synthesize rootTabBarController;
@synthesize firstNavigationController;
@synthesize thirdNavigationController;
@synthesize tabInitialViewController;
@synthesize tabRecordViewController;
@synthesize tabSettingViewController;
@synthesize homeViewController;
@synthesize performanceCheckingViewController;
@synthesize insertedMenuTableViewController;
@synthesize historyMenuViewController;
@synthesize date_RecordViewController;
@synthesize menu_RecordViewController;
@synthesize CONCEPT_COLOR = _CONCEPT_COLOR;
@synthesize timeControlView = _timeControlView;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // Override point for customization after application launch.
    
    
    //コンセプトカラーの設定
    _CONCEPT_COLOR = self.CONCEPT_COLOR;
    
    
    //メインウィンドウ
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //rootTabBarControllerの初期化
    [self initRootTabBarController];
    //各パーツの色の設定
    [self settingPartsColor:_CONCEPT_COLOR];
    //レンダリング(データとして与えられた情報を計算によって画像かすること)
    [self.window makeKeyAndVisible];
    
    
    //ステータスバーのフォントを白にする
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    //ステータスバーの背景色を露草色にする
    addStatusBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.window.frame.size.width, 20)];
    addStatusBar.backgroundColor = [UIColor colorWithHexString:_CONCEPT_COLOR alpha:1.0f];
    [self.window addSubview:addStatusBar];
    
    
    //sqliteの保存場所を示す「これはかなり便利、覚えておくべきだな」
    NSLog(@"app dir: %@",[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);
    
    //ローカル通知の初期化
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    
    
    
    
    
    return YES;
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    
    // アプリ起動中(フォアグラウンド)に通知が届いた場合
    if(application.applicationState == UIApplicationStateActive) {
        // ここに処理を書く
    }
    
    // アプリがバックグラウンドにある状態で通知が届いた場合
    if(application.applicationState == UIApplicationStateInactive) {
        // ここに処理を書く
    }
    
    // 通知領域から削除する
    [[UIApplication sharedApplication] cancelLocalNotification:notification];
    
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    //iosでアプリの最新バージョンを取得する方法
    //[self showNeedUpdateAlertIfNeed];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - Private Methods

-(NSString *)temporarystopRestartText
{
    NSString *result;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults stringForKey:@"temporarystopRestartText"] == Nil) {
        //初期値
        [defaults setValue:@"一時停止" forKey:@"temporarystopRestartText"];
    }
    //defaultsから取り出す
    result = [defaults stringForKey:@"temporarystopRestartText"];
    
    return result;
}


-(BOOL)temporarystopRestartEnabled
{
    BOOL *result;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:@"temporarystopRestartEnabled"] == Nil) {
        //初期値
        [defaults setBool:NO forKey:@"temporarystopRestarEnabled"];
    }
    //defaultsから取り出す
    result = [defaults boolForKey:@"temporarystopRestartEnabled"];
    
    return result;
    
    
}


-(NSString *)startCancelText
{
    
    NSString *result;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults stringForKey:@"startCancelText"] == Nil) {
        //初期値
        [defaults setValue:@"開始" forKey:@"startCancelText"];
    }
    //defaultsから取り出す
    result = [defaults stringForKey:@"startCancelText"];
    
    return result;
}


//CONCEPT_COLORのゲッタ
-(NSString *)CONCEPT_COLOR
{
    NSString *result;
    
    //User Defaultsインスタンス
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //Nilは空であることを指す
    if ([defaults stringForKey:@"CONCEPT_COLOR"] == Nil) {
        //初期値をUser Defaultsに保存する
        [defaults setValue:TUYUKUSAIRO forKey:@"CONCEPT_COLOR"];
    }
    //User Defaultsから色を取り出す
    result = [defaults stringForKey:@"CONCEPT_COLOR"];
    
    return result;
}


//appearanceによる各パーツの色の設定
-(void)settingPartsColor:(NSString *)NEW_CONCEPT_COLOR
{
    //コンセプトカラーを更新
    _CONCEPT_COLOR = NEW_CONCEPT_COLOR;
    
    //timeControlViewの色の設定
    _timeControlView.backgroundColor = [UIColor colorWithHexString:NEW_CONCEPT_COLOR alpha:1.0f];
    
    //tabbarの色の設定(appearanceではできないかな？)
    [tabInitialViewController.tabBarController.tabBar setTintColor:[UIColor colorWithHexString:NEW_CONCEPT_COLOR alpha:1.0f]];
    [tabRecordViewController.tabBarController.tabBar setTintColor:[UIColor colorWithHexString:NEW_CONCEPT_COLOR alpha:1.0f]];
    [tabSettingViewController.tabBarController.tabBar setTintColor:[UIColor colorWithHexString:NEW_CONCEPT_COLOR alpha:1.0f]];

    //segmentedControlの色の設定
    [[UISegmentedControl appearance] setTintColor:[UIColor colorWithHexString:NEW_CONCEPT_COLOR alpha:1.0f]];
    
    //navigationbarの色の設定
    [UINavigationBar appearance].barTintColor = [UIColor colorWithHexString:NEW_CONCEPT_COLOR alpha:1.0f];
    
    //navigationbarItemの色の設定
    [UINavigationBar appearance].tintColor = [UIColor whiteColor];
    
    //曇りガラスをoff
    [UINavigationBar appearance].translucent = NO;
    
    //navigationBarのtitleの色の設定
    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    
    //ステータスバーの色の設定
    addStatusBar.backgroundColor = [UIColor colorWithHexString:NEW_CONCEPT_COLOR alpha:1.0f];
    
}


-(void)initRootTabBarController
{
    
    //起点となるrootTabBarControllerを生成
    rootTabBarController = [UITabBarController new];
    
    //タブメニュー選択時のビューを生成
    tabInitialViewController = [InitialViewController new];
    
    //ナビゲーションビューコントロラーにtabInitialViewControllerを設定する
    firstNavigationController = [[UINavigationController alloc]initWithRootViewController:tabInitialViewController];
    //これを書いておかないと、InterfaceBuilderで追加したNavigationBarが隠れてしまう。
    [firstNavigationController setNavigationBarHidden:YES];
    
    tabRecordViewController = [RecordViewController new];
    tabSettingViewController = [SettingViewController new];
    
    //ナビゲーションビューコントロラーにtabSettingViewControllerを設定する
    thirdNavigationController = [[UINavigationController alloc] initWithRootViewController:tabSettingViewController];
    //これを書いておかないと、InterfaceBuilderで追加したNavigationBarが隠れてしまう。
    [thirdNavigationController setNavigationBarHidden:YES];
    
    /*InitialViewControllerのcontentViewのxibファイルからの初期化*/
    homeViewController = [[HomeViewController alloc] init];
    performanceCheckingViewController = [[PerformanceCheckingViewController alloc] init];
    
    
    historyMenuViewController = [[HistoryMenuViewController alloc] init];
    
    menu_RecordViewController = [[Menu_RecordViewController alloc] init];
    date_RecordViewController = [[Date_RecordViewController alloc] init];
    
    
    //タブバーアイテムの設定(色はデフォルトでシステムカラーのままである)
    firstNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"ホーム" image:[UIImage imageNamed:@"home_p@2x"] tag:0];
    tabRecordViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"記録" image:[UIImage imageNamed:@"memory_p@2x"] tag:1];
    thirdNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"その他" image:[UIImage imageNamed:@"more_p@2x"] tag:2];
    
    
    
    //ViewControllerを格納するcontrollersを生成,最後のnilを忘れちゃいけない
    NSArray *controllers = [NSArray arrayWithObjects:firstNavigationController, tabRecordViewController, thirdNavigationController,nil];
    //rootTabBarControllerに設定する
    [(UITabBarController*)rootTabBarController setViewControllers:controllers animated:NO];
    
    
    //windowsに追加する。viewを追加するなら、addView
    //[self.window addSubview:rootTabBarController.view];
    
    //windosに追加する。viewControllerを追加するなら、setRootViewController
    [self.window setRootViewController:rootTabBarController];
    
    
}


//タブ切り替え
-(void)switchTabBarController:(NSInteger)selectedViewIndex
{
    UITabBarController *controller = (UITabBarController *)rootTabBarController;
    controller.selectedViewController = [controller.viewControllers objectAtIndex:selectedViewIndex];
    
}


//利用中のバージョンより、新しいバージョンのアプリがストアに公開されている場合にダイアログを表示する
-(void)showNeedUpdateAlertIfNeed
{
    
    [self getLatestAppVersionAsynchronousWithCompletionBlock:^(NSString *latestAppVersion) {
        // 現行のアプリバージョンが、最新のアプリバージョンよりも古い場合(NSNumericSearchでバージョン番号での比較が可能)、
        if ([latestAppVersion compare:[self applicationVersion] options:NSNumericSearch] == NSOrderedDescending) {
            static BOOL isAlreadyShow = NO;
            // 通知中でなければ、
            if (!isAlreadyShow) {
                isAlreadyShow = YES;
                // メインスレッドで通知を実行する。
                dispatch_async(dispatch_get_main_queue(), ^{
                    // ダイアログを表示するなど、通知の処理をここに記述。
                });
            }
        }
    }];
}


//アプリの最新バージョンをAppleStoreから非同期で取得する
-(void)getLatestAppVersionAsynchronousWithCompletionBlock:(void(^)(NSString *))completionBlock
{
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@", kAppleStoreID]]
                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData // キャッシュしない
                                         timeoutInterval:20.0];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (data) {
                                   NSDictionary *versionSummary = [NSJSONSerialization JSONObjectWithData:data
                                                                                                  options:NSJSONReadingAllowFragments
                                                                                                    error:&error];
                                   NSDictionary *results = [[versionSummary objectForKey:@"results"] objectAtIndex:0];
                                   NSString *latestVersion = [results objectForKey:@"version"];
                                   NSLog(@">>>>> Latest App Version is %@.", latestVersion);
                                   completionBlock(latestVersion);
                               } else {
                                   NSLog(@">>>>> Fail to Get Latest App Version.");
                               }
                           }];


}


//利用中のアプリのバージョンを取得する
-(NSString *)applicationVersion
{
    
    return  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
 
}

@end
