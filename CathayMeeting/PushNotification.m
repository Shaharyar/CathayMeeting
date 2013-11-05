//
//  PushNotification.m
//  InsProposal
//
//  Created by dev1 on 2012/7/05.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PushNotification.h"
#import "ASIHTTPRequest.h"
#import "NetDetectHelper.h"
#import "ASIFormDataRequest.h"
#import "EncodingHelper.h"
#import "AppDelegate.h"
#import "CathayGlobalVariable.h"


/*
 APP不需要帶STATUS狀態，由後台依TOKEN_ID判斷做INSERT或UPDATE，
 APP不管做什麼動作 (關閉推播或開啟推播)   全部參數都重新傳回後端，由後台直接更新
 
 參數如下
 APP_NAME: (APP英文名稱) 
 OS_TYPE: 1表示IOS、2表示Android
 TOKEN_ID:
 IS_NOTIFY: Y(表示允許推播) N(表示不允許)
 USERID: (使用者ID)
 */ 

#define APP_NAME @"CathayMeeting"
#define OS_TYPE @"1"

//檢核時間：7天 (10080分)
#define SEVENDAY_MINS 10080

@implementation PushNotification

//static NSString *recordAppPushUrl = @"http://10.20.35.1/servlet/HttpDispatcher/CM_pushNtfc/push";
static NSString *recordAppPushUrl = @"http://180.166.180.248/servlet/HttpDispatcher/CM_pushNtfc/push";

// 外部调用的入口方法
-(void)callPushNotification{  
    
    //實作PushNotificationDelegate
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.pushNotificationDelegate = self;
    
    
    //-------------------                    
    //取plist檢查是否已申請token
    
    //取得NSUserDefaults資料
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *loginID = [prefs stringForKey:@"idFiled"];
    NSString *registrationID = [prefs stringForKey:@"RegistrationID"];
    BOOL isNotifyServer = [prefs boolForKey:@"isNotifyServer"];
    
    NSLog(@"===>loginID: %@",loginID);
    NSLog(@"===>registrationID: %@",registrationID);
    NSLog(@"===>isNotifyServer: %d",isNotifyServer);
    
    if (registrationID) {
        
        //檢查通知設定是否關閉
        bool pushStatus = [self checkPushSettingStatus];
        
        if([loginID isEqualToString:registrationID]==NO ){
            
            NSString *msg = [NSString stringWithFormat:@"是否更改推送通知接受者为:%@",loginID];
            
            UIAlertView *alert = [[UIAlertView alloc] 
                                  initWithTitle: @"提醒"
                                  message:msg
                                  delegate:self
                                  cancelButtonTitle:@"取消" 
                                  otherButtonTitles:@"确定",nil];
            [alert show];
            [alert release];
            
        } else {
            
            if(!pushStatus){
                [self alertMsgByTime];
            }
            
            if(isNotifyServer != pushStatus){
                NSLog(@"系统推送状态与后台不一致");
                //取Token更新後端
                [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound];
            }
        }
           
        
    } else {
        NSLog(@"從沒進來過會送第一次資料");
        //APNs申請Token                
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound];
        
    }
    
}

#pragma mark -
#pragma mark PushNotificationDelegate
// 在本机记录登录者的更新状态 调用insertTokenToDB
-(void) returnAPNStoken:(NSString *) returnToken {
    
    //取得使用者帳號
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    if (returnToken && [returnToken length]>0) {
        
        NSString *loginID = [prefs stringForKey:@"idFiled"];
        
        //沒有要更換使用者又要寫回資料時，需取原先使用者id
        if (isNotChange) {
            NSLog(@"沒有要更換使用者但需寫回資料");
            loginID = [prefs stringForKey:@"RegistrationID"];
        }
       
        //檢查通知設定是否關閉
        bool pushStatus = [self checkPushSettingStatus];
        
        NSString *isNotify;
        if(pushStatus){
            isNotify = @"Y";
        }
        else{
            isNotify = @"N";
        }
        
        //記錄至後端DB
        [self insertTokenToDB:returnToken UserID:loginID IsNotify:isNotify]; 
    }
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    NSLog(@"click at %d, %@", buttonIndex, title);
    
    //取NSUserDefaults資料
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    //更新"Setting提醒訊息"時間
    NSString* updateDate = (NSString *)[[alertView layer]valueForKey:@"UpdatePushSettingDate"];
    
    if(updateDate){
        [prefs setObject:updateDate forKey:@"CheckPushSettingDate"];
    }
    
    //使用者選擇取消
    if (buttonIndex == 0) {
        
        //檢查通知設定是否關閉
        bool pushStatus = [self checkPushSettingStatus];
        if(!pushStatus){
            [self alertMsgByTime];
        }
        
        //沒有要更換使用者
        isNotChange = YES;
        
        //判斷推播狀態是否一致
        BOOL isNotifyServer = [prefs boolForKey:@"isNotifyServer"];
        
        if(isNotifyServer != pushStatus){

            NSLog(@"機器推播狀態與後台不一致");

            //取Token更新後端
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound];
        }
        return;
    } else {
        //------------------------
        //更改推播通知接收者為登入者
        
        //再次向APNS取得Token                
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound];
        
    }
    
}

#pragma mark -
#pragma mark check PushNotification Setting status
// 看设定中的推送通知是否打开
-(BOOL) checkPushSettingStatus {
    
    UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    /*    
     //檢核標記Badge是否打開        
     if (types & UIRemoteNotificationTypeBadge) { 
     NSLog(@"===============================>YES   Badge  ......");
     }
     
     //檢核聲音Sound是否打開         
     if (types & UIRemoteNotificationTypeSound) { 
     NSLog(@"===============================>YES   Sound  ......");
     }
     */    
    
    //推播只檢核提示Alert有無打開
    if (types & UIRemoteNotificationTypeAlert) { 
        //已開啟
        return YES;
    } else {
        //未開啟
        return NO;
    }
    
}

// 比對時間，看是否有推送通知
-(void) alertMsgByTime{
    //--------------------------
    //比對時間，秀提示訊息
    
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //現在時間
    NSString *dateString = [dateFormat stringFromDate:now];
    
    //NSUserDefaults記錄時間
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *pushSettingDate = [prefs stringForKey:@"CheckPushSettingDate"];
    NSDate *checkDate = [dateFormat dateFromString:pushSettingDate];
    
    NSLog(@"=====>>checkDate : %@",checkDate);
    NSLog(@"Now Sys Date: %@", [dateFormat stringFromDate:now]);

    [dateFormat release];
    
    //轉換為Interval進行比較
    NSTimeInterval localInterval = [checkDate timeIntervalSince1970]*1;
    NSTimeInterval nowInterval = [now timeIntervalSince1970]*1;
    
    NSTimeInterval diff = nowInterval - localInterval;
    
    //分
    int diffMins = diff / 60; 
    
    NSLog(@"PushNotification time difference is %d mins", diffMins);
    
    //大於七天就彈訊息
    if (diffMins >= SEVENDAY_MINS) {
        
        UIAlertView *alert = [[UIAlertView alloc] 
                              initWithTitle: @"提醒"
                              message:@"您的推送通知目前是关闭状态，将无法接收到推送的新信息。如果想要开启请到设置/通知/行动会议进行开启。"
                              delegate:self
                              cancelButtonTitle:@"确认" otherButtonTitles:nil];
        
        [[alert layer]setValue:dateString forKey:@"UpdatePushSettingDate"];
        [alert show];
        [alert release];
    }
}


#pragma mark -
#pragma mark Insert DB
// 写入本地数据库 用户的更新时间状态等
-(void)insertTokenToDB:(NSString *)token UserID:(NSString *)id IsNotify:(NSString *) isNotify{

    NSLog(@"=====>>insertTokenToDB  token:%@  id:%@  isNotify:%@",token,id ,isNotify);

    //----------------------    
    //測試目前網路是否有通
    NetDetectHelper *netDetecter = [[NetDetectHelper alloc]init];
    BOOL isConnected = [netDetecter connectedToNetwork];
    [netDetecter release];

    NSLog(@"networkStatus is %@", (isConnected? @"YES" : @"NO"));

    if(!isConnected){
        return;
    }

    //網路連線
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:recordAppPushUrl]];

    /*
     APP_NAME: (APP英文名稱)
     OS_TYPE: 1表示IOS、2表示Android
     TOKEN_ID:
     IS_NOTIFY: Y(表示允許推播) N(表示不允許)   ReturnPushStatus
     USERID: (使用者ID)
    */
    [request setPostValue:APP_NAME forKey:@"APP_NAME"];
    [request setPostValue:OS_TYPE forKey:@"OS_TYPE"];
    [request setPostValue:token forKey:@"TOKEN_ID"];
    [request setPostValue:isNotify forKey:@"IS_NOTIFY"];
    [request setPostValue:id forKey:@"USERID"];

    [request setValidatesSecureCertificate:NO]; //取消HTTPS授權檢查

    NSLog(@"requestURL-->%@", [request url]);

    //正常執行成功
    [request setCompletionBlock:^{
    
        NSLog(@"Complete....");
    
        //BIG5
        EncodingHelper* encodeHelper = [EncodingHelper new];
        NSData *cleanData = [encodeHelper cleanBIG5:[request responseData]];
        [encodeHelper release];
    
        NSString *str = [[NSString alloc] initWithData:cleanData encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5)]; 
    
        NSLog(@"html is:%@",str);
    
        if (str || [str length]>0) {
        
            //檢查回傳資料是否為登入頁面
            BOOL match = ([str rangeOfString:@"$MobiAppLoginFlag" options:NSCaseInsensitiveSearch].location != NSNotFound);
        
            if(match){
                return ;
            }
        
            //去除空白
            NSString *trimmedString = [str stringByTrimmingCharactersInSet:
                                   [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [str release];
        
        
            NSDictionary *jsonDic = [trimmedString JSONValue];
            NSString *status = (NSString *)[jsonDic objectForKey:@"ReturnPushStatus"];
        
        
            NSLog(@"count is %d",[jsonDic count]);
            NSLog(@"======>>returnAPNStoken : %@", id);
            NSLog(@"======>>ReturnPushStatus : %@", status);
        
            if ([status isEqualToString:@"Y"]) {
            
                //--------------------------
                //寫入NSUserDefaults
                //取得使用者帳號
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            
                [prefs setObject:id forKey:@"RegistrationID"];
            
                if([isNotify isEqualToString:@"Y"]){
                    [prefs setBool:YES forKey:@"isNotifyServer"];
                }
                else{
                    [prefs setBool:NO forKey:@"isNotifyServer"];
                }
            
                //現在的日期
                NSDate *today = [NSDate date];
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSString *dateString = [dateFormat stringFromDate:today];
                [dateFormat release];
            
                //記錄時間
                [prefs setObject:dateString forKey:@"CheckPushSettingDate"];
            
            }
        
        }
    
    }];

    //執行失敗
    [request setFailedBlock:^{
    
        NSError *error = [request error];
        NSLog(@"Connection Failed - %@, DOMAIN - %@, CODE - %d", [error localizedDescription] ,error.domain, error.code);
    }];

    [request startAsynchronous];
}

@end