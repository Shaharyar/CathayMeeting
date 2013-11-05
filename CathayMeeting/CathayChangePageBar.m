//
//  CathayChangePageBar.m
//  CathayMeeting
//
//  Created by Fanny Sheng on 12/6/5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CathayChangePageBar.h"

#define BUTTON_X 8.0f
#define BUTTON_Y 8.0f
#define BUTTON_SPACE 10.0f
#define BUTTON_HEIGHT 35.0f
#define BUTTON_WIDTH 35.0f
#define BUTTON_WIDE_WIDTH 50.0f

@implementation CathayChangePageBar
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code
        self.backgroundColor = [UIColor colorWithRed:136/255.0 green:162/255.0 blue:111/255.0 alpha:0.8];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.autoresizesSubviews = YES;
    }
    
    return self;
}


@end
