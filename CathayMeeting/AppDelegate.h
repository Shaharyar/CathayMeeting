//
//  AppDelegate.h
//  CathayMeeting
//
//  Created by Fanny Sheng on 12/5/29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginModalViewDelegate.h"
#import "LogInOutAgent.h"
#import "AppDataSingleton.h"
#import "PushNotificationDelegate.h"

@class CathayMeetingViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, LoginModalViewDelegate> {
    //登出代理
    LogInOutAgent *logInOutAgent;
}

@property (strong, nonatomic) UIWindow *window;
//@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) CathayMeetingViewController *viewController;
@property (nonatomic, assign) UIViewController *currentPresentedModalViewController;
@property (nonatomic, retain) LogInOutAgent *logInOutAgent;

@property (nonatomic, retain) id<PushNotificationDelegate> pushNotificationDelegate;

@end
    