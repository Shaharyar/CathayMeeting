//
//  LoginModalViewController.h
//  CathayLifeB2EPad
//
//  Created by dev1 on 2011/4/29.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//
//  登入視窗

#import <UIKit/UIKit.h>
#import "LoadingViewDelegate.h"
#import "AppDataSingleton.h"

@protocol LoginModalViewDelegate;
@class LoadingView;

@interface LoginModalViewController : UIViewController<LoadingViewDelegate, UIWebViewDelegate> {
    
    id<LoginModalViewDelegate> delegate;
    
    UITextField *idFiled;
	UITextField *passwordFiled;
	UILabel *messageLabel;
    IBOutlet UILabel *versionLabel;
	UISwitch *idSwitch;
    UIWebView *popWebView;
    LoadingView *loadView;
   	int status;
    BOOL lockStatus;
    
    NSMutableData *receiveData;
    
}

@property (nonatomic, retain) IBOutlet UITextField *idFiled;
@property (nonatomic, retain) IBOutlet UITextField *passwordFiled;
@property (nonatomic, retain) IBOutlet UILabel *messageLabel;
@property (nonatomic, retain) IBOutlet UISwitch *idSwitch;
@property (nonatomic, retain) IBOutlet UIWebView *popWebView;
@property (retain, nonatomic) IBOutlet UILabel *copyRightChtLabel;
@property (retain, nonatomic) IBOutlet UILabel *copyRightEngLabel;
@property (nonatomic, assign) id<LoginModalViewDelegate> delegate;
@property (nonatomic, assign) int status;   //0代表正常登入狀態，1代表session timeout狀態


-(IBAction)textFiledDoneEditing:(id)sender;
-(IBAction)idSwitchChanged;
-(IBAction)login:(id)sender;
-(IBAction) enterCathayBookOfflineMode; //直接進入國泰書櫃離線模式

- (BOOL) validateForm ;
- (BOOL) identifyID:(NSString *)idStr;

@end
