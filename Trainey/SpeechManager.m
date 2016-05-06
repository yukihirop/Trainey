//
//  SpeechManager.m
//  UnitTestSample
//
//  Created by Yukinaga Azuma on 2014/02/13.
//  Copyright (c) 2014年 Yukinaga Azuma. All rights reserved.
//

#import "SpeechManager.h"

@implementation SpeechManager

- (id)init
{
    self = [super init];
    if (self) {
        speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
    }
    return self;
}

-(void)speech:(NSString *)string
{
    
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:string];
    AVSpeechSynthesisVoice* voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"ja-JP"];
    utterance.voice = voice;
    utterance.rate = 0.1;
    utterance.pitchMultiplier = 1.0;
    [speechSynthesizer speakUtterance:utterance];
}

@end
