//
//  EttsModelViewController.h
//  TTSDemo
//
//  Created by lappi on 7/28/16.
//  Copyright © 2016 baidu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BDS_EttsModelManagerInterface.h"
#import "BDSEventManager.h"
@class TTSConfigViewController;
@interface EttsModelViewController : UITableViewController<EttsModelDownloaderDelegate>
@property(nonatomic,weak)TTSConfigViewController* parent;
@property(nonatomic)BOOL viewIsValid;
@property(nonatomic,strong)BDSEventManager* modelManager;
-(void)loadAudioModelWithName:(NSString*)modelName
                modelLanguage:(NSString*)language
                modelTextData:(NSString*)textDataFile
              modelSpeechData:(NSString*)speechDataFile;
-(void)modelDownloadSucceeded;
@end
