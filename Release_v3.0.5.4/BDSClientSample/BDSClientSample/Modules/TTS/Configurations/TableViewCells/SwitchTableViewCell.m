//
//  SwitchTableViewCell.m
//  TTSDemo
//
//  Created by lappi on 3/16/16.
//  Copyright © 2016 baidu. All rights reserved.
//

#import "SwitchTableViewCell.h"

@implementation SwitchTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    [self.stateSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
}

-(void)switchChanged:(id)from{
    if(self.delegate){
        [self.delegate switchStateChanged:[self.stateSwitch isOn] forPropertyID:self.PROPERTY_ID];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
