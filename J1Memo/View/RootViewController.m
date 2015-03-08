//
//  RootViewController.m
//  J1Memo
//
//  Created by OKU Junichirou on 11/05/04.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "J1CoreDataManager.h"
#import "J1GroupManager.h"
#import "GroupEditViewController.h"
#import "J1MemoManager.h"
#import "MemoListViewController.h"
#import "EditViewController.h"

const int kSpecialSection = 0;
static J1GroupManager *sGroupManager = nil;

@interface RootViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation RootViewController

@synthesize fetchedResultsController=__fetchedResultsController;
@synthesize managedObjectContext=__managedObjectContext;


#pragma mark - view life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Set up the edit and add buttons.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.title = @"Group";

    sGroupManager = [J1GroupManager sharedManager];
    self.managedObjectContext = [J1CoreDataManager sharedManager].managedObjectContext;
    
    // Set up a toolbar.
    UIBarButtonItem *spacer1
        = [[UIBarButtonItem alloc]
           initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
           target:nil action:nil];

    composeButton_
        = [[UIBarButtonItem alloc]
           initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
           target:self
           action:@selector(compose:)];
    composeButton_.style = UIBarButtonItemStylePlain;

    NSArray *items = [[NSArray alloc] initWithObjects:spacer1, composeButton_, nil];
    
    self.navigationController.toolbarHidden = NO;
    [self setToolbarItems:items animated:YES];
    
/*
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject)];
    self.navigationItem.rightBarButtonItem = addButton;
    [addButton release];
*/
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	NSLog(@"%@.%s", [self class], sel_getName(_cmd));
    
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
    
    [tableView_ deselectRowAtIndexPath:[tableView_ indexPathForSelectedRow] animated:animated];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	NSLog(@"%@.%s", [self class], sel_getName(_cmd));
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	NSLog(@"%@.%s", [self class], sel_getName(_cmd));
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	NSLog(@"%@.%s", [self class], sel_getName(_cmd));
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

#pragma mark - Table view methods

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super	setEditing:editing animated:YES];
	NSLog(@"%@.%s editing=%@", [self class], sel_getName(_cmd), ( editing ? @"YES" : @"NO" ) );
	
	[tableView_ setEditing:editing animated:YES];
	
	// rewrite All Group
	NSIndexPath *indexPath = nil;
	indexPath = [NSIndexPath indexPathForRow:0 inSection:kSpecialSection];
	[tableView_ reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	// rewrite Unsorted Group
	indexPath = [NSIndexPath indexPathForRow:1 inSection:kSpecialSection];
	[tableView_ reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	
	if (editing) {
		[sGroupManager showNewGroup];
	}
	else {
		[sGroupManager hideNewGroup];
	}
}

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

#pragma mark - Table View Datasource Interface
// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RootView";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }

    // Configure the cell.
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	Group *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
	if (self.editing && [managedObject.type intValue] == kNewGroup) {
		return UITableViewCellEditingStyleInsert;
	}
	else {
		return UITableViewCellEditingStyleDelete;
	}
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
	Group *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
	return  [managedObject.section intValue] == 1;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the managed object for the given index path
        [[J1GroupManager sharedManager] deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        [[J1CoreDataManager sharedManager] saveContext];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
		Group *newManagedObject = [[J1GroupManager sharedManager] insertNewObject];
		
		GroupEditViewController *viewController = [[GroupEditViewController alloc] initWithNibName:@"GroupEditViewController" bundle:nil];
		viewController.editingGroup = newManagedObject;
		[self.navigationController pushViewController:viewController animated:YES];
		
		[tableView_ reloadData];
	}
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    MemoListViewController *detailViewController = [[MemoListViewController alloc] initWithNibName:@"MemoListViewController" bundle:nil];
    // ...
    // Pass the selected object to the new view controller.
    detailViewController.selectedGroup = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"%@.%s", [self class], sel_getName(_cmd));
	
	NSManagedObject *selectedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	GroupEditViewController *viewController = [[GroupEditViewController alloc] initWithNibName:@"GroupEditViewController" bundle:nil];
    //	viewController.fetchedResultsController = theGroupCollection.fetchedResultsController;
	viewController.editingGroup = (Group *)selectedObject;
	[self.navigationController pushViewController:viewController animated:YES];

}

-(void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    // prevent to display "New Group..." cell when swiped
   
}

-(void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    // prevent to display "New Group..." cell when swiped
}

#pragma mark - configure cell
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Group *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
 
	// Configure the textLabel of the cell.	
	cell.textLabel.text	= managedObject.name;
	
	// Configure the number of the cell, and the accesarry
	switch ([managedObject.type intValue]) {
        case kAllGroup:
            cell.detailTextLabel.text   = @"";
            cell.accessoryType          = UITableViewCellAccessoryDisclosureIndicator;
            cell.editingAccessoryType   = UITableViewCellAccessoryNone;
           break;
        case kOthersGroup:
            cell.detailTextLabel.text   = [NSString stringWithFormat:@"%d", [managedObject.memos count]];
            cell.accessoryType          = UITableViewCellAccessoryDisclosureIndicator;
            cell.editingAccessoryType   = UITableViewCellAccessoryNone;
           break;
		case kUserGGoup:
			cell.detailTextLabel.text   = [NSString stringWithFormat:@"%d", [managedObject.memos count]];
            cell.accessoryType          = UITableViewCellAccessoryDisclosureIndicator;
            cell.editingAccessoryType	= UITableViewCellAccessoryDetailDisclosureButton;
			break;
		case kNewGroup:
			cell.detailTextLabel.text   = nil;
            cell.accessoryType			= UITableViewCellAccessoryNone;			
            cell.editingAccessoryType	= UITableViewCellAccessoryNone;
			break;
		case kTrashGroup:
			cell.detailTextLabel.text   = [NSString stringWithFormat:@"%d", [managedObject.memos count]];
            cell.accessoryType          = UITableViewCellAccessoryDisclosureIndicator;
            cell.editingAccessoryType   = UITableViewCellAccessoryNone;
			break;
		default:
			cell.detailTextLabel.text   = nil;
            cell.accessoryType          = UITableViewCellAccessoryNone;
            cell.editingAccessoryType   = UITableViewCellAccessoryNone;
			break;
	}
}

#pragma mark - Toolbar buttons

- (void)compose:(id)sender
{
    Memo *newManagedObject = [[J1MemoManager sharedManager] insertNewObject:[J1GroupManager sharedOthersGroup]];

    EditViewController *detailViewController = [[EditViewController alloc] initWithNibName:@"EditViewController" bundle:nil];
    detailViewController.editingMemo = newManagedObject;
    [detailViewController setEditing:YES animated:NO];
    
    [self.navigationController pushViewController:detailViewController animated:YES];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (__fetchedResultsController != nil)
    {
        return __fetchedResultsController;
    }
    
    /*
     Set up the fetched results controller.
    */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
	NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"section" ascending:YES];
	NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"type"    ascending:YES];
	NSSortDescriptor *sortDescriptor3 = [[NSSortDescriptor alloc] initWithKey:@"name"    ascending:YES];
	NSArray *sortDescriptors		  = [[NSArray alloc] initWithObjects:sortDescriptor1, sortDescriptor2, sortDescriptor3, nil];
	    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController
        = [[NSFetchedResultsController alloc]
            initWithFetchRequest:fetchRequest
            managedObjectContext:self.managedObjectContext
            sectionNameKeyPath:@"section"
           cacheName:[[self class] description]];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
/*
    [aFetchedResultsController release];
    [fetchRequest release];
    [sortDescriptor release];
    [sortDescriptors release];
*/

	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error])
        {
	    /*
	     Replace this implementation with code to handle the error appropriately.

	     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
	     */
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return __fetchedResultsController;
}    

#pragma mark - Fetched results controller delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [tableView_ beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [tableView_ insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView_ deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = tableView_;
    
    switch(type)
    {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [tableView_ endUpdates];
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [myTableView reloadData];
}
 */

@end
