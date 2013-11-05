//
//  LogoutDelegate.m
//  CathayLifeB2EPad
//
//  Created by dev1 on 2011/5/5.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "LogInOutAgent.h"
#import "AppDelegate.h"
#import "CathayGlobalVariable.h"
#import "LoginModalViewController.h"
#import "ASIHTTPRequest.h"


@implementation LogInOutAgent
@synthesize viewController;
@synthesize isTimeOut;

//登出的URL
//static NSString *logoutUrlB2E = @"http://10.20.35.1/servlet/HttpDispatcher/LoginApp/logout";
static NSString *logoutUrlB2E = @"http://180.166.180.248/servlet/HttpDispatcher/LoginApp/logout";

-(void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark Action

- (void)logout{
    
    //建立連線
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:logoutUrlB2E]];
    //[request setDefaultResponseEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5)];
    
    [request setValidatesSecureCertificate:NO]; //取消HTTPS授權檢查
    
    [request setCompletionBlock:^{
        NSLog(@"Request Complete....");
        NSString *responseString = [request responseString];
        NSLog(@"resp is %@", responseString);
        
    }];
    
    [request setFailedBlock:^{
        //登出失敗，僅Log，不警告
        NSError *error = [request error];
        NSLog(@"登出失败 - %@, DOMAIN - %@, CODE - %d", [error localizedDescription] ,error.domain, error.code);
    }];
    
    [request startAsynchronous]; 
    
    //直接叫出登入視窗
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    LoginModalViewController *loginView = [[LoginModalViewController alloc]init];
    loginView.delegate = self;
    loginView.status = (isTimeOut)?1:0;
    [appDelegate.viewController presentModalViewController:loginView animated:YES];	
    [loginView release];
}

//檢核timeout flag
-(void)checkTimoutAndJumpLoginViewWithFlag:(NSString *)flag superController:(id<ReLoginActions>)superController {
    
    NSLog(@"checkTimoutAndJumpLoginViewWithFlag .... %@ ,%d",flag, [flag isEqualToString:@"b2e"]);
    
    if ([flag isEqualToString:@"b2e"]){
        
        NSLog(@"b2e timeout....");
        
        isTimeOut = YES;
        self.viewController = superController;
        
        //強制登出
        [self logout];
    }
}

#pragma mark -
#pragma mark LoginModalViewDelegate

- (void)didDismissModalView {
    
    NSLog(@"關閉登入視窗！ timeout flag:%d",isTimeOut);
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [AppDataSingleton shareData].cathayBooksOfflineModeEnabled = NO; //關閉書櫃離線瀏覽模式
    [AppDataSingleton shareData].okToLoad = YES;     //允許頁面開始讀取
    
    //退出登入視窗
    [appDelegate.viewController dismissModalViewControllerAnimated:YES];
    
    NSLog(@"登入完成，重新載入頁面資訊....");
    
    /*
    if (isTimeOut) {
        
        #ifdef IS_DEBUG
        NSLog(@"timeout重新登入完成，重新載入頁面資訊....");
        #endif
        
        [self.viewController reloadContent];
    }
    */
}

- (void)didDismissModalViewWithOfflineMode {
    
    NSLog(@"直接進入離線瀏覽模式！");
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //開啟書櫃離線瀏覽模式
    [AppDataSingleton shareData].cathayBooksOfflineModeEnabled = YES;
    [AppDataSingleton shareData].okToLoad = YES; //允許頁面開始讀取
    
    [appDelegate.viewController dismissModalViewControllerAnimated:YES];
}

@end
