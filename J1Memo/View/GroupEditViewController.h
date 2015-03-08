//
//  GroupEditViewController.h
//  J1Memo
//
//  Created by 奥 潤一郎 on 11/07/13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Group.h"

@interface GroupEditViewController : UIViewController
    <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, NSFetchedResultsControllerDelegate>
{

	// User Interface
	IBOutlet	UITableViewCell *myNameCell;
	IBOutlet	UITextField		*myNameText;
	
	IBOutlet	UITableViewCell *myCreatedDateCell;
	IBOutlet	UILabel			*myCreatedDateLabel;
	
	IBOutlet	UITableViewCell *myModifiedDateCell;
	IBOutlet	UILabel			*myModifiedDateLabel;
	
	IBOutlet	UIBarButtonItem	*myDoneButton;
	IBOutlet	UITableView		*myTableView;
	
	// CoreData interface
	Group  __weak          *editingGroup;

@private
	NSFetchedResultsController  *__fetchedResultsController;
	NSManagedObjectContext		*__managedObjectContext;
}

@property (nonatomic,weak)   Group                 *editingGroup;

@property (nonatomic,strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic,strong) NSManagedObjectContext     *managedObjectContext;

@end
