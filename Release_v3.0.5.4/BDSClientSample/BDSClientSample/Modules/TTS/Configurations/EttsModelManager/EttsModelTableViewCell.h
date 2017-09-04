//
//  EttsModelTableViewCell.h
//  TTSDemo
//
//  Created by lappi on 7/28/16.
//  Copyright © 2016 baidu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BDS_EttsModelManagerInterface.h"
#import "BDSEventManager.h"

typedef enum AudioModelStatus{
    AudioModelStatus_notReady = 0,
    AudioModelStatus_queing,
    AudioModelStatus_queued,
    AudioModelStatus_downloading,
    AudioModelStatus_downloadError,
    AudioModelStatus_usable
}AudioModelStatus;

@class EttsModelViewController;
@class EttsModelTableViewCell;
@interface AudioModel : NSObject<EttsModelDownloaderDelegate>
@property(nonatomic,strong)NSString* modelName;
@property(nonatomic,strong)NSString* modelTextDataPath;
@property(nonatomic,strong)NSString* modelSpeechDataPath;
@property(nonatomic,strong)NSString* modelLanguage;
@property(nonatomic)NSInteger modelDownloaded;
@property(nonatomic)NSInteger modelSize;
@property(nonatomic,weak)EttsModelTableViewCell *modelUI;
@property(nonatomic,strong)NSString* modelID;
@property(nonatomic,strong)NSString* modelDownloadHandle;
@property(nonatomic)AudioModelStatus status;
@property(nonatomic,strong)BDSEventManager* modelManager;
@property(nonatomic,weak)EttsModelViewController* delegate;
-(void)actionButtonTapped;
-(void)stopDownload;
@end

@interface EttsModelTableViewCell : UITableViewCell
- (IBAction)ActionButtonTap:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *ActionButton;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *DetailLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *DownloadProgress;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *DownloadWait;
@property (weak, nonatomic) IBOutlet UILabel *ModelNameLabel;
@property (strong, nonatomic) AudioModel* backend;
-(void)setModelBackend:(AudioModel *)backend;
-(void)backendUpdated;
@end
