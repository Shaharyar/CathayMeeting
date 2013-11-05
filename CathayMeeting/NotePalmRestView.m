//
//  NotePalmRestView.m
//  CathayMeeting
//
//  Created by Fanny Sheng on 12/8/13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NotePalmRestView.h"

@implementation NotePalmRestView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:NULL];
        
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

- (void)dealloc{
    
    [self removeObserver:self forKeyPath:@"frame"];
    [super dealloc];
}


#pragma mark UIResponder instance methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesCancelled:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{    
	[super touchesMoved:touches withEvent:event];
}

@end
