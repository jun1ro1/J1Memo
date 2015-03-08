//
//  OrganizeViewController.h
//  J1Memo
//
//  Created by 奥 潤一郎 on 11/07/26.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"

@interface OrganizeViewController : UIViewController
<UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>

{
    Group   __weak              *selectedGroup_;
    NSArray                     *selectedObjects_;
    
    // User interface
    IBOutlet UITableView        *tableView_;
    IBOutlet UIBarButtonItem    *doneButton_;
   
@private
    Group   __weak              *newGroup_;
    NSFetchedResultsController  *fetchedResultsController_;

}

@property (nonatomic, strong) NSArray *selectedObjects;
@property (nonatomic, weak)   Group   *selectedGroup;
@property (nonatomic, weak)   Group   *theNewGroup;
@property (nonatomic, strong) NSFetchedResultsController    *fetchedResultsController;

// User interface
- (IBAction)done:(id)sender;

@end
