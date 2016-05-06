//
//  HistoryMenuViewCell.m
//  Trainey
//
//  Created by 福田幸弘 on 2015/05/07.
//  Copyright (c) 2015年 yukihiro fukuda. All rights reserved.
//

#import "HistoryMenuViewCell.h"


@implementation HistoryMenuViewCell
{
    NSInteger senderTag;
}


@synthesize categoryNumber;
@synthesize menuNameLabel;
@synthesize weightField = _weightField;
@synthesize repeatCountField = _repeatCountField;


- (void)awakeFromNib
{
    // Initialization code
    
    //デリゲートの設定
    _weightField.delegate = self;
    _repeatCountField.delegate = self;
    
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(IBAction)onReturn:(UITextField *)sender
{
    [sender resignFirstResponder];
}


-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    
    [self showAlertView:textField];
    
    return NO;
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
            alert.message = @"負荷(kg)を入力して下さい。";
            [alert textFieldAtIndex:0].placeholder = @"負荷(kg)";
            break;
        case 2:
            alert.message = @"反復回数を入力して下さい。";
            [alert textFieldAtIndex:0].placeholder = @"反復回数(回)";
            break;
    }
    
    [alert addButtonWithTitle:@"cancel"];
    [alert addButtonWithTitle:@"OK"];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [alert textFieldAtIndex:0].clearButtonMode = UITextFieldViewModeWhileEditing;
    //キーボードの種類を変える
    [alert textFieldAtIndex:0].keyboardType = UIKeyboardTypeDecimalPad;
    [alert show];
    
}


//エンティティに対し、保存処理を行うようにする必要があるね
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == 1) {
        
        switch (senderTag) {
            case 1:
                _weightField.text = [[alertView textFieldAtIndex:0] text];
                //UIAlertViewでOKが押されたら、weightを保存する
                [self.delegate saveHistorys_textField:self forKey:@"weight"];
                break;
            case 2:
                _repeatCountField.text = [[alertView textFieldAtIndex:0] text];
                //UIAlertViewでOKが押されたら、weightを保存する
                [self.delegate saveHistorys_textField:self forKey:@"repeatCount"];
                break;
        }
    }
    
}


@end
