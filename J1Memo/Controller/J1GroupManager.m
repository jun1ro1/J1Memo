//
//  GroupManager.m
//  J1Memo
//
//  Created by OKU Junichirou on 11/05/22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "J1GroupManager.h"
#import "J1AppDelegate.h"
#import "J1CoreDataManager.h"

@implementation J1GroupManager

#pragma mark - static variables
static J1GroupManager    *sGroupManager	= nil;
static Group           *sAllGroup		= nil;
static Group           *sOthersGroup	= nil;
static Group           *sTrashGroup     = nil;
static int					 sOrder;

#pragma mark - Class Methods
// Returns the GroupManager singleton instance
+ (J1GroupManager *)sharedManager {    
    if (!sGroupManager) {
        sGroupManager = [[J1GroupManager alloc] init];
        sOrder = 1;
    }
    return sGroupManager;
}

// Returns the all Group.
+ (Group *)sharedAllGroup {  
    return sAllGroup;
}

// Returns the others Group.
+ (Group *)sharedOthersGroup {
    return sOthersGroup;
}

// Returns the others Group.
+ (Group *)sharedTrashGroup {
    return sTrashGroup;
}

#pragma mark - Instance Methods
#pragma mark - initialize

- (id)init {
	// Initialize the super class.
	self = [super init];
	if (self == nil) {
		return self;
	}
    
    // Initialize the Data Base
	NSLog(@"%@.%s initializing the data base", [self class], sel_getName(_cmd));
	
    // Get a managed object context
	NSManagedObjectContext *moc = [J1CoreDataManager sharedManager].managedObjectContext;
    
    // Create an entity to search groups
//    [moc performBlockAndWait:^{
        NSEntityDescription	   *entity = [NSEntityDescription entityForName:@"Group" inManagedObjectContext:moc];
    
        // Variables to execute fetch request
        NSFetchRequest  *request   = nil;
        NSPredicate     *predicate = nil;
        NSArray         *array     = nil;
        NSError         *error     = nil;
        
        // A variable to create a gropu object
        Group           *newManagedObject = nil;
        
        // search the "All" group    
        predicate = [NSPredicate predicateWithFormat:@"type == %@", [NSNumber numberWithInt:kAllGroup]];
        request = [[NSFetchRequest alloc] init];
        [request setEntity:entity];
        [request setPredicate:predicate];
        
        error = nil;
        array = [moc executeFetchRequest:request error:&error];
        if (error || !array || [array count] == 0) {
            // create the "All" group object
            newManagedObject = [[Group alloc] initWithEntity:entity insertIntoManagedObjectContext:moc];
            newManagedObject.type    = [NSNumber numberWithInt:kAllGroup];
            newManagedObject.name    = @"All";
            newManagedObject.section = [NSNumber numberWithInt:0];
            sAllGroup = newManagedObject;
        }
        else {
            sAllGroup = [array objectAtIndex:0];
            NSAssert3([array count] == 1, @"%@.%s number of 'All' groups = %d",[self class], sel_getName(_cmd), [array count]);
        }

        // search the "Others" group    
        predicate = [NSPredicate predicateWithFormat:@"type == %@", [NSNumber numberWithInt:kOthersGroup]];
        request = [[NSFetchRequest alloc] init];
        [request setEntity:entity];
        [request setPredicate:predicate];
        
        error = nil;
        array = [moc executeFetchRequest:request error:&error];
        if (error || !array || [array count] == 0) {
            // create the "Others" group object
            newManagedObject = [[Group alloc] initWithEntity:entity insertIntoManagedObjectContext:moc];
            newManagedObject.type    = [NSNumber numberWithInt:kOthersGroup];
            newManagedObject.name    = @"Others"; // @"¥uffff";
            newManagedObject.section = [NSNumber numberWithInt:0];
            sOthersGroup = newManagedObject;
        }
        else {
            sOthersGroup = [array objectAtIndex:0];
            NSAssert3([array count] == 1, @"%@.%s number of 'All' groups = %d",[self class], sel_getName(_cmd), [array count]);
        }

        
        // search the "Trash" group    
        predicate = [NSPredicate predicateWithFormat:@"type == %@", [NSNumber numberWithInt:kTrashGroup]];
        request = [[NSFetchRequest alloc] init];
        [request setEntity:entity];
        [request setPredicate:predicate];
        
        error = nil;
        array = [moc executeFetchRequest:request error:&error];
        if (error || !array || [array count] == 0) {
            // create the "Others" group object
            newManagedObject = [[Group alloc] initWithEntity:entity insertIntoManagedObjectContext:moc];
            newManagedObject.type    = [NSNumber numberWithInt:kTrashGroup];
            newManagedObject.name    = @"Trash";
            newManagedObject.section = [NSNumber numberWithInt:2];
            sTrashGroup = newManagedObject;
        }
        else {
            sTrashGroup = [array objectAtIndex:0];
            NSAssert3([array count] == 1, @"%@.%s number of 'All' groups = %d",[self class], sel_getName(_cmd), [array count]);
        }
        
        
        // delete "New Group"
        predicate = [NSPredicate predicateWithFormat:@"type == %@", [NSNumber numberWithInt:kNewGroup]];
        request = [[NSFetchRequest alloc] init];
        [request setEntity:entity];
        [request setPredicate:predicate];
        
        error = nil;
        array = [moc executeFetchRequest:request error:&error];
        if (!error && array) {
            for (NSManagedObject *obj in array) {
                [moc deleteObject:obj];
            }
        }
        
//    }];
    
    // Tips:
    // http://stackoverflow.com/questions/12075831/coredata-this-nspersistentstorecoordinator-has-no-persistent-stores-it-cannot
    // Save the database.
    // [[J1CoreDataManager sharedManager] saveContext];
    
    
/*
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
*/
    return self;
}

- (Group *)insertNewObject {
    // Create a normal Group object.
	// Create a new instance of the entity managed by the fetched results controller.
    
    // get a managed object context
	NSManagedObjectContext *context = [J1CoreDataManager sharedManager].managedObjectContext;
    
    // create a new managed object
	Group *newManagedObject = 
    [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:context];
	
	// If appropriate, configure the new managed object.
	newManagedObject.name    = @"";
	newManagedObject.type    = [NSNumber numberWithInt:kUserGGoup];
	newManagedObject.section = [NSNumber numberWithInt:1]; // 0:Special Group 1:Normal Group
    newManagedObject.order   = [NSNumber numberWithInt:sOrder];
	sOrder++;
	
	return newManagedObject;
}

- (void)deleteObject:(Group *)object
{
    NSManagedObjectContext *context = [J1CoreDataManager sharedManager].managedObjectContext;    
   
    [context deleteObject:object];
}


- (void)showNewGroup {
    // get a managed object context
	NSManagedObjectContext *context = [J1CoreDataManager sharedManager].managedObjectContext;    
	
	Group *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:context];
    
	newManagedObject.name    = @"New Group...";
	newManagedObject.type    = [NSNumber numberWithInt:kNewGroup];
	newManagedObject.section = [NSNumber numberWithInt:1];
}

- (void)hideNewGroup {
    // get a managed object context
	NSManagedObjectContext *context = [J1CoreDataManager sharedManager].managedObjectContext;    
	
   
    // create an entity and set it to the fetch request
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription	   *entity = [NSEntityDescription entityForName:@"Group" inManagedObjectContext:context];
    [request setEntity:entity];
	
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type == %@", [NSNumber numberWithInt:kNewGroup]];
	[request setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *array = [context executeFetchRequest:request error:&error];
	if (array != nil) {
		for (NSManagedObject *obj in array) {
			[context deleteObject:obj];
		}
	}
}

@end
