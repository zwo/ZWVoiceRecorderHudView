// ZWVoiceRecorderHudView.m

#import "ZWVoiceRecorderHudView.h"
#import <AVFoundation/AVFoundation.h>

static CGFloat const kHudSize=270.0;
static NSTimeInterval const kTimerUpdateInterval=0.05;
static NSTimeInterval const kMaxRecordTime=60.0;
static int const kSoundMeterCount=40;

@interface ZWVoiceRecorderHudView ()<AVAudioRecorderDelegate>
@property (nonatomic, strong) AVAudioRecorder *recorder;
@end

@implementation ZWVoiceRecorderHudView
{
    int _soundMeters[40];
    NSTimeInterval _recordTime;
    NSTimer *_timer;
    CGRect _hudRect;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentMode=UIViewContentModeRedraw;
        _hudRect = CGRectMake(self.center.x - (kHudSize / 2), self.center.y - (kHudSize / 2), kHudSize, kHudSize);
        _title=@"Speak Now";
    }
    return self;
}

- (instancetype)initWithParentView:(UIView *)view {
    return [self initWithFrame:view.bounds];
}

- (void)startForFilePath:(NSString *)filePath
{
    _recordTime = 0.0;
    [self soundMeterInitialization];
    _timer = [NSTimer scheduledTimerWithTimeInterval:kTimerUpdateInterval target:self selector:@selector(updateMeters) userInfo:nil repeats:YES];
    
    NSError *error = nil;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&error];
    [audioSession setActive:YES error:&error];
    
    NSMutableDictionary * recordSetting = [NSMutableDictionary dictionary];
    [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatAppleIMA4] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:16000.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
    
    _recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:filePath] settings:recordSetting error:&error];
    _recorder.delegate = self;
    [_recorder prepareToRecord];
    _recorder.meteringEnabled = YES;
    [_recorder recordForDuration:(NSTimeInterval) 160];
}

- (void)stopRecording
{
    [self cancelRecording];
}

- (void)cancelRecording
{
    if (!_timer)
        return;
    
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    if (!_recorder)
        return;
    
    if (self.recorder.isRecording) {
        [self.recorder stop];
    }
    
    self.recorder = nil;
}

- (void)updateMeters
{
    _recordTime += kTimerUpdateInterval;
    [_recorder updateMeters];
    float averagePower = [_recorder averagePowerForChannel:0];
    [self addSoundMeterItem:averagePower];
    
    if (_recordTime>kMaxRecordTime) {
        [self stopRecording];
    }
}

#pragma mark - Sound meter operations

- (void)soundMeterInitialization
{
    for (int i=0; i<kSoundMeterCount; i++) {
        _soundMeters[i]=-100;
    }
}

- (void)shiftSoundMeterLeft {
    for(int i=0; i<kSoundMeterCount - 1; i++) {
        _soundMeters[i] = _soundMeters[i+1];
    }
}

- (void)addSoundMeterItem:(int)lastValue {
    [self shiftSoundMeterLeft];
    [self shiftSoundMeterLeft];
    _soundMeters[kSoundMeterCount - 1] = lastValue;
    _soundMeters[kSoundMeterCount - 2] = lastValue;
    
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIColor *strokeColor = [UIColor colorWithRed:0.886 green:0.0 blue:0.0 alpha:0.8];
    UIColor *fillColor = [UIColor colorWithRed:0.5827 green:0.5827 blue:0.5827 alpha:1.0];
    UIColor *gradientColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    UIColor *color = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    
    
    NSArray *gradientColors = [NSArray arrayWithObjects:
                               (id)fillColor.CGColor,
                               (id)gradientColor.CGColor, nil];
    CGFloat gradientLocations[] = {0, 1};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, gradientLocations);
    
    UIBezierPath *border = [UIBezierPath bezierPathWithRoundedRect:_hudRect cornerRadius:10.0];
    CGContextSaveGState(context);
    [border addClip];
    CGContextDrawRadialGradient(context, gradient,
                                CGPointMake(_hudRect.origin.x+kHudSize/2, 120), 10,
                                CGPointMake(_hudRect.origin.x+kHudSize/2, 195), 215,
                                kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    
    CGContextRestoreGState(context);
    [strokeColor setStroke];
    border.lineWidth = 3.0;
    [border stroke];
    
    // Draw sound meter wave
    [[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.4] set];
    
    CGContextSetLineWidth(context, 3.0);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    
    int baseLine = 250;
    int multiplier = 1;
    int maxLengthOfWave = 50;
    int maxValueOfMeter = 70;
    for(CGFloat x = kSoundMeterCount - 1; x >= 0; x--)
    {
        multiplier = ((int)x % 2) == 0 ? 1 : -1;
        
        CGFloat y = baseLine + ((maxValueOfMeter * (maxLengthOfWave - abs(_soundMeters[(int)x]))) / maxLengthOfWave) * multiplier;
        
        if(x == kSoundMeterCount - 1) {
            CGContextMoveToPoint(context, x * (kHudSize / kSoundMeterCount) + _hudRect.origin.x + 10, y);
            CGContextAddLineToPoint(context, x * (kHudSize / kSoundMeterCount) + _hudRect.origin.x + 7, y);
        }
        else {
            CGContextAddLineToPoint(context, x * (kHudSize / kSoundMeterCount) + _hudRect.origin.x + 10, y);
            CGContextAddLineToPoint(context, x * (kHudSize / kSoundMeterCount) + _hudRect.origin.x + 7, y);
        }
    }
    
    CGContextStrokePath(context);
    
    // Draw title
    [color setFill];
    [self.title drawInRect:CGRectInset(_hudRect, 0, 25) withFont:[UIFont systemFontOfSize:42.0] lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
    
    [[UIColor colorWithWhite:0.8 alpha:1.0] setFill];
    UIBezierPath *line = [UIBezierPath bezierPath];
    [line moveToPoint:CGPointMake(_hudRect.origin.x, _hudRect.origin.y + kHudSize)];
    [line addLineToPoint:CGPointMake(_hudRect.origin.x + kHudSize, _hudRect.origin.y + kHudSize)];
    [line setLineWidth:3.0];
    [line stroke];
}

@end