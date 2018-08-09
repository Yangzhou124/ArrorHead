//
//  MusicPlayManager.m
//  GameAgain
//
//  Created by Lwl on 2018/8/7.
//  Copyright © 2018年 Lwl. All rights reserved.
//

#import "MusicPlayManager.h"
 #import <AVFoundation/AVFoundation.h>

@implementation MusicPlayManager

static NSMutableDictionary *_musicPlayers;
+ (NSMutableDictionary *)musicPlayers{
    if (_musicPlayers==nil) {
        _musicPlayers=[NSMutableDictionary dictionary];
    }
    return _musicPlayers;
}

+ (BOOL)playMusic:(NSString *)filename{
    if (!filename) return NO;
    AVAudioPlayer *player = [self musicPlayers][filename];
    if (!player) {
        NSURL *url=[[NSBundle mainBundle]URLForResource:filename withExtension:nil];
        if (!url) return NO;
        //创建播放器
        player=[[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
        //缓冲
        if (![player prepareToPlay]) return NO;//如果缓冲失败，那么就直接返回
        //存入字典
        [self musicPlayers][filename]=player;
        
        if ([filename isEqualToString:@"BGM.mp3"]) {
            [player setNumberOfLoops:-1];//设置循环播放
        }
        //       player.volume = 0.1;//声音大小
    }
    //播放
    if (![player isPlaying]) {
        return [player play];//如果当前没处于播放状态，那么就播放
    }
    return YES;//正在播放
}


+ (void)pauseMusic:(NSString *)filename{
    if (!filename) return;
    AVAudioPlayer *player=[self musicPlayers][filename];
    [player pause];
}

+ (void)stopMusic:(NSString *)filename{
    if (!filename) return;
    AVAudioPlayer *player=[self musicPlayers][filename];
    [player stop];
    [[self musicPlayers] removeObjectForKey:filename];
}



@end
