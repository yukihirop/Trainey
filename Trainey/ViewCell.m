//
//  ViewCell.m
//  Trainey
//
//  Created by 福田幸弘 on 2015/07/19.
//  Copyright (c) 2015年 yukihiro fukuda. All rights reserved.
//

#import "ViewCell.h"

@implementation ViewCell
{
    NSUserDefaults *defaults;
}


@synthesize reminderLabel = _reminderLabel;


- (void)awakeFromNib
{
    // Initialization code
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end