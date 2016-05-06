//
//  PickerViewController.m
//  Trainey
//
//  Created by 福田幸弘 on 2015/07/17.
//  Copyright (c) 2015年 yukihiro fukuda. All rights reserved.
//

#import "PickerViewController.h"


@interface PickerViewController ()


@end


@implementation PickerViewController
{
    NSInteger records_sorting_date_pk_Count;
    NSInteger records_sorting_menu_pk_Count;
    AppDelegate *appDelegate;
    
}


@synthesize pickerView = _pickerView;
@synthesize toolBar = _toolBar;
@synthesize indexPath = _indexPath;


#pragma mark - Standard Methods


//iPhoneの画面サイズで読み込むxibを変える
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    CGRect screenSize = [UIScreen mainScreen].bounds;
    
    //@1xの場合(3G,3GSの場合,ipadのiphoneシミュレータの@1x)
    if (screenSize.size.height == 480) {
        nibNameOrNil = @"PickerViewController@3.5inch";
    }
    //@2xの場合(5,5s,5cの場合)
    else if (screenSize.size.height == 568){
        nibNameOrNil = @"PickerViewController@4inch";
    }
    //その他の場合
    else {
        nibNameOrNil = @"PickerViewController";
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
    
    //pickerViewの列の数
    records_sorting_date_pk_Count = [[DatesManager sharedManager].dates count];
    records_sorting_menu_pk_Count = [[MenusManager sharedManager].menus count];
    
    //デリゲートの設定
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
    _pickerView.backgroundColor = [UIColor whiteColor];
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Private Methods


//ツールバーのOKボタンが押されたら
-(IBAction)okButtonPushed:(id)sender
{
    
    [self.delegate didOKButtonClicked:self];
    
}


//ツールバーのcancelボタンが押されたら
-(IBAction)cancelButtonPushed:(id)sender
{
    
    [self.delegate didCancelButtonClicked:self];
    
}


#pragma mark - UIPickerView Methods


//列の数を指定
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    //とりあえず
    return 1;
}


//カラムの要素数を指定
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger numberOfRows;
    
    //日付別かメニュー別かで分ける
    switch (((RecordViewController *)appDelegate.tabRecordViewController).segmentedControl.selectedSegmentIndex) {
            
        case 0://日付別
            //最新の日付は除く
            numberOfRows = records_sorting_date_pk_Count-1;
            break;
        case 1://メニュー別
            numberOfRows = records_sorting_menu_pk_Count;
            break;
        default:
            break;
    }
    
    return numberOfRows;
    
}


//選択肢要素の表示文字列
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    NSString *titleForRow;
    NSString *menuNameWithNumber;
    
    switch (((RecordViewController *)appDelegate.tabRecordViewController).segmentedControl.selectedSegmentIndex) {
            
        case 0://日付別
            titleForRow = [DatesManager sharedManager].dates[records_sorting_date_pk_Count-row-2][@"dateText"];
            break;
        case 1://メニュー別
            menuNameWithNumber = [NSString stringWithFormat:@"%d. %@", (int)(row+1),[MenusManager sharedManager].menus[(int)row][@"menuName"]];
            if ([[MenusManager sharedManager].menus[(int)row][@"menuCategory"] intValue] == 0) {
                titleForRow = [NSString stringWithFormat:@"%@ (上)",menuNameWithNumber];
            }else if ([[MenusManager sharedManager].menus[(int)row][@"menuCategory"] intValue] == 1) {
                titleForRow = [NSString stringWithFormat:@"%@ (下)",menuNameWithNumber];
            }
            break;
        default:
            break;
    }
    
    return titleForRow;
    
}


//pickerViewで選択された時
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
    //選択されているindexPathを保存する
    _indexPath = [NSIndexPath indexPathForRow:0 inSection:row];
    
}


@end