//
//  PropertyViewController.h
//  J1Memo
//
//  Created by 奥 潤一郎 on 11/07/24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"
#import "Memo.h"

@interface PropertyViewController : UIViewController
<UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>
{
    
    Memo __weak                     *editingMemo;
    
    // User Interface
    IBOutlet	UITableViewCell     *IDCell_;
    IBOutlet	UILabel             *IDLabel_;
    
//    IBOutlet	UITableViewCell     *createdDateCell_;
    IBOutlet	UILabel             *createdDateLabel_;
    
    IBOutlet	UITableViewCell     *modifiedDateCell_;
    IBOutlet	UILabel             *modifiedDateLabel_;
    
    IBOutlet	UIBarButtonItem     *doneButton_;
    IBOutlet	UITableView         *tableView_;
    
    IBOutlet	UITableViewCell     *secretCell_;

@private
    Group __weak                    *newGroup_;
    
    // CoreData interface
    NSFetchedResultsController      *fetchedResultsController_;    
}

// Property
@property (nonatomic, weak) Memo  *editingMemo;
@property (nonatomic, weak) Group *theNewGroup;
@property (nonatomic, strong) NSFetchedResultsController	*fetchedResultsController;

@property (nonatomic, strong) IBOutlet UITableViewCell *createdDateCell;

@property (nonatomic, weak) UIPopoverController *parentPopover;

// User interface
- (IBAction)done:(id)sender;


@end
