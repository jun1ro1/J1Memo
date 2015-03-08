//
//  Group.h
//  J1Memo
//
//  Created by 奥 潤一郎 on 11/07/21.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Memo;

@interface Group : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSDate   * modifiedAt;
@property (nonatomic, retain) NSNumber * section;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSDate   * createdAt;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet    * memos;
@end

@interface Group (CoreDataGeneratedAccessors)

- (void)addMemosObject:(Memo *)value;
- (void)removeMemosObject:(Memo *)value;
- (void)addMemos:(NSSet *)values;
- (void)removeMemos:(NSSet *)values;

@end
