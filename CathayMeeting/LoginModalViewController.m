//
//  LoginModalViewController.m
//  CathayLifeB2EPad
//
//  Created by dev1 on 2011/4/29.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "LoginModalViewController.h"
#import "NetDetectHelper.h"
#import "RegexKitLite.h"
#import "CathayGlobalVariable.h"
#import "LoadingView.h"
#import "ASIFormDataRequest.h"
#import "EncodingHelper.h"
#import "PopWebViewController.h"
//#import "CathayMeetingViewController.h"
//#import "AppDelegate.h"
#import "BookShelfDAO.h"
#import "CathayDeviceUtil.h"
#import "CathayWebModalViewController.h"
#import "PushNotification.h"

@interface LoginModalViewController()
-(void) layoutViewsWithRotation;
@end

@implementation LoginModalViewController
@synthesize popWebView;
@synthesize copyRightChtLabel;
@synthesize copyRightEngLabel;
@synthesize idFiled, passwordFiled, messageLabel, idSwitch;
@synthesize delegate, status;

//static NSString *loginURL = @"http://10.20.35.1/servlet/HttpDispatcher/loginApp/login?";
static NSString *loginURL = @"http://180.166.180.248/servlet/HttpDispatcher/loginApp/login?";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [versionLabel release];
    [popWebView release];
    [copyRightChtLabel release];
    [copyRightEngLabel release];
    [idFiled release];
	[passwordFiled release];
	[messageLabel release];	
	[idSwitch release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    // Do any additional setup after loading the view from its nib.
    
    UIButton *hideWedBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //[hideWedBtn setImage:[UIImage imageNamed:@"deleteIcon50.png"] forState:UIControlStateNormal];
    [hideWedBtn setTitle:@"关闭视窗" forState:UIControlStateNormal];
    //hideWedBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    [hideWedBtn addTarget:self action:@selector(hideWebView) forControlEvents:UIControlEventTouchUpInside];
    hideWedBtn.showsTouchWhenHighlighted = YES;
    hideWedBtn.frame = CGRectMake(self.popWebView.bounds.size.width - 120, 10, 100, 40);    
    [self.popWebView addSubview:hideWedBtn];
    
    
    //取得使用者帳號
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSString *idSwitchState = [prefs stringForKey:@"idSwitchState"];
	NSString *catchUserID = [prefs stringForKey:@"catchUserID"];
	
	if ([idSwitchState isEqualToString:@"ON"]) {
		idSwitch.on = YES;
	}else {
		idSwitch.on = NO;
	}
    
	self.idFiled.text = catchUserID;
	
	//normal login
	if(status == 0){
		messageLabel.text = @"非本人请勿登录作业，否则我司保留追究法律责任的权利";
		//messageLabel.textColor = [UIColor redColor];
        //session time out login	
	}else {
		messageLabel.text = @"您未登录或过久未使用被系统登出，请重新登录！";
		//messageLabel.textColor = [UIColor whiteColor];
	}
    
    
    //取得目前軟體版本號
    NSString *version = [CathayDeviceUtil appVersion];
    //顯示版本號
    #ifdef TEST_URL
    versionLabel.text = [NSString stringWithFormat:@"v%@t", version];
    #endif
    
    #ifdef PROD_URL
    versionLabel.text = [NSString stringWithFormat:@"v%@", version];
    #endif
    
    //背景
    UIImage * bgTile = [UIImage imageNamed: @"bg_login_portrait.png"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:bgTile];

    
	[super viewDidLoad];
    
}

- (void)viewDidUnload
{
    [versionLabel release];
    versionLabel = nil;
    [self setPopWebView:nil];
    [self setCopyRightChtLabel:nil];
    [self setCopyRightEngLabel:nil];
    self.idFiled = nil;
    self.passwordFiled = nil;
    self.messageLabel = nil;
    self.idSwitch = nil;
    [super viewDidUnload];
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    popWebView.hidden = YES;
    popWebView.alpha = 0;
    
}

-(void) viewWillDisappear:(BOOL)animated {
	//檢查是否要記錄帳號
	[self idSwitchChanged];
    
	[super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    
    [self layoutViewsWithRotation];
    
    [super willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:duration];
}


-(void) layoutViewsWithRotation {
    
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    //UIInterfaceOrientation interfaceOrientation = UIInterfaceOrientationPortrait;
    
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
		
        #ifdef IS_DEBUG
        NSLog(@"Landscape");
        #endif
        
        //背景
        UIImage * bgTile = [UIImage imageNamed: @"bg_login_landscape.png"];
        self.view.backgroundColor = [UIColor colorWithPatternImage:bgTile];

        //版權宣告
        self.copyRightChtLabel.frame = CGRectMake( (1024 - copyRightChtLabel.bounds.size.width)/2 , 668, copyRightChtLabel.bounds.size.width, copyRightChtLabel.bounds.size.height);
        self.copyRightEngLabel.frame = CGRectMake( (1024 - copyRightEngLabel.bounds.size.width)/2 , 698, copyRightEngLabel.bounds.size.width, copyRightEngLabel.bounds.size.height);
        
    } else {
		
        #ifdef IS_DEBUG
        NSLog(@"Portrait");
        #endif
        
        //背景
        UIImage * bgTile = [UIImage imageNamed: @"bg_login_portrait.png"];
        self.view.backgroundColor = [UIColor colorWithPatternImage:bgTile];
        
        //版權宣告
        self.copyRightChtLabel.frame = CGRectMake((768 - copyRightChtLabel.bounds.size.width)/2, 751, copyRightChtLabel.bounds.size.width, copyRightChtLabel.bounds.size.height);
        self.copyRightEngLabel.frame = CGRectMake((768 - copyRightEngLabel.bounds.size.width)/2, 781, copyRightEngLabel.bounds.size.width, copyRightEngLabel.bounds.size.height);
        
    }
    
}


#pragma mark -
#pragma mark UI Action

-(IBAction)textFiledDoneEditing:(id)sender {
	
	[sender resignFirstResponder];
    [passwordFiled becomeFirstResponder];   //將指標移至密碼輸入欄
}

-(IBAction)idSwitchChanged {
	
	if(idSwitch.on){
		NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
		[prefs setObject:[self.idFiled.text uppercaseString] forKey:@"catchUserID"];
		[prefs setObject:@"ON" forKey:@"idSwitchState"];
        
	}else {
		NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
		[prefs setObject:@"" forKey:@"catchUserID"];
		
	}
    
    
}

-(IBAction)login:(id)sender{
    
    if (lockStatus) {
        return;
    }
	
	//檢核輸入值是否正確
	if([self validateForm]){
        NSLog(@"verify PASS");
	}else{
        NSLog(@"verify PASS");
		return;
	}
	
	//測試目前網路是否有通
	//BOOL isConnected = [UIDevice networkConnected];
	NetDetectHelper *netDetecter = [[NetDetectHelper alloc]init];
	BOOL isConnected = [netDetecter connectedToNetwork];
	[netDetecter release];
	
    NSLog(@"networkStatus is %@", (isConnected ? @"YES" : @"NO"));
    
	if(!isConnected){
		return;
	}
	
	NSString *id = self.idFiled.text;
	NSString *password = self.passwordFiled.text;
	
	NSLog(@"login id is ..%@", id);
    
	//Login request ---------------------
    
    // alex added
    NSString *postBody = [NSString stringWithFormat:@"username=%@&password=%@", [id uppercaseString], password];
    NSLog(@"postBody=%@", postBody);
    NSString *combinedURL = [loginURL stringByAppendingString:postBody];
    NSURL *url = [NSURL URLWithString:combinedURL];

    NSLog(@"url=%@", url);
    
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    //[ASIHTTPRequest setSessionCookies:nil];
    
    [request setRequestMethod:@"POST"];
    
    [request setValidatesSecureCertificate:NO]; //取消HTTPS授權檢查
    
    //set post
	
    //NSString *postBody = [NSString stringWithFormat:@"username=%@&password=%@", [id uppercaseString], password ];
    
    //[request appendPostData:[postBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setCompletionBlock:^{
        NSLog(@"Request Complete....");
        
        NSString *responseString = [request responseString];
        NSLog ( @"responseString=%@", responseString);
        
        [self hideLoadView];
        lockStatus = NO;
        
        //BIG5
        //EncodingHelper* encodeHelper = [EncodingHelper new];
        //NSData *cleanData = [encodeHelper cleanBIG5:[request responseData]];
        //[encodeHelper release];
        
        //NSString *str = [[NSString alloc] initWithData:cleanData encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5)];
        
        //去除空白
        NSString *trimmedString = [responseString stringByTrimmingCharactersInSet:
                                   [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        //[str release];
        
        NSLog(@"resp is %@", trimmedString);
        
        //允許 CathayBookShelf進行資料讀取
        [AppDataSingleton shareData].okToLoad = YES;
        
        //正常登入狀態
        if ([trimmedString rangeOfString:@"$MobileRtnCode0" options:NSCaseInsensitiveSearch].location != NSNotFound) {    
            
            NSLog(@"normal login status");
            
            //Saving id to NSUserDefaults
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            [prefs setObject:[self.idFiled.text uppercaseString] forKey:@"idFiled"];
            [prefs setObject:@"youLogin" forKey:@"loginFlag"];
            
            //---------------------------------
            //註冊推播通知
            //PushNotification *push = [[PushNotification alloc] init];
            //[push callPushNotification];
            //[push release];
            //---------------------------------

            //关闭离线浏览模式，并检查app版本
            [delegate didDismissModalView];
            
            
        //檢查回傳資料是否為密碼過期頁
        }else if ([trimmedString rangeOfString:@"$MobileRtnCode1" options:NSCaseInsensitiveSearch].location != NSNotFound){
            
            
            UIAlertView *alert = [[UIAlertView alloc] 
                                  initWithTitle: @"密码过期"
                                  message:@"您的密码已过期，请至国泰人园地重设密码！"
                                  delegate:nil 
                                  cancelButtonTitle:@"OK" 
                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
            
            //--------------
            
            [popWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:loginURL]]];
            
            
            [UIView animateWithDuration:0.8 animations:^(void) {
                
                popWebView.alpha = 1;
                
            }completion:^(BOOL finished) {
                
                popWebView.hidden = NO;
            }];
            
            /*
            //PopWebViewController *modalWebViewController = [[PopWebViewController alloc]initWithNibName:@"PopWebViewController" bundle:nil BodyHTML:str];
            PopWebViewController *modalWebViewController = [[PopWebViewController alloc]initWithNibName:@"PopWebViewController" bundle:nil targetURL:[NSURL URLWithString:loginURL]];
            
            modalWebViewController.modalPresentationStyle = UIModalPresentationPageSheet;
            
            [self presentModalViewController:modalWebViewController animated:YES];
            
            [modalWebViewController release];
            */
             
        //檢查回傳資料是否為密碼鎖碼頁
        }else if ([trimmedString rangeOfString:@"$MobileRtnCode2" options:NSCaseInsensitiveSearch].location != NSNotFound){
            
            UIAlertView *alert = [[UIAlertView alloc] 
                                  initWithTitle: @"登录失败"
                                  message:@"密码超过允许次数已被锁定，请至国泰人园地登录画面，点忘记密码可以解除锁定，并发送密码到您的邮箱及手机，或者联络您的主管协助重设密码！"
                                  delegate:nil 
                                  cancelButtonTitle:@"OK" 
                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
            
        }else {
            
            UIAlertView *alert = [[UIAlertView alloc] 
                                  initWithTitle: @"登录失败" 
                                  message:@"请检查帐号的密码是否正确"
                                  delegate:nil 
                                  cancelButtonTitle:@"OK" 
                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        }

        
    }];
    
    
    
    [request setFailedBlock:^{
        
        [self hideLoadView];
        lockStatus = NO;
        
        
        NSError *error = [request error];
        #ifdef IS_DEBUG
        NSLog(@"Connection Failed - %@, DOMAIN - %@, CODE - %d", [error localizedDescription] ,error.domain, error.code);
        #endif
        
        NSString *errMsg = @"";
        
        if ([[error domain] isEqualToString:@"ASIHTTPRequestErrorDomain"]) {
            
            errMsg = ERROR_MSG_NET;
            
            
        }else{
            
            errMsg = ERROR_MSG_DEFAULT;
        }
        
        UIAlertView *alert = [[UIAlertView alloc] 
                              initWithTitle: @"连接失败" 
                              message:errMsg
                              delegate:nil 
                              cancelButtonTitle:@"OK" 
                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        
	
        
    }];
    
    [request startAsynchronous];
    [self showLoadViewWithText:@"登录中"];
    lockStatus = YES;
    
}

-(IBAction) enterCathayBookOfflineMode {
    
    //檢核
    NSString * errMsg = @"";
	if([idFiled.text length]==0) {
		errMsg = [errMsg stringByAppendingString:@"工号未输入\n"];
	}
    
    if ([errMsg length]==0) {
        BookShelfDAO *dao = [BookShelfDAO sharedDAO];
        int count = [dao getCountsOfBooksByuserID:[self.idFiled.text uppercaseString]];
        
        //查無此使用者離線資料
        if (count == 0) {
            errMsg = [errMsg stringByAppendingString:@"查无此工号的离线资料\n"];
        }
    }
    
    if([errMsg length]>0){
		
		UIAlertView *alert = [[UIAlertView alloc] 
							  initWithTitle: @"提示"
							  message:errMsg
							  delegate:nil 
							  cancelButtonTitle:@"确认" 
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
    
    
    //Saving id to NSUserDefaults
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:[self.idFiled.text uppercaseString] forKey:@"idFiled"];
    
    [delegate didDismissModalViewWithOfflineMode];
    
}

#pragma mark -
#pragma mark LoadingViewDelegate

//Load View 顯示控制
-(void) showLoadViewWithText:(NSString *)text {
    
    loadView = [[LoadingView alloc] initWithUIView:self.view message:text];
	[loadView show];
}

-(void) hideLoadView {
    
    [loadView hide];
    [loadView release];
}


#pragma mark -
#pragma mark self-defined methods

- (BOOL) validateForm {
	
	//---------
	//檢核
	
	NSString * errMsg = @"";
	
	if([idFiled.text length]==0) {
		errMsg = [errMsg stringByAppendingString:@"工号未輸入\n"];
	} else if (idFiled.text.length != 10) {
        errMsg = [errMsg stringByAppendingString:@"工号长度必须为10位\n"];
    }
    //这里不验证身份证号码
    //else if ([self identifyID:idFiled.text]==NO) {
	//	errMsg = [errMsg stringByAppendingString:@"身份證字號有誤\n"];
	//}
	
	if ([passwordFiled.text length]==0) {
		errMsg = [errMsg stringByAppendingString:@"\"密碼未輸入\"\n"];
	}
	
	if([errMsg length]>0){
		errMsg = [errMsg stringByAppendingString:@"\n请确认以上栏位是否正确输入。\n"];
	}
	
	if([errMsg length]>0){
		
		UIAlertView *alert = [[UIAlertView alloc] 
							  initWithTitle: @"提示"
							  message:errMsg
							  delegate:nil 
							  cancelButtonTitle:@"确认" 
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
		return NO;
	}
	
	return YES;
}

// 身分證字號檢核
//- (BOOL) identifyID:(NSString *)idStr{
//	return [idStr isMatchedByRegex:@"^[A-Za-z][1-2][0-9]{8,8}$"];
//}

-(void) hideWebView {
    
    [UIView animateWithDuration:0.8 animations:^(void) {
        
        popWebView.alpha = 0;
        
    }completion:^(BOOL finished){

        popWebView.hidden = YES;
    }];
    
}




#pragma mark -
#pragma mark UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
	//NSString *flag = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('$MobiAppLoginFlag').value;"]; 
	NSString *flag = [webView stringByEvaluatingJavaScriptFromString:@"document.title"]; 
    #ifdef IS_DEBUG
    NSLog(@"flag=%@",flag);
    #endif
	
	//if loading page is 國泰金控員工入口網站首頁，dismiss modal
	if ([flag rangeOfString:@"国泰"].location != NSNotFound) {
        //if ([flag isEqualToString:@"國泰人壽會員登入"]) {	
        
        [UIView animateWithDuration:0.8 animations:^(void) {
            
            popWebView.alpha = 0;
            
        }completion:^(BOOL finished) {
            popWebView.hidden = YES;
            [self dismissModalViewControllerAnimated:YES];
        }];
        
        
	}
	
}


@end
