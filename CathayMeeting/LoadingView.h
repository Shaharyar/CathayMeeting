//
//  LoadingView.h
//  CathayMobiLife
//
//  Created by Mahmood1 on 12/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LoadingView : UIView {
    
    NSString *msg;
    
    @private
	UIActivityIndicatorView *activityView;
	UIView *container;
}
@property (nonatomic, retain) NSString *msg;

- (id)initWithUIView:(UIView *)aView message:(NSString *)msg;
- (void) show;
- (void) hide;
@end
