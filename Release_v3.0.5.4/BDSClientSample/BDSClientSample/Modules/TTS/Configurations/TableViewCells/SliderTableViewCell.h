//
//  SliderTableViewCell.h
//  TTSDemo
//
//  Created by lappi on 3/16/16.
//  Copyright © 2016 baidu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SliderTableViewCell;

@protocol SliderTableViewCellDelegate <NSObject>

-(void)sliderValueChanged:(float)newValue forProperty:(NSString*)propertyID fromSlider:(SliderTableViewCell*)src;

@end

@interface SliderTableViewCell : UITableViewCell
@property (nonatomic)BOOL isContinuous; // continuous stepping or
@property (nonatomic,weak) id<SliderTableViewCellDelegate>delegate;
@property (nonatomic,copy)NSString *PROPERTY_ID;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *currentValueLabel;
@property (nonatomic, strong) IBOutlet UISlider *valueSlider;
@end
