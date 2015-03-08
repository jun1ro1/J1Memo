//
//  GroupEditViewController.m
//  J1Memo
//
//  Created by 奥 潤一郎 on 11/07/13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GroupEditViewController.h"
#import "J1CoreDataManager.h"

@implementation GroupEditViewController

#pragma mark - property
@synthesize editingGroup;
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext     = __managedObjectContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	myTableView.delegate	= self;
	myTableView.dataSource	= self;
	myNameText.delegate		= self;
	
    self.managedObjectContext = [[J1CoreDataManager sharedManager] managedObjectContext];
    
//    [self.managedObjectContext performBlockAndWait:^{
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
//    }];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.title		= editingGroup.name;
	myNameText.text = editingGroup.name;
	[myNameText becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"%@.%s", [self class], sel_getName(_cmd));
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    NSLog(@"%@.%s", [self class], sel_getName(_cmd));

	editingGroup.name = myNameText.text;
    [[J1CoreDataManager sharedManager] saveContext];

//	NSError *error = nil;
//	if (![self.managedObjectContext save:&error]) {
//		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//		abort();
//	}
//	

	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	return 2;
	;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	NSInteger	rows = 0;
	
	switch (section) {
		case 0:
			rows = 1;
			break;
		case 1:
			rows = 2;
			break;
		default:
			break;
	}
	
    return rows;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *cell = nil;
	
	if (indexPath.section == 0) {
		cell = myNameCell;
	}
	else if (indexPath.section == 1) {
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
		switch (indexPath.row) {
			case 0:
				cell = myCreatedDateCell;
				myCreatedDateLabel.text = [formatter stringFromDate:self.editingGroup.createdAt];
				break;
			case 1:
				cell = myModifiedDateCell;
				myModifiedDateLabel.text = [formatter stringFromDate:self.editingGroup.modifiedAt];
				break;
			default:
				break;
		}
	}
	
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	// Return NO if you do not want the specified item to be editable.
	return NO;
}

#pragma mark -
#pragma mark UITextFieldDelegate method

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == myNameText) {
        [myNameText resignFirstResponder];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	if (textField == myNameText) {
		[self.navigationController popViewControllerAnimated:YES];
		
	}
}


#pragma mark -
#pragma mark Bar Button method

- (void)done:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
    /*
	 Set up the fetched results controller.
	 */
	
	// Clear cache.
	[NSFetchedResultsController deleteCacheWithName:@"GroupEditView"];
	
	// Create the fetch request for the entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	// Edit the entity name as appropriate.
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Set the batch size to a suitable number.
	[fetchRequest setFetchBatchSize:20];
	
	// Edit the sort key as appropriate.
	NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"type" ascending:YES];
	NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor1, sortDescriptor2, nil];
	
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	// Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
	NSFetchedResultsController *aFetchedResultsController = 
	[[NSFetchedResultsController alloc] 
	 initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"GroupEditView"];
    
    aFetchedResultsController.delegate = self;

	self.fetchedResultsController = aFetchedResultsController;

	return __fetchedResultsController;
}    


// NSFetchedResultsControllerDelegate method to notify the delegate that all section and object changes have been processed.

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	// In the simplest, most efficient, case, reload the table view.
	[myTableView reloadData];
}


@end
