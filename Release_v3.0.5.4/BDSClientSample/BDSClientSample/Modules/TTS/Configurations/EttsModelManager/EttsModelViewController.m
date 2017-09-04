//
//  EttsModelViewController.m
//  TTSDemo
//
//  Created by lappi on 7/28/16.
//  Copyright © 2016 baidu. All rights reserved.
//

#import "EttsModelViewController.h"
#import "EttsModelTableViewCell.h"
#import "TTSConfigViewController.h"
#import "BDSSpeechSynthesizer.h"

@interface EttsModelViewController ()
@end

@implementation EttsModelViewController



-(void)loadAudioModelWithName:(NSString*)modelName
                modelLanguage:(NSString*)language
                modelTextData:(NSString*)textDataFile
              modelSpeechData:(NSString*)speechDataFile{
    
}

-(void)modelDownloadSucceeded{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
        // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    
}
-(void)viewWillDisappear:(BOOL)animated{
    self.viewIsValid = NO;
}

-(void)fetchManagerLocalModels{

    
}
-(void)fetchManagerRemoteModels{
   
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
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
