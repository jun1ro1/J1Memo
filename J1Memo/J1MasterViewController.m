//
//  J1MasterViewController.m
//  J1Memo
//
//  Created by OKU Junichirou on 11/09/11.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "J1MasterViewController.h"

#import "J1DetailViewController.h"

@interface J1MasterViewController ()
- (NSURL *)localDocumentsURL;
- (NSURL *)ubiquitousDocumentsURL;

- (UIView *)cloudToolbarView;

- (void)showDocument:(UIManagedDocument *)document;

- (void)addDocumentURL:(NSURL *)url;
- (void)removeDocumentURL:(NSURL *)url;
@end

@implementation J1MasterViewController

@synthesize detailViewController = _detailViewController;
@synthesize useiCloud = _useiCloud;
@synthesize documentURLs = _documentURLs;
@synthesize query = _query;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - View lifecycle

static NSString * const UseiCloudKey = @"UseiCloud";

- (void)awakeFromNib
{
    _useiCloud = [[NSUserDefaults standardUserDefaults] boolForKey:UseiCloudKey];
    
    self.clearsSelectionOnViewWillAppear = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone);
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithCustomView:[self cloudToolbarView]];
    UIBarButtonItem *item3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    self.toolbarItems = [NSArray arrayWithObjects:item1, item2, item3, nil];
    
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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.detailViewController = (J1DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
        
        if (self.documentURLs.count > 0) {
            NSURL *url = [self.documentURLs objectAtIndex:0];
            UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:url];
            [self showDocument:document];
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.query enableUpdates];
    [self.navigationController setToolbarHidden:NO animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    [self.query disableUpdates];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.documentURLs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    NSURL *url = [self.documentURLs objectAtIndex:indexPath.row];
    cell.textLabel.text = [[url lastPathComponent] stringByDeletingPathExtension];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        NSURL *url = [self.documentURLs objectAtIndex:indexPath.row];
        UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:url];
        [self showDocument:document];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDocument"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSURL *url = [self.documentURLs objectAtIndex:indexPath.row];
        UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:url];
        [[segue destinationViewController] setDocument:document];
    }
}

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

#pragma mark - iCloud

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

#pragma mark - Documents

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    NSURL *documentURL = self.detailViewController.document.fileURL;
    if (documentURL) {
        NSUInteger row = [self.documentURLs indexOfObject:documentURL];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self.tableView selectRowAtIndexPath:indexPath animated:animated scrollPosition:UITableViewScrollPositionNone];
    }
}

- (void)updateUbiquitousDocuments:(NSNotification *)notification
{
    self.documentURLs = nil;
    [self.tableView reloadData];
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

#pragma mark - Document URLs

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
@end
