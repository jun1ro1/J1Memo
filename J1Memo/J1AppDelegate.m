//
//  J1AppDelegate.m
//  J1Memo
//
//  Created by OKU Junichirou on 11/09/11.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "J1AppDelegate.h"
#import "J1CoreDataManager.h"
#import "J1GroupManager.h"
#import "J1MemoManager.h"
#import "Memo.h"
#import "EditViewController.h"

NSString *kTheLastMemo = @"TheLastMemo";

@implementation J1AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	NSLog(@"%@.%s", [self class], sel_getName(_cmd));

    // Override point for customization after application launch.
 
    // Initialize the Core Data as the first step
    // Tips: http://stackoverflow.com/questions/12075831/coredata-this-nspersistentstorecoordinator-has-no-persistent-stores-it-cannot
    NSManagedObjectContext *moc = [[J1CoreDataManager sharedManager] managedObjectContext];

    J1MemoManager *manager = [J1MemoManager sharedManager];
	NSLog(@"%@.%s MemoManager = %@", [self class], sel_getName(_cmd), manager);

    // Get the last memo
    NSString *lastMemoID = [[NSUserDefaults standardUserDefaults] stringForKey:kTheLastMemo];
	NSLog(@"%@.%s the last memo ID = %@", [self class], sel_getName(_cmd), lastMemoID);
    
    Memo *memo = [manager fetchObjectWith:lastMemoID];
    
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        NSLog(@"%@.%s window.rootViewController = %@", [self class], sel_getName(_cmd), self.window.rootViewController);
        UISplitViewController *svc = (UISplitViewController *)self.window.rootViewController;
        UIViewController *mvc = [[[svc.viewControllers objectAtIndex:0] viewControllers] lastObject];
        EditViewController *dvc = [[[svc.viewControllers lastObject]      viewControllers] lastObject];
        NSLog(@"%@.%s Master View Controller = %@", [self class], sel_getName(_cmd), mvc);
        NSLog(@"%@.%s Detail View Controller = %@", [self class], sel_getName(_cmd), dvc);
        
        NSLog(@"%@.%s last memo = %@", [self class], sel_getName(_cmd), memo);
        
        if (!memo) {
            memo = [[J1MemoManager sharedManager] insertNewObject:[J1GroupManager sharedOthersGroup]];
        }
        
        // Tips: http://stackoverflow.com/questions/2754666/ipad-uisplitview-initial-state-in-portrait-how-to-display-popover-controller-wi
        svc.delegate = (id)dvc;
        dvc.editingMemo = memo;
    }
    else {
            
    }

    
    return YES;
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    [[J1CoreDataManager sharedManager] saveContext];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    [[J1CoreDataManager sharedManager] saveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    [[J1CoreDataManager sharedManager] saveContext];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [[J1CoreDataManager sharedManager] saveContext];
}


@end
