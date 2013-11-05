//
//  AppDelegate.m
//  CathayMeeting
//
//  Created by Fanny Sheng on 12/5/29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "CathayMeetingViewController.h"
#import "CathayFileHelper.h"
#import "CathayGlobalVariable.h"
#import "LoginModalViewController.h"
#import "BookShelfDAO.h"
#import "CathayDeviceUtil.h"
#import "CathayGroupAccessHelper.h"
#import "ASIFormDataRequest.h"
#import "EncodingHelper.h"

//版本更新通知url
//static NSString *checkCampaignUrl = @"http://10.20.35.1/servlet/HttpDispatcher/FBA8_1000/version";
static NSString *checkCampaignUrl = @"http://180.166.180.248/servlet/HttpDispatcher/FBA8_1000/version";
//新版本程序下载
//static NSString *appDLUrl = @"http://10.20.35.1/servlet/HttpDispatcher/FBA8_1000/appDownload";
static NSString *appDLUrl = @"http://180.166.180.248/servlet/HttpDispatcher/FBA8_1000/appDownload";

//-------------------------------------------------------------------------
//define

@interface AppDelegate()

//plist related
- (NSMutableDictionary *) getDicFromDocWithPlistName:(NSString *)name;
- (void) writeNowTime;
- (void) writeToPlistWithKey:(NSString *) key Value:(NSString *) value;

-(void) checkAppVersion;
@end

//-------------------------------------------------------------------------
//implement


@implementation AppDelegate

@synthesize window = _window;
//@synthesize navigationController = _navigationController;
@synthesize viewController;
@synthesize currentPresentedModalViewController;
@synthesize logInOutAgent;
@synthesize pushNotificationDelegate;

- (void)dealloc
{
    [_window release];
    [pushNotificationDelegate release];
//    [_navigationController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    //------------------------------
    //init Logoutdelegate...
    LogInOutAgent* agent = [[LogInOutAgent alloc]init];
    self.logInOutAgent = agent;
    [agent release];
    
    //------------------------------    
    //check the File existence
    [CathayFileHelper copyNeededFileToDocIfNeededWithFileName:@"app.plist"];
    [CathayFileHelper copyNeededFileToDocIfNeededWithFileName:@"DOC_LOCAL.sqlite"];
    [CathayFileHelper copyNeededFileToDocIfNeededWithFileName:@"blankPage.pdf"];
    
    
    //------------------------------        
    //初始啟動，將目前時間寫入，以供計算Timeout時間用
    [self writeNowTime];
    
    //------------------------------        
    // 寫入目前版本號至groupAccess，供國泰市集判斷版本號用
    
    
    CathayGroupAccessHelper *groupAccess = [[CathayGroupAccessHelper alloc]init];

    NSLog(@"寫入目前版本號至groupAccess");
    NSLog(@"目前groupAccess scheme:%@ appVersion:%@",
          [CathayDeviceUtil appUrlSchemes],
          [groupAccess getAppVersionWithAppScheme:[CathayDeviceUtil appUrlSchemes]]);

    [groupAccess putAppVersion:[CathayDeviceUtil appVersion] WithAppScheme:[CathayDeviceUtil appUrlSchemes]];
    [groupAccess release];    
    
    // Override point for customization after application launch.
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    
    //------------------------------    
    //call out the login view 
    LoginModalViewController *loginView = [[LoginModalViewController alloc]init];
    loginView.delegate = self;
    loginView.status = 0;
    [self.viewController presentModalViewController:loginView animated:NO];
    [loginView release];
    
    //初始不允許CathayLifeAppStore去讀取AppList，因為尚未登入
    [AppDataSingleton shareData].okToLoad = NO;
    
    //預設不開啟離線瀏覽模式
    [AppDataSingleton shareData].cathayBooksOfflineModeEnabled = NO;

    //建立寄送email之tmp資料夾
    [CathayFileHelper createFolderUnderDocument:@"mailTMP"];
    
    //如果mailTMP下有殘存資料要清空
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    NSString *folderpath = [docPath stringByAppendingPathComponent:@"mailTMP"];
    [CathayFileHelper deleteFilesUnderFolder:folderpath];
    
    //-------------------------------
    //清空上次最後使用筆的使用狀況(粗細 顏色)
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setValue:nil forKey:@"lastBrushSize"];
    [prefs setValue:nil forKey:@"lastBrushColor"];
    [prefs setValue:nil forKey:@"lastCanvasButton"];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    //------------------------------        
    //點擊Home鍵離開，將目前時間寫入，以供計算Timeout時間用
    NSLog(@"點擊Home鍵離開，將目前時間寫入，以供計算Timeout時間用");
    [self writeNowTime];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    //檢查是否超過設定的timeout時間，超過便會強迫登出，跳出登入視窗
    //目前設定以CRM timeout時間為基準 - 20分
    
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    
    //取得plist Local date
    NSMutableDictionary* plistDict = [self getDicFromDocWithPlistName:@"app.plist"];
    NSString *localTimeOutStamp = [plistDict objectForKey:@"TimeOutStamp"];
    
    NSLog(@"localTimeOutStamp: %@",localTimeOutStamp);
    NSLog(@"Now Sys Date: %@", [dateFormat stringFromDate:now]);
    
    NSDate *localDate = [dateFormat dateFromString:localTimeOutStamp];
    [dateFormat release];
    
    //轉換為Interval進行比較
    NSTimeInterval localInterval = [localDate timeIntervalSince1970]*1;
    NSTimeInterval nowInterval = [now timeIntervalSince1970]*1;
    
    NSTimeInterval diff = nowInterval - localInterval;
    
    int diffMins = diff / 60; 
    
    NSLog(@"time difference is %d mins", diffMins);
    
    if (diffMins >= TIMEOUT_MINS) {
        
        NSLog(@"超過預定Timeout時間(%d分），並轉至登入視窗！", diffMins);
        
        if (currentPresentedModalViewController) {
            [currentPresentedModalViewController dismissModalViewControllerAnimated:NO];
        }
        
        //------------------------------    
        //call out the login view 
        LoginModalViewController *loginView = [[LoginModalViewController alloc]init];
        loginView.delegate = self;
        loginView.status = 1;
        [self.viewController presentModalViewController:loginView animated:YES];
        [loginView release];
    }

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    //當程式要被強制關閉時，才將資料庫連線關閉
    //TODO 測試看看縮到背景後，一段時間沒用，資料庫連線會不會斷
    BookShelfDAO *dao = [BookShelfDAO sharedDAO];
    [dao closeDatabase];
}

#pragma mark -
#pragma mark pList related
-(NSMutableDictionary *) getDicFromDocWithPlistName:(NSString *)name {
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *filePath = [documentsDirectory stringByAppendingPathComponent:name];
	BOOL success = [fileManager fileExistsAtPath:filePath];
	
	if(!success){
        NSLog(@"plist is not Exist..");
		return nil;
	}
	
	return [[[NSMutableDictionary alloc] initWithContentsOfFile:filePath] autorelease];
	
}

-(void) writeNowTime {
    
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormat stringFromDate:today];
    [dateFormat release];
    NSLog(@"Timeout計時器，初始設定起始時間: %@", dateString);
    
    [self writeToPlistWithKey:@"TimeOutStamp" Value:dateString];
}

-(void) writeToPlistWithKey:(NSString *) key Value:(NSString *) value {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSMutableDictionary* plistDict = [self getDicFromDocWithPlistName:@"app.plist"];
    [plistDict setObject:value forKey:key];
    NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:@"app.plist"];
    NSLog(@"plistPath:%@", plistPath);
    BOOL plistOK = [plistDict writeToFile:plistPath atomically:YES];
    
    if (!plistOK) {
        NSLog(@"plist write failed!");
    }else {
        NSLog(@"plist write ok!");
    }
    
}

#pragma mark -
#pragma mark LoginModalViewDelegate

//登入完成後
- (void)didDismissModalView {
    
    //關閉離線瀏覽模式
    [AppDataSingleton shareData].cathayBooksOfflineModeEnabled = NO;
    [self.viewController dismissModalViewControllerAnimated:YES];
    
    [self checkAppVersion];
}

- (void)didDismissModalViewWithOfflineMode {
    
    NSLog(@"直接進入離線瀏覽模式！");
    
    //開啟離線瀏覽模式
    [AppDataSingleton shareData].cathayBooksOfflineModeEnabled = YES;
    [AppDataSingleton shareData].okToLoad = YES;
    
    [self.viewController dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    NSLog(@"更新通知，點下at %d, %@", buttonIndex, title);
    
    //立即更新
    if (buttonIndex == 1) {        
        
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:appDLUrl]];
        [request addRequestHeader:@"X-Requested-With" value:@"XMLHttpRequest"];
        
        NSString* appID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
        NSString* newVersion = [[alertView layer] valueForKey:@"VERSION"];
        
        [request setPostValue:@"IOS" forKey:@"OSTYPE"];
        [request setPostValue:appID forKey:@"IOS_IDENTIFY"];
        [request setPostValue:newVersion forKey:@"VERSION"];
        
        
        [request setValidatesSecureCertificate:NO]; //取消HTTPS授權檢查
        
        NSLog(@"requestURL-->%@", [request url]);
        
        //正常執行成功
        [request setCompletionBlock:^{
            
            //BIG5
            EncodingHelper* encodeHelper = [EncodingHelper new];
            NSData *cleanData = [encodeHelper cleanBIG5:[request responseData]];
            [encodeHelper release];
            
            NSString *str = [[NSString alloc] initWithData:cleanData encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5)];
            
            //去除空白
            NSString *trimmedString = [str stringByTrimmingCharactersInSet:
                                       [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [str release];
            
            NSLog(@"取得下載位置resp:%@", trimmedString);
            
            if (trimmedString && [trimmedString length]>0) {
                //開啟更新
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:trimmedString]];                        
            }
            
        }];
        
        //執行失敗
        [request setFailedBlock:^{
            
            NSError *error = [request error];
            NSLog(@"Connection Failed - %@, DOMAIN - %@, CODE - %d", [error localizedDescription] ,error.domain, error.code);
            
            UIAlertView *alert = [[UIAlertView alloc] 
                                  initWithTitle: @"错误通知"
                                  message:@"网络连接发生问题，请重试"
                                  delegate:self 
                                  cancelButtonTitle:@"下次再提醒我"
                                  otherButtonTitles:@"立即重复更新",  nil];
            
            [[alert layer]setValue:newVersion forKey:@"VERSION"];
            
            [alert show];
            [alert release];
            
        }];
        
        
        [request startAsynchronous];
        
        
    }
    
}

#pragma mark -
#pragma mark 版本檢查

-(void) checkAppVersion{
    
    //-------------
    //版本更新通知
    ASIFormDataRequest *activityRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:checkCampaignUrl]];
    [activityRequest addRequestHeader:@"X-Requested-With" value:@"XMLHttpRequest"];
    [activityRequest setPostValue:@"IOS" forKey:@"OSTYPE"];
    [activityRequest setPostValue:[CathayDeviceUtil appIdentifier] forKey:@"IOS_IDENTIFY"];
    [activityRequest setPostValue:[CathayDeviceUtil appVersion] forKey:@"VERSION"];
    [activityRequest setPostValue:[CathayDeviceUtil platform] forKey:@"PAD_TYPE"];
    [activityRequest setPostValue:[CathayDeviceUtil carrier] forKey:@"CARRIER"];
    [activityRequest setPostValue:[CathayDeviceUtil osVersion] forKey:@"OS"];
    [activityRequest setPostValue:[CathayDeviceUtil UDID] forKey:@"UDID"];
    
    //因為有中文，所以以Big5編碼送出
    [activityRequest setStringEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5)];
    
    [activityRequest setValidatesSecureCertificate:NO]; //取消HTTPS授權檢查
    
    NSLog(@"requestURL-->%@", [activityRequest url]);
    
    //正常執行成功
    [activityRequest setCompletionBlock:^{
        
        //BIG5
        EncodingHelper* encodeHelper = [EncodingHelper new];
        NSData *cleanData = [encodeHelper cleanBIG5:[activityRequest responseData]];
        [encodeHelper release];
        
        NSString *str = [[NSString alloc] initWithData:cleanData encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5)];
        
        //去除空白
        NSString *trimmedString = [str stringByTrimmingCharactersInSet:
                                   [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [str release];
        
        NSLog(@"版本比對 resp:%@", trimmedString);
        
        NSDictionary *jsonDic = [trimmedString JSONValue];
        
        //-------------------------
        // 版本比對訊息通知(更新)
        
        //當有系統訊息通知時
        if ([jsonDic count] > 0) {
            
            //取得遠端最新版本號
            NSString* remoteversion = [[jsonDic objectForKey:@"VERSION"]stringByReplacingOccurrencesOfString:@"." withString:@""];
            
            //取得目前軟體版本號
            NSString *version = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]stringByReplacingOccurrencesOfString:@"." withString:@""];
            
            NSLog(@"自身軟體版本比對 remoteversion:%f, version:%f", [remoteversion doubleValue], [version doubleValue]);
            
            if ([remoteversion doubleValue] > [version doubleValue]) {
                
                NSString *content = [jsonDic objectForKey:@"WHAT_IS_NEW"];
                
                UIAlertView *alert = [[UIAlertView alloc] 
                                      initWithTitle: @"更新通知" 
                                      message:content
                                      delegate:self 
                                      cancelButtonTitle:@"下次再提醒我" 
                                      otherButtonTitles:@"立即更新",  nil];
                
                [[alert layer]setValue:[jsonDic objectForKey:@"VERSION"] forKey:@"VERSION"];
                
                [alert show];
                [alert release];
                
            }
            
        }
        
        
    }];
    
    //執行失敗
    [activityRequest setFailedBlock:^{
        
        NSError *error = [activityRequest error];
        NSLog(@"Connection Failed - %@, DOMAIN - %@, CODE - %d", [error localizedDescription] ,error.domain, error.code);
        
    }];
    
    
    [activityRequest startAsynchronous];

    
}

#pragma mark -
#pragma mark Register Remote Notifications


- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    
#ifdef IS_DEBUG
    NSLog(@"收到token了...");
#endif    
    
    NSMutableString *tokenString = [NSMutableString stringWithString:[[deviceToken description] uppercaseString]];  
    [tokenString replaceOccurrencesOfString:@"<" withString:@"" options:0 range:NSMakeRange(0, tokenString.length)];  
    [tokenString replaceOccurrencesOfString:@">" withString:@"" options:0 range:NSMakeRange(0, tokenString.length)];  
    [tokenString replaceOccurrencesOfString:@" " withString:@"" options:0 range:NSMakeRange(0, tokenString.length)];  
    
    //委任pushNotificationDelegate實作
    [pushNotificationDelegate returnAPNStoken:tokenString];
    
}


- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {  
    
    UIAlertView* failureAlert = [[UIAlertView alloc] initWithTitle:@"推送错误："  
                                                           message:err.localizedDescription  
                                                          delegate:nil  
                                                 cancelButtonTitle:@"OK"  
                                                 otherButtonTitles:nil];  
    [failureAlert show];  
    [failureAlert release];  
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    //	viewController.token.text = [userInfo description];
    
#ifdef IS_DEBUG
	NSLog(@"Receive notification:%@",[userInfo description]);
#endif
    
    
}


- (UIRemoteNotificationType)enabledRemoteNotificationTypes {
    
	return UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound;
}


@end
