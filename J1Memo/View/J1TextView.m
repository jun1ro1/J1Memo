//
//  J1TextView.m
//  J1Memo
//
//  Created by 奥 潤一郎 on 11/07/24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "J1TextView.h"


@implementation J1TextView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (BOOL)isEditable2
{
    return editable_;
}

//- (void)setEditable:(BOOL)editable
//{
//    super.editable = editable;
//}

- (void)setEditable2:(BOOL)editable
{
    editable_ = editable;
    super.editable = editable;
    if (editable) {
        // to use the normal keyboard.
        self.inputView = NULL;
    }
    else {
        // set a dummy keyboard view in order to a keyboard is not appeared.
        self.inputView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 0.0, 0.0)];
    }
}

// delegated editable !!!

// http://stackoverflow.com/questions/1426731/how-disable-copy-cut-select-select-all-in-uitextview
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
	NSLog(@"%@.%s editable_=%s action=%s", [self class], sel_getName(_cmd), (editable_? "YES" : "NO"), sel_getName(action));
    
    if (editable_) {
        return [super canPerformAction:action withSender:sender];
    }
    
    // when the view is not editable
    if (action == @selector(cut:) || action == @selector(paste:) || action == @selector(delete:)
        || action == @selector(replaceCharactersInRange:withString:) ) {
        return NO;
    }
    else {
        return [super canPerformAction:action withSender:sender];
    }
}

@end
