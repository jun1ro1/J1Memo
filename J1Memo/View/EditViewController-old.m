//
//  EditViewController.m
//  J1Memo
//
//  Created by 奥 潤一郎 on 11/07/24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EditViewController.h"
#import "J1CoreDataManager.h"
#import "PropertyViewController.h"
#import "J1MemoManager.h"

#pragma mark - Constants
static int kSearchBarTag  = 100;
const  float kViewGap = 8.0;

@interface EditViewController ()
- (void)setDefaultToolbarItmes;
- (void)forwardSearch:(id)sender;
- (void)backwardSearch:(id)sender;
@end

@implementation EditViewController

#pragma mark - Property

@synthesize editingMemo;
@synthesize nextMemo;
@synthesize delegate;
@synthesize searching    = searching_;
@synthesize searchString = searchString_;

#pragma mark - View lifecycle

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

    // Create and set up text views
    textView_ = [[J1TextView alloc] init];
    textView_.frame = self.view.bounds;
    textView_.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    textView_.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    
	// Set the textview
	textView_.delegate      = self;
	textView_.text          = self.editingMemo.contents;
    
	textView_.userInteractionEnabled = YES;
	textView_.hidden = NO;

    
    // Create and set up a TextView for the previous view
    prevView_ = [[J1TextView alloc] init];
    prevView_.frame = self.view.bounds;
    prevView_.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    prevView_.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
	prevView_.userInteractionEnabled = NO;
	prevView_.hidden = YES;
    
    // Create and set up a TextView for the next view
    nextView_ = [[J1TextView alloc] init];
    nextView_.frame = self.view.bounds;
    nextView_.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    nextView_.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
	nextView_.userInteractionEnabled = NO;
	nextView_.hidden = YES;

    // Set up the scroll view
    scrollView_.frame = self.view.bounds;
    scrollView_.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // Expand the horizontal size of the scroll view for previous, current and next views.
    scrollView_.contentSize = CGSizeMake( self.view.bounds.size.width * 3 + kViewGap * 2, self.view.bounds.size.height );
    
    // paging enabled
    scrollView_.pagingEnabled = YES;
     
    scrollView_.showsHorizontalScrollIndicator = NO;
    scrollView_.showsVerticalScrollIndicator = NO;
    scrollView_.scrollsToTop = NO;
    scrollView_.backgroundColor = [UIColor darkGrayColor];
    
    
    // Put the views on the scroll view.
    CGFloat width  = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    
    prevView_.frame = CGRectMake( 0.0,                       0.0, width, height );
    textView_.frame = CGRectMake( width + kViewGap,          0.0, width, height );
    nextView_.frame = CGRectMake( ( width + kViewGap )* 2.0, 0.0, width, height );
    [scrollView_ addSubview:prevView_];
    [scrollView_ addSubview:textView_];
    [scrollView_ addSubview:nextView_];

    // add the scroll view to the view
    [self.view addSubview:scrollView_];
    
    // display the 2nd frame as a current page
    [scrollView_ scrollRectToVisible:CGRectMake( width + kViewGap, 0.0, width, height ) animated:NO];
    
    // set the delegate
    scrollView_.delegate = self;
    
    [self setDefaultToolbarItmes];

	changed_ = NO;
}

- (void)setDefaultToolbarItmes
{
    // Set up the edit and add buttons.
	self.navigationItem.rightBarButtonItem = [self editButtonItem];
	self.navigationItem.title = self.editingMemo.title;
	
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

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	if ( self.editing ) {
		textView_.editable = YES;
		[textView_ becomeFirstResponder];
	}
	else {
		textView_.editable = NO;
	}
	
    // Tips http://www.lancard.com/blog/2010/04/06/dont-want-hide-uitextview-behind-keyboard/
    // Tips http://stackoverflow.com/questions/1887891/what-is-the-reason-the-uikeyboardwillshownotification-called-once
    // TIps http://mobile.tutsplus.com/tutorials/iphone/ios-sdk-keeping-content-from-underneath-the-keyboard/
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
	[super viewWillAppear:animated];    
}

- (void)viewDidAppear:(BOOL)animated
{
    originalViewSize_ = CGSizeZero;
}


- (void)viewWillDisappear:(BOOL)animated {
    
    [self setSearching:NO animated:NO];
    [self setEditing:NO animated:NO];

	if (changed_) {
		[textView_ resignFirstResponder];
	}
    
    // http://www.lancard.com/blog/2010/04/06/dont-want-hide-uitextview-behind-keyboard/
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [nc removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	
	if (changed_) {
		self.editingMemo.contents = textView_.text;
		[[J1CoreDataManager sharedManager] saveContext];
        changed_ = NO;
	}
	
	[super viewDidDisappear:animated];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	NSLog(@"%@.%s editing=%@", [self class], sel_getName(_cmd), ( editing ? @"YES" : @"NO" ) );
	
	[super	setEditing:editing animated:animated];

	if (editing) {
		textView_.editable = YES;
		[textView_ becomeFirstResponder];
	}
	else {
		textView_.editable = NO;
		[textView_ resignFirstResponder];
	}
    
    // Paging scroll is disabed at the editing mode.
    [scrollView_ setScrollEnabled:(!editing)];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Instance Methods
- (void)selectRange:(NSRange)range
{
    [textView_ resignFirstResponder];

    // http://stackoverflow.com/questions/1708608/uitextview-selectedrange-not-displaying-when-set-programatically
    [textView_ scrollRangeToVisible:range];

    // Prevent a keyboard appearing
    textView_.editable = self.editing;

    [textView_ select:self];
    textView_.selectedRange = range;
}

#pragma mark - UIScrollViewDelegate
// http://iphone-dev.g.hatena.ne.jp/tokorom/20101002/1285998723

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.editing) {
        return;
    }

	NSLog(@"%@.%s", [self class], sel_getName(_cmd) );
    
    beganPoint_ = scrollView.contentOffset;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.editing) {
        return;
    }

    NSLog(@"%@.%s", [self class], sel_getName(_cmd) );
    
    if (fabs(scrollView.contentOffset.x - beganPoint_.x) < kViewGap) {
        NSLog(@"%@.%s return with no operation", [self class], sel_getName(_cmd) );
        return;
    }
    
    // Get the next memo
    J1TextView *theView = nil;
    
    if (scrollView.contentOffset.x < beganPoint_.x) {
        // scroll to the left
        self.nextMemo = [self.delegate previousObject:self.editingMemo];
        theView = prevView_;
    }
    else {
        // scroll to the right
        self.nextMemo = [self.delegate nextObject:self.editingMemo];
        theView = nextView_;
    }
    
	if (!self.nextMemo) {
		return;
	}
    
	theView.text = nextMemo.contents;
    theView.hidden = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.editing) {
        return;
    }

    NSLog(@"%@.%s", [self class], sel_getName(_cmd) );
    
    CGFloat width  = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;

    if (!self.nextMemo) {
        // display the current page when no next memo, and return.
        [scrollView_ scrollRectToVisible:CGRectMake( width + kViewGap, 0.0, width, height ) animated:YES];
       return;
    }
    
    if (fabs(scrollView.contentOffset.x - beganPoint_.x) < width / 2.0) {
        // display the current page when not enough scrolling
        self.nextMemo = nil; // release the next memo
        [scrollView_ scrollRectToVisible:CGRectMake( width + kViewGap, 0.0, width, height ) animated:YES];
        return;
    }

    // save the current memo
    if (changed_) {
		self.editingMemo.contents = textView_.text;
		[[J1CoreDataManager sharedManager] saveContext];
        changed_ = NO;
	}
	
    // change the next memo as a current memo
    self.editingMemo = self.nextMemo;
    self.nextMemo = nil;
    textView_.text = self.editingMemo.contents;
	self.navigationItem.title = self.editingMemo.title;

    // display the current page
    [scrollView_ scrollRectToVisible:CGRectMake( width + kViewGap, 0.0, width, height )  animated:NO];
    
    prevView_.hidden = YES;
    nextView_.hidden = YES;

    prevView_.text = nil;
    nextView_.text = nil;
}

#pragma mark - Text view methods

// http://stackoverflow.com/questions/5384072/uitextview-setselectedrange-changes-editable-property

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    return self.editing;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    return self.editing;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    NSLog(@"%@ %s", [[self class] description], sel_getName(_cmd));
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    NSLog(@"%@ %s", [[self class] description], sel_getName(_cmd));
}

- (void)textViewDidChange:(UITextView *)textView {
//    NSLog(@"%@ %s", [[self class] description], sel_getName(_cmd));
	changed_ = YES;
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
    scrollView_.frame = self.view.bounds;
    scrollView_.contentSize = CGSizeMake( scrollView_.contentSize.width, self.view.bounds.size.height );

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
    scrollView_.frame = self.view.bounds;
    scrollView_.contentSize = CGSizeMake( scrollView_.contentSize.width, self.view.bounds.size.height );

    self.view.frame = frame;
    self.navigationController.toolbar.frame = toolbarFrame;
    [UIView commitAnimations];
}

#pragma mark - Toolbar

- (void)actionButtonPressed:(id)sender
{
	NSLog(@"%@.%s", [self class], sel_getName(_cmd) );
    
    UIActionSheet *actionSheet
    = [[UIActionSheet alloc]
       initWithTitle:nil
       delegate:self
       cancelButtonTitle:@"Cancel"
       destructiveButtonTitle:nil
       otherButtonTitles:@"Email", @"Print", nil];
    [actionSheet showFromBarButtonItem:sender animated:YES];
}

#pragma mark ActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            //
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
    
	PropertyViewController *vc = [[PropertyViewController alloc] initWithNibName:@"PropertyViewController" bundle:nil];
	vc.editingMemo = self.editingMemo;
	
    // http://stackoverflow.com/questions/1814126/using-presentmodalviewcontroller-to-load-a-view/1818086#1818086
	vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self.navigationController presentViewController:vc animated:YES completion:^(void){}];
//    [self	presentModalViewController:vc animated:YES];

    // work around
//    [self.navigationController pushViewController:vc animated:YES];

}

- (void)animationDidStop {
	[UIView setAnimationsEnabled:YES];
}													

-(void)trashButtonPressed:(id)sender
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
    
    //transitionWithView:duration:options:animations:completion
    
    J1TextView *nextView = [[J1TextView alloc] init];
    nextView.frame = self.view.bounds;
    nextView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    nextView.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    nextView.text = memo.contents;
    
    CGFloat width  = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    
    nextView.frame = CGRectMake( width + kViewGap,0.0, width, height );
//    nextView.hidden = YES;

    [UIView transitionWithView:scrollView_
            duration:0.5
            options:UIViewAnimationOptionTransitionCurlDown
//     
            animations:^(void){
//                nextView.hidden = NO;

                [textView_ removeFromSuperview];
                [scrollView_ addSubview:nextView];
            }
            completion:^(BOOL finishied){
                textView_ = nextView;
                textView_.delegate = self;
                self.editingMemo = memo;
                self.navigationItem.title = memo.title;           
            }];
         
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

    if (searching) {
        searching_ = YES;
        // show a searchBar
        UISearchBar *searchBar = [[UISearchBar alloc] init];
        searchBar.tag = kSearchBarTag; // hint to find the searchBar
        searchBar.delegate = self;
        searchBar.frame = CGRectMake(0, 0, textView_.bounds.size.width, 0);
        searchBar.alpha = 0.0;
        [self.view addSubview:searchBar];
        [searchBar sizeToFit];
        
        CGRect frame = textView_.frame;
        frame.origin.y      += searchBar.bounds.size.height;
        frame.size.height   -= searchBar.bounds.size.height;
        
        if (animated) {
            [UIView animateWithDuration:0.3
                             animations:^{
                                 searchBar.alpha = 1.0;
                                 textView_.frame = frame;
                             }
                             completion:^(BOOL finished){
                                 [searchBar becomeFirstResponder];
                             }];
        }
        else {
            [searchBar becomeFirstResponder];
        }
        [self setSearchingToolbarItmes];
    }
    else {
        searching_ = NO;
        // Hide a searchBar
        UIView *view = [self.view viewWithTag:kSearchBarTag];
        if (view) {
            [view resignFirstResponder];
            ((UISearchBar *)view).delegate = nil;
            
            CGRect frame = textView_.frame;
            frame.origin.y      -= view.bounds.size.height;
            frame.size.height   += view.bounds.size.height;
            
            if (animated) {
                [UIView animateWithDuration:0.3
                                 animations:^{
                                     view.alpha = 0.0;
                                     textView_.frame = frame;
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
#pragma mark Search a text
- (NSRange)searchText:(NSString *)text options:(NSStringCompareOptions)aMask range:(NSRange)aRange
{
	NSLog(@"%@.%s text=%@", [self class], sel_getName(_cmd), text );

    if (!text) {
        // Not found
        return NSMakeRange(NSNotFound, 0);
    }
    
    // Check the range bound
    NSRange range = aRange;
    range.location = MIN(range.location, textView_.text.length - 1);
    range.length   = MIN(range.length  , textView_.text.length - range.location);
    
    NSStringCompareOptions mask = NSCaseInsensitiveSearch;
    if (aMask & NSBackwardsSearch) {
        mask |= NSBackwardsSearch;
    }
    
	NSLog(@"%@.%s location=%d length=%d", [self class], sel_getName(_cmd), range.location, range.length);

    NSRange found = [textView_.text rangeOfString:text options:mask range:range];
    
    return found;
}

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
    
    [textView_ setEditable:self.editing];
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	NSLog(@"%@.%s", [self class], sel_getName(_cmd) );

    if (searchBar.text.length == 0) {
        return;
    }
    // stackoverflow.com
    [searchBar resignFirstResponder];

    searchBackwardRange_ = NSMakeRange(0, textView_.text.length); 
    searchForwardRange_  = NSMakeRange(0, textView_.text.length); 
    self.searchString = searchBar.text;
    [self forwardSearch:nil];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	NSLog(@"%@.%s", [self class], sel_getName(_cmd) );
    
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
    NSRange found = [self searchText:self.searchString options:NSBackwardsSearch range:searchBackwardRange_];
    if (found.location != NSNotFound) {
        [self selectRange:found];

        // Set up the next range
        searchBackwardRange_ = NSMakeRange(0, found.location + 1);
        searchForwardRange_  = NSMakeRange(found.location + found.length, textView_.text.length - found.location);
 
        NSRange next = NSMakeRange(NSNotFound, 0);
        next = [self searchText:self.searchString options:NSBackwardsSearch range:searchBackwardRange_];
        backwardButton_.enabled = (next.location != NSNotFound);
        
        next = [self searchText:self.searchString options:0 range:searchForwardRange_];
        forwardButton_.enabled = (next.location != NSNotFound);
    }
    else {
        searchBackwardRange_ = NSMakeRange(0, textView_.text.length); 
        searchForwardRange_  = NSMakeRange(0, textView_.text.length); 
        backwardButton_.enabled = NO;
        forwardButton_.enabled  =NO;
    }
}

- (void)forwardSearch:(id)sender
{
    NSRange found = [self searchText:self.searchString options:0 range:searchForwardRange_];
    if (found.location != NSNotFound) {
        [self selectRange:found];
        
        // Set up the next range
        searchBackwardRange_ = NSMakeRange(0, found.location + 1);
        searchForwardRange_  = NSMakeRange(found.location + found.length, textView_.text.length - found.location);
        
        NSRange next = NSMakeRange(NSNotFound, 0);
        next = [self searchText:self.searchString options:NSBackwardsSearch range:searchBackwardRange_];
        backwardButton_.enabled = (next.location != NSNotFound);
        
        next = [self searchText:self.searchString options:0 range:searchForwardRange_];
        forwardButton_.enabled = (next.location != NSNotFound);
    }
    else {
        searchBackwardRange_ = NSMakeRange(0, textView_.text.length); 
        searchForwardRange_  = NSMakeRange(0, textView_.text.length); 
        backwardButton_.enabled = NO;
        forwardButton_.enabled  =NO;
    }
}


@end
