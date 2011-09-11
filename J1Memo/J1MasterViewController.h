//
//  J1MasterViewController.h
//  J1Memo
//
//  Created by OKU Junichirou on 11/09/11.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class J1DetailViewController;

@interface J1MasterViewController : UITableViewController

@property (strong, nonatomic) J1DetailViewController *detailViewController;
@property (nonatomic) BOOL useiCloud;
@property (strong, nonatomic) NSMutableArray *documentURLs;
@property (strong, nonatomic) NSMetadataQuery *query;

- (IBAction)addDocument:(id)sender;

@end
