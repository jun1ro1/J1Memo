//
//  J1ScrollViewController.h
//  J1Memo
//
//  Created by 奥 潤一郎 on 11/08/22.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Memo.h"
#import "MemoManagerDelegate.h"


@interface J1ScrollViewController : UIViewController {

Memo __weak                     *editingMemo;
id <MemoManagerDelegate> __weak delegate;
}

@property (nonatomic, weak) Memo    *editingMemo;
@property (nonatomic) id<MemoManagerDelegate> __weak delegate;

@end
