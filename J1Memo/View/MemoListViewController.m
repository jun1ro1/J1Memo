
//
//  MemoListViewController.m
//  J1Memo
//
//  Created by 奥 潤一郎 on 11/07/21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MemoListViewController.h"
#import "J1CoreDataManager.h"
#import "J1GroupManager.h"
#import "EditViewController.h"
#import "J1ScrollViewController.h"
#import "J1MemoManager.h"
#import "PropertyViewController.h"
#import "OrganizeViewController.h"

#pragma mark - Constants
static  NSString *kCacheName = @"MemoListViewController";

#pragma mark - Internal class

@interface MemoListViewController ()
// - (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (NSPredicate *)configurePredicate:(NSString *)searchString;
@end

#pragma mark - MemoListViewController implementation

@implementation MemoListViewController

#pragma mark - property

@synthesize detailViewController = detailViewController_;

@synthesize selectedGroup = selectedGroup_;
@synthesize fetchedResultsController = fetchedResultsController_;
@synthesize tableView = tableView_;
@synthesize selectedObjects = selectedObjects_;

#pragma mark - Initialize

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


#pragma mark - Memory management

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
	NSLog(@"%@.%s", [self class], sel_getName(_cmd));
    // Do any additional setup after loading the view from its nib.
    
    // Set the title of the navigation bar
    self.navigationItem.title
        = (self.selectedGroup == nil) ? [J1GroupManager sharedAllGroup].name : self.selectedGroup.name;
    
    // Set up navigation button items
	self.navigationItem.rightBarButtonItem = [self editButtonItem];
    
    // Set up bar button items
    organizeButton_
        = [[UIBarButtonItem alloc]
            initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize
            target:self
            action:@selector(organize:)];
    organizeButton_.enabled = NO;
    
    UIBarButtonItem *spacer1
        = [[UIBarButtonItem alloc]
            initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
            target:nil
            action:nil];
    
    disposeButton_
        = [[UIBarButtonItem alloc]
            initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
            target:self
            action:@selector(dispose:)];
    disposeButton_.enabled = NO;

    UIBarButtonItem *spacer2
        = [[UIBarButtonItem alloc]
           initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
           target:nil
           action:nil];
    
    composeButton_
        = [[UIBarButtonItem alloc]
           initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
           target:self
           action:@selector(compose:)];
    
    NSArray *items
        = [[NSArray alloc]
           initWithObjects:organizeButton_, spacer1, disposeButton_, spacer2, composeButton_, nil];
    
    self.navigationController.toolbarHidden = NO;
    [self setToolbarItems:items animated:YES];
    
    // to display the original table
    originalTableView_.dataSource = self;
    originalTableView_.delegate   = self;
    
    // multiple selection is allowed during show mode and editing ode
    originalTableView_.allowsMultipleSelectionDuringEditing = YES;
    
    // the currently displayed table is the original table initialy
    self.tableView = originalTableView_;
        
    // clear all selected memos
    self.selectedObjects = [[NSMutableSet alloc] initWithCapacity:10];
    
    // create search display controlller
    searchDisplayController_ = [[UISearchDisplayController alloc] initWithSearchBar:searchBar_ contentsController:self];
    // set search bar and search display controller delegate
    searchBar_.delegate = self;
    self.searchDisplayController.delegate = self;
    self.searchDisplayController.searchResultsDataSource = self;
    self.searchDisplayController.searchResultsDelegate   = self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	NSLog(@"%@.%s", [self class], sel_getName(_cmd));
    
    // Deselect the row when return the MemoListView.
    if (!self.editing && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"%@.%s", [self class], sel_getName(_cmd));
    
    if (self.editing) {
        // clear the selected rows
        for (NSIndexPath *path in [self.tableView indexPathsForSelectedRows]) {
            [self.tableView deselectRowAtIndexPath:path animated:YES];
        }
        self.selectedObjects = [[NSMutableSet alloc] initWithCapacity:10];
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	NSLog(@"%@.%s editing=%@", [self class], sel_getName(_cmd), ( editing ? @"YES" : @"NO" ) );
	[super	setEditing:editing animated:YES];
	[self.tableView setEditing:editing animated:YES];
    
    organizeButton_.enabled = editing;
    disposeButton_.enabled  = editing;
    
    // clear all selected flags
    self.selectedObjects = [[NSMutableSet alloc] initWithCapacity:10];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MemoListView";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell.
    Memo *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // Configure a selection of the row
    if (self.editing) {
        if ([self.selectedObjects member:managedObject]) {
            [tableView selectRowAtIndexPath:indexPath   animated:YES scrollPosition:UITableViewScrollPositionNone];
        }
        else { 
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }

	// Configure a textLabel of the cell.    
    // text
	cell.textLabel.text	= managedObject.title;
	
    // modified date
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	cell.detailTextLabel.text = [formatter stringFromDate:[managedObject valueForKey:@"modifiedAt"]];
	
	cell.accessoryType			= UITableViewCellAccessoryDisclosureIndicator;
	cell.editingAccessoryType	= UITableViewCellAccessoryDetailDisclosureButton;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.fetchedResultsController.sectionNameKeyPath) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        return	sectionInfo.name;
    }
    else {
        return nil;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSLog(@"%@.%s indexPath=%d.%d", [self class], sel_getName(_cmd), indexPath.section, indexPath.row);

    // Navigation logic may go here. Create and push another view controller.
    
    if (tableView.editing) {
        Memo *memo = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self.selectedObjects addObject:memo];
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.detailViewController.editingMemo = [self.fetchedResultsController objectAtIndexPath:indexPath];
        self.detailViewController.delegate = self;
        
        self.detailViewController.searchString = searchString_;
    }
    else {
        EditViewController *detailViewController = [[EditViewController alloc] initWithNibName:@"EditViewController" bundle:nil];
        detailViewController.editingMemo = [self.fetchedResultsController objectAtIndexPath:indexPath];
        detailViewController.delegate    = self;
        
        detailViewController.searchString = searchString_;
        
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSLog(@"%@.%s indexPath=%d.%d", [self class], sel_getName(_cmd), indexPath.section, indexPath.row);
    
    // Navigation logic may go here. Create and push another view controller.
    
    if (tableView.editing) {
        Memo *memo = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self.selectedObjects removeObject:memo];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"%@.%s indexPath=%d.%d", [self class], sel_getName(_cmd), indexPath.section, indexPath.row);
	
	NSManagedObject *selectedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
/*    [self performSegueWithIdentifier:@"PropertyView2" sender:selectedObject]; */

	PropertyViewController *viewController
    = [[PropertyViewController alloc] initWithNibName:@"PropertyViewController" bundle:nil];
	viewController.editingMemo = (Memo *)selectedObject;
    
    // http://stackoverflow.com/questions/1814126/using-presentmodalviewcontroller-to-load-a-view/1818086#1818086
	viewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self	presentModalViewController:viewController animated:YES];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	NSLog(@"%@.%s", [self class], sel_getName(_cmd));
    
    if ([segue.identifier isEqualToString:@"PropertyView"]) {
        [segue.destinationViewController setSelectedObjects:sender];
    }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
		[[J1MemoManager sharedManager] disposeObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
		[[J1CoreDataManager sharedManager] saveContext];
		
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - UISearchDisplayControllerDelegate Protocol
#pragma mark searchResultsTable lifecycle
- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    NSLog(@"%@.%s", [self class], sel_getName(_cmd));
 
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
	NSLog(@"%@.%s", [self class], sel_getName(_cmd));

    // http://cocoadays.blogspot.com/2010/07/uisearchdisplaycontroller-uitableview.html    
    // Users can select multipe rows in the editing/searching mode.
    tableView.editing = self.editing;
    tableView.allowsMultipleSelectionDuringEditing = YES;
    tableView.delegate = self;
    
    // switch the currently displayed table to "searchResultsTableView"
    self.tableView  = tableView;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView
{
	NSLog(@"%@.%s", [self class], sel_getName(_cmd));

    // http://www.iphonedevsdk.com/forum/iphone-sdk-development/27849-possible-resize-searchdisplaycontroller-tableview-results.html

    // adjust "earchResultsTableView" size not to hide the toolbar.
    CGRect frame = tableView.frame;
    frame.size.height -= self.navigationController.toolbar.bounds.size.height;
    tableView.frame = frame;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView
{
	NSLog(@"%@.%s", [self class], sel_getName(_cmd));

    // return the currently displayed table to the original table
    self.tableView = originalTableView_;

}

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView
{
	NSLog(@"%@.%s", [self class], sel_getName(_cmd));    
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView
{
	NSLog(@"%@.%s", [self class], sel_getName(_cmd));

    // Copy selections of the "searchResultsTable"
    [NSFetchedResultsController deleteCacheWithName:kCacheName];

    // restore the predicate
    NSPredicate *preidicate = [self configurePredicate:nil];
    self.fetchedResultsController.fetchRequest.predicate = preidicate;
    
    // perform the fetch and reload the original table
    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];

    // Copy the saved selections on "searchResultsTable" to ones on the original table
    for (NSManagedObject *obj in self.selectedObjects) {
        NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:obj];
        if (indexPath) {
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
    
//    [self.tableView reloadData];
}

#pragma mark Search State Change
- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
	NSLog(@"%@.%s", [self class], sel_getName(_cmd));
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
	NSLog(@"%@.%s", [self class], sel_getName(_cmd));
    
    searchString_ = nil;
    [originalTableView_ reloadData];
}

#pragma mark Responding to Changes in Search Criteria
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
	NSLog(@"%@.%s", [self class], sel_getName(_cmd));

    // Update a predicate and "fetchedResultsController"
    [NSFetchedResultsController deleteCacheWithName:kCacheName];

    searchString_ = searchString;
    
    NSPredicate *predicate = nil;
    if (searchString != nil && searchString.length > 0) {
        predicate = [self configurePredicate:searchString];
    }
    else {
        predicate = [self configurePredicate:nil];
    }
    
    self.fetchedResultsController.fetchRequest.predicate = predicate;
    
    // Peform to search the specified string
    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];
    
    return YES;
}

#pragma mark Configure the predicate.
- (NSPredicate *)configurePredicate:(NSString *)searchString
{
    NSPredicate *predicate = nil;
    if (searchString) {
        if (self.selectedGroup == [J1GroupManager sharedAllGroup]) {
            predicate
            = [NSPredicate predicateWithFormat:@"%K != %@ AND contents contains[cd] %@", 
               @"group.identifier", [J1GroupManager sharedTrashGroup].identifier, searchString];
        }
        else {
            predicate
            = [NSPredicate predicateWithFormat:@"%K = %@ AND contents contains[cd] %@",
               @"group.identifier", self.selectedGroup.identifier, searchString];
            
        }
    }
    else {
        if (self.selectedGroup == [J1GroupManager sharedAllGroup]) {
            predicate
            = [NSPredicate predicateWithFormat:@"%K != %@", @"group.identifier", [J1GroupManager sharedTrashGroup].identifier];
        }
        else {
            predicate
            = [NSPredicate predicateWithFormat:@"%K = %@", @"group.identifier", self.selectedGroup.identifier];
        }
    }
    return predicate;
}


#pragma mark - Content changes management

// Notifies the delegate that section and object changes are about to be processed and notifications will be sent. 
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	NSLog(@"%@.%s", [self class], sel_getName(_cmd));
	[self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	// Update the table view appropriately.
	switch (type) {
		case NSFetchedResultsChangeInsert:
			NSLog(@"%@.%s insert=%d", [self class], sel_getName(_cmd), sectionIndex);
			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationRight];
			break;
		case NSFetchedResultsChangeDelete:
			NSLog(@"%@.%s delete=%d", [self class], sel_getName(_cmd), sectionIndex);
			[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
		default:
			break;
	}	
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	
	switch (type) {
		case NSFetchedResultsChangeInsert:
			NSLog(@"%@.%s insert=%d.%d", [self class], sel_getName(_cmd), newIndexPath.section, newIndexPath.row);
			[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                               withRowAnimation:UITableViewRowAnimationRight];
			break;
		case NSFetchedResultsChangeDelete:
			NSLog(@"%@.%s delete=%d.%d", [self class], sel_getName(_cmd), indexPath.section, indexPath.row);
			[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                               withRowAnimation:UITableViewRowAnimationFade];
			break;
		case NSFetchedResultsChangeUpdate:
			NSLog(@"%@.%s update=%d.%d", [self class], sel_getName(_cmd), indexPath.section, indexPath.row);
			[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                               withRowAnimation:UITableViewRowAnimationFade];
			break;
        case NSFetchedResultsChangeMove:
			NSLog(@"%@.%s delete=%d.%d insert=%d.%d", [self class], sel_getName(_cmd),
				  indexPath.section, indexPath.row, newIndexPath.section, newIndexPath.row);
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                               withRowAnimation:UITableViewRowAnimationLeft];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                               withRowAnimation:UITableViewRowAnimationRight];
            break;			
		default:
			break;
	}	
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	NSLog(@"%@.%s", [self class], sel_getName(_cmd));
	[self.tableView endUpdates];
} 



#pragma mark - Fetched results controller
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController_ != nil) {
        return fetchedResultsController_;
    }
    
	// Clear the cache.
	[NSFetchedResultsController deleteCacheWithName:kCacheName];
	
	// Get the managedObject Context.
	NSManagedObjectContext *context = [J1CoreDataManager sharedManager].managedObjectContext;
	
    /*
	 Set up the fetched results controller.
	 */
	// Create the fetch request for the entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	// Edit the entity name as appropriate.
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Memo" inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	
	// Set the batch size to a suitable number.
	[fetchRequest setFetchBatchSize:20];
	
	// Edit the sort key as appropriate.
	NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"group.name" ascending:YES];
	NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor1, sortDescriptor2, nil];
	
	[fetchRequest setSortDescriptors:sortDescriptors];
	
    // Set the predicate and the key path to the section name.
    NSPredicate *predicate = [self configurePredicate:nil];
    [fetchRequest setPredicate:predicate];
	NSString *sectionNameKeyPath = nil;
    
	// Set the name key path
    if (self.selectedGroup == [J1GroupManager sharedAllGroup]) {
		sectionNameKeyPath = @"group.name";
	}
    
	// Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
	NSFetchedResultsController *aFetchedResultsController = 
        [[NSFetchedResultsController alloc] 
         initWithFetchRequest:fetchRequest
         managedObjectContext:context
         sectionNameKeyPath:sectionNameKeyPath
         cacheName:kCacheName];
        
    // Set the delegate
    aFetchedResultsController.delegate = self;

	// Set the property and retain it.
	self.fetchedResultsController = aFetchedResultsController;

	// Peform the fetch to load the database.
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
    
	return fetchedResultsController_;
}

#pragma mark - Toolbar buttons

- (void)organize:(id)sender
{
	NSLog(@"%@.%s", [self class], sel_getName(_cmd));

    // Get the selected memos
    NSArray *paths = [self.tableView indexPathsForSelectedRows];
    
    // Get the all managed objects before disposing.
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[paths count]];
    for (NSIndexPath *path in paths) {
        [array addObject:[self.fetchedResultsController objectAtIndexPath:path]];
    }

    OrganizeViewController *detailViewController = [[OrganizeViewController alloc] initWithNibName:@"OrganizeViewController" bundle:nil];
    detailViewController.selectedGroup = self.selectedGroup;

    detailViewController.selectedObjects = array;
    
    [self.navigationController
        presentViewController:detailViewController animated:YES completion:^(void) {}
    ];
    
   
//    [self.navigationController pushViewController:detailViewController animated:YES];

}

- (void)dispose:(id)sender
{
    // Get the selected memos
    NSArray *paths = [self.tableView indexPathsForSelectedRows];

    NSString *title = nil;
    if (paths.count <= 0) {
        return;
    }
    else if (paths.count == 1) {
        NSString *name = ((Memo *)[self.fetchedResultsController objectAtIndexPath:[paths objectAtIndex:0]]).title;
        title = [NSString stringWithFormat:@"Delete '%@'", name];
                 
   }
    else {
        title = [NSString stringWithFormat:@"Delete %d memos", paths.count];
    }
    
    // Confirm to dispose the memo.
    if (!disposeActionSheet_) {
        disposeActionSheet_
        = [[UIActionSheet alloc]
           initWithTitle:nil
           delegate:self
           cancelButtonTitle:@"Cancel"
           destructiveButtonTitle:title
           otherButtonTitles:nil];
    }
    
    // Show the action sheet.
    if (disposeActionSheet_.visible) {
        [disposeActionSheet_ dismissWithClickedButtonIndex:disposeActionSheet_.cancelButtonIndex animated:YES];
    }
    else {
        [disposeActionSheet_ showFromBarButtonItem:sender animated:YES];
    }
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        // Get the selected memos
        NSArray *paths = [self.tableView indexPathsForSelectedRows];
        
        // Get the all memos before disposing.
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[paths count]];
        for (NSIndexPath *path in paths) {
            [array addObject:[self.fetchedResultsController objectAtIndexPath:path]];
        }
        
        // Dispose the memos
        [array enumerateObjectsUsingBlock:
            ^(id obj, NSUInteger idx, BOOL *stop) {
                [[J1MemoManager sharedManager] disposeObject:obj];
            }
        ];
        
        // Save DB
        [[J1CoreDataManager  sharedManager] saveContext];
    }
}

- (void)compose:(id)sender
{
    Memo *newManagedObject = [[J1MemoManager sharedManager] insertNewObject:self.selectedGroup];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.detailViewController.editingMemo = newManagedObject;
        self.detailViewController.delegate = self;
        [self.detailViewController setEditing:YES animated:NO];
    }
    else {
        EditViewController *detailViewController = [[EditViewController alloc] initWithNibName:@"EditViewController" bundle:nil];
        detailViewController.editingMemo = newManagedObject;
        detailViewController.delegate    = self;
        
        [detailViewController setEditing:YES animated:NO];
        
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
}

#pragma mark - Memo manager delegate
- (Memo *)objectAtIndexPath:(NSIndexPath *)indexPath {
	
	return (Memo *)[self.fetchedResultsController objectAtIndexPath:indexPath];
}

- (Memo *)objectAtPreviousIndexPath:(NSIndexPath *)indexPath {
    
	if (!indexPath) {
		return nil;
	}
    
	NSUInteger indexes[2] = { NSUIntegerMax, NSUIntegerMax };
    
	if      (indexPath.row > 0 ) {
		indexes[0] = indexPath.section;
		indexes[1] = indexPath.row - 1;
	}
	else if (indexPath.section > 0) {
		id <NSFetchedResultsSectionInfo> sectionInfo
        = [[self.fetchedResultsController sections] objectAtIndex:(indexPath.section - 1)];		
		indexes[0] = indexPath.section - 1;
		indexes[1] = sectionInfo.numberOfObjects - 1;
	}
	else {
		// error
	}
	
	if (indexes[0] != NSUIntegerMax) {
		NSIndexPath *newIndexPath = [NSIndexPath indexPathWithIndexes:indexes length:2];
		return [self.fetchedResultsController objectAtIndexPath:newIndexPath];
	}
	else {
		return nil;
	}
}

- (Memo *)objectAtNextIndexPath:(NSIndexPath *)indexPath {
	
	if (!indexPath) {
		return nil;
	}
	
	id <NSFetchedResultsSectionInfo> sectionInfo
    = [[self.fetchedResultsController sections] objectAtIndex:indexPath.section];
	
	NSUInteger indexes[2] = { NSUIntegerMax, NSUIntegerMax };
	
	if      (indexPath.row + 1 < sectionInfo.numberOfObjects) {
		indexes[0] = indexPath.section;
		indexes[1] = indexPath.row + 1;
	}
	else if (indexPath.section + 1 < [self.fetchedResultsController.sections count]) {
		indexes[0] = indexPath.section + 1;
		indexes[1] = 0;
	}
	else {
		// error
	}
    
	if (indexes[0] != NSUIntegerMax) {
		NSIndexPath *newIndexPath = [NSIndexPath indexPathWithIndexes:indexes length:2];
		return [self.fetchedResultsController objectAtIndexPath:newIndexPath];
	}
	else {
		return nil;
	}
}

- (Memo *)previousObject:(Memo *)memo {
    
	if (!memo) {
		return nil;
	}
	
	NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:memo];
	return [self objectAtPreviousIndexPath:indexPath];
}

- (Memo *)nextObject:(Memo *)memo {
	
	if (!memo) {
		return nil;
	}
	
	NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:memo];
	return [self objectAtNextIndexPath:indexPath];
}

- (void)selectObject:(Memo *)memo animated:(BOOL)animated
{
    NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:memo];
    [self.tableView selectRowAtIndexPath:indexPath animated:animated scrollPosition:UITableViewScrollPositionMiddle];
}

- (void)deselectObject:(Memo *)memo animated:(BOOL)animated
{
    NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:memo];
    [self.tableView deselectRowAtIndexPath:indexPath animated:animated];

}

@end
