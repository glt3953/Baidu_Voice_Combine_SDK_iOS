//
//  SelectionTableViewCell.m
//  TTSDemo
//
//  Created by lappi on 3/16/16.
//  Copyright © 2016 baidu. All rights reserved.
//

#import "SelectionTableViewCell.h"

@implementation selectionCellContext

-(instancetype)initWithName:(NSString*)name{
    self = [super init];
    if(self){
        self.isSelected = NO;
        self.itemName = name;
    }
    return self;
}

-(void)setSelectionState:(BOOL)isSelected{
    self.isSelected = isSelected;
    if(self.ContextUI){
        [self.ContextUI.SelectionStateView setHidden:!isSelected];
    }
}

@end

@implementation SelectionTableViewCell

-(void)setContext:(selectionCellContext*)ctx{
    if(self.cellContext && self.cellContext.ContextUI == self){
        self.cellContext.ContextUI = nil;
    }
    self.cellContext = ctx;
    if(self.cellContext){
        self.cellContext.ContextUI = self;
        [self.nameLabel setText:self.cellContext.itemName];
        [self.SelectionStateView setHidden:!self.cellContext.isSelected];
    }
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    self.SelectionStateView.layer.cornerRadius = 10;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
