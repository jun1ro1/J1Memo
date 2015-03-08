//
//  RootViewController.h
//  J1Memo
//
//  Created by OKU Junichirou on 11/05/04.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Group.h"

@interface RootViewController : UIViewController 
    <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate> {

    // User interface
    IBOutlet UITableView			*tableView_;
    UIBarButtonItem                 *composeButton_;

    NSFetchedResultsController      *__fetchedResultsController;
    NSManagedObjectContext          *__managedObjectContext;
}

@property (nonatomic, strong) NSFetchedResultsController    *fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext        *managedObjectContext;

- (void)compose:(id)sender;

@end
