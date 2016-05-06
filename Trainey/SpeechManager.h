//
//  SpeechManager.h
//  UnitTestSample
//
//  Created by Yukinaga Azuma on 2014/02/13.
//  Copyright (c) 2014年 Yukinaga Azuma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface SpeechManager : NSObject
{
    AVSpeechSynthesizer *speechSynthesizer;
}

-(void)speech:(NSString *)string;

@end
