//
//  SelectionTableViewController.h
//  TTSDemo
//
//  Created by lappi on 3/16/16.
//  Copyright © 2016 baidu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectionTableViewController : UITableViewController
@property(nonatomic)BOOL isMultiSelect;
@property(nonatomic,strong)NSArray* selectableItemNames;
@property(nonatomic,strong)NSMutableArray* selectedItems;
@property(nonatomic)BOOL allowNoneSelected;
@end
