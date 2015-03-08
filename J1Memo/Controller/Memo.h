//
//  Memo.h
//  J1Memo
//
//  Created by 奥 潤一郎 on 11/08/06.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Group;

@interface Memo : NSManagedObject

@property (nonatomic, retain) NSNumber * secret;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSDate   * modifiedAt;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * contents;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSDate   * createdAt;
@property (nonatomic, retain) Group    * group;

@end
