//
//  SizePopupViewController.m
//  CathayLifeB2EPad
//
//  Created by dev1 on 12/4/27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SizePopupViewController.h"

@interface SizePopupViewController ()

@end



@implementation SizePopupViewController

@synthesize delegate,segment,initSize;

#pragma mark	Class methods

+ (SizePopupViewController*) sizePopupViewController
{
	return [ [ [ self alloc ] initWithNibName: @"SizePopupViewController" bundle: nil ] autorelease ];
}


+ (CGSize) idealSizeForViewInPopover
{
	return CGSizeMake( 380, 70 );
}

#pragma mark	UIViewController( UIPopoverController ) methods

- (CGSize) contentSizeForViewInPopover
{
	return [ [ self class ] idealSizeForViewInPopover ];
}


#pragma mark	Instance methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //提供初始值
    if (initSize) {
        self.segment.selectedSegmentIndex = [initSize intValue];
    }
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)segmentSwitch:(id)sender {
    
	//NSInteger *idtype = (NSInteger *)[sender selectedSegmentIndex];
    #ifdef IS_DEBUG
    NSLog(@"===> size selected segment = %d", [sender selectedSegmentIndex]);
    #endif
    
	switch ([sender selectedSegmentIndex]) {
		case 0:
			//5px
            [delegate changeBrushSize:2.0f];
			break;
		case 1:
			//8px
            [delegate changeBrushSize:5.0f];            
			break;	
		case 2:
			//10px
            [delegate changeBrushSize:8.0f];            
			break;
		case 3:
			//13px
            [delegate changeBrushSize:11.0f];            
			break;
		case 4:
			//15px
            [delegate changeBrushSize:13.0f];            
			break;
    }
    
}

- (void)setStatus:(NSString *)size{
      self.segment.selectedSegmentIndex = [size intValue];

}


@end
