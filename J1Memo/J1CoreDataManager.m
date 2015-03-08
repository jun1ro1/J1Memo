//
//  J1CoreDataManager.m
//  J1Memo
//
//  Created by 奥 潤一郎 on 11/06/30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "J1CoreDataManager.h"
#define IOS_VERSION_GREATER_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)

@implementation J1CoreDataManager

#pragma mark - properties

@synthesize managedObjectContext=__managedObjectContext;
@synthesize managedObjectModel=__managedObjectModel;
@synthesize persistentStoreCoordinator=__persistentStoreCoordinator;

#pragma mark - static variables

static J1CoreDataManager *sJ1CoreDataManager = nil;

#pragma mark - memory management
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

#pragma mark - class methods
+ (J1CoreDataManager *)sharedManager {
    
    if (!sJ1CoreDataManager) {
        sJ1CoreDataManager = [[J1CoreDataManager alloc] init];
    }
    return sJ1CoreDataManager;
}


#pragma mark - Core Data stack
- (void)saveContext
{
    NSManagedObjectContext *moc = self.managedObjectContext;
    [moc performBlockAndWait:^{
        if (moc != nil)
        {
            NSError *error = nil;
            if ([moc hasChanges] && ![moc save:&error])
            {
                /*
                 Replace this implementation with code to handle the error appropriately.
                 
                 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
                 */
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            } 
        }
    }];
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        // iCloud
        // Tips: https://goddess-gate.com/dc2/index.php/post/452
        
        if (IOS_VERSION_GREATER_THAN(@"5.0")) {
            // iCloud is active
            NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
            [moc performBlockAndWait:^{
                [moc setPersistentStoreCoordinator:coordinator];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mergeChangesFrom_iCloud:) name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:coordinator];
            }];
            __managedObjectContext = moc;
        }
        else{
            __managedObjectContext = [[NSManagedObjectContext alloc] init];
            [__managedObjectContext setPersistentStoreCoordinator:coordinator];
        }
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    // https://goddess-gate.com/dc2/index.php/post/452
    // http://stackoverflow.com/questions/1092396/iphone-retrieving-resources-for-logical-unit-tests
    // http://d.hatena.ne.jp/rabbit2go/touch/20110219/1298114054
    // http://iamleeg.blogspot.com/2010/01/unit-testing-core-data-driven-apps-fit.html
    // NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"J1Memo" withExtension:@"momd"];
    NSArray *bundles = [NSArray arrayWithObject:[NSBundle bundleForClass:[self class]]];
    __managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:bundles];

//    NSURL *modelURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"J1Memo" withExtension:@"momd"];
//    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    

    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"J1Memo.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSPersistentStoreCoordinator *psc = __persistentStoreCoordinator;
    
    if (IOS_VERSION_GREATER_THAN(@"5.0")) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            NSDictionary *options = nil;
//          NSURL *cloudURL = [fileManager URLForUbiquityContainerIdentifier:@"com.me.jun1ro1.J1Memo"];
            NSURL *cloudURL = [fileManager URLForUbiquityContainerIdentifier:nil];
            NSString *coreDataCloudContent = [[cloudURL path] stringByAppendingPathComponent:@"data"];
            if ([coreDataCloudContent length] != 0) {
                // iCloud is available
                cloudURL = [NSURL fileURLWithPath:coreDataCloudContent];
                options = [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                           [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                           @"J1Memo.sotre", NSPersistentStoreUbiquitousContentNameKey,
                           cloudURL, NSPersistentStoreUbiquitousContentURLKey,
                           nil];
            }
            else {
                // iCloud is not avalable
                options = [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                           [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                           nil];
            }

            NSError *error = nil;
            [psc lock];
            if (![psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
            [psc unlock];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"asynchronous added persistent store");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RefetchAllDatabaseData" object:self userInfo:nil];
            });
        });
    }
    else {
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                                 nil];
        if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             
             Typical reasons for an error here include:
             * The persistent store is not accessible;
             * The schema for the persistent store is incompatible with current managed object model.
             Check the error message to determine what the actual problem was.
             
             
             If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
             
             If you encounter schema incompatibility errors during development, you can reduce their frequency by:
             * Simply deleting the existing store:
             [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
             
             * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
             [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
             
             Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
             
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }        
    }
        
    
    return __persistentStoreCoordinator;
}

- (void)mergeiCloudChanges:(NSNotification *)note forContext:(NSManagedObjectContext *)moc {
    [moc mergeChangesFromContextDidSaveNotification:note];

    NSNotification *refreshNotification = [NSNotification notificationWithName:@"RefreshAllViews" object:self userInfo:[note userInfo]];
    [[NSNotificationCenter defaultCenter] postNotification:refreshNotification];
}

- (void)mergeChangesFrom_iCloud:(NSNotification *)notification {
    NSManagedObjectContext *moc = [self managedObjectContext];
    
    [moc performBlock:^{
        [self mergeiCloudChanges:notification forContext:moc];
    }];
}


#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
