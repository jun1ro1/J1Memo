//
//  EditViewController.h
//  J1Memo
//
//  Created by 奥 潤一郎 on 11/07/24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "J1TextView.h"
#import "Memo.h"
#import "MemoManagerDelegate.h"

@interface EditViewController_old : UIViewController 
    <UITextViewDelegate, UISearchBarDelegate, UIScrollViewDelegate, UIActionSheetDelegate>
{
    
	Memo __weak                     *editingMemo;
    Memo __weak                     *nextMemo;

    id <MemoManagerDelegate> __weak delegate;
    
    // for search function
    NSString                        *searchString_;

    IBOutlet UIScrollView           *scrollView_;
    J1TextView                      *prevView_;
	J1TextView                      *textView_;
    J1TextView                      *nextView_;
    
@private
    CGSize                          originalViewSize_;
    UIBarButtonItem                 *backwardButton_;
    UIBarButtonItem                 *forwardButton_;
    
    BOOL                            searching_;
	BOOL                            changed_;
    CGPoint                         beganPoint_;

    // for search function
    NSRange                         searchBackwardRange_;
    NSRange                         searchForwardRange_;
}

@property (nonatomic, weak) Memo    *editingMemo;
@property (nonatomic, weak) Memo    *nextMemo;
@property (nonatomic) id<MemoManagerDelegate> __weak delegate;
@property (nonatomic, readonly) BOOL searching;
@property (nonatomic, strong) NSString  *searchString;

- (void)setSearching:(BOOL)searching animated:(BOOL)animated;

- (NSRange)searchText:(NSString *)text options:(NSStringCompareOptions)aMask range:(NSRange)aRange ;
- (void)selectRange:(NSRange)range;

@end
