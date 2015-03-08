//
//  J1ScrollViewController.m
//  J1Memo
//
//  Created by 奥 潤一郎 on 11/08/22.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "J1ScrollViewController.h"
#import "EditViewController.h"

@implementation J1ScrollViewController

#pragma mark - Property

@synthesize editingMemo;
@synthesize delegate;

#pragma mark - Memory Management

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // スクロールビューの初期化
    UIScrollView* scrollView = [[UIScrollView alloc] init];
    scrollView.frame = self.view.bounds;
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    // 横にページスクロールできるようにコンテンツの大きさを横長に設定
    scrollView.contentSize = CGSizeMake( 320 * 3, 480 );

    // ページごとのスクロールにする
    scrollView.pagingEnabled = YES;
    
    // スクロールバーを非表示にする
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;

    // ステータスバータップでトップにスクロールする機能をOFFにする
    scrollView.scrollsToTop = NO;

    // スクロールビューに各画面を貼り付け
    for ( int i = 0; i < 1; ++i ){
        EditViewController *myViewController = [[EditViewController alloc] init];
        myViewController.view.frame = CGRectMake( 320 * i, 0, 320, 480 );
        [scrollView addSubview:myViewController.view];
        myViewController.editingMemo = self.editingMemo;
        myViewController.delegate    = self.delegate;
    }
    // スクロールビューに各画面に貼り付け
    [self.view addSubview:scrollView];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
