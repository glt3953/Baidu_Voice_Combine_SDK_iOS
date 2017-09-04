//
//  InputTableViewCell.m
//  TTSDemo
//
//  Created by lappi on 3/16/16.
//  Copyright © 2016 baidu. All rights reserved.
//

#import "InputTableViewCell.h"

@implementation InputTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (IBAction)FinishTapped:(id)sender
{
    [self.valueField resignFirstResponder];
    if(self.delegate){
        [self.delegate InputCellChangedValue:self.valueField.text forProperty:self.PROPERTY_ID];
    }
}
@end
