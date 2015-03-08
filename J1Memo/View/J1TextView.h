//
//  J1TextView.h
//  J1Memo
//
//  Created by 奥 潤一郎 on 11/07/24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface J1TextView : UITextView
{    
    BOOL    editable_;
}

@property (nonatomic, getter = isEditable) BOOL editable;

- (void)setEditable2:(BOOL)editable;

@end
