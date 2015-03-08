//
//  J1MemoManager.h
//  J1Memo
//
//  Created by 奥 潤一郎 on 11/07/19.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Memo.h"
#import "Group.h"


@interface J1MemoManager : NSObject
{
    Group                  *group_;
}


// Class method
+ (J1MemoManager *)sharedManager;

// Instance method
//- (id)initWithGroup:(Group *)group;

- (Memo *)insertNewObject:(Group *)group;
- (Memo *)fetchObjectWith:(NSString *)identifier;
- (void)  moveObject:(Memo *)memo toGroup:(Group *)group;
- (void)  disposeObject:(Memo *)memo;
- (void)  clearTrash;

@end
