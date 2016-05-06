//
//  ThemeViewCell.m
//  Trainey
//
//  Created by 福田幸弘 on 2015/05/18.
//  Copyright (c) 2015年 yukihiro fukuda. All rights reserved.
//

#import "ThemeViewCell.h"


@implementation ThemeViewCell


- (void)awakeFromNib
{
    // Initialization code
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(IBAction)selectconceptColor:(UIButton *)sender
{
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *CONCEPT_COLOR;
    
    switch (sender.tag) {
        case 0:
            CONCEPT_COLOR = TUYUKUSAIRO;
            break;
        case 1:
            CONCEPT_COLOR = TUTUJIIRO;
            break;
        case 2:
            CONCEPT_COLOR = SUMIREIRO;
            break;
        case 3:
            CONCEPT_COLOR = AOMIDORI;
            break;
        case 4:
            CONCEPT_COLOR = YAMABUKIIRO;
            break;
        case 5:
            CONCEPT_COLOR = SUMI;
            break;
    }
    
    //user defaultsのコンセプトカラーを設定しなおす。
    [defaults setValue:CONCEPT_COLOR forKey:@"CONCEPT_COLOR"];
    //コンセプトカラーを設定しなおす。
    [appDelegate settingPartsColor:[defaults stringForKey:@"CONCEPT_COLOR"]];
    
    
    //SettingViewControllerのnavigationbarの色をCONCEPT_COLORに変える(SettingViewControllerだけ)
    //SettingViewControllerのインスタンスはゲッタで取得した方がいいのかな？（数が増えるとそうすべきかも）
    appDelegate.tabSettingViewController.navigationBar.barTintColor = [UIColor colorWithHexString:CONCEPT_COLOR alpha:1.0f];
    
}


@end