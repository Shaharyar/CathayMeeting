//
//  CathayMeetingViewController.h
//  CathayMeeting
//
//  Created by Fanny Sheng on 12/5/29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AQGridView.h"
#import "MBProgressHUD.h"
#import "ReaderViewController.h"
#import "ReLoginActions.h"
#import "LoadingViewDelegate.h"

typedef enum {
	RemoteStatusInUse = 1,          
	RemoteStatusDeprecated = 0,     
} RemoteStatus;

@class BookShelfDAO;
@class ASIHTTPRequest;
@class ASINetworkQueue;
@class ASIFormDataRequest;


@interface CathayMeetingViewController : UIViewController< UIActionSheetDelegate,AQGridViewDelegate,
AQGridViewDataSource,ReLoginActions,LoadingViewDelegate,ReaderViewControllerDelegate,
MBProgressHUDDelegate,MFMailComposeViewControllerDelegate>{
    
    NSMutableArray *documentsArray;
    
    BookShelfDAO *dao;
    
    //net
    ASIFormDataRequest *downloadRequest;
    ASINetworkQueue *downloadQueue;
    
    UIView *downloadView;
    UIProgressView *progressView;
    UILabel *downloadMsgLabel;
    UILabel *downloadRcvMbytesLabel;
    UITextView *downloadMsgTextView;
    UIButton *down_StopBtn;
    
    NSMutableSet *cacheSelectedIndexs;  //多選 - 暫存未下載之項目
    NSMutableSet *cachefailedIndexs;    //多選 - 暫存大量下載時，錯誤的項目
    NSMutableSet *cacheUpdateIndexs;  //多選 - 暫存更新之項目
    NSMutableSet *cacheMailIndexs;  //多選 - 暫存打包寄送之項目
    
    NSString *keepCompanyID;
    NSString *keepMeetID;
    NSString *keepDateID;
    
    long long totalDownloadBytes;   //單筆-總下載大小
    long long nowDownloadBytes;     //單筆-目前下載量
    
    int lastmeetingcell; //記錄上一個點選的meet cell
    
    BOOL editorModeEnable; //多選編輯模式
}

@property (retain, nonatomic) IBOutlet UIImageView *headerImgView;
@property (retain, nonatomic) IBOutlet UIImageView *bottomImgView;
@property (retain, nonatomic) IBOutlet UIView *contentView;
@property (retain, nonatomic) IBOutlet AQGridView *meetinggridView;
@property (retain, nonatomic) IBOutlet AQGridView *dategridView;
@property (retain, nonatomic) IBOutlet AQGridView *docgridView;

@property (retain, nonatomic) IBOutlet UILabel *versionLabel;
@property (nonatomic, retain) IBOutlet UILabel *offlineModeLabel;

@property (nonatomic, retain) IBOutlet UILabel *dateLabel;
@property (nonatomic, retain) IBOutlet UIButton *meetingButton;
@property (nonatomic, retain) IBOutlet UIButton *mutiSelectButton;
@property (nonatomic, retain) IBOutlet UIButton *refreshButton;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) IBOutlet UILabel *loadingLabel;
@property (nonatomic, retain) IBOutlet UIView *loadingView;

//data..
@property (nonatomic, retain) NSMutableDictionary *menuDataDic; //所有原始資料
@property (nonatomic, retain) NSMutableArray *categoryItems; 

@property (retain, nonatomic) NSMutableDictionary *meetingDict; //各會議資料
@property (retain, nonatomic) NSMutableDictionary *dateDict; // 會議下各會期資料
@property (retain, nonatomic) NSArray *gridMeetingKeys;
@property (retain, nonatomic) NSArray *gridDateKeys;
@property (nonatomic, retain) NSMutableArray *documentsArray; //文件資料

//downloadView related
@property (nonatomic, retain) IBOutlet UIView *downloadView;
@property (nonatomic, retain) IBOutlet UIProgressView *progressView;
@property (nonatomic, retain) IBOutlet UILabel *downloadMsgLabel;
@property (nonatomic, retain) IBOutlet UILabel *downloadRcvMbytesLabel;
@property (nonatomic, retain) IBOutlet UITextView *downloadMsgTextView;
@property (nonatomic, retain) IBOutlet UIButton *down_StopBtn;

- (IBAction) logout;
- (IBAction) showMenuView;
- (IBAction) cancelDownload:(id)sender;
- (IBAction) selectDoc:(id)sender;
- (IBAction) refreshRemoteData:(id)sender;


@end
