// ZWVoiceRecorderHudView.h

#import <UIKit/UIKit.h>

@interface ZWVoiceRecorderHudView : UIView

@property (nonatomic,strong) NSString *title;

- (instancetype)initWithParentView:(UIView *)view;

- (void)startForFilePath:(NSString *)filePath;
- (void)stopRecording;
- (void)cancelRecording;

@end
