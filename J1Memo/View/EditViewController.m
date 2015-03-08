//
//  EditViewController.m
//  J1Memo
//
//  Created by 奥 潤一郎 on 11/07/24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EditViewController.h"
#import "J1TextViewController.h"
#import "J1CoreDataManager.h"
#import "PropertyViewController.h"
#import "J1GroupManager.h"
#import "J1MemoManager.h"
#import "J1AppDelegate.h"

#pragma mark - Constants
static int      kSearchBarTag  = 100;
const  int      kTrashButtonTag = 101;
const  float    kViewGap = 8.0;


@interface EditViewController ()
- (void)setDefaultToolbarItmes;
- (void)disposeMemo;

- (void)forwardSearch:(id)sender;
- (void)backwardSearch:(id)sender;
@end

@implementation EditViewController

#pragma mark - Property

/* @synthesize editingMemo; */
@synthesize nextMemo;
@synthesize delegate;
@synthesize searching    = searching_;
@synthesize searchString = searchString_;
@synthesize popover = popove_;

@synthesize pageViewController = pageViewController_;

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    NSLog(@"%@.%s", [self class], sel_getName(_cmd) );

    // Create a Text View Controller
    
    J1TextViewController *viewController = [[J1TextViewController alloc] initWithNibName:@"J1TextViewController" bundle:nil];
    viewController.editingMemo = self.editingMemo;
    viewController.delegate = self;
    
    // Create pageViewController
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    [self.pageViewController setViewControllers:[NSArray arrayWithObject:viewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
//    viewController.textView.text = self.editingMemo.contents;
    
    self.pageViewController.delegate = self;
    self.pageViewController.dataSource = self;
    
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    
    // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
    CGRect pageViewRect = self.view.bounds;

    // Tips: http://stackoverflow.com/questions/2754666/ipad-uisplitview-initial-state-in-portrait-how-to-display-popover-controller-wi
//    self.splitViewController.delegate = self;

    /*    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        pageViewRect = CGRectInset(pageViewRect, 40.0, 40.0);
    }
*/
    self.pageViewController.view.frame = pageViewRect;

    [self.pageViewController didMoveToParentViewController:self];

    // Tips http://www.slingsoft.com/blog/uipageviewcontroller.html
    for (UIGestureRecognizer *g in self.pageViewController.gestureRecognizers) {
        g.delegate = self;
    }
    
    // Add the page view controller's gesture recognizers to the book view controller's view so that the gestures are started more easily.
    self.view.gestureRecognizers = self.pageViewController.gestureRecognizers;
    
    [self setDefaultToolbarItmes];
    
    searchAtLoading = (self.searchString != nil);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    
    J1TextViewController *viewController = (J1TextViewController *)[self.pageViewController.viewControllers objectAtIndex:0];
    
	if ( self.editing ) {
		[viewController setEditing:YES animated:NO];
		[viewController becomeFirstResponder];
	}
	else {
		[viewController setEditing:NO animated:NO];
	}
	
    
    NSLog(@"%@.%s", [self class], sel_getName(_cmd) );
    
    // Tips http://www.lancard.com/blog/2010/04/06/dont-want-hide-uitextview-behind-keyboard/
    // Tips http://stackoverflow.com/questions/1887891/what-is-the-reason-the-uikeyboardwillshownotification-called-once
    // TIps http://mobile.tutsplus.com/tutorials/iphone/ios-sdk-keeping-content-from-underneath-the-keyboard/
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [nc addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    
	[super viewWillAppear:animated];    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSLog(@"%@.%s", [self class], sel_getName(_cmd) );
    originalViewSize_ = CGSizeZero;
    
    if (searchAtLoading) {
        searchAtLoading = NO;
        [self setSearching:YES animated:NO];
        [self forwardSearch:nil];
    }
}


- (void)viewWillDisappear:(BOOL)animated {
    
    
    NSLog(@"%@.%s", [self class], sel_getName(_cmd) );
    
    [self setSearching:NO animated:NO];
    [self setEditing:NO animated:NO];
    
    J1TextViewController *viewController = (J1TextViewController *)[self.pageViewController.viewControllers objectAtIndex:0];
    [viewController resignFirstResponder];
    
    // http://www.lancard.com/blog/2010/04/06/dont-want-hide-uitextview-behind-keyboard/
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [nc removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    }
    
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    
    NSLog(@"%@.%s", [self class], sel_getName(_cmd) );
    
    // Get the text view controller
    J1TextViewController *viewController = (J1TextViewController *)[self.pageViewController.viewControllers objectAtIndex:0];
    
    // Save the document to change the MemoListView in iPhone
    [viewController save];
	
	[super viewDidDisappear:animated];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	NSLog(@"%@.%s editing=%@", [self class], sel_getName(_cmd), ( editing ? @"YES" : @"NO" ) );
	
	[super	setEditing:editing animated:animated];
    
    // get the view controller
    J1TextViewController *viewController = (J1TextViewController *)[self.pageViewController.viewControllers objectAtIndex:0];
    
    if (editing) {
        [viewController setEditing:YES animated:animated];
        [viewController becomeFirstResponder];
    }
    else {
        [viewController setEditing:NO animated:animated];
        [viewController resignFirstResponder];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            // Save the documents to change the MemoListView
            [viewController save];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
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


#pragma mark - Accessors
- (Memo *)editingMemo {
    return editingMemo_;
}

- (void)setEditingMemo:(Memo *)editingMemo {
    editingMemo_ = editingMemo;
    self.navigationItem.title = editingMemo_.title;
    J1TextViewController *vc = (J1TextViewController *)[self.pageViewController.viewControllers lastObject];
    vc.editingMemo = editingMemo_;
    
	NSLog(@"%@.%s editingMemo=%@", [self class], sel_getName(_cmd), editingMemo.identifier);
    
    [[NSUserDefaults standardUserDefaults] setObject:editingMemo.identifier forKey:kTheLastMemo];
    
    self.navigationItem.rightBarButtonItem.enabled = [self.editingMemo.group.type intValue] != kTrashGroup;
    
    if (self.searchString) {
        searchAtLoading = NO;
        if (!searching_) {
            [self setSearching:YES animated:NO];
        }

        [self forwardSearch:nil];
    }

    if (self.popover) {
        [self.popover dismissPopoverAnimated:YES];
    }

}


#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    //NSLog(@"%@",[gestureRecognizer class]);
    return ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]);
}

#pragma mark - ToolbarItmes
- (void)setDefaultToolbarItmes
{
    // set the title
	self.navigationItem.title = self.editingMemo.title;
    
    
    // Set up the edit button
    self.navigationItem.rightBarButtonItem = [self editButtonItem];

    // Set up other item buttons.
    UIBarButtonItem *button1
    = [[UIBarButtonItem alloc]
       initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
       target:self
       action:@selector(searchButtonPressed:)];
    
    UIBarButtonItem *spacer1
    = [[UIBarButtonItem alloc]
       initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *button2
    = [[UIBarButtonItem alloc]
       initWithBarButtonSystemItem:UIBarButtonSystemItemAction
       target:self
       action:@selector(actionButtonPressed:)];
    
    UIBarButtonItem *spacer2
    = [[UIBarButtonItem alloc]
       initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *button3
    = [[UIBarButtonItem alloc]
       initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
       target:self
       action:@selector(trashButtonPressed:)];
    
    UIBarButtonItem *spacer3
    = [[UIBarButtonItem alloc]
       initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *button4
    = [[UIBarButtonItem alloc]
       initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(propertyButtonPressed:)];
    
    // Set up the toolbar
    NSArray *barItems
    = [[NSArray alloc]
       initWithObjects:button1, spacer1, button2, spacer2, button3, spacer3, button4, nil];
    
    self.navigationController.toolbarHidden = NO;
    [self setToolbarItems:barItems animated:YES];
}

- (void)setSearchingToolbarItmes
{
    // Set up the edit and add buttons.
	self.navigationItem.rightBarButtonItem = [self editButtonItem];
	self.navigationItem.title = self.editingMemo.title;
	
    UIBarButtonItem *button1
    = [[UIBarButtonItem alloc]
       initWithBarButtonSystemItem:UIBarButtonSystemItemDone
       target:self
       action:@selector(searchDonePressed:)];
    
    UIBarButtonItem *spacer1
    = [[UIBarButtonItem alloc]
       initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *button2
    = [[UIBarButtonItem alloc]
       initWithBarButtonSystemItem:UIBarButtonSystemItemRewind
       target:self
       action:@selector(backwardSearch:)];
    backwardButton_ = button2;
    
    UIBarButtonItem *spacer2
    = [[UIBarButtonItem alloc]
       initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *button3
    = [[UIBarButtonItem alloc]
       initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward
       target:self
       action:@selector(forwardSearch:)];
    forwardButton_ = button3;
    
    UIBarButtonItem *spacer3
    = [[UIBarButtonItem alloc]
       initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *spacer4
    = [[UIBarButtonItem alloc]
       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    UIBarButtonItem *spacer5
    = [[UIBarButtonItem alloc]
       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    // Set up the toolbar
    NSArray *barItems
    = [[NSArray alloc]
       initWithObjects:button1, spacer1, button2, spacer2, button3, spacer3, spacer4, spacer5, nil];
    
    self.navigationController.toolbarHidden = NO;
    [self setToolbarItems:barItems animated:YES];
}


#pragma mark - Instance Methods


#pragma mark - Page View Controller Data Source
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSLog(@"%@.%s", [self class], sel_getName(_cmd) );

    if (self.isEditing) {
        return nil;
    }
    
    Memo *memo = [self.delegate previousObject:self.editingMemo];
    if (!memo) {
        return nil;
    }
    
    // Create a new view controller
    J1TextViewController *vc = [[J1TextViewController alloc] initWithNibName:@"J1TextViewController" bundle:nil];
    vc.delegate = self;

//    self.editingMemo = memo;
    vc.editingMemo = memo;
    
    return vc;    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSLog(@"%@.%s", [self class], sel_getName(_cmd) );

    if (self.isEditing) {
        return nil;
    }
    
    Memo *memo = [self.delegate nextObject:self.editingMemo];
    if (!memo) {
        return nil;
    }
    
    J1TextViewController *vc = [[J1TextViewController alloc] initWithNibName:@"J1TextViewController" bundle:nil];
    vc.delegate = self;

//    self.editingMemo = memo;
    vc.editingMemo = memo;
    
    return vc;
}

#pragma mark - Page View Controller Delegate
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    NSLog(@"%@.%s didFinishAnimating=%@ transitionCompleted=%@", [self class], sel_getName(_cmd), (finished ? @"YES" : @"NO" ), ( completed ? @"YES" : @"NO" ) );
    
    if (finished && completed) {
        [previousViewControllers
         enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
             // Save the text in the before view
             [(J1TextViewController *)obj save];
        }
        ];
//        self.navigationItem.title = self.editingMemo.title;

        // get the view controller
        J1TextViewController *viewController = (J1TextViewController *)[self.pageViewController.viewControllers objectAtIndex:0];
        [viewController setEditing:NO animated:NO];
        
        [self.delegate deselectObject:self.editingMemo animated:NO];
        [self.delegate selectObject:viewController.editingMemo animated:YES];
        
        self.editingMemo = viewController.editingMemo;
    }
}

#pragma mark - UISplitViewControllerDelegate
- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
	NSLog(@"%@.%s", [self class], sel_getName(_cmd));
    
    barButtonItem.title = viewController.title ? viewController.title : @"Memo";
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    //    [self.detailViewController.toolbarItems setLeftBarButtonItem:barButtonItem animated:YES];
    self.popover = popoverController;  
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)button
{
	NSLog(@"%@.%s", [self class], sel_getName(_cmd));
    
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.popover = nil;
}

- (void)splitViewController:(UISplitViewController *)svc popoverController:(UIPopoverController *)pc willPresentViewController:(UIViewController *)aViewController
{
	NSLog(@"%@.%s", [self class], sel_getName(_cmd));
    
    self.popover = pc;
}


#pragma mark - changing the view size when a keyboard appears
- (void)keyboardWillShow:(NSNotification *)aNotification {
    NSLog(@"%@.%s", [self class], sel_getName(_cmd) );
    
    // get the keyboard CGRect
    CGRect keyboardRect = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [[self.view superview] convertRect:keyboardRect fromView:nil];
    NSLog(@"%@.%s keyboardRect=(%f, %f) frame.size=(%f, %f)", [self class], sel_getName(_cmd), keyboardRect.origin.x, keyboardRect.origin.y, keyboardRect.size.width, keyboardRect.size.height );
    
    // get the keyboard animationDuration
    NSTimeInterval animationDuration = [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // decrement the height of a keyboard
    CGRect frame = self.view.frame;
    NSLog(@"%@.%s before frame.origin=(%f, %f) frame.size=(%f, %f)", [self class], sel_getName(_cmd), frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
    
    // save the original view size
    if (CGSizeEqualToSize(originalViewSize_, CGSizeZero)) {
        originalViewSize_ = frame.size;
    }
    
    frame.size.height = originalViewSize_.height - keyboardRect.size.height;
    
    // adjust toolbar position
    CGRect toolbarFrame = self.navigationController.toolbar.frame;
    toolbarFrame.origin.y = self.view.window.bounds.size.height - toolbarFrame.size.height- keyboardRect.size.height;
    
    // change the view
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    self.view.frame = frame;
    self.navigationController.toolbar.frame = toolbarFrame;
    
    [UIView commitAnimations];
    NSLog(@"%@.%s after frame.origin=(%f, %f) frame.size=(%f, %f)", [self class], sel_getName(_cmd), frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
}

- (void)keyboardWillHide:(NSNotification *)aNotification {
    NSLog(@"%@.%s", [self class], sel_getName(_cmd) );
    
    CGRect keyboardRect = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [[self.view superview] convertRect:keyboardRect fromView:nil];
    
    NSTimeInterval animationDuration = [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGRect frame = self.view.frame;
    frame.size.height += keyboardRect.size.height;
    
    CGRect toolbarFrame = self.navigationController.toolbar.frame;
    toolbarFrame.origin.y = self.view.window.bounds.size.height - toolbarFrame.size.height;
    
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
//  scrollView_.frame = self.view.bounds;
//  scrollView_.contentSize = CGSizeMake( scrollView_.contentSize.width, self.view.bounds.size.height );
    
    self.view.frame = frame;
    self.navigationController.toolbar.frame = toolbarFrame;
    [UIView commitAnimations];
}

#pragma mark - Toolbar

- (void)actionButtonPressed:(id)sender
{
	NSLog(@"%@.%s", [self class], sel_getName(_cmd) );
    
    if (!functionActionSheet) {
        functionActionSheet
        = [[UIActionSheet alloc]
           initWithTitle:nil
           delegate:self
           cancelButtonTitle:@"Cancel"
           destructiveButtonTitle:nil
           otherButtonTitles:@"Email", @"Print", nil];
    }
    
    if (functionActionSheet.visible) {
        [functionActionSheet dismissWithClickedButtonIndex:functionActionSheet.cancelButtonIndex animated:YES];
    }
    else {
        [functionActionSheet showFromBarButtonItem:sender animated:YES];
    }
}

#pragma mark ActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (actionSheet.tag) {
        case kTrashButtonTag:
            switch (buttonIndex) {
                case 0:
                    // Delete this memo
                    [self disposeMemo];
                    break;
                    
                default:
                    break;
            }

            break;
            
        default:
            break;
    }
}

#pragma mark - Default button items
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	NSLog(@"%@.%s", [self class], sel_getName(_cmd));
    
    if ([segue.identifier isEqualToString:@"PropertyView"]) {
        [segue.destinationViewController setEditingMemo:sender];
    }
}


- (void)propertyButtonPressed:(id)sender {
	NSLog(@"%@.%s", [self class], sel_getName(_cmd) );
    
    /*	
     [self performSegueWithIdentifier:@"PropertyView" sender:self.editingMemo];
     */
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        PropertyViewController *vc = [[PropertyViewController alloc] initWithNibName:@"PropertyViewController" bundle:nil];
        vc.editingMemo = self.editingMemo;
        [vc.view sizeToFit];
        vc.contentSizeForViewInPopover = vc.view.bounds.size;

        if (!propertyPopover) {
            propertyPopover = [[UIPopoverController alloc] initWithContentViewController:vc];
        }
        else {
            propertyPopover.contentViewController = vc;
        }
        
        if (propertyPopover.popoverVisible) {
            vc.parentPopover = nil;
            [propertyPopover dismissPopoverAnimated:YES];
        }
        else {
            vc.parentPopover = propertyPopover;
            [propertyPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
    else {
        PropertyViewController *vc = [[PropertyViewController alloc] initWithNibName:@"PropertyViewController" bundle:nil];
        vc.editingMemo = self.editingMemo;
        
        // Tips: http://stackoverflow.com/questions/1814126/using-presentmodalviewcontroller-to-load-a-view/1818086#1818086
        vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self.navigationController presentViewController:vc animated:YES completion:^(void){}];
        //    [self	presentModalViewController:vc animated:YES];
        
    }
    // work around
    //    [self.navigationController pushViewController:vc animated:YES];
    
}

/*
- (void)animationDidStop {
	[UIView setAnimationsEnabled:YES];
}
*/
 

-(void)trashButtonPressed:(id)sender
{
    NSLog(@"%@.%s", [self class], sel_getName(_cmd) );
	
    // Confirm to delete this memo.
    if (!deleteActionSheet) {
        deleteActionSheet
        = [[UIActionSheet alloc]
           initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete this memo" otherButtonTitles:nil];
        deleteActionSheet.tag = kTrashButtonTag;
        
    }
    // Show the action sheet
    if (deleteActionSheet.visible) {
        [deleteActionSheet dismissWithClickedButtonIndex:deleteActionSheet.cancelButtonIndex animated:YES];
    }
    else {
        [deleteActionSheet showFromBarButtonItem:(UIBarButtonItem *)sender animated:YES];
    }
}

- (void)disposeMemo
{
    NSLog(@"%@.%s", [self class], sel_getName(_cmd) );
	
	if (![UIView areAnimationsEnabled]) {
		return;
	}
	
    // Get the next or the previous memo.
    Memo *memo = [self.delegate nextObject:self.editingMemo];
    UIViewAnimationTransition animation = UIViewAnimationTransitionCurlUp;
    if (!memo) {
        memo = [self.delegate previousObject:self.editingMemo];
        animation = UIViewAnimationTransitionCurlDown;
    }
    
    // Dispose the memo and save the context.
    [[J1MemoManager sharedManager] disposeObject:self.editingMemo];
    [[J1CoreDataManager sharedManager] saveContext]; 
    
    if (!memo) {
        // If no other memo does not exist, then pop to the navigation controller.
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }

    // The current page view controller is an old view controller
    UIViewController *oldViewController = self.pageViewController;
   
    // Create a new text view controller
    J1TextViewController *viewController = [[J1TextViewController alloc] initWithNibName:@"J1TextViewController" bundle:nil];
    viewController.editingMemo = memo;
    viewController.delegate = self;
    
    self.editingMemo = memo;
    
    // Create a new page view controller
    UIPageViewController *newViewController
    = [[UIPageViewController alloc]
       initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl
       navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
       options:nil];
    
    [newViewController
     setViewControllers:[NSArray arrayWithObject:viewController]
     direction:UIPageViewControllerNavigationDirectionForward
     animated:NO completion:nil];
    
    newViewController.delegate = self;
    newViewController.dataSource = self;
    
    // Add the new view controller as a child one
    [self addChildViewController:newViewController];
    
        // Animate from the current view to the new view
    [self transitionFromViewController:oldViewController toViewController:newViewController duration:0.3 options:UIViewAnimationOptionTransitionCurlUp animations:NULL completion:^(BOOL finished){
        self.pageViewController = newViewController;
        
        [self.view addSubview:self.pageViewController.view];
        
        // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
        CGRect pageViewRect = self.view.bounds;
/*
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            pageViewRect = CGRectInset(pageViewRect, 40.0, 40.0);
        }
*/        
        self.pageViewController.view.frame = pageViewRect;

        [self.pageViewController didMoveToParentViewController:self];
        
        // Tips http://www.slingsoft.com/blog/uipageviewcontroller.html
        for (UIGestureRecognizer *g in self.pageViewController.gestureRecognizers) {
            g.delegate = self;
        }
        
        // Add the page view controller's gesture recognizers to the book view controller's view so that the gestures are started more easily.
        self.view.gestureRecognizers = self.pageViewController.gestureRecognizers;
        
        [viewController setEditing:NO animated:NO];
    }];

    //transitionWithView:duration:options:animations:completion
/*
    J1TextView *nextView = [[J1TextView alloc] init];
    nextView.frame = self.view.bounds;
    nextView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    nextView.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    nextView.text = memo.contents;
    
    CGFloat width  = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    
    nextView.frame = CGRectMake( width + kViewGap,0.0, width, height );
    //    nextView.hidden = YES;
*/
    
//    [UIView transitionWithView:scrollView_
//                    duration:0.5
//                       options:UIViewAnimationOptionTransitionCurlDown
     //     
//                    animations:^(void){
                        //                nextView.hidden = NO;
//                        
//                     [textView_ removeFromSuperview];
//                        [scrollView_ addSubview:nextView];
//                    }
//                    completion:^(BOOL finishied){
//                        textView_ = nextView;
//                      textView_.delegate = self;
//                        self.editingMemo = memo;
//                        self.navigationItem.title = memo.title;           
//                    }];
    
    /*   
     textView_.userInteractionEnabled = NO;
     
     [UIView animateWithDuration:0.5
     animations:^(void) {
     textView_.text = memo.contents;
     self.navigationItem.title = memo.title;
     }];
     self.editingMemo = memo;
     
     textView_.userInteractionEnabled = YES;
     */
    
    /*    
     // If the next memo does exist, display the next memo.
     nextView_.text = memo.contents;
     
     // Set the textview
     nextView_.delegate = self;
     
     [UIView beginAnimations:nil context:NULL];
     [UIView setAnimationDelegate:self];
     [UIView setAnimationDidStopSelector:@selector(animationDidStop)];
     [UIView	setAnimationDuration:0.5];
     [UIView setAnimationTransition:animation forView:self.view cache:YES];
     
     textView_.userInteractionEnabled = NO;
     textView_.hidden = YES;
     
     nextView_.userInteractionEnabled = YES;
     nextView_.hidden = NO;
     
     self.navigationItem.title = self.editingMemo.title;
     
     [UIView	commitAnimations];
     [UIView	setAnimationsEnabled:NO];
     
     
     self.editingMemo = memo;
     
     J1TextView *temp = textView_;
     textView_ = nextView_;
     nextView_  = temp;
     */
}

- (void)setSearching:(BOOL)searching animated:(BOOL)animated
{
	NSLog(@"%@.%s searching=%@", [self class], sel_getName(_cmd), ( searching ? @"YES" : @"NO" ) );
    
//    J1TextViewController *vc= (J1TextViewController *)[self.pageViewController.viewControllers objectAtIndex:0];
    
    if (searching) {
        searching_ = YES;
        // show a searchBar
        UISearchBar *searchBar = [[UISearchBar alloc] init];
        searchBar.tag = kSearchBarTag; // hint to find the searchBar
        searchBar.delegate = self;
        searchBar.frame = CGRectMake(0, 0, self.pageViewController.view.bounds.size.width, 0);
        searchBar.text  = self.searchString;
        [self.view addSubview:searchBar];
        [searchBar sizeToFit];
        
        CGRect frame = self.pageViewController.view.frame;
        frame.origin.y      += searchBar.bounds.size.height;
        frame.size.height   -= searchBar.bounds.size.height;
        
        if (animated) {
            searchBar.alpha = 0.0;
            [UIView animateWithDuration:0.3
                             animations:^{
                                 searchBar.alpha = 1.0;
                                 self.pageViewController.view.frame = frame;
                             }
                             completion:^(BOOL finished){
                                 [searchBar becomeFirstResponder];
                            }];
        }
        else {
            searchBar.alpha = 1.0;
            self.pageViewController.view.frame = frame;
            [searchBar becomeFirstResponder];
        }
        [self setSearchingToolbarItmes];
    }
    else {
        searching_ = NO;
        // Hide a searchBar
        UIView *view = [self.view viewWithTag:kSearchBarTag];
        if (view) {
            // Tips: http://appteam.blog114.fc2.com/blog-entry-99.html
            [view endEditing:YES];
            [view resignFirstResponder];
            ((UISearchBar *)view).delegate = nil;
            
            CGRect frame = self.pageViewController.view.frame; // vc.view.frame;
            frame.origin.y      -= view.bounds.size.height;
            frame.size.height   += view.bounds.size.height;
            
            if (animated) {
                [UIView animateWithDuration:0.3
                                 animations:^{
                                     view.alpha = 0.0;
                                     self.pageViewController.view.frame = frame;
                                 }
                                 completion:^(BOOL finishied){
                                     [view removeFromSuperview];
                                 }];
            }
            else {
                [view removeFromSuperview];
            }
        }
        backwardButton_ = nil;
        forwardButton_  = nil;
        [self setDefaultToolbarItmes];
    }
}

#pragma mark - Search function

#pragma mark UISearchBar delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    //	NSLog(@"%@.%s", [self class], sel_getName(_cmd) );
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	NSLog(@"%@.%s", [self class], sel_getName(_cmd) );
    
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
	NSLog(@"%@.%s", [self class], sel_getName(_cmd) );
    
    backwardButton_.enabled = YES;
    forwardButton_.enabled = YES;
    
//    [textView_ setEditable:self.editing];
    [searchBar resignFirstResponder];
    [self forwardSearch:nil];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	NSLog(@"%@.%s", [self class], sel_getName(_cmd) );
    
    if (searchBar.text.length == 0) {
        return;
    }
    // Tips: http://appteam.blog114.fc2.com/blog-entry-99.html
    [searchBar endEditing:YES];

    // stackoverflow.com
    [searchBar resignFirstResponder];
    
    self.searchString = searchBar.text;
    [self forwardSearch:nil];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	NSLog(@"%@.%s", [self class], sel_getName(_cmd) );
    
    // Tips: http://appteam.blog114.fc2.com/blog-entry-99.html
    [searchBar endEditing:YES];
    
    [searchBar resignFirstResponder];
    self.searchString = nil;
}

- (void)searchButtonPressed:(id)sender {
    [self setSearching:YES animated:YES];
}

- (void)searchDonePressed:(id)sender {
    [self setSearching:NO animated:YES];
}


- (void)backwardSearch:(id)sender
{
    // hide a keyboard
    UIView *view = [self.view viewWithTag:kSearchBarTag];
    if (view) {
        [view resignFirstResponder];
    }

    J1TextViewController *viewController = (J1TextViewController *)[self.pageViewController.viewControllers objectAtIndex:0];
    
    [viewController searchTextBackward:self.searchString];
}
 
 - (void)forwardSearch:(id)sender
{
    // hide a keyboard
    UIView *view = [self.view viewWithTag:kSearchBarTag];
    if (view) {
        [view resignFirstResponder];
    }

    J1TextViewController *viewController = (J1TextViewController *)[self.pageViewController.viewControllers objectAtIndex:0];
     
    [viewController searchTextForward:self.searchString];
}

- (void)foundText:(NSString *)text backwardRange:(NSRange)bRange forwardRange:(NSRange)fRange
{
	NSLog(@"%@.%s", [self class], sel_getName(_cmd) );
    backwardButton_.enabled = (bRange.location != NSNotFound);
    forwardButton_.enabled  = (fRange.location != NSNotFound);

}


@end
