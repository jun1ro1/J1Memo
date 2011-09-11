//
//  J1DetailViewController.h
//  J1Memo
//
//  Created by OKU Junichirou on 11/09/11.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface J1DetailViewController : UIViewController <UISplitViewControllerDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) UIManagedDocument *document;
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) UIPopoverController *documentPopoverController;
@property (nonatomic) CGFloat keyboardHeight;

@end
