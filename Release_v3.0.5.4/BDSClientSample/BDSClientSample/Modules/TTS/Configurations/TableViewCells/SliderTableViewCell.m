//
//  SliderTableViewCell.m
//  TTSDemo
//
//  Created by lappi on 3/16/16.
//  Copyright © 2016 baidu. All rights reserved.
//
#include <math.h>
#import "SliderTableViewCell.h"

@implementation SliderTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    self.isContinuous = YES;
    [self.valueSlider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    [self.valueSlider addTarget:self action:@selector(sliderEditEnded:) forControlEvents:UIControlEventTouchUpInside];
    [self.valueSlider addTarget:self action:@selector(sliderEditEnded:) forControlEvents:UIControlEventTouchUpOutside];
}

-(void)sliderChanged:(id)fromSlider{
    if(!self.isContinuous){
        int value = round(self.valueSlider.value);
        [self.valueSlider setValue:(float)value];
        [self.currentValueLabel setText:[NSString stringWithFormat:@"%d", value]];
    }else{
        [self.currentValueLabel setText:[NSString stringWithFormat:@"%.2f", self.valueSlider.value]];
    }
}

-(void)sliderEditEnded:(id)fromSlider{
    if(!self.isContinuous){
        int value = round(self.valueSlider.value);
        [self.valueSlider setValue:(float)value];
        [self.currentValueLabel setText:[NSString stringWithFormat:@"%d", value]];
        if(self.delegate){
            [self.delegate sliderValueChanged:(float)value forProperty:self.PROPERTY_ID fromSlider:self];
        }
    }else{
        [self.currentValueLabel setText:[NSString stringWithFormat:@"%.2f", self.valueSlider.value]];
        if(self.delegate){
            [self.delegate sliderValueChanged:self.valueSlider.value forProperty:self.PROPERTY_ID fromSlider:self];
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
