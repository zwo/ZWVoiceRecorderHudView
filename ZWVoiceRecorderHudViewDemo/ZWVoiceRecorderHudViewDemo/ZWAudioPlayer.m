//
//  ZWAudioPlayer.m
//  ZWVoiceRecorderHudViewDemo
//
//  Created by Victor on 15-2-17.
//  Copyright (c) 2015年 Victor. All rights reserved.
//

#import "ZWAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>
@implementation ZWAudioPlayer

- (void)managerAudioWithFilePath:(NSString*)filePath toPlay:(BOOL)toPlay {
    if (toPlay) {
        [self playAudioWithFileName:filePath];
    } else {
        [self pausePlayingAudio];
    }
}

- (void)stopAudio
{
    self.playingFileName=@"";
    if (_player && _player.isPlaying) {
        [_player stop];
    }
}

- (void)pausePlayingAudio
{
    if (_player) {
        [_player pause];
    }
}

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - Actions

- (void)playAudioWithFileName:(NSString*)fileName
{
    if (fileName.length > 0) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        if (_playingFileName && [fileName isEqualToString:_playingFileName]) {
            if (_player) {
                [_player play];
            }
        } else {
            if (_player) {
                [_player stop];
                self.player = nil;
            }
            AVAudioPlayer *pl = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:fileName] error:nil];
            pl.delegate = self;
            [pl play];
            self.player = pl;
        }
        self.playingFileName = fileName;
    }
}

- (BOOL)isPlaying {
    if (!_player) {
        return NO;
    }
    return _player.isPlaying;
}

#pragma mark - audio delegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self stopAudio];
}

@end
