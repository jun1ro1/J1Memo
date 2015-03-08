//
//  J1MemoManager.m
//  J1Memo
//
//  Created by 奥 潤一郎 on 11/07/19.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "J1MemoManager.h"
#import "J1CoreDataManager.h"
#import "J1GroupManager.h"

@implementation J1MemoManager

#pragma mark - static variables
static J1MemoManager    *sManager	= nil;

#pragma mark - Initialize
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


#pragma mark - Singleton
+ (J1MemoManager *)sharedManager {
    if (!sManager) {
        sManager = [[J1MemoManager alloc] init];
    }
    return sManager;
}


#pragma mark - instance method
- (Memo *)insertNewObject:(Group *)group {
    
	NSManagedObjectContext *context = [J1CoreDataManager sharedManager].managedObjectContext;
	Memo *newManagedObject = 
    [NSEntityDescription insertNewObjectForEntityForName:@"Memo" inManagedObjectContext:context];
    
    // add to the specified Group or the Others Group
	if (group == nil) {
        // Add to the "OthersGroup"
        [[J1GroupManager sharedOthersGroup] addMemosObject:newManagedObject];
	}
    else if (group == [J1GroupManager sharedAllGroup]) {
        // Add to the "OthersGroup" instead of the "AllGroup"
        [[J1GroupManager sharedOthersGroup] addMemosObject:newManagedObject];
    }
	else {
        // Add to the specified group
        [group addMemosObject:newManagedObject];
	}
	
	return newManagedObject;
}

- (Memo *)fetchObjectWith:(NSString *)identifier
{
    NSManagedObjectContext *context = [J1CoreDataManager sharedManager].managedObjectContext;
    
    if (!identifier) {
        return nil;
    }
    
    // search the "Others" group    
    NSPredicate *predicate= [NSPredicate predicateWithFormat:@"identifier LIKE %@", identifier];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Memo" inManagedObjectContext:context]];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *array = [context executeFetchRequest:request error:&error];
    
    Memo *memo = nil;
    if (!error && array && [array count] == 1) {
        // create the "Others" group object
        memo = [array objectAtIndex:0];
    }
    return memo;
}

- (void)  moveObject:(Memo *)memo toGroup:(Group *)group
{
}

- (void)disposeObject:(Memo *)memo {
    
    // change the linkage to the "TrashGroup"
    memo.group = [J1GroupManager sharedTrashGroup];
}

- (void)  clearTrash {
    NSManagedObjectContext *context = [J1CoreDataManager sharedManager].managedObjectContext;

    // Unlink the all Memos from the Trash Group.
    NSSet *memos = [J1GroupManager sharedTrashGroup].memos;
    [[J1GroupManager sharedTrashGroup] removeMemos:memos];

    // Delete the Memo Objects.
    [memos enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [context deleteObject:obj];
    }];  
}

@end
