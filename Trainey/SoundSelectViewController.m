//
//  SoundSelectViewController.m
//  Trainey
//
//  Created by 福田幸弘 on 2015/06/21.
//  Copyright (c) 2015年 yukihiro fukuda. All rights reserved.
//

#import "SoundSelectViewController.h"


#define SOUNDSELECT_TABLEVIEW_HEIGHT 554
#define SOUNDSELECT_TABLEVIEW_SECTION_COUNT 2
#define SOUNDSELECT_TABLEVIEW_SECTION_HEIGHT 30
#define SOUNDSELECT_TABLEVIEW_ROW_HEIGHT 53
#define SOUNDSELECT_TABLEVIEW_POSITION_Y 64


//カスタムセルの識別子
static NSString *SoundSelectViewCellIdentifier = @"SoundSelectViewCell";


@interface SoundSelectViewController ()


@end


@implementation SoundSelectViewController
{
    NSArray *soundArray_normal;
    NSArray *soundArray_funny;
    NSArray *soundNameArray_normal;
    NSArray *soundNameArray_funny;
    NSString *sound;
    BGMManager *soundManager;
    //読み込むSoundSelectViewCellのxib
    NSString *soundSelectViewCellIdentifer;
}


@synthesize tableView = _tableView;

#pragma mark - Standard Methods


//iPhoneの画面サイズで読み込むxibを変える
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    CGRect screenSize = [UIScreen mainScreen].bounds;
    
    //@1xの場合(3G,3GSの場合,ipadのiphoneシミュレータの@1x)
    if (screenSize.size.height == 480) {
        nibNameOrNil = @"SoundSelectViewController@3.5inch";
    }
    //@2xの場合(5,5s,5cの場合)
    else if (screenSize.size.height == 568){
        nibNameOrNil = @"SoundSelectViewController@4inch";
    }
    //その他の場合
    else {
        nibNameOrNil = @"SoundSelectViewController";
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
    
    soundArray_normal = [NSArray arrayWithObjects:
                         @"ピンポーン",
                         @"ピンポーン(明るめ)",
                         @"ピンポーン×3",
                         @"ピンポーン×3(明るめ)",
                         @"重い鐘1",
                         nil];
    
    soundArray_funny = [NSArray arrayWithObjects:
                        @"一本締め",
                        @"車のウィンカー",
                        @"泡",
                        @"目をパチパチ",
                        @"下水道",
                        @"コルク栓",
                        nil];
    
    
    soundManager = [BGMManager new];
    
    
    CGRect frame = CGRectMake(0, SOUNDSELECT_TABLEVIEW_POSITION_Y, [UIScreen mainScreen].bounds.size.width,SOUNDSELECT_TABLEVIEW_HEIGHT);
    _tableView.frame = frame;
    
    //delegateとdataSorceの設定
    _tableView.delegate = (id)self;
    _tableView.dataSource = (id)self;
    
    
    //読み込むSoundSelectViewCellのxibを選ぶ
    [self loadSoundSelectViewCell];
    
    
    //カスタムセルの登録(xibファイルから)
    [_tableView registerNib:[UINib nibWithNibName:soundSelectViewCellIdentifer bundle:nil] forCellReuseIdentifier:SoundSelectViewCellIdentifier];
    
    //更新
    [_tableView reloadData];
    
    [self.view addSubview:_tableView];
    
    
}


-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:NO];
 
    //チェックマークを全て外す
    for (UITableViewCell *cell in [_tableView visibleCells])
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    //音楽を停止させる
    [soundManager stopBGM];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Private Methods


//読み込むSoundSelectViewCellを選ぶ
- (void)loadSoundSelectViewCell {
    
    
    CGRect screenSize = [UIScreen mainScreen].bounds;
    
    //@1xの場合(3G,3GSの場合,ipadのiphoneシミュレータの@1x)
    if (screenSize.size.height == 480) {
        soundSelectViewCellIdentifer = @"SoundSelectViewCell@3.5inch";
    }
    //@2xの場合(5,5s,5cの場合)
    else if (screenSize.size.height == 568){
        soundSelectViewCellIdentifer = @"SoundSelectViewCell@4inch";
    }
    //その他の場合
    else {
        soundSelectViewCellIdentifer = @"SoundSelectViewCell";
    }
    
    
}


//OKボタンが押されたら、
-(IBAction)okButtonPushed:(UIBarButtonItem *)sender
{
    
    [soundManager stopBGM];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:sound forKey:@"soundText"];
    
    //InitialViewControllerへnavigationControllerを介して移動する
    [self.navigationController popViewControllerAnimated:YES];
    
    
}


//<戻るボタンが押された時の処理
-(IBAction)backButtonPushed:(id)sender
{
    [soundManager stopBGM];
    
    //InitialViewControllerへnavigationControllerを介して移動する
    [self.navigationController popViewControllerAnimated:YES];
    
}


#pragma mark - UITableView Methods


//セクションの数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"呼ばれました (SoundSelectViewController, numberOfSectionsInTableView)");
    
    //2
    return SOUNDSELECT_TABLEVIEW_SECTION_COUNT;
}


//セクションの高さ
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //30
    return SOUNDSELECT_TABLEVIEW_SECTION_HEIGHT;
}


//セクションをカスタマイズしたい場合
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //viewのインスタンスを生成
    UIView *view = [UIView new];
    //黒
    view.backgroundColor = [UIColor colorWithRed:74.f/255.f green:74.f/255.f blue:74.f/255.f alpha:1];
    //viewに追加したいラベルのインスタンスを準備
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, SOUNDSELECT_TABLEVIEW_SECTION_HEIGHT)];
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
            label.text = @"  アラーム音";
            break;
        case 1://下半身
            label.text = @"  ネタ音";
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
    switch (section)
    {
        case 0:
            numberOfRows = [soundArray_normal count];
            break;
        case 1:
            //10
            numberOfRows = [soundArray_funny count];
            break;
    }
    
    return numberOfRows;
    
    
}


//セルの設定
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    SoundSelectViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SoundSelectViewCellIdentifier];
    // Configure the cell...
    if (nil == cell) {
        cell = [[SoundSelectViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:SoundSelectViewCellIdentifier];
    }
    
    //セルの設定
    [self configureCell:cell atIndexPath:indexPath];
    
    
    return cell;
}


//行の高さ
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return SOUNDSELECT_TABLEVIEW_ROW_HEIGHT;
}


//セルの設定をする
-(void)configureCell:(SoundSelectViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSString *soundName;
    
    switch (indexPath.section) {
        case 0:
            soundName = [NSString stringWithFormat:@"%d. %@",(int)indexPath.row+1,soundArray_normal[indexPath.row]];
            break;
        case 1:
            soundName = [NSString stringWithFormat:@"%d. %@",(int)indexPath.row+1,soundArray_funny[indexPath.row]];
        default:
            break;
    }
    
    cell.soundNameLabel.text = soundName;
    
}


// セルが選択された時に呼び出される
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //選択された音が再生される
    switch (indexPath.section) {
        case 0:
            sound = soundArray_normal[indexPath.row];
            break;
        case 1:
            sound = soundArray_funny[indexPath.row];
        default:
            break;
    }
    
    
    //一つだけにチェックを入れる(ハイライトを消す)
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 選択されたセルを取得
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        
        //チェックマークを全て外す
        for (UITableViewCell *cell in [tableView visibleCells])
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        // セルのアクセサリにチェックマークを指定
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        //BGMを再生する
        [soundManager startBGM:[NSString stringWithFormat:@"%@.mp3",sound]];
        
    }else if (cell.accessoryType == UITableViewCellAccessoryCheckmark){
        
        // セルのアクセサリにチェックマークを指定
        cell.accessoryType = UITableViewCellAccessoryNone;
        //BGMを再生する
        [soundManager stopBGM];
        
        
    }
    
    
}


@end
