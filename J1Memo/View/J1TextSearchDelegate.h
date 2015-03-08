//
//  J1TextSearchDelegate.h
//  J1Memo
//
//  Created by 潤一郎 奥 on 11/11/20.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol J1TextSearchDelegate <NSObject>

- (void)foundText:(NSString *)text backwardRange:(NSRange)bRange forwardRange:(NSRange)fRange;

@end
