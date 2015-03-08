//
//  J1MasterViewController.h
//  J1Memo
//
//  Created by OKU Junichirou on 11/09/11.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Group.h"

@class EditViewController;

@interface J1MasterViewController : UIViewController
    <UITableViewDelegate, UITableViewDataSource,
    NSFetchedResultsControllerDelegate>
{
    // User interface
    IBOutlet UITableView			*tableView_;
    UIBarButtonItem                 *composeButton_;
}

@property (strong, nonatomic) EditViewController *detailViewController;

@property (nonatomic, strong) NSFetchedResultsController    *fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext        *managedObjectContext;

- (void)compose:(id)sender;



//@property (nonatomic) BOOL useiCloud;
//@property (strong, nonatomic) NSMutableArray *documentURLs;
//@property (strong, nonatomic) NSMetadataQuery *query;

// - (IBAction)addDocument:(id)sender;

@end
