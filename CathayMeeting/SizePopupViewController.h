//
//  SizePopupViewController.h
//  CathayLifeB2EPad
//
//  Created by dev1 on 12/4/27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SizePopupDelegate <NSObject>

@required // Delegate protocols

- (void)changeBrushSize:(float) size;

@end

////////////////////////////////////////////////////



@interface SizePopupViewController : UIViewController

@property (nonatomic, assign, readwrite) id <SizePopupDelegate> delegate;
@property (retain, nonatomic) IBOutlet UISegmentedControl *segment;
@property (retain, nonatomic) NSString *initSize;



+ (SizePopupViewController*) sizePopupViewController;
+ (CGSize) idealSizeForViewInPopover;

- (IBAction) segmentSwitch:(id)sender;
- (void)setStatus:(NSString *)size;

@end
