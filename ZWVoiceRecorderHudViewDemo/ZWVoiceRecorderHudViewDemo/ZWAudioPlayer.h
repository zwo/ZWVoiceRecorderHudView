//
//  ZWAudioPlayer.h
//  ZWVoiceRecorderHudViewDemo
//
//  Created by Victor on 15-2-17.
//  Copyright (c) 2015年 Victor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVAudioPlayer.h>
@interface ZWAudioPlayer : NSObject
<AVAudioPlayerDelegate>
@property (nonatomic, strong) AVAudioPlayer *player;

@property (nonatomic, copy) NSString *playingFileName;

- (void)managerAudioWithFilePath:(NSString*)filePath toPlay:(BOOL)toPlay;
+ (instancetype)sharedInstance;
- (void)pausePlayingAudio;//暂停
- (void)stopAudio;//停止
- (BOOL)isPlaying;
@end
