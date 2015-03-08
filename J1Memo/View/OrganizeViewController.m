//
//  OrganizeViewController.m
//  J1Memo
//
//  Created by 奥 潤一郎 on 11/07/26.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OrganizeViewController.h"
#import "J1CoreDataManager.h"
#import "J1GroupManager.h"
#import "Memo.h"

@implementation OrganizeViewController

#pragma mark - Property
@synthesize selectedObjects = selectedObjects_;
@synthesize theNewGroup = newGroup_;
@synthesize selectedGroup = selectedGroup_;
@synthesize fetchedResultsController = fetchedResultsController_;

#pragma mark - Memory maagement
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
    self.theNewGroup = self.selectedGroup;
    
    // Set the table view delegate
    tableView_.dataSource = self;
    tableView_.delegate   = self;
    
    // Set the tool bar.
    doneButton_.target = self;
    doneButton_.action = @selector(done:);

    NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"%@.%s", [self class], sel_getName(_cmd));
    
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	NSLog(@"%@.%s", [self class], sel_getName(_cmd));
    
    [self.selectedObjects enumerateObjectsUsingBlock:
         ^(Memo *obj, NSUInteger idx, BOOL *stop) {
             // Set the group of the memo to the specified one.
             obj.group = self.theNewGroup;
         }
     ]; 
    [[J1CoreDataManager sharedManager] saveContext];
/*
 if (self.theNewGroup != self.selectedGroup) {
        editingMemo.group = self.theNewGroup;
		NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        
   }
*/
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
    static NSString *CellIdentifier = @"OrganizeCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    Group *managedObject 
    = [[[[self.fetchedResultsController sections] objectAtIndex:indexPath.section] objects] objectAtIndex:indexPath.row];
    
    cell.textLabel.text = managedObject.name;

    if (self.theNewGroup == managedObject) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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

#pragma mark - Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSIndexPath *ret = indexPath;
    
    Group   *managedObject 
    = [[[[self.fetchedResultsController sections] objectAtIndex:indexPath.section] objects]objectAtIndex:indexPath.row];
    
    if ([managedObject.type intValue] != kUserGGoup) {
        ret = nil;
    }
    
	return ret;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    // Get the selected group
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    self.theNewGroup
    = [[[[self.fetchedResultsController sections] objectAtIndex:indexPath.section] objects]objectAtIndex:indexPath.row];
    
    [tableView reloadData];
}

#pragma mark - Tool bar

- (void)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^(void) {}];
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
	[NSFetchedResultsController deleteCacheWithName:@"OrganizeViewController"];
	
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
    
    // Set the preidicate to show normal groups only
    NSPredicate *predicate
    = [NSPredicate predicateWithFormat:@"%K = %d", @"type", kUserGGoup];
    [fetchRequest setPredicate:predicate];

	// Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
	NSFetchedResultsController *aFetchedResultsController = 
	[[NSFetchedResultsController alloc] 
	 initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"OrganizeViewController"];
    
    //    aFetchedResultsController.delegate = self;
    // set the property and retain it
	self.fetchedResultsController = aFetchedResultsController;

	return fetchedResultsController_;
}

@end
