//
//  LoginModalViewDelegate.h
//  CathayLifeB2EPad
//
//  Created by dev1 on 2011/4/29.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol LoginModalViewDelegate <NSObject>

@required
- (void)didDismissModalView;

@optional
- (void)didDismissModalViewWithOfflineMode;
- (void)doResumeActionWithData:(NSMutableData *)passData;

@end
