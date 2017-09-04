//
//  ViewController.h
//  SpeechSDKDemo
//
//  Created by lappi on 6/14/16.
//  Copyright © 2016 baidu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *DemoSelectionTableView;

@end

