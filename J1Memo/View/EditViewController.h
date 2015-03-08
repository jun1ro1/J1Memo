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
#import "J1TextSearchDelegate.h"

@interface EditViewController : UIViewController 
<UISearchBarDelegate, UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIActionSheetDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate, UISplitViewControllerDelegate,
    J1TextSearchDelegate>
{
    
	Memo __weak                     *editingMemo_;
    Memo __weak                     *nextMemo;
    
    id <MemoManagerDelegate> __weak delegate;
    
    // for search function
    NSString                        *searchString_;

@private
    CGSize                          originalViewSize_;
    UIBarButtonItem                 *backwardButton_;
    UIBarButtonItem                 *forwardButton_;
    UIPopoverController             *propertyPopover;
    UIActionSheet                   *functionActionSheet;
    UIActionSheet                   *deleteActionSheet;
    
    BOOL                            searchAtLoading;
    
    BOOL                            searching_;
    CGPoint                         beganPoint_;
    
}

@property (nonatomic, weak) Memo    *editingMemo;
@property (nonatomic, weak) Memo    *nextMemo;
@property (nonatomic) id<MemoManagerDelegate> __weak delegate;

@property (nonatomic, readonly) BOOL searching;
@property (nonatomic, strong) NSString  *searchString;

// for user interface
@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, strong) UIPopoverController           *popover;

- (void)setSearching:(BOOL)searching animated:(BOOL)animated;


@end
