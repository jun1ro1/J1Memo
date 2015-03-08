
//
//  J1MasterViewController.m
//  J1Memo
//
//  Created by OKU Junichirou on 11/09/11.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "J1MasterViewController.h"
#import "J1DetailViewController.h"
#import "J1GroupManager.h"
#import "J1CoreDataManager.h"
#import "RootViewController.h"
#import "PropertyViewController.h"
#import "MemoListViewController.h"
#import "GroupEditViewController.h"
#import "J1MemoManager.h"
#import "EditViewController.h"

const int kSpecialSection = 0;
static J1GroupManager *sGroupManager = nil;

@interface J1MasterViewController ()
//- (NSURL *)localDocumentsURL;
//- (NSURL *)ubiquitousDocumentsURL;

//- (UIView *)cloudToolbarView;

//- (void)showDocument:(UIManagedDocument *)document;

//- (void)addDocumentURL:(NSURL *)url;
//- (void)removeDocumentURL:(NSURL *)url;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation J1MasterViewController

@synthesize detailViewController = detailViewController_;

//@synthesize useiCloud = _useiCloud;
//@synthesize documentURLs = _documentURLs;
//@synthesize query = _query;

@synthesize fetchedResultsController=__fetchedResultsController;
@synthesize managedObjectContext=__managedObjectContext;


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - View lifecycle

static NSString * const UseiCloudKey = @"UseiCloud";

- (void)awakeFromNib
{
//    _useiCloud = [[NSUserDefaults standardUserDefaults] boolForKey:UseiCloudKey];
    
//    self.clearsSelectionOnViewWillAppear = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone);

    
/*
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithCustomView:[self cloudToolbarView]];
    UIBarButtonItem *item3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    self.toolbarItems = [NSArray arrayWithObjects:item1, item2, item3, nil];
*/
/*
    NSURL *ubiquitousDocumentsURL = [self ubiquitousDocumentsURL];
    if (ubiquitousDocumentsURL) {
        NSMetadataQuery *query = [[NSMetadataQuery alloc] init];
        query.predicate = [NSPredicate predicateWithFormat:@"%K == '*.mydoc'", NSMetadataItemFSNameKey];
        query.searchScopes = [NSArray arrayWithObject:NSMetadataQueryUbiquitousDocumentsScope];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUbiquitousDocuments:) name:NSMetadataQueryDidFinishGatheringNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUbiquitousDocuments:) name:NSMetadataQueryDidUpdateNotification object:nil];
        [query startQuery];
        self.query = query;
    }
*/
 }

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	NSLog(@"%@.%s", [self class], sel_getName(_cmd));

    sGroupManager = [J1GroupManager sharedManager];
    self.managedObjectContext = [J1CoreDataManager sharedManager].managedObjectContext;
    
    // Get the last memo.
    
	
    // Create a new meo
//    Memo *newManagedObject = [[J1MemoManager sharedManager] insertNewObject:[J1GroupManager sharedOthersGroup]];

    // Do any additional setup after loading the view, typically from a nib.
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.title = @"Group";
    
    
    
    // Get the EditViewController
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.detailViewController = (EditViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];

        // Assign a new object to edit first
//        self.detailViewController.editingMemo = newManagedObject;
    }

/* 
        if (self.documentURLs.count > 0) {
            NSURL *url = [self.documentURLs objectAtIndex:0];
            UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:url];
            [self showDocument:document];
            [tableView_ selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        }
    }
*/
    
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
    
//   [self.query enableUpdates];
   [self.navigationController setToolbarHidden:NO animated:NO];
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
//    [self.query disableUpdates];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	NSLog(@"%@.%s", [self class], sel_getName(_cmd));
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

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


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

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
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
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
//    }
    
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

/*
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSURL *url = [self.documentURLs objectAtIndex:indexPath.row];
        if ([self.detailViewController.document.fileURL isEqual:url]) {
            [self showDocument:nil];
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
            [coordinator coordinateWritingItemAtURL:url options:NSFileCoordinatorWritingForDeleting error:NULL byAccessor:^(NSURL *newURL) {
                [[NSFileManager defaultManager] removeItemAtURL:newURL error:NULL];
            }];
        });
        [self removeDocumentURL:url];
    }
}
*/


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	NSLog(@"%@.%s", [self class], sel_getName(_cmd));

    if ([segue.identifier isEqualToString:@"MemoListView"]) {
        [segue.destinationViewController setSelectedGroup:[self.fetchedResultsController objectAtIndexPath:tableView_.indexPathForSelectedRow]];
        [segue.destinationViewController setDetailViewController:self.detailViewController];
    }
    else if ([segue.identifier isEqualToString:@"PropertyView"]) {
        [segue.destinationViewController setSelectedObjects:sender];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSLog(@"%@.%s", [self class], sel_getName(_cmd));
    
//    MemoListViewController *detailViewController = [[MemoListViewController alloc] initWithNibName:@"MemoListViewController" bundle:nil];
    // ...
    // Pass the selected object to the new view controller.
//    detailViewController.selectedGroup = [self.fetchedResultsController objectAtIndexPath:indexPath];
//    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	NSLog(@"%@.%s", [self class], sel_getName(_cmd));

/*    
    // https://devforums.apple.com/message/466234#466234
	NSManagedObject *selectedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"PropertyView" sender:selectedObject];
*/	
    GroupEditViewController *viewController = [[GroupEditViewController alloc] initWithNibName:@"GroupEditViewController" bundle:nil];
	viewController.editingGroup = [self.fetchedResultsController objectAtIndexPath:indexPath];

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


#pragma mark - iCloud
/*
- (void)setUseiCloud:(BOOL)value
{
    if (_useiCloud != value) {
        _useiCloud = value;
        [[NSUserDefaults standardUserDefaults] setBool:_useiCloud forKey:UseiCloudKey];
        
        NSURL *baseURL = (_useiCloud ? [self ubiquitousDocumentsURL] : [self localDocumentsURL]);
        for (NSURL *url in self.documentURLs) {
            NSURL *destinationURL = [baseURL URLByAppendingPathComponent:[url lastPathComponent]];
            [[NSFileManager defaultManager] setUbiquitous:_useiCloud itemAtURL:url destinationURL:destinationURL error:NULL];
        }
        self.documentURLs = nil;
    }
}

- (void)changeiCloud:(id)sender
{
    self.useiCloud = [sender isOn];
}
*/

/*
- (UIView *)cloudToolbarView
{
    BOOL hasiCloud = ([self ubiquitousDocumentsURL] != nil);
    UIView *cloudView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 160.0, 33.0)];
    UILabel *cloudLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 3.0, 80.0, 27.0)];
    cloudLabel.text = NSLocalizedString(@"Use iCloud", @"Use iCloud");
    cloudLabel.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
    cloudLabel.textColor = [UIColor whiteColor];
    cloudLabel.backgroundColor = [UIColor clearColor];
    cloudLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    [cloudView addSubview:cloudLabel];
    UISwitch *cloudSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(81.0, 3.0, 79.0, 27.0)];
    [cloudSwitch addTarget:self action:@selector(changeiCloud:) forControlEvents:UIControlEventValueChanged];
    cloudSwitch.enabled = hasiCloud;
    [cloudView addSubview:cloudSwitch];
    return cloudView;
}
 */

#pragma mark - Documents

/*
- (void)updateUbiquitousDocuments:(NSNotification *)notification
{
    self.documentURLs = nil;
    [tableView_ reloadData];
}

- (void)showDocument:(UIManagedDocument *)document
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        if (document) {
            if (!self.detailViewController) {
                self.detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"detail"];
            }
            self.detailViewController.document = document;
            [self.navigationController pushViewController:self.detailViewController animated:YES];
        }
    } else {
        if (![self.detailViewController.document.fileURL isEqual:document.fileURL]) {
            self.detailViewController.document = document;
        }
    }
}

- (IBAction)addDocument:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"New Document", @"New Document") message:NSLocalizedString(@"Choose a name for your new document.", @"Choose a name for your new document.") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"Create", @"Create"), nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *field = [alertView textFieldAtIndex:0];
    field.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    [alertView show];
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    NSString *name = [[alertView textFieldAtIndex:0] text];
    return (name.length > 0);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSString *name = [[alertView textFieldAtIndex:0] text];
        NSString *extension = @"mydoc";
        NSURL *baseURL = (self.useiCloud ? [self ubiquitousDocumentsURL] : [self localDocumentsURL]);
        NSURL *url = [[baseURL URLByAppendingPathComponent:name] URLByAppendingPathExtension:extension];
        if ([self.documentURLs containsObject:url]) {
            NSUInteger n = 2;
            do {
                url = [[baseURL URLByAppendingPathComponent:[name stringByAppendingFormat:@" %ld", n]] URLByAppendingPathExtension:extension];
                n++;
            } while ([self.documentURLs containsObject:url]);
        }
        UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:url];
        [document saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            [self addDocumentURL:url];
            
            NSUInteger row = [self.documentURLs indexOfObject:url];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        }];
        [self showDocument:document];
    }
}
*/

#pragma mark - Document URLs
/*
- (NSURL *)localDocumentsURL
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *)ubiquitousDocumentsURL
{
    return [[[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil] URLByAppendingPathComponent:@"Documents"];
}

- (NSMutableArray *)documentURLs
{
    if (!_documentURLs) {
        _documentURLs = [[NSMutableArray alloc] init];
        if (self.useiCloud) {
            for (NSMetadataItem *item in self.query.results) {
                NSURL *url = [item valueForAttribute:NSMetadataItemURLKey];
                [_documentURLs addObject:url];
            }
        } else {
            [_documentURLs addObjectsFromArray:[[NSFileManager defaultManager] contentsOfDirectoryAtURL:[self localDocumentsURL] includingPropertiesForKeys:nil options:0 error:NULL]];
        }
        [_documentURLs sortUsingComparator:^NSComparisonResult(NSURL *url1, NSURL *url2) {
            return [[url1 lastPathComponent] localizedStandardCompare:[url2 lastPathComponent]];
        }];
        
    }
    return _documentURLs;
}

- (void)addDocumentURL:(NSURL *)url
{
    [self.documentURLs addObject:url];
    [self.documentURLs sortUsingComparator:^NSComparisonResult(NSURL *url1, NSURL *url2) {
        return [[url1 lastPathComponent] localizedStandardCompare:[url2 lastPathComponent]];
    }];
    
    NSUInteger row = [self.documentURLs indexOfObject:url];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)removeDocumentURL:(NSURL *)url
{
    NSUInteger row = [self.documentURLs indexOfObject:url];
    
    [self.documentURLs removeObject:url];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}
*/

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
