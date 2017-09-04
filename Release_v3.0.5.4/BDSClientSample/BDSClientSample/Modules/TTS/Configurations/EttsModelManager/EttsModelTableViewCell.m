//
//  EttsModelTableViewCell.m
//  TTSDemo
//
//  Created by lappi on 7/28/16.
//  Copyright © 2016 baidu. All rights reserved.
//

#import "EttsModelTableViewCell.h"
#import "EttsModelViewController.h"
@implementation AudioModel

-(instancetype)init{
    self = [super init];
    return self;
}

-(void)actionButtonTapped{
   
}

-(void)stopDownload{
   
}

#pragma mark - EttsModelDownloaderDelegate
-(void)modelDownloadQueuedForHandle:(NSString*)downloadHandle
                         forModelID:(NSString*)modelID
                         userParams:(NSDictionary*)params
                              error:(NSError*)err{
    
}

-(void)modelDownloadStartedForHandle:(NSString*)downloadHandle{
   
}

-(void)modelDownloadProgressForHandle:(NSString*)downloadHandle
                           totalBytes:(NSInteger)total
                      downloadedBytes:(NSInteger)downloaded{
    
}

-(void)modelFinishedForHandle:(NSString*)downloadHandle
                    withError:(NSError*)err{
   
}

-(void)gotRemoteModels:(NSArray*)models error:(NSError*)err{
    
}

-(void)gotDefaultModels:(NSArray*)models error:(NSError*)err{
    
}

-(void)gotLocalModels:(NSArray*)models error:(NSError*)err{
    
}

@end

@implementation EttsModelTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)ActionButtonTap:(id)sender {
    [self.backend actionButtonTapped];
}

-(void)setModelBackend:(AudioModel *)backend{
    
}

-(void)backendUpdated{
    
}
@end
