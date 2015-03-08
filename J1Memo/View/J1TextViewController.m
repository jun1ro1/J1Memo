//
//  J1TextViewController.m
//  J1Memo
//
//  Created by 潤一郎 奥 on 11/10/29.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "J1AppDelegate.h"
#import "J1TextViewController.h"
#import "J1CoreDataManager.h"

@implementation J1TextViewController

@synthesize editable;
/* @synthesize editingMemo = editingMemo_; */
@synthesize textView = textView_;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    NSLog(@"%@ %s", [[self class] description], sel_getName(_cmd));
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
    NSLog(@"%@ %s", [[self class] description], sel_getName(_cmd));

    // Do any additional setup after loading the view from its nib.
    
    // Set the text view delegate
    self.textView.delegate = self;
    
    // Set the content
    self.textView.text = self.editingMemo.contents;
    [[NSUserDefaults standardUserDefaults] setObject:self.editingMemo.identifier forKey:kTheLastMemo];
        
    // Set to be not edited
    changed_ = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSLog(@"%@ %s", [[self class] description], sel_getName(_cmd));
    
    // Write back to the managed object
    [self save];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    NSLog(@"%@ %s", [[self class] description], sel_getName(_cmd));
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    NSLog(@"%@ %s", [[self class] description], sel_getName(_cmd));

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

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    [super setEditing:editing animated:animated];
    
    if (editing) {
        self.editable = YES;
        self.textView.editable = YES;
        [self.textView setEditable2:YES];
        [self.textView becomeFirstResponder];
    }
    else {
        self.editable = NO;
        self.textView.editable = NO;
        [self.textView setEditable2:NO];
        [self.textView resignFirstResponder];
    }
}


#pragma mark - Accessors

- (Memo *)editingMemo {
    return editingMemo_;
}

- (void)setEditingMemo:(Memo *)editingMemo {
    editingMemo_ = editingMemo;
    self.textView.text = editingMemo_.contents;

    searchBackwardRange_ = NSMakeRange(0, textView_.text.length); 
    searchForwardRange_  = NSMakeRange(0, textView_.text.length); 
    
    [[NSUserDefaults standardUserDefaults] setObject:editingMemo.identifier forKey:kTheLastMemo];
}

- (void)selectRange:(NSRange)range
{
    [textView_ resignFirstResponder];
    
    [textView_ scrollRangeToVisible:range];
    
    // Prevent a keyboard appearing
    textView_.editable = self.editing;
    
    // Tips: http://stackoverflow.com/questions/1708608/uitextview-selectedrange-not-displaying-when-set-programatically
    [textView_ select:self];
    textView_.selectedRange = range;
    
    // Prevent to enter an editing mode when the method "selectedRange" is called
//    textView_.editable = self.editing;
}

#pragma mark - text view delegate

// http://stackoverflow.com/questions/5384072/uitextview-setselectedrange-changes-editable-property

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    NSLog(@"%@ %s editing=%d", [[self class] description], sel_getName(_cmd), self.editing);
    return self.editing;
//  return YES;
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


- (BOOL)isChanged
{
    return changed_;
}

- (void)save;
{
    NSLog(@"%@ %s changed=%@", [[self class] description], sel_getName(_cmd), changed_ ? @"YES" : @"NO"); 
    if (changed_) {
       self.editingMemo.contents = self.textView.text;
       [[J1CoreDataManager sharedManager] saveContext];
        changed_ = NO;
    }

}

#pragma mark - search functions

#pragma mark Search a text in the specified range
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

    // Do searching
    NSRange found = [textView_.text rangeOfString:text options:mask range:range];
    
    return found;
}

- (void)searchTextBackward:(NSString *)text
{
    // Do searching
    NSRange found = [self searchText:text options:NSBackwardsSearch range:searchBackwardRange_];
    NSRange backwardRange = NSMakeRange(NSNotFound, 0);
    NSRange forwardRange  = NSMakeRange(NSNotFound, 0);
    
    if (found.location != NSNotFound) {
        // Select the found string
        [self selectRange:found];
        
        // Set up the next range
        searchBackwardRange_ = NSMakeRange(0, found.location + 1);
        searchForwardRange_  = NSMakeRange(found.location + found.length, textView_.text.length - found.location);
        
        // delegate
        
        backwardRange = [self searchText:text options:NSBackwardsSearch range:searchBackwardRange_];
        forwardRange  = [self searchText:text options:0 range:searchForwardRange_];
    }
    else {
        [self selectRange:NSMakeRange(0, 0)];
        searchBackwardRange_ = NSMakeRange(0, textView_.text.length); 
        searchForwardRange_  = NSMakeRange(0, textView_.text.length); 
    }
    
    if ([delegate respondsToSelector:@selector(foundText:backwardRange:forwardRange:)]) {
        [delegate foundText:text backwardRange:backwardRange forwardRange:forwardRange];
    }

}

- (void)searchTextForward:(NSString *)text
{
    NSRange found = [self searchText:text options:0 range:searchForwardRange_];

    NSRange backwardRange = NSMakeRange(NSNotFound, 0);
    NSRange forwardRange  = NSMakeRange(NSNotFound, 0);
     
    if (found.location != NSNotFound) {
        [self selectRange:found];
        
        // Set up the next range
        searchBackwardRange_ = NSMakeRange(0, found.location + 1);
        searchForwardRange_  = NSMakeRange(found.location + found.length, textView_.text.length - found.location);
        
        backwardRange = [self searchText:text options:NSBackwardsSearch range:searchBackwardRange_];
        forwardRange  = [self searchText:text options:0 range:searchForwardRange_];
    }
    else {
        [self selectRange:NSMakeRange(0, 0)];
        searchBackwardRange_ = NSMakeRange(0, textView_.text.length);
        searchForwardRange_  = NSMakeRange(0, textView_.text.length); 
    }

    if ([delegate respondsToSelector:@selector(foundText:backwardRange:forwardRange:)]) {
        [delegate foundText:text backwardRange:backwardRange forwardRange:forwardRange];
    }
}

@end
