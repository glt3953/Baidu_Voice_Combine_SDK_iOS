//
//  SwitchTableViewCell.h
//  TTSDemo
//
//  Created by lappi on 3/16/16.
//  Copyright © 2016 baidu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SwitchTableViewCellDelegate <NSObject>

-(void)switchStateChanged:(BOOL)newState forPropertyID:(NSString*)propertyID;

@end

@interface SwitchTableViewCell : UITableViewCell
@property (nonatomic,weak) id<SwitchTableViewCellDelegate> delegate;
@property (nonatomic, copy) NSString *PROPERTY_ID;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UISwitch *stateSwitch;
@end
