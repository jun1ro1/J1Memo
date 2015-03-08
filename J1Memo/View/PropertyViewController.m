//
//  PropertyViewController.m
//  J1Memo
//
//  Created by 奥 潤一郎 on 11/07/24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PropertyViewController.h"
#import "J1CoreDataManager.h"
#import "J1GroupManager.h"

@implementation PropertyViewController

#pragma mark - Property
@synthesize editingMemo;
@synthesize theNewGroup = newGroup_;
@synthesize fetchedResultsController = fetchedResultsController_;
@synthesize createdDateCell = createdDateCell_;
@synthesize parentPopover;

#pragma mark - Constants

#define kSecretSection		0
#define kCategorySection	1
#define kLifeCycleSection	2


#pragma mark - Memory management
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
    NSLog(@"%@.%s", [self class], sel_getName(_cmd));

    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Set the table view delegate
	tableView_.delegate     = self;
	tableView_.dataSource   = self;
	
    // set and retain it
	self.theNewGroup = editingMemo.group;
    
	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
}

- (void)viewWillAppear:(BOOL)animated {
	NSLog(@"%@.%s", [self class], sel_getName(_cmd));
    
	[super viewWillAppear:animated];
	self.navigationItem.title = editingMemo.title;
    
    // Set up the toolbar item
/*    
    UIBarButtonItem *spacer1
    = [[UIBarButtonItem alloc]
       initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *button1
    = [[UIBarButtonItem alloc]
       initWithBarButtonSystemItem:UIBarButtonSystemItemDone
       target:self
       action:@selector(done:)];
    
    NSArray *barItems
    = [[NSArray alloc]
       initWithObjects:spacer1, button1, nil];

    self.navigationController.toolbarHidden = NO;
    [self setToolbarItems:barItems animated:NO];
*/
    
    doneButton_.target = self;
    doneButton_.action = @selector(done:);
    

}

- (void)viewDidDisappear:(BOOL)animated {
	NSLog(@"%@.%s", [self class], sel_getName(_cmd));
    
	if (self.theNewGroup != editingMemo.group) {
        editingMemo.group = self.theNewGroup;
		NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        
		// Save the context.
        NSError *error = nil;
		if (![context save:&error]) {
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
		}
    }
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
	NSLog(@"%@.%s", [self class], sel_getName(_cmd));
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	NSLog(@"%@.%s", [self class], sel_getName(_cmd));
    
	return 3;
    ;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	NSLog(@"%@.%s", [self class], sel_getName(_cmd));
    
	NSInteger	rows = 0;
	
	switch (section) {
		case kLifeCycleSection:
			rows = 2;
			break;
		case kSecretSection:
			rows = 1;
			break;
		case kCategorySection:
        {
			id <NSFetchedResultsSectionInfo> sectionInfo = 
            [[self.fetchedResultsController sections] objectAtIndex:0];
			rows = [sectionInfo numberOfObjects];
        }
			break;
		default:
			break;
	}
	
    return rows;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //	NSLog(@"%@.%s", [self class], _cmd);
    
	UITableViewCell *cell = nil;
    
	if      (indexPath.section == kLifeCycleSection) {
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
		switch (indexPath.row) {
			case 0:
				cell = createdDateCell_;
				createdDateLabel_.text = [formatter stringFromDate:editingMemo.createdAt];
				break;
			case 1:
				cell = modifiedDateCell_;
				modifiedDateLabel_.text = [formatter stringFromDate:editingMemo.modifiedAt];
				break;
			default:
				break;
		}
	}
	else if (indexPath.section == kSecretSection) {
		cell = secretCell_;
	}
	else if (indexPath.section == kCategorySection) {
		static NSString *CellIdentifier = @"PropertyViewCell";
		
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		}
		
		Group *managedObject 
        = [[[[self.fetchedResultsController sections] objectAtIndex:0] objects]objectAtIndex:indexPath.row];
		
		cell.textLabel.text = managedObject.name;
		if (self.theNewGroup == managedObject) {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		}
		else if (self.editingMemo.group == nil
				 && [managedObject.type intValue] == kOthersGroup){
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		}		
		else {
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
	}
    
    return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
	NSString *header = nil;
    
	switch (section) {
		case kLifeCycleSection:
            //			header = @"Life Time";
			header = nil;
			break;
		case kSecretSection:
			header = @"Security";
			break;
		case kCategorySection:
			header = @"Group";
			break;
		default:
			break;
	}
	return header;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

#pragma mark - Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSIndexPath *ret = indexPath;
    
	if (indexPath.section == kCategorySection) {
		Group   *managedObject 
		= [[[[self.fetchedResultsController sections] objectAtIndex:0] objects]objectAtIndex:indexPath.row];
		
		if ([managedObject.type intValue] != kUserGGoup) {
			ret = nil;
		}
		
	}
	
	return ret;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
	if (indexPath.section == kCategorySection) {		
        NSIndexPath *oldIndexPath
        = [NSIndexPath indexPathForRow:[self.fetchedResultsController indexPathForObject:self.theNewGroup].row
                             inSection:indexPath.section];
        // set and retain it
 		self.theNewGroup =
        [[[[self.fetchedResultsController sections] objectAtIndex:0] objects] objectAtIndex:indexPath.row];
        
        NSArray *indexPaths = [NSArray arrayWithObjects:oldIndexPath, indexPath, nil];
        
        if (oldIndexPath.row != indexPath.row) {
            [tableView beginUpdates];
            [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
            [tableView endUpdates];
        }
	}
}

#pragma mark -
#pragma mark Bar Button method

- (void)done:(id)sender {
	NSLog(@"%@.%s", [self class], sel_getName(_cmd));
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if (self.parentPopover) {
            [self.parentPopover dismissPopoverAnimated:YES];
        }
    }
    else {
        [self dismissModalViewControllerAnimated:YES];
    }
    
    // work around
//    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController_ != nil) {
        return fetchedResultsController_;
    }
    
    /*
	 Set up the fetched results controller.
	 */
    
	// get managed object context
 	NSManagedObjectContext *managedObjectContext = [[J1CoreDataManager sharedManager] managedObjectContext];
	
	// Clear cache.
	[NSFetchedResultsController deleteCacheWithName:@"PropertyCategory"];
	
	// Create the fetch request for the entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	// Edit the entity name as appropriate.
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Group" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
    
	// Set the batch size to a suitable number.
	[fetchRequest setFetchBatchSize:20];
	
	// Edit the sort key as appropriate.
	NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"type" ascending:YES];
	NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor1, sortDescriptor2, nil];
	
	[fetchRequest setSortDescriptors:sortDescriptors];

    // Set the predicate
    NSPredicate *predicate
        = [NSPredicate predicateWithFormat:@"%K = %d", @"type", kUserGGoup];
    [fetchRequest setPredicate:predicate];
	
	// Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
	NSFetchedResultsController *aFetchedResultsController = 
	[[NSFetchedResultsController alloc] 
	 initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"PropertyCategory"];
    
    //    aFetchedResultsController.delegate = self;
    // set the property and retain it
	self.fetchedResultsController = aFetchedResultsController;
	
	return fetchedResultsController_;
}    


@end
