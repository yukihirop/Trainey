//
//  MenuViewCell.m
//  Trainey
//
//  Created by 福田幸弘 on 2015/05/06.
//  Copyright (c) 2015年 yukihiro fukuda. All rights reserved.
//

#import "MenuViewCell.h"


//contentの変数
#define CONTENT_SIZE 3



@implementation MenuViewCell
{
    NSInteger senderTag;
}


@synthesize weightFields = _weightFields;
@synthesize repeatCountFields = _repeatCountFields;
@synthesize toolBar = _toolBar;


- (void)awakeFromNib
{
    // Initialization code
    
    for (int i = 0; i < CONTENT_SIZE; i++) {
        
        //デリゲートの設定
        ((UITextField *)_weightFields[i]).delegate = self;
        ((UITextField *)_repeatCountFields[i]).delegate = self;
        
        //[(UISwitch *)_isTrainingSwitchs[i] addTarget:self action:@selector(save_isTry:) forControlEvents:UIControlEventValueChanged];

        
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    //alertを発生
    [self showAlertView:textField];
    return NO;
}


#pragma mark Private Methods


//-(void)save_isTry:(UISwitch *)sender
//{
//    
//    //records(データベース)のisTryを保存する
//    [self.delegate saveRecords_dateText_isTry:self atCellTag:self.tag atRowIndex:sender.tag/3];
//    
//}


-(void)showAlertView:(UITextField *)sender
{
    UIAlertView *alert = [UIAlertView new];
    
    //デリゲートの設定
    alert.delegate = self;
    
    //senderTagに設定
    senderTag = sender.tag;
    
    //sender.tagで場合分け
    switch (senderTag % 3) {
        case 0:
            break;
        case 1:
            alert.message = @"負荷(kg)を入力して下さい。";
            //[alert textFieldAtIndex:0].placeholder = @"負荷(kg)";
            break;
        case 2:
            alert.message = @"反復回数を入力して下さい。";
            //[alert textFieldAtIndex:0].placeholder = @"反復回数(回)";
            break;
    }
    
    [alert addButtonWithTitle:@"cancel"];
    [alert addButtonWithTitle:@"OK"];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [alert textFieldAtIndex:0].clearButtonMode = UITextFieldViewModeWhileEditing;
    //キーボードタイプを変更する
    [alert textFieldAtIndex:0].keyboardType = UIKeyboardTypeDecimalPad;
    [alert show];
    
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    //はい、もしくはOKが押されたら、
    if (buttonIndex == 1) {
        
        
        //UITextFiledの場合の処理
        switch (senderTag%3) {
            case 0:
                //trash
                //cellTagで指定されるcellを削除する
                [self.delegate deleteMenuViewCell:self atCellTag:self.tag];
                break;
            case 1:
                //負荷(kg)
                ((UITextField *)_weightFields[senderTag/3]).text = [[alertView textFieldAtIndex:0] text];
                //UIAlertViewでOKが押されたら、weightを保存する
                [self.delegate saveRecords_dateText_textField:self atCellTag:self.tag atRowIndex:senderTag/3 forKey:@"weight"];
                break;
            case 2:
                //反復回数
                ((UITextField *)_repeatCountFields[senderTag/3]).text = [[alertView textFieldAtIndex:0] text];
                //UIAlertViewでOKが押されたら、repeatCountを保存する
                [self.delegate saveRecords_dateText_textField:self atCellTag:self.tag atRowIndex:senderTag/3 forKey:@"repeatCount"];
                break;
        }
        
    }
    
}


//barButtonのtrashがおされたら
-(IBAction)trashButtonPushed:(UIBarButtonItem *)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告"
                                                    message:@"本当に削除しますか？"
                                                   delegate:self
                                          cancelButtonTitle:@"cancel"
                                          otherButtonTitles:@"はい", nil];
    
    //デリゲートの設定
    alert.delegate = self;
    
    //senderTagに設定
    senderTag = sender.tag;
    
    [alert show];
    
    NSLog(@"(MenuViewCell, trashButtonPushed)");
    
}


//保存処理
-(IBAction)saveButtonPushed:(UIBarButtonItem *)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:@"保存しました。"
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"はい", nil];
    [alert show];
    
    //保存処理
    //records(データベース)のisTryを保存する
    [self.delegate saveRecords_dateText_isTry:self atCellTag:self.tag];
}


@end
