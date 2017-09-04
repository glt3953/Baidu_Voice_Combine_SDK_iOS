//
//  SelectionTableViewController.m
//  TTSDemo
//
//  Created by lappi on 3/16/16.
//  Copyright © 2016 baidu. All rights reserved.
//

#import "SelectionTableViewController.h"
#import "SelectionTableViewCell.h"

@interface SelectionTableViewController ()
@property (nonatomic,strong)NSMutableArray* cellContextList;
@end

@implementation SelectionTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.cellContextList = [[NSMutableArray alloc] init];
    for (NSString *name in self.selectableItemNames) {
        [self.cellContextList addObject:[[selectionCellContext alloc] initWithName:name]];
    }
    for(NSNumber* n in self.selectedItems)
    {
        ((selectionCellContext*)[self.cellContextList objectAtIndex:[n integerValue]]).isSelected = YES;
    }
    [self.tableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.selectableItemNames == nil)
        return 0;
    return self.selectableItemNames.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SelectionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SELECTION_TABLEVIEW_CELL" forIndexPath:indexPath];
    
    // Configure the cell...
    [cell setContext:[self.cellContextList objectAtIndex:indexPath.row]];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectionCellContext* ctx = (selectionCellContext*)[self.cellContextList objectAtIndex:indexPath.row];
    [ctx setSelectionState:!ctx.isSelected];
    if(ctx.isSelected){
        // select
        [self.selectedItems addObject:[NSNumber numberWithInteger:indexPath.row]];
        if(!self.isMultiSelect && self.selectedItems.count > 1){
            int previousSelectedIndex = [[self.selectedItems objectAtIndex:0] intValue];
            ctx = (selectionCellContext*)[self.cellContextList objectAtIndex:previousSelectedIndex];
            [ctx setSelectionState:NO];
            [self.selectedItems removeObjectAtIndex:0];
        }
    }
    else{
        // deselect
        if(!self.allowNoneSelected && self.selectedItems.count == 1){
            [ctx setSelectionState:!ctx.isSelected];    // ignore
            return NO;
        }
        for(NSNumber* item in self.selectedItems){
            if([item integerValue] == indexPath.row){
                [self.selectedItems removeObject:item];
                break;
            }
        }
    }
    return NO;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
