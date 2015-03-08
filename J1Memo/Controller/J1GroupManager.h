//
//  J1GroupManager.h
//  J1Memo
//
//  Created by OKU Junichirou on 11/05/22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

//              section     type
//  All             0       kAllGroup    = -2
//  Others          0       kOthersGroup = -1
//
//  xxx             1       kNoramlGroup =  0
//                          kNewGroup    = 9999
//
//  Trash           2       kTrashGroup  = -3
//

#import <Foundation/Foundation.h>
#import "Group.h"

enum {
    kTrashGroup     = -3,
	kAllGroup       = -2,
	kOthersGroup    = -1,
	kUserGGoup      =  0,
	kNewGroup		= 9999
};

@interface J1GroupManager : NSObject {
    
}

// Class Method
+ (J1GroupManager *)sharedManager;
+ (Group *)sharedAllGroup;
+ (Group *)sharedOthersGroup;
+ (Group *)sharedTrashGroup;

// Instance Method
- (Group *)insertNewObject;
- (void)deleteObject:(Group *)object;
- (void)showNewGroup;
- (void)hideNewGroup;

@end
