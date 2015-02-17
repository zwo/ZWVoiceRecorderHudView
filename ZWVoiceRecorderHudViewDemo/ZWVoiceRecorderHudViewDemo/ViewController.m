//
//  ViewController.m
//  ZWVoiceRecorderHudViewDemo
//
//  Created by Victor on 15-2-16.
//  Copyright (c) 2015年 Victor. All rights reserved.
//

#import "ViewController.h"
#import "ZWVoiceRecorderHudView.h"
#import "ZWAudioPlayer.h"

@interface ViewController ()
@property (nonatomic, strong) ZWVoiceRecorderHudView *recorderHudView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.recorderHudView=[[ZWVoiceRecorderHudView alloc] initWithParentView:self.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)getRecorderPath
{
    NSString *recorderPath = nil;
    recorderPath = [[NSString alloc] initWithFormat:@"%@/Documents/test.caf", NSHomeDirectory()];
    return recorderPath;
}

- (IBAction)onButtonPlay {
    [[ZWAudioPlayer sharedInstance] managerAudioWithFilePath:[self getRecorderPath] toPlay:YES];
}

- (IBAction)startRecording {
    [self.view addSubview:_recorderHudView];
    [_recorderHudView startForFilePath:[self getRecorderPath]];
}

- (IBAction)stopRecording {
    [_recorderHudView stopRecording];
    [_recorderHudView removeFromSuperview];
}

// 这里为取消录制，即手指滑出按钮所在区域，正常实现为停止录制并删除文件，这里仅仅实现停止录制
- (IBAction)cancelRecording {
    [_recorderHudView cancelRecording];
    [_recorderHudView removeFromSuperview];
}

@end
