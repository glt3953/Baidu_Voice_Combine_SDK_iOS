//
//  SelectionTableViewCell.h
//  TTSDemo
//
//  Created by lappi on 3/16/16.
//  Copyright © 2016 baidu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SelectionTableViewCell;
@interface selectionCellContext : NSObject
-(instancetype)initWithName:(NSString*)name;
@property(nonatomic,strong)NSString* itemName;
@property(nonatomic,weak)SelectionTableViewCell* ContextUI;
@property(nonatomic)BOOL isSelected;
-(void)setSelectionState:(BOOL)isSelected;
@end

@interface SelectionTableViewCell : UITableViewCell
@property (nonatomic,weak) selectionCellContext* cellContext;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UIView *SelectionStateView;
-(void)setContext:(selectionCellContext*)ctx;
@end
