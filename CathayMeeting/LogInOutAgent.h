//
//  LogoutDelegate.h
//  CathayLifeB2EPad
//
//  Created by dev1 on 2011/5/5.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//
//  專門用來執行 登出入機制

#import <Foundation/Foundation.h>
#import "ASIHTTPRequestDelegate.h"
#import "ASINetworkQueue.h"
#import "LoginModalViewDelegate.h"
#import "LoadingViewDelegate.h"
#import "ReLoginActions.h"


@interface LogInOutAgent : NSObject <ASIHTTPRequestDelegate, LoginModalViewDelegate> {

    BOOL isTimeOut;
}
@property (nonatomic, assign) id<ReLoginActions, LoadingViewDelegate> *viewController;
@property (nonatomic, assign) BOOL isTimeOut;

- (void)logout;
- (void)checkTimoutAndJumpLoginViewWithFlag:(NSString *)flag superController:(id<ReLoginActions>)superController;

@end
