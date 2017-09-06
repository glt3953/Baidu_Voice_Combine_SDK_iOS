//
//  ASRViewController.m
//  SDKTester
//
//  Created by baidu on 16/1/27.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "ASRViewController.h"
#import "BDSASRDefines.h"
#import "BDSASRParameters.h"
#import "BDSWakeupDefines.h"
#import "BDSWakeupParameters.h"
#import "BDSEventManager.h"
#import "BDRecognizerViewController.h"
#import "BDVRSettings.h"
#import "fcntl.h"
#import "AudioInputStream.h"

//#error "Config Your Api Key and Secret Key"
const NSString* API_KEY = @"fERVROo5MeYFt3aNwih24tNP";
const NSString* SECRET_KEY = @"1d5c9e8c0d36d15d557c4abdccff88a7";
const NSString* APP_ID = @"8437071";
static NSUInteger maxFileTestNum = 3;

@interface ASRViewController () <BDSClientASRDelegate, BDSClientWakeupDelegate, BDRecognizerViewDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) BDSEventManager *asrEventManager;
@property (strong, nonatomic) BDSEventManager *wakeupEventManager;

@property (weak, nonatomic) IBOutlet UITextView *resultTextView;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;
@property (weak, nonatomic) IBOutlet UIButton *finishButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *voiceRecogButton;
@property (strong, nonatomic) UIActionSheet *moreActionSheet;

@property(nonatomic, assign) BOOL continueToVR;
@property(nonatomic, strong) NSFileHandle *fileHandler;
@property(nonatomic, strong) BDRecognizerViewController *recognizerViewController;
@property(nonatomic, assign) TBDVoiceRecognitionOfflineEngineType curOfflineEngineType;

@property(nonatomic, strong) NSTimer *longPressTimer;
@property(nonatomic, assign) BOOL longPressFlag;
@property(nonatomic, assign) BOOL touchUpFlag;

@property(nonatomic, assign) BOOL longSpeechFlag;

@property (nonatomic) NSInteger fileTestIndex; //文件测试序号
@property (nonatomic, strong) NSDate *firstPkgDate; //发送第一包的时间戳
@property (nonatomic, strong) NSDate *negativePkgDate; //发送负包的时间戳
@property (nonatomic) double allTimeInterval; //批量跑完文件的累计耗时
@property (nonatomic, copy) NSString *fileTestResult; //批量音频文件的识别结果

@end

@implementation ASRViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.asrEventManager = [BDSEventManager createEventManagerWithName:BDS_ASR_NAME];
    self.wakeupEventManager = [BDSEventManager createEventManagerWithName:BDS_WAKEUP_NAME];

    NSLog(@"Current SDK version: %@", [self.asrEventManager libver]);
    
    self.continueToVR = NO;
    [[BDVRSettings getInstance] configBDVRClient];
    [self configVoiceRecognitionClient];
    self.moreActionSheet = [[UIActionSheet alloc] initWithTitle:@"More Functions"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"文件识别", @"音频流识别", @"内置UI", @"开始唤醒", @"结束唤醒", @"唤醒+识别", @"加载离线引擎", @"卸载离线引擎", @"长语音", nil];
    
    _fileTestIndex = 0;
    _allTimeInterval = 0;
    _fileTestResult = @"";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.curOfflineEngineType = (TBDVoiceRecognitionOfflineEngineType)[[[BDVRSettings getInstance] getCurrentValueForKey:(NSString *)BDS_ASR_OFFLINE_ENGINE_TYPE] integerValue];
}

#pragma mark - UI Button

- (IBAction)dismissASR:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)finishButtonPressed:(id)sender
{
    self.finishButton.enabled = NO;
    [self.asrEventManager sendCommand:BDS_ASR_CMD_STOP];
}

- (IBAction)cancelButtonPressed:(id)sender
{
    self.finishButton.enabled = NO;
    self.cancelButton.enabled = NO;
    [self.asrEventManager sendCommand:BDS_ASR_CMD_CANCEL];
}

- (IBAction)voiceRecogButtonTouchDown:(id)sender {
    self.touchUpFlag = NO;
    self.longPressFlag = NO;
    self.longPressTimer = [NSTimer timerWithTimeInterval:0.5
                                                  target:self
                                                selector:@selector(longPressTimerTriggered) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:self.longPressTimer forMode:NSRunLoopCommonModes];
    
    [self cleanLogUI];
    [self.asrEventManager setParameter:@(NO) forKey:BDS_ASR_ENABLE_LONG_SPEECH];
    [self.asrEventManager setParameter:@(NO) forKey:BDS_ASR_NEED_CACHE_AUDIO];
    [self.asrEventManager setParameter:@"" forKey:BDS_ASR_OFFLINE_ENGINE_TRIGGERED_WAKEUP_WORD];
    [self voiceRecogButtonHelper];
}

- (void)longPressTimerTriggered
{
    if (!self.touchUpFlag) {
        self.longPressFlag = YES;
        [self.asrEventManager setParameter:@(YES) forKey:BDS_ASR_VAD_ENABLE_LONG_PRESS];
    }
    [self.longPressTimer invalidate];
}

- (IBAction)voiceRecogButtonTouchUp:(id)sender {
    self.touchUpFlag = YES;
    if (self.longPressFlag) {
        [self.asrEventManager sendCommand:BDS_ASR_CMD_STOP];
    }
}

- (IBAction)moreButtonPressed:(id)sender
{
    [self.moreActionSheet showInView:self.view];
}

- (void)fileRecognition
{
    _firstPkgDate = [NSDate date];
    _fileTestIndex++;
    [self cleanLogUI];
    NSString* testFile = [[NSBundle mainBundle] pathForResource:@"47a5aa4f-dfb5-42a5-9b2f-1d86db0b5332" ofType:@"pcm"];
    [self.asrEventManager setParameter:testFile forKey:BDS_ASR_AUDIO_FILE_PATH];
    [self.asrEventManager setDelegate:self];
    [self.asrEventManager sendCommand:BDS_ASR_CMD_START];
}

- (void)sdkUI
{
    [self cleanLogUI];
    [self.asrEventManager setParameter:@"" forKey:BDS_ASR_AUDIO_FILE_PATH];
    [self configFileHandler];
    [self configRecognizerViewController];
    [self.recognizerViewController startVoiceRecognition];
}

- (void)startWakeup
{
    [self cleanLogUI];
    [self configWakeupClient];
    [self.wakeupEventManager setParameter:nil forKey:BDS_WAKEUP_AUDIO_FILE_PATH];
    [self.wakeupEventManager setParameter:nil forKey:BDS_WAKEUP_AUDIO_INPUT_STREAM];
    [self.wakeupEventManager sendCommand:BDS_WP_CMD_LOAD_ENGINE];
    [self.wakeupEventManager sendCommand:BDS_WP_CMD_START];
}

- (void)stopWakeup
{
    [self.wakeupEventManager sendCommand:BDS_WP_CMD_STOP];
    [self.wakeupEventManager sendCommand:BDS_WP_CMD_UNLOAD_ENGINE];
}

- (void)loadOfflineEngine
{
    [self cleanLogUI];
    [self configOfflineClient];
    [self.asrEventManager sendCommand:BDS_ASR_CMD_LOAD_ENGINE];
}

- (void)unLoadOfflineEngine
{
    [self.asrEventManager sendCommand:BDS_ASR_CMD_UNLOAD_ENGINE];
}

- (void)audioStreamRecognition
{
    [self cleanLogUI];
    AudioInputStream *stream = [[AudioInputStream alloc] init];
    [self.asrEventManager setParameter:stream forKey:BDS_ASR_AUDIO_INPUT_STREAM];
    [self.asrEventManager setParameter:@"" forKey:BDS_ASR_AUDIO_FILE_PATH];
    [self.asrEventManager setDelegate:self];
    [self.asrEventManager sendCommand:BDS_ASR_CMD_START];
    [self onInitializing];
}

- (void)longSpeechRecognition
{
    [self cleanLogUI];
    self.longSpeechFlag = YES;
    [self.asrEventManager setParameter:@(NO) forKey:BDS_ASR_NEED_CACHE_AUDIO];
    [self.asrEventManager setParameter:@"" forKey:BDS_ASR_OFFLINE_ENGINE_TRIGGERED_WAKEUP_WORD];
    [self.asrEventManager setParameter:@(YES) forKey:BDS_ASR_ENABLE_LONG_SPEECH];
    // 长语音请务必开启本地VAD
    [self.asrEventManager setParameter:@(YES) forKey:BDS_ASR_ENABLE_LOCAL_VAD];
    [self voiceRecogButtonHelper];
}

#pragma mark - UI Button Helper

- (void)cleanLogUI
{
    self.resultTextView.text = @"";
    self.logTextView.text = @"";
}

- (void)onInitializing
{
    self.voiceRecogButton.enabled = NO;
    [self.voiceRecogButton setTitle:@"Initializing..." forState:UIControlStateNormal];
}

- (void)onStartWorking
{
    self.finishButton.enabled = YES;
    self.cancelButton.enabled = YES;
    [self.voiceRecogButton setTitle:@"Speaking..." forState:UIControlStateNormal];
}

- (void)onEnd
{
    self.longSpeechFlag = NO;
    self.finishButton.enabled = NO;
    self.cancelButton.enabled = NO;
    self.voiceRecogButton.enabled = YES;
    [self.voiceRecogButton setTitle:@"语音识别" forState:UIControlStateNormal];
}

- (void)voiceRecogButtonHelper
{
//    [self configFileHandler];
    [self.asrEventManager setDelegate:self];
    [self.asrEventManager setParameter:nil forKey:BDS_ASR_AUDIO_FILE_PATH];
    [self.asrEventManager setParameter:nil forKey:BDS_ASR_AUDIO_INPUT_STREAM];
    [self.asrEventManager sendCommand:BDS_ASR_CMD_START];
    [self onInitializing];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self fileRecognition];
            break;
        case 1:
            [self audioStreamRecognition];
            break;
        case 2:
            [self sdkUI];
            break;
        case 3:
            self.continueToVR = NO;
            [self startWakeup];
            break;
        case 4: {
            self.continueToVR = NO;
            [self stopWakeup];
        }
            break;
        case 5: {
            self.continueToVR = YES;
            [self startWakeup];
        }
            break;
        case 6: {
            [self loadOfflineEngine];
        }
            break;
        case 7: {
            [self unLoadOfflineEngine];
        }
            break;
        case 8: {
            [self longSpeechRecognition];
        }
            break;
        default:
            break;
    }
}

#pragma mark - MVoiceRecognitionClientDelegate

- (void)VoiceRecognitionClientWorkStatus:(int)workStatus obj:(id)aObj {
    switch (workStatus) {
        case EVoiceRecognitionClientWorkStatusNewRecordData: {
            [self.fileHandler writeData:(NSData *)aObj];
            break;
        }
            
        case EVoiceRecognitionClientWorkStatusStartWorkIng: {
            NSDictionary *logDic = [self parseLogToDic:aObj];
            [self printLogTextView:[NSString stringWithFormat:@"CALLBACK: start vr, log: %@\n", logDic]];
            [self onStartWorking];
            break;
        }
        case EVoiceRecognitionClientWorkStatusStart: {
            [self printLogTextView:@"CALLBACK: detect voice start point.\n"];
            break;
        }
        case EVoiceRecognitionClientWorkStatusEnd: {
            [self printLogTextView:@"CALLBACK: detect voice end point.\n"];
            _negativePkgDate = [NSDate date];
            break;
        }
        case EVoiceRecognitionClientWorkStatusFlushData: {
            [self printLogTextView:[NSString stringWithFormat:@"CALLBACK: partial result - %@.\n\n", [self getDescriptionForDic:aObj]]];
            break;
        }
        case EVoiceRecognitionClientWorkStatusFinish: {
            [self printLogTextView:[NSString stringWithFormat:@"CALLBACK: final result - %@.\n\n", [self getDescriptionForDic:aObj]]];
            if (aObj) {
                NSTimeInterval allPkgTimeInterval = [[NSDate date] timeIntervalSinceDate:self.firstPkgDate];
                _allTimeInterval += allPkgTimeInterval;
                NSTimeInterval negativePkgTimeInterval = [[NSDate date] timeIntervalSinceDate:self.negativePkgDate];
                static double allNegativePkgTimeInterval = 0;
                allNegativePkgTimeInterval += negativePkgTimeInterval;
                
                _fileTestResult = [[NSString stringWithFormat:@"序号%ld，耗时：%.3f, 最后一包耗时：%.3f，识别结果：%@，最后一包累计耗时：%.3f，累计耗时：%.3f \n\n", (long)_fileTestIndex, allPkgTimeInterval, negativePkgTimeInterval, aObj[@"results_recognition"][0], allNegativePkgTimeInterval, _allTimeInterval] stringByAppendingString:_fileTestResult];
                _resultTextView.text = _fileTestResult;
                NSLog(@"文件批量测试结果：%@", _resultTextView.text);
                
                if (_fileTestIndex < maxFileTestNum) {
                    [self performSelector:@selector(fileRecognition) withObject:nil afterDelay:0.3];  // 延迟0.3秒，以便识别工作正常结束
                }
//                self.resultTextView.text = [self getDescriptionForDic:aObj];
            }
            if (!self.longSpeechFlag) {
                [self onEnd];
            }
            break;
        }
        case EVoiceRecognitionClientWorkStatusMeterLevel: {
            break;
        }
        case EVoiceRecognitionClientWorkStatusCancel: {
            [self printLogTextView:@"CALLBACK: user press cancel.\n"];
            [self onEnd];
            break;
        }
        case EVoiceRecognitionClientWorkStatusError: {
            [self printLogTextView:[NSString stringWithFormat:@"CALLBACK: encount error - %@.\n", (NSError *)aObj]];
            [self onEnd];
            break;
        }
        case EVoiceRecognitionClientWorkStatusLoaded: {
            [self printLogTextView:@"CALLBACK: offline engine loaded.\n"];
            break;
        }
        case EVoiceRecognitionClientWorkStatusUnLoaded: {
            [self printLogTextView:@"CALLBACK: offline engine unLoaded.\n"];
            break;
        }
        case EVoiceRecognitionClientWorkStatusChunkThirdData: {
            [self printLogTextView:[NSString stringWithFormat:@"CALLBACK: Chunk 3-party data length: %lu\n", (unsigned long)[(NSData *)aObj length]]];
            break;
        }
        case EVoiceRecognitionClientWorkStatusChunkNlu: {
            NSString *nlu = [[NSString alloc] initWithData:(NSData *)aObj encoding:NSUTF8StringEncoding];
            [self printLogTextView:[NSString stringWithFormat:@"CALLBACK: Chunk NLU data: %@\n", nlu]];
            break;
        }
        case EVoiceRecognitionClientWorkStatusChunkEnd: {
            [self printLogTextView:[NSString stringWithFormat:@"CALLBACK: Chunk end, sn: %@.\n", aObj]];
            if (!self.longSpeechFlag) {
                [self onEnd];
            }
            break;
        }
        case EVoiceRecognitionClientWorkStatusFeedback: {
            NSDictionary *logDic = [self parseLogToDic:aObj];
            [self printLogTextView:[NSString stringWithFormat:@"CALLBACK Feedback: %@\n", logDic]];
            break;
        }
        case EVoiceRecognitionClientWorkStatusRecorderEnd: {
            [self printLogTextView:@"CALLBACK: recorder closed.\n"];
            break;
        }
        case EVoiceRecognitionClientWorkStatusLongSpeechEnd: {
            [self printLogTextView:@"CALLBACK: Long Speech end.\n"];
            [self onEnd];
            break;
        }
        default:
            break;
    }
}

- (void)WakeupClientWorkStatus:(int)workStatus obj:(id)aObj
{
    switch (workStatus) {
        case EWakeupEngineWorkStatusStarted: {
            [self printLogTextView:@"WAKEUP CALLBACK: Started.\n"];
            break;
        }
        case EWakeupEngineWorkStatusStopped: {
            [self printLogTextView:@"WAKEUP CALLBACK: Stopped.\n"];
            break;
        }
        case EWakeupEngineWorkStatusLoaded: {
            [self printLogTextView:@"WAKEUP CALLBACK: Loaded.\n"];
            break;
        }
        case EWakeupEngineWorkStatusUnLoaded: {
            [self printLogTextView:@"WAKEUP CALLBACK: UnLoaded.\n"];
            break;
        }
        case EWakeupEngineWorkStatusTriggered: {
            [self printLogTextView:[NSString stringWithFormat:@"WAKEUP CALLBACK: Triggered - %@.\n", (NSString *)aObj]];
            if (self.continueToVR) {
                self.continueToVR = NO;
                [self.asrEventManager setParameter:@(YES) forKey:BDS_ASR_NEED_CACHE_AUDIO];
                [self.asrEventManager setParameter:aObj forKey:BDS_ASR_OFFLINE_ENGINE_TRIGGERED_WAKEUP_WORD];
                [self voiceRecogButtonHelper];
            }
            break;
        }
        case EWakeupEngineWorkStatusError: {
            [self printLogTextView:[NSString stringWithFormat:@"WAKEUP CALLBACK: encount error - %@.\n", (NSError *)aObj]];
            break;
        }
            
        default:
            break;
    }
}

- (void)printLogTextView:(NSString *)logString
{
    self.logTextView.text = [logString stringByAppendingString:_logTextView.text];
    [self.logTextView scrollRangeToVisible:NSMakeRange(0, 0)];
}

- (NSDictionary *)parseLogToDic:(NSString *)logString
{
    NSArray *tmp = NULL;
    NSMutableDictionary *logDic = [[NSMutableDictionary alloc] initWithCapacity:3];
    NSArray *items = [logString componentsSeparatedByString:@"&"];
    for (NSString *item in items) {
        tmp = [item componentsSeparatedByString:@"="];
        if (tmp.count == 2) {
            [logDic setObject:tmp.lastObject forKey:tmp.firstObject];
        }
    }
    return logDic;
}

#pragma mark - BDRecognizerViewDelegate

- (void)onRecordDataArrived:(NSData *)recordData sampleRate:(int)sampleRate
{
    [self.fileHandler writeData:(NSData *)recordData];
}

- (void)onEndWithViews:(BDRecognizerViewController *)aBDRecognizerViewController withResult:(id)aResult
{
    if (aResult) {
        self.resultTextView.text = [self getDescriptionForDic:aResult];
    }
    [self.asrEventManager setDelegate:self];
}

#pragma mark - Private: Configuration

- (void)configVoiceRecognitionClient {
    //设置DEBUG_LOG的级别
    [self.asrEventManager setParameter:@(EVRDebugLogLevelTrace) forKey:BDS_ASR_DEBUG_LOG_LEVEL];
    //配置API_KEY 和 SECRET_KEY 和 APP_ID
    [self.asrEventManager setParameter:@[API_KEY, SECRET_KEY] forKey:BDS_ASR_API_SECRET_KEYS];
    [self.asrEventManager setParameter:APP_ID forKey:BDS_ASR_OFFLINE_APP_CODE];
    //配置端点检测（二选一）
    [self configModelVAD];
//    [self configDNNMFE];
    
//     [self.asrEventManager setParameter:@"15361" forKey:BDS_ASR_PRODUCT_ID];
    // ---- 语义与标点 -----
//    [self enableNLU];
//    [self enablePunctuation];
    // ------------------------
}


- (void) enableNLU {
    // ---- 开启语义理解 -----
    [self.asrEventManager setParameter:@(YES) forKey:BDS_ASR_ENABLE_NLU];
    [self.asrEventManager setParameter:@"15361" forKey:BDS_ASR_PRODUCT_ID];
}

- (void) enablePunctuation {
    // ---- 开启标点输出 -----
    [self.asrEventManager setParameter:@(NO) forKey:BDS_ASR_DISABLE_PUNCTUATION];
    // 普通话标点
//    [self.asrEventManager setParameter:@"1537" forKey:BDS_ASR_PRODUCT_ID];
    // 英文标点
    [self.asrEventManager setParameter:@"1737" forKey:BDS_ASR_PRODUCT_ID];

}


- (void)configModelVAD {
    NSString *modelVAD_filepath = [[NSBundle mainBundle] pathForResource:@"bds_easr_basic_model" ofType:@"dat"];
    [self.asrEventManager setParameter:modelVAD_filepath forKey:BDS_ASR_MODEL_VAD_DAT_FILE];
    [self.asrEventManager setParameter:@(YES) forKey:BDS_ASR_ENABLE_MODEL_VAD];
}

- (void)configDNNMFE {
    NSString *mfe_dnn_filepath = [[NSBundle mainBundle] pathForResource:@"bds_easr_mfe_dnn" ofType:@"dat"];
    [self.asrEventManager setParameter:mfe_dnn_filepath forKey:BDS_ASR_MFE_DNN_DAT_FILE];
    NSString *cmvn_dnn_filepath = [[NSBundle mainBundle] pathForResource:@"bds_easr_mfe_cmvn" ofType:@"dat"];
    [self.asrEventManager setParameter:cmvn_dnn_filepath forKey:BDS_ASR_MFE_CMVN_DAT_FILE];
    // 自定义静音时长
//    [self.asrEventManager setParameter:@(501) forKey:BDS_ASR_MFE_MAX_SPEECH_PAUSE];
//    [self.asrEventManager setParameter:@(500) forKey:BDS_ASR_MFE_MAX_WAIT_DURATION];
}

- (void)configWakeupClient {
    
    [self.wakeupEventManager setDelegate:self];
    [self.wakeupEventManager setParameter:APP_ID forKey:BDS_WAKEUP_APP_CODE];
    
    [self configWakeupSettings];
}

- (void)configWakeupSettings {
    NSString* dat = [[NSBundle mainBundle] pathForResource:@"bds_easr_basic_model" ofType:@"dat"];

    // 默认的唤醒词为"百度一下"，如需自定义唤醒词，请在 http://ai.baidu.com/tech/speech/wake 中评估并下载唤醒词，替换此参数
    NSString* words = [[NSBundle mainBundle] pathForResource:@"bds_easr_wakeup_words" ofType:@"dat"];
    [self.wakeupEventManager setParameter:dat forKey:BDS_WAKEUP_DAT_FILE_PATH];
    [self.wakeupEventManager setParameter:words forKey:BDS_WAKEUP_WORDS_FILE_PATH];
}

- (void)configOfflineClient {

    // 离线可识别自定义语法规则下的词，
    NSString* gramm_filepath = [[NSBundle mainBundle] pathForResource:@"bds_easr_gramm" ofType:@"dat"];;
    NSString* lm_filepath = [[NSBundle mainBundle] pathForResource:@"bds_easr_basic_model" ofType:@"dat"];;
    NSString* wakeup_words_filepath = [[NSBundle mainBundle] pathForResource:@"bds_easr_wakeup_words" ofType:@"dat"];;
    [self.asrEventManager setDelegate:self];
    [self.asrEventManager setParameter:APP_ID forKey:BDS_ASR_OFFLINE_APP_CODE];
    [self.asrEventManager setParameter:lm_filepath forKey:BDS_ASR_OFFLINE_ENGINE_DAT_FILE_PATH];
    // 请在 (官网)[http://speech.baidu.com/asr] 参考模板定义语法，下载语法文件后，替换BDS_ASR_OFFLINE_ENGINE_GRAMMER_FILE_PATH参数
    [self.asrEventManager setParameter:gramm_filepath forKey:BDS_ASR_OFFLINE_ENGINE_GRAMMER_FILE_PATH];
    [self.asrEventManager setParameter:wakeup_words_filepath forKey:BDS_ASR_OFFLINE_ENGINE_WAKEUP_WORDS_FILE_PATH];
    
}

- (void)configRecognizerViewController {
    BDRecognizerViewParamsObject *paramsObject = [[BDRecognizerViewParamsObject alloc] init];
    paramsObject.isShowTipAfterSilence = YES;
    paramsObject.isShowHelpButtonWhenSilence = NO;
    paramsObject.tipsTitle = @"您可以这样问";
    paramsObject.tipsList = [NSArray arrayWithObjects:@"我要吃饭", @"我要买电影票", @"我要订酒店", nil];
    paramsObject.waitTime2ShowTip = 0.5;
    paramsObject.isHidePleaseSpeakSection = YES;
    paramsObject.disableCarousel = YES;
    self.recognizerViewController = [[BDRecognizerViewController alloc] initRecognizerViewControllerWithOrigin:CGPointMake(9, 80)
                                                                                                         theme:nil
                                                                                              enableFullScreen:YES
                                                                                                  paramsObject:paramsObject
                                                                                                      delegate:self];
}

- (void)configFileHandler {
    self.fileHandler = [self createFileHandleWithName:@"recoder.pcm" isAppend:NO];
}

#pragma mark - Private: File

- (NSString *)getFilePath:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if (paths && [paths count]) {
        return [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
    } else {
        return nil;
    }
}

- (NSFileHandle *)createFileHandleWithName:(NSString *)aFileName isAppend:(BOOL)isAppend {
    NSFileHandle *fileHandle = nil;
    NSString *fileName = [self getFilePath:aFileName];
    
    int fd = -1;
    if (fileName) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:fileName]&& !isAppend) {
            [[NSFileManager defaultManager] removeItemAtPath:fileName error:nil];
        }
        
        int flags = O_WRONLY | O_APPEND | O_CREAT;
        fd = open([fileName fileSystemRepresentation], flags, 0644);
    }
    
    if (fd != -1) {
        fileHandle = [[NSFileHandle alloc] initWithFileDescriptor:fd closeOnDealloc:YES];
    }
    
    return fileHandle;
}

- (NSString *)getDescriptionForDic:(NSDictionary *)dic {
    if (dic) {
        return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dic
                                                                              options:NSJSONWritingPrettyPrinted
                                                                                error:nil] encoding:NSUTF8StringEncoding];
    }
    return nil;
}

@end
