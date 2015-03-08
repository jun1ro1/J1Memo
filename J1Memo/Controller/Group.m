//
//  Group.m
//  J1Memo
//
//  Created by 奥 潤一郎 on 11/07/21.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Group.h"
#import "Memo.h"


@implementation Group
@dynamic order;
@dynamic modifiedAt;
@dynamic section;
@dynamic identifier;
@dynamic createdAt;
@dynamic type;
@dynamic name;
@dynamic memos;

#pragma mark -

// set the properties when an object is created.
- (void)awakeFromInsert {
	[super awakeFromInsert];
    
    // set the indentifier
    CFUUIDRef   uuid = CFUUIDCreate(NULL);
    NSString    *identifier = objc_retainedObject(CFUUIDCreateString(NULL, uuid));
    CFRelease(uuid);
    [self setPrimitiveValue:identifier forKey:@"identifier"];
    
    // set the created date and the modified date.
	NSDate *now = [NSDate date];
	[self setPrimitiveValue:now forKey:@"modifiedAt"];
	[self setPrimitiveValue:now forKey:@"createdAt"];
	
    // for DEBUG
	NSLog(@"%@.%s created %@ at %@", [self class], sel_getName(_cmd), identifier, now );
}

- (void)setContents:(NSString *)value {
    
    // get the current time.
	NSDate *now = [NSDate date];
    
	[self willChangeValueForKey:@"contents"];
	[self willChangeValueForKey:@"title"];
	[self willChangeValueForKey:@"modifiedAt"];
	
	// set contents
	[self setPrimitiveValue:value forKey:@"contents"];
	
	// get a title and set it
	NSRange range	 = [value lineRangeForRange:NSMakeRange(0, 0)];
	NSString *s = [value substringWithRange:range];
	NSInteger i = [s length] - 1;
	while (i >=0) {
		unichar c = [s characterAtIndex:i];
		if (c != 0x000d && c != 0x000a) {
			break;
		}
		i--;
	}
	i++;
	
	NSString *aTitle = (i > 0) ? [s substringToIndex:i] : @"";
	[self setPrimitiveValue:aTitle forKey:@"title"];
    
	// set a time stamp
	[self setPrimitiveValue:now forKey:@"modifiedAt"];
    
	// notify values changed
	[self didChangeValueForKey:@"modifiedAt"];
	[self didChangeValueForKey:@"title"];
	[self didChangeValueForKey:@"contents"];
}

@end
