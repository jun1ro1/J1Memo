//
//  MemoListViewController.h
//  J1Memo
//
//  Created by 奥 潤一郎 on 11/07/21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"
#import "Memo.h"
#import "MemoManagerDelegate.h"

@class EditViewController;

@interface MemoListViewController : UIViewController
    <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate,
    UISearchBarDelegate, UISearchDisplayDelegate, UIActionSheetDelegate, 
    MemoManagerDelegate>
{
    // instance variable
    Group __weak                    *selectedGroup_;
    
    // user interface
    IBOutlet    UITableView         *originalTableView_;
    UIBarButtonItem                 *organizeButton_;
    UIBarButtonItem                 *disposeButton_;
    UIBarButtonItem                 *composeButton_;
//    UIPopoverController             *popover_;
    
    UIActionSheet                   *disposeActionSheet_;

    // search bar
    IBOutlet    UISearchBar         *searchBar_;
   
    
@private
    // the currently displayed table view which is equal to "originalTableView_" or "searchResultsTableView"
    UITableView                     *tableView_;
    
    NSFetchedResultsController      *fetchedResultsController_;
    NSMutableSet                    *selectedObjects_;
    
    UISearchDisplayController       *searchDisplayController_;
    NSString                        *searchString_;
}

@property (strong, nonatomic) EditViewController *detailViewController;

@property (nonatomic, weak)   Group                         *selectedGroup;
@property (nonatomic, strong) NSFetchedResultsController    *fetchedResultsController;
@property (nonatomic, strong) UITableView                   *tableView;
@property (nonatomic, strong) NSMutableSet                  *selectedObjects;

- (IBAction)compose:(id)sender;

@end
