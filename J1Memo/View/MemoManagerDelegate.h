//
//  MemoManagerDelegate.h
//  J1Memo
//
//  Created by 奥 潤一郎 on 11/07/25.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Memo.h"

@protocol MemoManagerDelegate <NSObject>
- (Memo *)objectAtIndexPath:(NSIndexPath *)indexPath;

- (Memo *)objectAtPreviousIndexPath:(NSIndexPath *)indexPath;
- (Memo *)objectAtNextIndexPath:(NSIndexPath *)indexPath;

- (Memo *)previousObject:(Memo *)memo;
- (Memo	*)nextObject:(Memo *)memo;

- (void)selectObject:(Memo *)memo animated:(BOOL)animated;
- (void)deselectObject:(Memo *)memo animated:(BOOL)animated;
@end
