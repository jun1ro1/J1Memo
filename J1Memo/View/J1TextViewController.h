//
//  J1TextViewController.h
//  J1Memo
//
//  Created by 潤一郎 奥 on 11/10/29.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "J1TextView.h"
#import "Memo.h"
#import "J1TextSearchDelegate.h"

@interface J1TextViewController : UIViewController
<UITextViewDelegate>

{
    
    BOOL                            editable;
	Memo __weak                     *editingMemo_;

    IBOutlet J1TextView *textView_;

    id <J1TextSearchDelegate> __weak delegate;

@private
    BOOL                            changed_;

    // for search function
    NSRange                         searchBackwardRange_;
    NSRange                         searchForwardRange_;

}

@property (nonatomic, getter = isEditable) BOOL editable;

@property (nonatomic, weak) Memo    *editingMemo;

@property(nonatomic, strong) J1TextView *textView;

@property (nonatomic) id<J1TextSearchDelegate> __weak delegate;


- (BOOL)isChanged;
- (void)save;

- (void)selectRange:(NSRange)range;

- (NSRange)searchText:(NSString *)text options:(NSStringCompareOptions)aMask range:(NSRange)aRange ;
- (void)searchTextForward:(NSString *)text;
- (void)searchTextBackward:(NSString *)text;

@end
