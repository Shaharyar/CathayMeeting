//
//  LoadingView.m
//  CathayMobiLife
//
//  Created by Mahmood1 on 12/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LoadingView.h"
#import <QuartzCore/QuartzCore.h>

#define CONTENT_TAG 588
#define MSG_TAG 589

@implementation LoadingView
@synthesize msg;

- (id)initWithUIView:(UIView *)aView message:(NSString *)msg {
	CGRect containerBounds = aView.bounds;
    if ((self = [super initWithFrame:aView.bounds])) {

		
		UIView *content = [[UIView alloc] initWithFrame:CGRectMake((containerBounds.size.width - 250) / 2, (containerBounds.size.height - 180) / 2, 250, 180)];
        content.tag = CONTENT_TAG;
        content.layer.cornerRadius = 10;
		UIColor* bgColor = [[UIColor alloc] initWithRed: 0/255.0 green:0/255.0 blue:0/255.0 alpha:0.7];
        content.backgroundColor = bgColor;
        [bgColor release];

		
        UIImageView *imageview = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"smalltree.png"]];
		imageview.frame = CGRectMake(75, 10, 100, 100);
		
        
		[content addSubview:imageview];
		[imageview release];

		CGRect nameLabelRect = CGRectMake(0, 100, 250, 25);
		UILabel *titleLable = [[UILabel alloc] initWithFrame:nameLabelRect];
        titleLable.tag = MSG_TAG;
		titleLable.textAlignment = UITextAlignmentCenter;
        titleLable.text = msg;
		self.msg = msg;
        titleLable.font = [UIFont boldSystemFontOfSize:18];
		titleLable.alpha = 0.8;
		titleLable.backgroundColor = [UIColor clearColor];
		titleLable.textColor = [UIColor whiteColor];
		
		[content addSubview: titleLable];
		[titleLable release];		
		
		
        activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		activityView.frame = CGRectMake(110, 130, 30.0f, 30.0f);
		[content addSubview:activityView];

		
		
		[self addSubview:content];
		[content release];
		
		[self setAlpha:0.8];
		[self setHidden:YES];
        
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
		
		container = aView;
		[container retain];
    }
    return self;
}

-(void) show {
    
    self.frame = container.bounds;
    UIView *content = [self viewWithTag:CONTENT_TAG];
    content.frame = CGRectMake((container.bounds.size.width - 250) / 2, (container.bounds.size.height - 180) / 2, 250, 180);
        
    UILabel *titleLabel = (UILabel *)[content viewWithTag:MSG_TAG];
    titleLabel.text = self.msg;
    
    /*
    NSLog(@"container.bounds.size.width:%f, height:%f", container.bounds.size.width, container.bounds.size.height);
    NSLog(@"self.bounds.size.width:%f, height:%f", self.bounds.size.width, self.bounds.size.height);
     */
    
	[container addSubview:self];
	[activityView startAnimating];
	[self setHidden:NO];
}
-(void) hide {
	[activityView stopAnimating];
	[self setHidden:YES];
	[self removeFromSuperview];
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (void)dealloc {
	[activityView release];
	[container release];
    [msg release];
    [super dealloc];
}


@end

