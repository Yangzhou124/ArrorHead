//
//  MusicPlayManager.h
//  GameAgain
//
//  Created by Lwl on 2018/8/7.
//  Copyright © 2018年 Lwl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MusicPlayManager : NSObject
 + (BOOL)playMusic:(NSString *)filename;//播放音乐
 + (void)pauseMusic:(NSString *)filename;//暂停播放
 + (void)stopMusic:(NSString *)filename;//停止音乐
@end
