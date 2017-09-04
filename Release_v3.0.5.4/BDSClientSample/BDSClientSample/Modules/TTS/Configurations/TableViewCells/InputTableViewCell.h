//
//  InputTableViewCell.h
//  TTSDemo
//
//  Created by lappi on 3/16/16.
//  Copyright © 2016 baidu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InputTableViewCellDelegate <NSObject>

-(void)InputCellChangedValue:(NSString*)newValue forProperty:(NSString*)propertyID;

@end

@interface InputTableViewCell : UITableViewCell
@property (nonatomic,weak)id<InputTableViewCellDelegate>delegate;
@property (nonatomic,copy)NSString *PROPERTY_ID;
@property (nonatomic, strong) IBOutlet UITextField *valueField;
@property (nonatomic, strong) IBOutlet UIButton *FinishButton;
- (IBAction)FinishTapped:(id)sender;
@end
