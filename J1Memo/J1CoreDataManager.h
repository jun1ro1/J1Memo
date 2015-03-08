//
//  J1CoreDataManager.h
//  J1Memo
//
//  Created by 奥 潤一郎 on 11/06/30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface J1CoreDataManager : NSObject {
}

@property (nonatomic, readonly, strong) NSManagedObjectContext          *managedObjectContext;
@property (nonatomic, readonly, strong) NSManagedObjectModel            *managedObjectModel;
@property (nonatomic, readonly, strong) NSPersistentStoreCoordinator    *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

// class method
+ (J1CoreDataManager *)sharedManager;

@end
