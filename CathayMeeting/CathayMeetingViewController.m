
//
//  CathayMeetingViewController.m
//  CathayMeeting
//
//  Created by Fanny Sheng on 12/5/29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CathayMeetingViewController.h"
#import "CathayGlobalVariable.h"
#import "DocumentCell.h"
#import "MeetingCell.h"
#import "DateCell.h"
#import "CellLoading.h"
#import "PlistHelper.h"
#import "CathayFileHelper.h"
#import "AppDelegate.h"
#import "CathayDeviceUtil.h"
#import "NetDetectHelper.h"
#import "ASIFormDataRequest.h"
#import "EncodingHelper.h"
#import "NSString+SBJSON.h"
#import "ASINetworkQueue.h"
#import "BookShelfDAO.h"
#import <QuartzCore/QuartzCore.h>
#import "CathayPDFGenerator.h"

//ActionSheet 按鈕文字
#define OPEN_TEXT @"打开"
#define DEL_TEXT @"删除"
#define RENAME_TEXT @"重命名"
#define DOWN_TEXT @"下载"

//書本類型
#define PATH_PDF @"PDF"

//HUD tag
#define HUD_SYNC_TAG 300
#define HUD_LOADING_TAG 301
#define HUD_OTHER_TAG 302
#define HUD_PDFLOADING_TAG 303

//GridView tag
#define GRIDVIEW_MEETING 400
#define GRIDVIEW_DATE 401
#define GRIDVIEW_DOC 402

//書本類型
#define FILE_EXT_PDF @"pdf"

//View tag
#define BLOCK_VIEW_TAG 255

//down_StopBtn Text
#define DOWN_BTN_TEXT_CANCEL @"取消"
#define DOWN_BTN_TEXT_CLOSE @"关闭"

//取会议列表和对应的文件列表
//static NSString *meetingUrl = @"http://10.20.35.1/servlet/HttpDispatcher/FBA8_1000/categories";
static NSString *meetingUrl = @"http://180.166.180.248/servlet/HttpDispatcher/FBA8_1000/categories";

//取得書本同步資料，並更新本地端資訊
//static NSString *aliveBooksUrl = @"http://10.20.35.1/servlet/HttpDispatcher/FBA8_1000/aliveBookIds";
static NSString *aliveBooksUrl = @"http://180.166.180.248/servlet/HttpDispatcher/FBA8_1000/aliveBookIds";

//会议文件下载请求地址
//static NSString *cloudBooksURL = @"http://10.20.35.1/servlet/HttpDispatcher/FBA8_1000/books?";
static NSString *cloudBooksURL = @"http://180.166.180.248/servlet/HttpDispatcher/FBA8_1001/books?";

@interface CathayMeetingViewController ()

@property (nonatomic, assign) MBProgressHUD *HUD;

/////////
-(void) layoutViewsWithRotation;

// plist
//-(NSMutableDictionary *) getDocumentsPlistDictUnderDoc;
//-(void) writeDocumentsPlistDictToDoc:(NSMutableDictionary *) newDict;

//文件排序
-(NSArray *) sortedDicKeysByOrderWithDic:(NSDictionary *)dict ascending:(BOOL) ascending;
-(NSMutableArray *) sortedByOrderWithDocArray:(NSMutableArray *)docArray ascending:(BOOL) ascending;

//warn Msg
-(void)showMessage:(NSString *)message;

//File Management
-(NSString *) getDocumentUserDirectoryPath;
-(void) checkAndCreateUserSubDirectory ;

//Data related
-(void) showBookFunctionPopUpWithSelectedIndex:(NSUInteger) index  bookCell:(DocumentCell *)selctedCell;

//Data
-(void) getRemoteMenuData;
-(void) parseMenuDictToGenMeetingDic;
-(void) getRemoteDocByDateID:(NSString *) dateID;
//-(void) parsedDocMenuDictToGenDocDic;

-(BOOL) writeBookAndRelatedDataToDB:(NSDictionary *) bookDic;

//Local Data
-(void) getLocalMenuData;
-(void) getLocalDocsByDateID:(NSString *) dateID;

//sync
-(void) syncBooks;
-(void) syncWithRemoteData;
-(NSMutableArray *) parseCloudData:(NSMutableArray *) cloudBooksArray withCategory:(NSString *) categoryID;

//download
-(void) downloadFileWithUrlPath:(NSString *)urlPath savePath:(NSString *) savePath bookDic:(NSMutableDictionary *) bookDic;
-(void) downloadAllDoc;
-(void) showDownloadView;
-(void) hideDownloadView;
-(void) setProgress:(float)progress;

//loading View
-(void) showLoadViewWithText:(NSString *) text;
-(void) showAlertViewWithText:(NSString *) text;
-(void) hideLoadView;

//刪除更新件之原有筆跡
-(void) deleteOldPageStrokeDict:(NSDictionary *) bookDic;

//多選處理列 - 選取/取消選取 cell，並同步cache arrays
-(void) selectUnselectBookGridCell:(DocumentCell *)cell index:(NSUInteger) index selection:(BOOL)select showMessage:(BOOL) showMessage;
//多選寄送
- (void)sendMultiEmail;

//自動開啟文件
- (void)autoOpenOnlyDoc:(NSMutableDictionary*) documentDic;

@end


@implementation CathayMeetingViewController

@synthesize headerImgView,bottomImgView,contentView,meetinggridView;
//@synthesize documentsPlistDict,documentsDict,gridDocumentKeys;
@synthesize documentsArray;
@synthesize dategridView,docgridView;
@synthesize versionLabel,offlineModeLabel;
@synthesize activityIndicator,loadingView,loadingLabel;
@synthesize menuDataDic,categoryItems;
@synthesize meetingDict,gridMeetingKeys;
@synthesize dateDict,gridDateKeys;
@synthesize meetingButton,dateLabel;
//all download
@synthesize downloadView, progressView, downloadMsgLabel, downloadRcvMbytesLabel;
@synthesize downloadMsgTextView, down_StopBtn;
@synthesize HUD;
@synthesize mutiSelectButton,refreshButton;


- (void)dealloc{
    
    [headerImgView release];
    [bottomImgView release];
    [contentView release];
    [meetinggridView release];
    [documentsArray release];
    [dategridView release];
    [docgridView release];
    [versionLabel release];
    [offlineModeLabel release];
    [activityIndicator release];
    [loadingView release];
    [loadingLabel release];
    [menuDataDic release];
    [categoryItems release];
    [meetingDict release];
    [gridMeetingKeys release];
    [dateDict release];
    [gridDateKeys release];
    [dateLabel release];
    [meetingButton release];
    [mutiSelectButton release];
    [refreshButton release];
    
    [cachefailedIndexs release];
    [cacheSelectedIndexs release];
    [cacheUpdateIndexs release];
    [cacheMailIndexs release];
    
    [downloadView release];
    [progressView release];
    [downloadMsgLabel release];
    [downloadRcvMbytesLabel release];
    [downloadMsgTextView release];
    [down_StopBtn release];

    [HUD release];
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //取得資料庫實體...
    dao = [BookShelfDAO sharedDAO];
    
    //取得目前軟體版本號
    NSString *version = [CathayDeviceUtil appVersion];
    //顯示版本號
    #ifdef TEST_URL
    self.versionLabel.text = [NSString stringWithFormat:@"v%@t", version];
    #endif
    
    #ifdef PROD_URL
    self.versionLabel.text = [NSString stringWithFormat:@"v%@", version];
    #endif
    
    lastmeetingcell = -1; // 還沒選擇過meetcell;
    self.offlineModeLabel.hidden = YES;
    
    cachefailedIndexs = [[NSMutableSet alloc] init];
    cacheSelectedIndexs = [[NSMutableSet alloc] init];
    cacheUpdateIndexs = [[NSMutableSet alloc] init];
    cacheMailIndexs = [[NSMutableSet alloc] init];
        
    self.meetinggridView.delegate = self;
    self.meetinggridView.dataSource = self;
    self.meetinggridView.tag = GRIDVIEW_MEETING;
    self.dategridView.tag = GRIDVIEW_DATE;
    self.docgridView.tag = GRIDVIEW_DOC;
    
    
 //   self.meetinggridView.layoutDirection = AQGridViewLayoutDirectionHorizontal;
 //   self.dategridView.layoutDirection = AQGridViewLayoutDirectionHorizontal;

}

- (void)viewDidUnload
{
    
    [cachefailedIndexs release];
    cachefailedIndexs = nil;
    [cacheSelectedIndexs release];
    cacheSelectedIndexs = nil;
    [cacheUpdateIndexs release];
    cacheUpdateIndexs = nil;
    [cacheMailIndexs release];
    cacheMailIndexs = nil;
    
    [self setHeaderImgView:nil];
    [self setBottomImgView:nil];
    [self setContentView:nil];
    [self setMeetinggridView:nil];
    [self setDocumentsArray:nil];
    [self setDocgridView:nil];
    [self setDategridView:nil];
    [self setVersionLabel:nil];
    [self setOfflineModeLabel:nil];
    [self setLoadingView:nil];
    [self setLoadingLabel:nil];
    [self setMenuDataDic:nil];
    [self setCategoryItems:nil];
    [self setMeetingDict:nil];    [self setGridMeetingKeys:nil];
    [self setDateDict:nil];    [self setGridDateKeys:nil];
    [self setMeetingButton:nil]; 
    [self setDateLabel:nil];
    [self setMutiSelectButton:nil];
    [self setRefreshButton:nil];
    
    [self setDownloadView:nil];
    [self setProgressView:nil];
    [self setDownloadMsgLabel:nil];
    [self setDown_StopBtn:nil];
    [self setDownloadRcvMbytesLabel:nil];
    [self setDownloadMsgTextView:nil];

    [super viewDidUnload];

}

- (void) viewWillAppear:(BOOL)animated {
    
    //NSLog(@"viewWillAppear");
    
    [super viewWillAppear:animated];
    
     if ([AppDataSingleton shareData].okToLoad) {
         //重新登入畫面
         self.contentView.hidden = NO;
         self.meetingButton.hidden = YES;
         self.dateLabel.hidden = YES;
     }
}

-(void) viewDidAppear:(BOOL)animated {
        
    [super viewDidAppear:animated];
    
    NSLog(@"CathayMeeting viewDidAppear");
    
    if ([AppDataSingleton shareData].okToLoad) {
        
        //離線模式
        if ([AppDataSingleton shareData].cathayBooksOfflineModeEnabled) {
                        
            self.offlineModeLabel.hidden = NO;
            self.refreshButton.hidden = YES;
            [self showMessage:@"您正在使用离线模式，请定期登录更新文件，确保资料的正确性"];
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
            [self getLocalMenuData];
            [pool release];
             
            //線上模式
        }else {
            self.offlineModeLabel.hidden = YES;    
            self.refreshButton.hidden = NO;
            
            //使用者資料準備
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
            [self checkAndCreateUserSubDirectory];
            //[self syncBooks];
            [self getRemoteMenuData];
            [pool release];
        }
        
        //初始畫面
        [self.meetinggridView reloadData];
        
        [AppDataSingleton shareData].okToLoad = NO;
     
    }
    
    [self layoutViewsWithRotation];

	//[self.meetinggridView deselectItemAtIndex: [self.meetinggridView indexOfSelectedItem] animated: animated];

}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
    NSLog(@"***** didReceiveMemoryWarning *****");
    
}

#pragma mark -
#pragma mark RotateSupport

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    
    //NSLog(@"ProposalList willAnimateRotationToInterfaceOrientation");
    
    [self layoutViewsWithRotation];
    
    [super willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:duration];
}


//經驗值，針對畫面元素的位置大小調整，必須要寫在viewDidAppear才會產生作用
-(void) layoutViewsWithRotation {
    
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    //UIInterfaceOrientation interfaceOrientation = UIInterfaceOrientationPortrait;
    
 //   int gridPadding = 24;   //contentView左右留白空間
    
	if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
		
        #ifdef IS_DEBUG
        NSLog(@"Landscape");
        #endif
        
        UIImage * headerImg = [UIImage imageNamed: @"header1024.png"];
        UIImage * bottomImg = [UIImage imageNamed: @"bottom1024.png"];
        
        self.headerImgView.image = headerImg;
        self.headerImgView.frame = CGRectMake(0, 0, headerImg.size.width, headerImg.size.height);
        
        //依照現在是哪個view決定contentView位置
        
        if (self.meetingButton.hidden == YES) {
            self.contentView.frame = CGRectMake(0, self.headerImgView.frame.size.height+25, 1024 ,768-headerImg.size.height-bottomImg.size.height+25);
            self.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed: @"contentview_l.png"]];
            
            self.meetinggridView.frame = CGRectMake(0, 0,self.contentView.frame.size.width,250);
            self.dategridView.frame = CGRectMake(0, 270, self.contentView.frame.size.width, self.contentView.frame.size.height-250+25);
        }else {
            self.contentView.frame = CGRectMake(0, -768, 1024 ,537);
        }
              
        self.docgridView.frame = CGRectMake(0, self.headerImgView.frame.size.height+25,self.contentView.frame.size.width ,self.contentView.frame.size.height);
                          
        self.bottomImgView.image = bottomImg;
        self.bottomImgView.frame = CGRectMake(0,620, bottomImg.size.width, bottomImg.size.height);
        self.bottomImgView.backgroundColor = [UIColor clearColor];
        
	} else {
		
        #ifdef IS_DEBUG
        NSLog(@"Portrait");        
        #endif
        
        UIImage * headerImg = [UIImage imageNamed: @"header768.png"];
        UIImage * bottomImg = [UIImage imageNamed: @"bottom768.png"];
        
        self.headerImgView.image = headerImg;
        self.headerImgView.frame = CGRectMake(0, 0, headerImg.size.width, headerImg.size.height); 

      //  self.contentView.frame = CGRectMake(gridPadding, self.headerImgView.frame.size.height, 768 - gridPadding * 2, 1004-headerImg.size.height-bottomImg.size.height);
        
        if (self.meetingButton.hidden == YES) {
        self.contentView.frame = CGRectMake(0, self.headerImgView.frame.size.height+25, 768,self.view.frame.size.height-headerImg.size.height-bottomImg.size.height+35);
          self.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed: @"contentview_p.png"]];

        self.meetinggridView.frame =CGRectMake(0, 0, self.contentView.frame.size.width, 250);
        self.dategridView.frame = CGRectMake(0, 300, self.contentView.frame.size.width,  self.contentView.frame.size.height-250+35);
            
        }else {
            self.contentView.frame = CGRectMake(0, -1004, 768 ,783);
        }
        
        self.docgridView.frame = CGRectMake(0, self.headerImgView.frame.size.height+25,self.contentView.frame.size.width ,self.contentView.frame.size.height);

        self.bottomImgView.image = bottomImg;
        self.bottomImgView.frame = CGRectMake(0, self.view.frame.size.height-bottomImg.size.height, bottomImg.size.width, bottomImg.size.height);

	}
}


- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    //NSLog(@"ProposalList didRotateFromInterfaceOrientation");
    
    [super didRotateFromInterfaceOrientation:interfaceOrientation];
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //NSLog(@"ProposalList shouldAutorotateToInterfaceOrientation");
    
    // Return YES for supported orientations
	return YES;
}


#pragma mark -
#pragma mark AQGridViewDataSource

- (NSUInteger) numberOfItemsInGridView: (AQGridView *) gridView;
{
    
    int num = 0;
    
    if (gridView.tag == GRIDVIEW_MEETING) {
        num = [self.meetingDict count];
    }else if (gridView.tag == GRIDVIEW_DATE) {
        if(self.dateDict != NULL){
            num = [self.dateDict count];
        }
    }else if(gridView.tag == GRIDVIEW_DOC) {
        if(self.documentsArray != NULL){
            num = [self.documentsArray count];
        }
    }

    return num;
}

- (AQGridViewCell *) gridView: (AQGridView *)inGridView cellForItemAtIndex: (NSUInteger) index;
{   
    if (inGridView.tag == GRIDVIEW_MEETING) {

        static NSString *reuseIdentifier = @"MeetingCell";
        
        MeetingCell *cell = (MeetingCell *)[inGridView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil) {
            cell = [MeetingCell cell];
            cell.reuseIdentifier = reuseIdentifier;
        }
        
        NSString *meetingID = [self.gridMeetingKeys objectAtIndex:index];
        NSMutableDictionary *dataDict = [self.meetingDict objectForKey:meetingID];
        
        cell.nameLabel.text = [dataDict objectForKey:@"CATEGORY_NAME"];
        NSString *coverImgName = @"meeting.png";
        
        UIImage *coverImg = [UIImage imageNamed:coverImgName];
        
        if (coverImg) {
            cell.coverImg.hidden = NO;
            cell.noPicLabel.hidden = YES;
            cell.coverImg.image = coverImg;
        }else{
            cell.coverImg.hidden = YES;
            cell.nameLabel.hidden = NO;
            cell.noPicLabel.hidden = NO;
        }
        
        return cell;
        
    }else if (inGridView.tag == GRIDVIEW_DATE) {
        
        static NSString *reuseIdentifier = @"DateCell";
        
        DateCell *cell = (DateCell *)[inGridView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil) {
            cell = [DateCell cell];
            cell.reuseIdentifier = reuseIdentifier;
        }
        
        NSString *meetingID = [self.gridDateKeys objectAtIndex:index];
        NSMutableDictionary *dataDict = [self.dateDict objectForKey:meetingID];
        
        cell.nameLabel.text = [dataDict objectForKey:@"CATEGORY_NAME"];
        NSString *coverImgName = @"calendar_128.png";
        
        UIImage *coverImg = [UIImage imageNamed:coverImgName];
        
        if (coverImg) {
            cell.coverImg.hidden = NO;
            cell.noPicLabel.hidden = YES;
            cell.coverImg.image = coverImg;
        }else{
            cell.coverImg.hidden = YES;
            cell.nameLabel.hidden = NO;
            cell.noPicLabel.hidden = NO;
        }
        
        return cell;

    }else if (inGridView.tag == GRIDVIEW_DOC) {
        
        self.mutiSelectButton.hidden = NO;
        
        static NSString *reuseIdentifier = @"DocumentCell";
        
        DocumentCell *cell = (DocumentCell *)[inGridView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil) {
            cell = [DocumentCell cell];
            cell.reuseIdentifier = reuseIdentifier;
        }

        NSMutableDictionary *dataDict = [self.documentsArray objectAtIndex:index];
        
        cell.nameLabel.text = [dataDict objectForKey:@"TITLE"];
        NSString *coverImgName = @"icon_doc.png";
        GridStatus gridStatus = [[dataDict objectForKey:@"BookGridStatus"]intValue];
        [cell setStatus:gridStatus];

        
        UIImage *coverImg = [UIImage imageNamed:coverImgName];
        
        if (coverImg) {
            cell.coverImg.hidden = NO;
            cell.noPicLabel.hidden = YES;
            cell.coverImg.image = coverImg;
            cell.checkedImg.hidden = YES;
        }else{
            cell.coverImg.hidden = YES;
            cell.nameLabel.hidden = NO;
            cell.noPicLabel.hidden = NO;
            cell.checkedImg.hidden = YES;
        }
        
        return cell;
        
    }
    
}


- (CGSize) portraitGridCellSizeForGridView: (AQGridView *) gridView;
{
    
    if(gridView.tag == GRIDVIEW_MEETING){
        return CGSizeMake(220, 240);
    }else if(gridView.tag == GRIDVIEW_DATE){
        return CGSizeMake(200, 240);
    }
    
	return CGSizeMake(240, 260);
}


#pragma mark -
#pragma mark AQGridViewDelegate

- (void) gridView:(AQGridView *) inGridView didSelectItemAtIndex: (NSUInteger) index;
{
    
    if(inGridView.tag == GRIDVIEW_MEETING){
        
       MeetingCell *cell = (MeetingCell *)[inGridView cellForItemAtIndex:index];
       UIImage *coverImg_selected = [UIImage imageNamed:@"meeting_selected.png"];
       UIImage *coverImg = [UIImage imageNamed:@"meeting.png"];
        
        if (lastmeetingcell == -1) {
            cell.coverImg.image = coverImg_selected;          
        }else {
            MeetingCell *last_cell = (MeetingCell *)[inGridView cellForItemAtIndex:lastmeetingcell];
            last_cell.coverImg.image = coverImg;
            cell.coverImg.image = coverImg_selected;
        }
        
        lastmeetingcell = (int)index;
        
       NSString *meetingID = [self.gridMeetingKeys objectAtIndex:index]; //選取之會議別
        
       //透過選取之會議別  先記錄公司別
        for (int i = 0; i < [menuDataDic count]; i++) {
            
            NSString *companyID = [[self.menuDataDic allKeys]objectAtIndex:i]; //公司別
            
            NSMutableDictionary *tmp =  [self.menuDataDic objectForKey: companyID];
            
            [tmp enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                
                if([key isEqualToString:@"subFolders"]){
                    
                    //抓各會議類別資料
                    if (obj != NULL) {
                        for (int j = 0; j < [obj count]; j++) {
                            NSString *meetingID_tmp = [[obj allKeys]objectAtIndex:j]; //會議別
                            if ([meetingID isEqualToString:meetingID_tmp]) {
                                keepCompanyID = companyID;
                            }
                        }    
                    }
                }
                
            }];
        }
        //記錄會議別
        keepMeetID = meetingID;
        
       NSMutableDictionary *tmp =  [self.meetingDict objectForKey: meetingID]; //該會議之資料
        
       NSMutableDictionary *realDic = [[NSMutableDictionary alloc]init];
        
        [tmp enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if([key isEqualToString:@"subFolders"]){
                //抓各會期資料
                if (obj != [NSNull null]) {
                                        
                    for (int j = 0; j < [obj count]; j++) {
                        NSString *dateID = [[obj allKeys]objectAtIndex:j]; //會期
                        NSMutableDictionary *date_tmp =  [obj objectForKey: dateID];
                        [realDic setObject:date_tmp forKey:dateID]; 
                    }    
                }
            }
        }];
        
        self.dateDict = realDic;
        [realDic release];
        //預設按照order進行排序
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        self.gridDateKeys = [self sortedDicKeysByOrderWithDic:self.dateDict ascending:YES];
        [pool release];
        
        [self.dategridView reloadData];
        
        //回復表格未被選取前的狀態
        [self.meetinggridView deselectItemAtIndex: index animated: YES];

        
    }else if(inGridView.tag == GRIDVIEW_DATE){
        
        NSString *dateID = [self.gridDateKeys objectAtIndex:index]; //選取之會期
        
        NSString *meetName = [[self.meetingDict objectForKey:keepMeetID] objectForKey: @"CATEGORY_NAME"];
        
        //把會議名稱set到meetingButton
        [self.meetingButton setTitle:[NSString stringWithFormat:@"< < %@",meetName] forState:UIControlStateNormal];
        
        //記錄會期
        keepDateID = dateID;
        
        //把會議日期set到dateLabel
        NSMutableDictionary *tmp =  [self.dateDict objectForKey: dateID]; //該會期之資料
        self.dateLabel.text = [NSString stringWithFormat:@"会议日期 : %@ ",[tmp objectForKey: @"CATEGORY_NAME"]];
        
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
            
        //離線模式
        if ([AppDataSingleton shareData].cathayBooksOfflineModeEnabled) {
            
           [self getLocalDocsByDateID: dateID];
            
            //線上模式
        }else {
           [self getRemoteDocByDateID: dateID];
        }
        [pool release];
        
        //回復表格未被選取前的狀態
        [self.dategridView deselectItemAtIndex: index animated: YES];

    }else if(inGridView.tag == GRIDVIEW_DOC){
     
        DocumentCell *cell = (DocumentCell *)[inGridView cellForItemAtIndex:index];
        
        //a. 多選編輯模式
        if (editorModeEnable) {
            
            BOOL selection = cell.checkedImg.hidden;
            [self selectUnselectBookGridCell:cell index:index selection:selection showMessage:YES];
            
        //b. 單選
        }else{
            
            [self showBookFunctionPopUpWithSelectedIndex:index bookCell:cell];
        }
       
        
        //回復表格未被選取前的狀態
        [self.docgridView deselectItemAtIndex: index animated: YES];
        
    }    
    
    
}
#pragma mark -
#pragma mark 商品資料Plist 
/*
//取得Doc下plist Dict
-(NSMutableDictionary *) getDocumentsPlistDictUnderDoc {
    
    PlistHelper *helper = [[PlistHelper alloc]init];
    NSString *docPath = [CathayFileHelper getDocumentPath];
    NSMutableDictionary *plistDic = nil;
    
    if ([helper checkPlist:DOCUMENT_PLIST_NAME path:docPath]) {
        plistDic = [helper getPlistDictionaryWithPlistName:DOCUMENT_PLIST_NAME path:docPath];
    }
    [helper release];
    
    return plistDic;
}


//將DocumentsPlistDict寫入pList
-(void) writeDocumentsPlistDictToDoc:(NSMutableDictionary *) newDict {
    
    PlistHelper *helper = [[PlistHelper alloc]init];
    NSString *docPath = [CathayFileHelper getDocumentPath];
    
    if(![helper writeDic:newDict plistName:DOCUMENT_PLIST_NAME path:docPath]) {
#ifdef IS_DEBUG
        NSLog(@"DocumentsPlistDict寫入失敗");
#endif
    }
    
    [helper release];
}
*/

#pragma mark - Sorted related

//
//根據Dictionary中的"ORDER"欄位（數值）進行排序（由大到小）
//將排序後的key值傳回
//
//orderBy : NSOrderedDescending / NSOrderedAscending
//
-(NSArray *) sortedDicKeysByOrderWithDic:(NSDictionary *)dict ascending:(BOOL) ascending{
    
    NSArray *blockSortedKeys = [dict keysSortedByValueUsingComparator: ^(id obj1, id obj2) {
        
        NSDictionary *dic1 = (NSDictionary *)obj1;
        NSDictionary *dic2 = (NSDictionary *)obj2;
        
        int dic1value = [[dic1 objectForKey:@"ORDER"] integerValue];
        int dic2value = [[dic2 objectForKey:@"ORDER"] integerValue];
        
        if (dic1value < dic2value) {
            return (NSComparisonResult)ascending?NSOrderedDescending:NSOrderedAscending;
        }
        
        else if (dic1value > dic2value) {
            return (NSComparisonResult)ascending?NSOrderedAscending:NSOrderedDescending;
        }
        
        else {
            //return (NSComparisonResult)NSOrderedSame;
            return NSOrderedSame;
        }
    }];
    
    
    return blockSortedKeys;
}

//將文件資料排序
-(NSMutableArray *) sortedByOrderWithDocArray: (NSMutableArray *)docArray ascending:(BOOL) ascending{
    
    [docArray sortUsingComparator: 
     ^(id obj1, id obj2) 
     {
         NSInteger value1 = [[obj1 objectForKey: @"ORDER"] intValue];
         NSInteger value2 = [[obj2 objectForKey: @"ORDER"] intValue];
         if (value1 < value2) 
         {
             return (NSComparisonResult)ascending?NSOrderedDescending:NSOrderedAscending;
         }
         
         if (value1 > value2) 
         {
             return (NSComparisonResult)ascending?NSOrderedAscending:NSOrderedDescending;
         }
         //return (NSComparisonResult)NSOrderedSame;
         return NSOrderedSame;
     }];

    return docArray;
}

#pragma mark - cell功能

//點選書本時，跳出對應的按鈕視窗
- (void) showBookFunctionPopUpWithSelectedIndex:(NSUInteger) index  bookCell:(DocumentCell *)selctedCell {
    
    
    NSMutableDictionary * bookDic = [self.documentsArray objectAtIndex:index];
    NSString *bookID = [bookDic objectForKey:@"BOOK_ID"];
    GridStatus status = [[bookDic objectForKey:@"BookGridStatus"]intValue];
    //NSRange range = [bookID rangeOfString:@"_export"];    
    GridStatus gridStatus = [[bookDic objectForKey:@"BookGridStatus"]intValue];   

    UIActionSheet *action = nil;

    if (gridStatus == GridStatusInvalid)  {
        //已下架之檔案可以提供刪除
        action = [[UIActionSheet alloc] initWithTitle:nil
                                             delegate:self
                                    cancelButtonTitle:nil
                               destructiveButtonTitle:nil
                                    otherButtonTitles:OPEN_TEXT, DEL_TEXT, nil];

    }else if(status == GridStatusNormal) {
        //檔案未下載，點選後直接下載
        
        action = [[UIActionSheet alloc] initWithTitle:nil
                                             delegate:self
                                    cancelButtonTitle:nil
                               destructiveButtonTitle:nil
                                    otherButtonTitles:DOWN_TEXT, nil];
        
    }else {
        
        //如果為預設的文件則不給予刪除，直接開啟
      
        NSMutableDictionary *documentDic = [self.documentsArray objectAtIndex:index];
        
        NSString *pdfPath = [[[self getDocumentUserDirectoryPath]stringByAppendingPathComponent:PATH_PDF]stringByAppendingFormat:@"/%@.pdf",bookID];
        
        //檢查檔案是否存在
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:pdfPath];
        
        if (!fileExists) {
            #ifdef IS_DEBUG
            NSLog(@"無法開啟檔案，位置無此檔案：%@",pdfPath);
            #endif
            
            //離線模式
            if ([AppDataSingleton shareData].cathayBooksOfflineModeEnabled) {
                [self showMessage:@"文件不存在，无法打开。请到登录模式下重新下载。"];
                return;
            }else {
                [self showMessage:@"文件不存在，无法打开。自动重新下载。"];
                
                NSString *urlPath = [documentDic objectForKey:@"REMOTE_FILE_URL"];
                [self downloadFileWithUrlPath:urlPath savePath:pdfPath bookDic:documentDic];
                
                return;
            }    
           
        }
        
        NSString *phrase = nil; // Document password (for unlocking most encrypted PDF files)
        //init nextController
        ReaderDocument *document = [[ReaderDocument alloc] initWithFilePath:pdfPath password:phrase];
        document.title = [documentDic objectForKey:@"TITLE"];
        document.bookid = [documentDic objectForKey:@"BOOK_ID"];
        
        if (document != nil) // Must have a valid ReaderDocument object in order to proceed
        {
            ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];
            readerViewController.delegate = self; // Set the ReaderViewController delegate to self
            readerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
            readerViewController.noteid = keepDateID;
            readerViewController.noteTitle = [NSString stringWithFormat:@"%@_%@",[[self.meetingDict objectForKey:keepMeetID] objectForKey: @"CATEGORY_NAME"],[[self.dateDict objectForKey: keepDateID] objectForKey: @"CATEGORY_NAME"]];


            
            //若原存有筆跡資料，要把筆跡資料加回    
            NSString *dataPath = [[[[CathayFileHelper getDocumentPath]stringByAppendingPathComponent:[dao getUserID]]
                stringByAppendingPathComponent:@"PDF"]stringByAppendingPathComponent:document.bookid];
            
            BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:dataPath];
            if (fileExists) {
                NSData *data = [[NSData alloc]initWithContentsOfFile:dataPath];
                NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
                readerViewController.pageStrokeDict = [unarchiver decodeObjectForKey:@"pageStrokeDict"];
                
                [unarchiver finishDecoding];
                [unarchiver release];
                [data release];
            }
            
            //若原存有筆的使用資料，要設成最後使用狀態    
            NSString *pendataPath = [[[CathayFileHelper getDocumentPath]stringByAppendingPathComponent:@"mailTMP"]stringByAppendingPathComponent:@"pendata"];
            BOOL penfileExists = [[NSFileManager defaultManager] fileExistsAtPath:pendataPath];
            if (penfileExists) {
                NSData *data = [[NSData alloc]initWithContentsOfFile:pendataPath];
                NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
                readerViewController.penDic = [unarchiver decodeObjectForKey:@"pendata"];
                
                [unarchiver finishDecoding];
                [unarchiver release];
                [data release];
            }

            
            [self presentModalViewController:readerViewController animated:NO];
            [readerViewController release]; 
        } 
        
        [document release];                            
                                    
    }
                    
    //將selectedIndex放進Action供取出book資料
    action.tag = index;  
    
    //present the popover view non-modal with a
	//refrence to the button pressed within the current view
    CGRect popoverRect = [self.view convertRect:[selctedCell frame] 
                                       fromView:[selctedCell superview]];
    
    popoverRect.size.width = MIN(popoverRect.size.width, 200); 
    
    [action showFromRect:popoverRect inView:self.view animated:YES];
    [action release];
    
}

#pragma mark - 多選功能

//多選處理列 - 選取/取消選取 cell，並同步cache arrays
-(void) selectUnselectBookGridCell:(DocumentCell *)cell index:(NSUInteger) index selection:(BOOL)select showMessage:(BOOL) showMessage{
    
#ifdef IS_DEBUG
    NSLog(@"選取/取消選取 cell, select:%d", select);
#endif
    
    NSDictionary *bookDic = [documentsArray objectAtIndex:index];
    NSString *bookID = [bookDic objectForKey:@"BOOK_ID"];
   // NSString *fileExt = [bookDic objectForKey:@"FILE_EXT"];
    GridStatus gridStatus = [[bookDic objectForKey:@"BookGridStatus"]intValue];    
    
    //未下載不允許寄送
    if(gridStatus == GridStatusNormal) {
        
        if (showMessage) {
            [self showMessage:@"未下载的文件，不可多选寄送，请先下载文件。"];            
        }
        [self.docgridView deselectItemAtIndex: index animated: YES];
        return;
    }
    
    //檢查文件是否存在，若文件不存在則不給予多選寄送
    NSString *pdfPath = [[[self getDocumentUserDirectoryPath]stringByAppendingPathComponent:PATH_PDF]stringByAppendingFormat:@"/%@.pdf",bookID];
    
    //檢查檔案是否存在
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:pdfPath];
    if (!fileExists) {
        if (showMessage) {
            [self showMessage:@"该文件不存在，请离开多选寄送模式，再次点击该文件重新下载。"];            
        }
        [self.docgridView deselectItemAtIndex: index animated: YES];
        return;
    }
    
    
    NSNumber *indexNum = [NSNumber numberWithInt:index];
    if (select) {
        
        //將cell 勾選
        [cell checkCell];
        [cacheMailIndexs addObject:indexNum];
        
       // NSLog(@"cacheMailIndexs count:%d indexNum:%d", [cacheMailIndexs count], [indexNum intValue]);
        
    }else {
        
        [cell unCheckCell];
        if ([cacheMailIndexs containsObject:indexNum]) {
            [cacheMailIndexs removeObject:indexNum];
        }        
        
    }
    
}


#pragma mark - UIActionSheetDelegate

//文件按鈕事件處理 - 開啟、下載、更新、刪除、分享
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
   
    if (buttonIndex < 0) {
        return;
    }
    
    //Action點選何項功能
	NSString *selectedValue = [actionSheet buttonTitleAtIndex:buttonIndex];
    
#ifdef IS_DEBUG
    NSLog(@"click button:%d tag:%d title:%@", buttonIndex, actionSheet.tag, selectedValue);
#endif
    
    

    NSString *bookID = [[self.documentsArray objectAtIndex:actionSheet.tag]objectForKey:@"BOOK_ID"];

    NSMutableDictionary *documentDic = [self.documentsArray objectAtIndex:actionSheet.tag];
    
    //a. 開啟
    if ([selectedValue isEqualToString:OPEN_TEXT]) {
    
            
            NSString *pdfPath = [[[self getDocumentUserDirectoryPath]stringByAppendingPathComponent:PATH_PDF]stringByAppendingFormat:@"/%@.pdf",bookID];
            
            //檢查檔案是否存在
            BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:pdfPath];
            
            if (!fileExists) {
#ifdef IS_DEBUG
                NSLog(@"無法開啟檔案，位置無此檔案：%@",pdfPath);
#endif
                [self showMessage:@"文件不存在，无法打开"];
                return;
            }
            
            NSString *phrase = nil; // Document password (for unlocking most encrypted PDF files)
            //init nextController
            ReaderDocument *document = [[ReaderDocument alloc] initWithFilePath:pdfPath password:phrase];
            document.title = [documentDic objectForKey:@"TITLE"];
            document.bookid = [documentDic objectForKey:@"BOOK_ID"];

            if (document != nil) // Must have a valid ReaderDocument object in order to proceed
            {
                ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];
                readerViewController.delegate = self; // Set the ReaderViewController delegate to self
                readerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
                readerViewController.noteid = keepDateID;
                readerViewController.noteTitle = [NSString stringWithFormat:@"%@_%@",[[self.meetingDict objectForKey:keepMeetID] objectForKey: @"CATEGORY_NAME"],[[self.dateDict objectForKey: keepDateID] objectForKey: @"CATEGORY_NAME"]];


                
                //若原存有筆跡資料，要把筆跡資料加回                    
                NSString *dataPath = [[[[CathayFileHelper getDocumentPath]stringByAppendingPathComponent:[dao getUserID]]stringByAppendingPathComponent:@"PDF"]stringByAppendingPathComponent:document.bookid];
                BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:dataPath];
                if (fileExists) {
                    NSData *data = [[NSData alloc]initWithContentsOfFile:dataPath];
                    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
                    readerViewController.pageStrokeDict = [unarchiver decodeObjectForKey:@"pageStrokeDict"];
                    //NSLog(@"pageStrokeDict : %@",readerViewController.pageStrokeDict);
                    
                    [unarchiver finishDecoding];
                    [unarchiver release];
                    [data release];
                }
                
                //若原存有筆的使用資料，要設成最後使用狀態    
                NSString *pendataPath = [[[CathayFileHelper getDocumentPath]stringByAppendingPathComponent:@"mailTMP"]stringByAppendingPathComponent:@"pendata"];
                BOOL penfileExists = [[NSFileManager defaultManager] fileExistsAtPath:pendataPath];
                if (penfileExists) {
                    NSData *data = [[NSData alloc]initWithContentsOfFile:pendataPath];
                    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
                    readerViewController.penDic = [unarchiver decodeObjectForKey:@"pendata"];
                    
                    [unarchiver finishDecoding];
                    [unarchiver release];
                    [data release];
                }
                
                [self presentModalViewController:readerViewController animated:NO];
                [readerViewController release]; 
            }
        
            [document release];
        
        //b. 下載    
    }else if ([selectedValue isEqualToString:DOWN_TEXT]) {
        
        // documentDic 該文件
        
        NSString *savePath = [[[self getDocumentUserDirectoryPath]stringByAppendingPathComponent:PATH_PDF]stringByAppendingFormat:@"/%@.pdf",bookID];
        NSString *urlPath = [documentDic objectForKey:@"REMOTE_FILE_URL"];
        
        [self downloadFileWithUrlPath:urlPath savePath:savePath bookDic:documentDic];
    
        //c. 刪除
    }else if ([selectedValue isEqualToString:DEL_TEXT]) {
        
#ifdef IS_DEBUG
            NSLog(@"刪除書本：%@", bookID);
#endif        
    
         NSString *pdfPath = [[[self getDocumentUserDirectoryPath]stringByAppendingPathComponent:PATH_PDF]stringByAppendingFormat:@"/%@.pdf",bookID];
        
        
        //刪除本機資料
        BOOL delOK = [self deleteBookAndRelatedDataFromDB:documentDic];
        
        if (delOK) {
            
            [CathayFileHelper deleteItem:pdfPath];
                               
            //更新cell狀態
            [self.documentsArray removeObjectAtIndex:actionSheet.tag];
                                    
            [self.docgridView reloadData];
            
        }else {
            
#ifdef IS_DEBUG
            NSLog(@"刪除書本：%@ 本機db資料失敗", bookID);
#endif
            [self showMessage:@"删除失败"]; 
        }

    }
 
} 

#pragma mark - File Management

//取得使用者資料路徑
-(NSString *) getDocumentUserDirectoryPath {
        
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0]stringByAppendingPathComponent:[dao getUserID]];

}

//檢查並建立使用者資料儲存資料夾
// ex: document/[USER ID]/PDF
-(void) checkAndCreateUserSubDirectory {
    
    NSFileManager *filemgr =[NSFileManager defaultManager];
    
    //新資料夾
    NSString *userDir = [self getDocumentUserDirectoryPath];
    
    //建立pdf資料夾
    NSString *newDir  = [userDir stringByAppendingPathComponent:PATH_PDF];
#ifdef IS_DEBUG
    NSLog(@"建立pdf資料夾:%@",newDir);
#endif
    
    NSError *error;
    if (![filemgr fileExistsAtPath:newDir])	//Does directory already exist?
	{
		if (![filemgr createDirectoryAtPath:newDir
                withIntermediateDirectories:YES
                                 attributes:nil
                                      error:&error])
		{
			NSLog(@"Create directory(%@) error: %@", newDir, error);
		}
	}    
    
    
}


#pragma mark - Warn Message related

-(void)showMessage:(NSString *)message {
    
    HUD = [[MBProgressHUD alloc]initWithView:self.view.window];
    [self.view.window addSubview:HUD];
    HUD.tag = HUD_OTHER_TAG;
    HUD.delegate = self;
    HUD.dimBackground = YES;
    UIView *emptyView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 2, 2)];
    HUD.customView = emptyView;
    [emptyView release];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = message;
    [HUD show:YES];
    
    [HUD hide:YES afterDelay:2.0];

}

#pragma mark ReaderViewControllerDelegate methods

- (void)dismissReaderViewController:(ReaderViewController *)viewController {   

    [self dismissModalViewControllerAnimated:YES];
    
    if ([self.documentsArray count] == 1) {
        [self showMenuView];
    }
}

#pragma mark - IBAction

//登出
- (IBAction)logout
{
#ifdef IS_DEBUG
    NSLog(@"使用者點選登出 .....");	
#endif
    
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.logInOutAgent.isTimeOut = NO;
    appDelegate.logInOutAgent.viewController = self;
    [appDelegate.logInOutAgent logout];
    
    //把原本的資料都清掉
    self.menuDataDic = nil;
    self.meetingDict = nil;
    self.dateDict = nil;
    self.documentsArray = nil;
    self.gridMeetingKeys = nil;
    self.gridDateKeys = nil;
    
    [self.meetinggridView reloadData];
    [self.dategridView reloadData];
    [self.docgridView reloadData];
    
}

- (IBAction) showMenuView{
#ifdef IS_DEBUG
    NSLog(@"回到選單頁 .....");	
#endif
    
    if (editorModeEnable==YES) {
        editorModeEnable = NO;
        [cacheMailIndexs removeAllObjects];
       [self.mutiSelectButton setTitle:@"多选寄送" forState:UIControlStateNormal];        
    }
       
    self.mutiSelectButton.hidden = YES;
    self.meetingButton.hidden = YES;
    self.dateLabel.hidden =YES;
    
    //把contentView滑回來
    
    UIImage * headerImg = [UIImage imageNamed: @"header768.png"];
    UIImage * bottomImg = [UIImage imageNamed: @"bottom768.png"];
    
    [UIView animateWithDuration:1.0 animations:^{
        
        UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
            //橫
            self.contentView.frame = CGRectMake(0, self.headerImgView.frame.size.height+25, 1024 ,768-headerImg.size.height-bottomImg.size.height+25);
            self.meetinggridView.frame = CGRectMake(0, 0,self.contentView.frame.size.width,250);
            self.dategridView.frame = CGRectMake(0, 270, self.contentView.frame.size.width, self.contentView.frame.size.height-250+25);
            self.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed: @"contentview_l.png"]];
            
        } else {
            self.contentView.frame = CGRectMake(0, self.headerImgView.frame.size.height+25, self.view.frame.size.width,self.view.frame.size.height-headerImg.size.height-bottomImg.size.height+35);
            self.meetinggridView.frame =CGRectMake(0, 0, self.contentView.frame.size.width, 250);
            self.dategridView.frame = CGRectMake(0, 300, self.contentView.frame.size.width,  self.contentView.frame.size.height-250+35);
            self.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed: @"contentview_p.png"]];
        }
        
    }];

    
 //   self.contentView.hidden = NO;
    [self.documentsArray removeAllObjects];
    [self.docgridView reloadData];
    
}

//多選寄送 
- (IBAction)selectDoc:(id)sender {
    
    if ([MFMailComposeViewController canSendMail] == NO){
        [self showMessage:@"您还没有开启邮件设定，请到设置中设定"];
        return;
    }
    
    if ([self.mutiSelectButton.titleLabel.text isEqualToString: @"多选寄送"]) {
        
        [self.mutiSelectButton setTitle:@"完成" forState:UIControlStateNormal];
        editorModeEnable = YES;   
        [self showMessage:@"多选模式，请选取要寄送的文件，完成后点击完成开始发送"];
        
        
    }else{
        
        [self.mutiSelectButton setTitle:@"多选寄送" forState:UIControlStateNormal];
         editorModeEnable = NO;
        
        if ([cacheMailIndexs count] != 0) {
            [self sendMultiEmail];
        }
        
        for (int i = 0; i < [self.documentsArray count]; i++) {
            DocumentCell *cell = (DocumentCell *)[self.docgridView cellForItemAtIndex:i];
            BOOL selection = cell.checkedImg.hidden;
            
            if (!selection) {                
                [self selectUnselectBookGridCell:cell index:i selection:selection showMessage:NO];
            }
            
        }
    }
        
}

- (IBAction) refreshRemoteData:(id)sender{
        
    //重新load遠端資料  先把舊資料都清掉
    self.menuDataDic = nil;
    self.meetingDict = nil;
    self.dateDict = nil;
    self.documentsArray = nil;
    self.gridMeetingKeys = nil;
    self.gridDateKeys = nil;
    
    [self.meetinggridView reloadData];
    [self.dategridView reloadData];
    [self.docgridView reloadData];
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [self getRemoteMenuData];
    [pool release];

}

#pragma mark - Load/Alert View related

-(void) showLoadViewWithText:(NSString *) text{
    
    [activityIndicator startAnimating];
    loadingLabel.text = text;
    loadingView.hidden = NO;
    [self.view bringSubviewToFront:loadingView];
    
}

-(void) showAlertViewWithText:(NSString *) text{
    
    [activityIndicator stopAnimating];
    loadingLabel.text = text;
    loadingView.hidden = NO;
    [self.view bringSubviewToFront:loadingView];
    
}

-(void) hideLoadView {
    
    [activityIndicator stopAnimating];
    loadingView.hidden = YES;
}

//******

#pragma mark - Remote Data related

//取得雲端Menu清單
-(void) getRemoteMenuData {
    NSLog(@"getRemoteMenuData");
        
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
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:meetingUrl]];
    
    //[request setPostValue:@"IOS" forKey:@"OSTYPE"];
    
    [request setValidatesSecureCertificate:NO]; //取消HTTPS授權檢查
    
    NSLog(@"requestURL-->%@", [request url]);
    
    //正常執行成功
    [request setCompletionBlock:^{
        NSLog(@"Complete....");
        
        [self hideLoadView];
        
        //BIG5
        //EncodingHelper* encodeHelper = [EncodingHelper new];
        //NSData *cleanData = [encodeHelper cleanBIG5:[request responseData]];
        //[encodeHelper release];
        NSData *cleanData = [request responseData];
        
        //NSString *str = [[NSString alloc] initWithData:cleanData encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5)];
        NSString *str = [[NSString alloc] initWithData:cleanData encoding:NSUTF8StringEncoding];
        
        NSLog(@"getRemoteMenuData html is:%@", str);
        
        //去除空白
        NSString *trimmedString = [str stringByTrimmingCharactersInSet:
                                   [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        //[cleanData release];
        [str release];
        
        NSLog(@"getRemoteMenuData html is:%@",trimmedString);
        
        if (trimmedString || [trimmedString length]>0) {
            
            //檢查回傳資料是否為登入頁面
            BOOL match = ([trimmedString rangeOfString:@"$MobiAppLoginFlag" options:NSCaseInsensitiveSearch].location != NSNotFound);
            
            //if loading page is logging page show app login view
            if (match) {
                
                NSLog(@"判斷為Session Time Out，重新導至登入頁面！");
                
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [appDelegate.logInOutAgent checkTimoutAndJumpLoginViewWithFlag:@"b2e" superController:self]; 
                return;
            }
        }
        
        NSMutableDictionary *jsonDic = [trimmedString JSONValue];
        
        NSLog(@"count is %d",[jsonDic count]);
        
        self.menuDataDic = jsonDic;
        
        //檢核
        if (!menuDataDic || [menuDataDic count]==0) {
            NSLog(@"無選單資料，無法產生選單....");
            
            [self showAlertViewWithText:ERROR_MSG_DATA_NOT_FOUND];
            
        }else {
            
            NSLog(@"menuDataDic : %@",self.menuDataDic);
            
            [self syncWithRemoteData];
            [self parseMenuDictToGenMeetingDic];
        }
        
        NSLog(@"---------调用getRemoteData---------");
    }];
    
    //執行失敗
    [request setFailedBlock:^{
        //loading hide
        [self hideLoadView];
        
        NSError *error = [request error];
        NSLog(@"Connection Failed - %@, DOMAIN - %@, CODE - %d", [error localizedDescription] ,error.domain, error.code);
        
        if ([[error domain] isEqualToString:@"ASIHTTPRequestErrorDomain"]) {
            
            [self showAlertViewWithText:ERROR_MSG_NET];
            
        }else{
            
            [self showAlertViewWithText:ERROR_MSG_DEFAULT];
        }
    }];
    [request startAsynchronous]; 
    
    [self showLoadViewWithText:MSG_LOADING];
    
}


//parse  menu資料產生會議及會期選單
-(void) parseMenuDictToGenMeetingDic {
        
    NSMutableDictionary *realDic = [[NSMutableDictionary alloc]init];
    
    for (int i = 0; i < [menuDataDic count]; i++) {
        
        NSString *companyID = [[self.menuDataDic allKeys]objectAtIndex:i]; //公司別

        // NSLog(@"公司別 companyID : %@ ",companyID);
        NSMutableDictionary *tmp =  [self.menuDataDic objectForKey: companyID];
        
        [tmp enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            
            if([key isEqualToString:@"subFolders"]){
                
                //抓各會議類別資料
                if (obj != NULL) {
                    for (int j = 0; j < [obj count]; j++) {
                        NSString *meetingID = [[obj allKeys]objectAtIndex:j]; //會議別
                        NSMutableDictionary *meet_tmp =  [obj objectForKey: meetingID];
                        
                        [realDic setObject:meet_tmp forKey:meetingID]; 
                    }    
                }
            }
        }];
    }
    
    NSLog(@"realDic:%@", realDic);
    
    self.meetingDict = realDic;
    [realDic release];
    
    //預設按照order進行排序
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    self.gridMeetingKeys = [self sortedDicKeysByOrderWithDic:self.meetingDict ascending:YES];
    [pool release];
     
    [self.meetinggridView reloadData];
 }

//取得會議文件
-(void) getRemoteDocByDateID:(NSString *) dateID {
    NSLog(@"getRemoteDocMenuData");
    
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
    NSString *postBody = [NSString stringWithFormat:@"CATEGORY_ID=%@", dateID];
    NSLog(@"postBody=%@", postBody);
    NSString *combinedURL = [cloudBooksURL stringByAppendingString:postBody];
    //[postBody release];
    
    NSLog(@"combinedURL=%@", combinedURL);
    NSURL *url = [NSURL URLWithString:combinedURL];
    //[combinedURL release];
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [ASIHTTPRequest setSessionCookies:nil];
    //[request setRequestMethod:@"POST"];
    
    //[request setPostValue:@"IOS" forKey:@"OSTYPE"];
    //[request setPostValue:dateID forKey:@"CATEGORY_ID"]; //傳送會期資料回後端以撈取文件

    [request setValidatesSecureCertificate:NO]; //取消HTTPS授權檢查
        
    HUD = [[MBProgressHUD alloc]initWithView:self.view.window];
    [self.view.window addSubview:HUD];
    HUD.tag = HUD_LOADING_TAG;
    HUD.delegate = self;
    HUD.dimBackground = YES;
    HUD.labelText = @"资料载入中";
    [HUD show:YES];
    
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        //BIG5
        //EncodingHelper* encodeHelper = [EncodingHelper new];
        //NSData *cleanData = [encodeHelper cleanBIG5:[request responseData]];
        //[encodeHelper release];
        NSData *cleanData = [request responseData];
        
        //NSString *str = [[NSString alloc] initWithData:cleanData encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5)];
        NSString *str = [[NSString alloc] initWithData:cleanData encoding:(NSUTF8StringEncoding)];
        
        NSLog(@"str=%@",str);
        
        //去除空白
        NSString *trimmedString = [str stringByTrimmingCharactersInSet:
                                   [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [str release];
        
        NSLog(@"html is:%@",trimmedString);
        
        if (trimmedString || [trimmedString length]>0) {
            
            //檢查回傳資料是否為登入頁面
            BOOL match = ([trimmedString rangeOfString:@"$MobiAppLoginFlag" options:NSCaseInsensitiveSearch].location != NSNotFound);
            
            //if loading page is logging page show app login view
            if (match) {
                
                NSLog(@"判斷為Session Time Out，重新導至登入頁面！");
                
                //session time out 隱藏loading頁
                [HUD hide:YES];
                
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [appDelegate.logInOutAgent checkTimoutAndJumpLoginViewWithFlag:@"b2e" superController:self]; 
                return;
            }
        }
        
        NSMutableArray *jsonArray = [trimmedString JSONValue];
        
        NSLog(@"count is %d",[jsonArray count]);
        NSLog(@"jsonArray %@",jsonArray);
                
        //檢核
        if (!jsonArray || [jsonArray count]==0) {
            
            self.documentsArray = [self parseCloudData:nil withCategory:dateID];  //作已下架比對
                       
            //若本機端已無資料
            if(!self.documentsArray || [self.documentsArray count]==0) {
                [self showMessage:ERROR_MSG_DATA_NOT_FOUND];
            }
        } else {
            self.documentsArray = [self parseCloudData:jsonArray withCategory:dateID];  //作已下架比對
        }
                
        //文件排序
        self.documentsArray = [self sortedByOrderWithDocArray:self.documentsArray ascending:YES];
          
        if([self.documentsArray count] != 0 ){
            for (int i = 0; i < [self.documentsArray count]; i++) {
                
                NSMutableDictionary * tmp = [self.documentsArray objectAtIndex:i];
                NSNumber *indexNum = [NSNumber numberWithInt:i];
                
                if ([[tmp objectForKey:@"BookGridStatus"]intValue] == 0) {
                    //未下載件，丟到應下載cache中
                    [cacheSelectedIndexs addObject:indexNum];
                }else if([[tmp objectForKey:@"BookGridStatus"]intValue] == 1){
                    //更新件，丟進下載及更新cache
                    [cacheSelectedIndexs addObject:indexNum];
                    [cacheUpdateIndexs addObject:indexNum];
                }
            }
        }

        if([cacheSelectedIndexs count] == 0){
            NSLog(@"無資料需下載");
            [self.docgridView reloadData];
            
            if ([self.documentsArray count] == 1) {
                
                //僅有一個檔案時自動開啟
                NSMutableDictionary *dic = [self.documentsArray objectAtIndex:0];
                
                NSString *bookID = [dic objectForKey:@"BOOK_ID"];        
                
                NSString *pdfPath = [[[self getDocumentUserDirectoryPath]stringByAppendingPathComponent:PATH_PDF]stringByAppendingFormat:@"/%@.pdf",bookID];
                
                //檢查檔案是否存在
                BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:pdfPath];
                
                if (fileExists) {
                    [self autoOpenOnlyDoc:dic];
                }       
            }
            
        } else {
             [self downloadAllDoc]; 
        }
            
        //畫面處理
        self.dateLabel.hidden = NO;
        
        [UIView animateWithDuration:1.0 animations:^{
            
            UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
            if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
                //橫
                self.contentView.frame = CGRectMake(0, -768, 1024 ,537);
                
            } else {
                self.contentView.frame = CGRectMake(0, -1004, 1024 ,783);
            }
            
        }completion:^(BOOL finished){
            self.meetingButton.hidden = NO;
        }];
        
     //   self.contentView.hidden = YES;
     //   self.meetingButton.hidden = NO;
        
        [HUD hide:YES afterDelay:0.5];
        
    }];
    
    [request setFailedBlock:^{
        
        [HUD hide:YES];
        
        NSError *error = [request error];
        NSLog(@"Connection Failed - %@, DOMAIN - %@, CODE - %d", [error localizedDescription] ,error.domain, error.code);
        
        if ([[error domain] isEqualToString:@"ASIHTTPRequestErrorDomain"]) {
            
            [self showMessage:ERROR_MSG_NET];
            
            
        }else{
            
            [self showMessage:ERROR_MSG_DEFAULT];
        }
        
        self.documentsArray = nil;
        [self.docgridView reloadData];
        
    }];
    
    [request startAsynchronous];
}

/*
//parse  menu資料產生會議及會期選單
-(void) parsedDocMenuDictToGenDocDic {
    
    NSMutableDictionary *realDic = [[NSMutableDictionary alloc]init];
    
    for (int i = 0; i < [menuDataDic count]; i++) {
        
        NSString *companyID = [[self.menuDataDic allKeys]objectAtIndex:i]; //公司別
        
        //    NSLog(@"公司別 companyID : %@ ",companyID);
        
        NSMutableDictionary *tmp =  [self.menuDataDic objectForKey: companyID];
        
        [tmp enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            
            if([key isEqualToString:@"subFolders"]){
                
                //抓各會議類別資料
                if (obj != NULL) {
                    for (int j = 0; j < [obj count]; j++) {
                        NSString *meetingID = [[obj allKeys]objectAtIndex:j]; //會議別
                        NSMutableDictionary *meet_tmp =  [obj objectForKey: meetingID];
                        
                        [realDic setObject:meet_tmp forKey:meetingID]; 
                    }    
                }
                
                //抓各會議下面的會期資料  
                /*  
                 [meet_tmp enumerateKeysAndObjectsUsingBlock:^(id key2, id obj2, BOOL *stop2) {
                 if([key2 isEqualToString:@"subFolders"]){
                 [realDic setObject:obj2 forKey:meetingID]; 
                 }   
                 }];
                 }
                 
            }
            
        }];
    }
    
    self.meetingDict = realDic;
    [realDic release];
    
    //預設按照order進行排序
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    self.gridMeetingKeys = [self sortedDicKeysByOrderWithDic:self.meetingDict ascending:YES];
    [pool release];
    
    [self.meetinggridView reloadData];
    
}*/

#pragma mark - Local Data related

//取得本地端Menu清單
-(void) getLocalMenuData {
    
    [self showLoadViewWithText:MSG_LOADING];
    
    NSMutableDictionary *companiesDic = [dao queryAllCompanies];  //公司清單
    
    for (NSString *cpyCode in [companiesDic allKeys]) {
        
        NSMutableDictionary *categoriesL1Dic = [dao queryCategoriesOfLevelOneByCpyCode:cpyCode];  //取得該公司別第一層類別
        NSMutableDictionary *cpyDic = [companiesDic valueForKey:cpyCode];
        [cpyDic setValue:categoriesL1Dic forKey:@"subFolders"];
        
        for (NSString *categoryID in [categoriesL1Dic allKeys]) {
            
            NSMutableDictionary *ctL1Dic = [categoriesL1Dic valueForKey:categoryID];
            NSString *type = [ctL1Dic valueForKey:@"TYPE"];
            
            //如果此類別不是資料夾屬性，則略過此筆
            if (![type isEqualToString:@"F"]) {
                continue;
            }
            
            //取得該公司別及類別下的第二層類別資料
            NSMutableDictionary *categoriesL2Dic = [dao queryCategoriesOfLevelTwoByCpyCode:cpyCode upperCategoryID:categoryID];
            [ctL1Dic setValue:categoriesL2Dic forKey:@"subFolders"];    //放入資料
        }
    }
    
    self.menuDataDic = companiesDic;
    [self parseMenuDictToGenMeetingDic];
    
    [self hideLoadView];
}

-(void) getLocalDocsByDateID:(NSString *) dateID {
    
    NSLog(@"getLocalDocsByDateID");
    
    NSMutableArray *localBooksArray = [dao queryBooksArrayByCategoryId:dateID];
    
    //檢核
    if (!localBooksArray || [localBooksArray count]==0) {
        
        self.documentsArray = nil;
        [self.docgridView reloadData];
        [self showMessage:ERROR_MSG_DATA_NOT_FOUND];
        
    }else {
        
        self.documentsArray = localBooksArray;
        //文件排序
        self.documentsArray = [self sortedByOrderWithDocArray:self.documentsArray ascending:YES];
        
        [self.docgridView reloadData];
        
        if ([self.documentsArray count] == 1) {
            
            //僅有一個檔案時自動開啟
            NSMutableDictionary *dic = [self.documentsArray objectAtIndex:0];
            
            NSString *bookID = [dic objectForKey:@"BOOK_ID"];        
            
            NSString *pdfPath = [[[self getDocumentUserDirectoryPath]stringByAppendingPathComponent:PATH_PDF]stringByAppendingFormat:@"/%@.pdf",bookID];
            
            //檢查檔案是否存在
            BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:pdfPath];
            
            if (fileExists) {
                [self autoOpenOnlyDoc:dic];
            }       
        }
    }
    
    //畫面處理
    
    self.dateLabel.hidden = NO;
    
    [UIView animateWithDuration:1.0 animations:^{
        
        UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
            //橫
            self.contentView.frame = CGRectMake(0, -768, 1024 ,537);
            
        } else {
            self.contentView.frame = CGRectMake(0, -1004, 1024 ,783);
        }
    }completion:^(BOOL finished){
        self.meetingButton.hidden = NO;
    }];

   // self.contentView.hidden = YES;
   // self.meetingButton.hidden = NO;
}


#pragma mark -
#pragma mark Sync related

//取得書本同步資料，並更新本地端資訊
-(void) syncBooks {
    
    //測試目前網路是否有通
	//BOOL isConnected = [UIDevice networkConnected];
	NetDetectHelper *netDetecter = [[NetDetectHelper alloc]init];
	BOOL isConnected = [netDetecter connectedToNetwork];
	[netDetecter release];
	
    NSLog(@"networkStatus is %@", (isConnected? @"YES" : @"NO"));
    
	if(!isConnected){
		return;
	}
    
    NSURL *url = [NSURL URLWithString:aliveBooksUrl];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    //[request setRequestMethod:@"POST"];
    // [request setPostValue:@"IOS" forKey:@"OSTYPE"];
    
    [request setValidatesSecureCertificate:NO]; //取消HTTPS授權檢查
    
    //MBProgressHUD *HUD2 = [[MBProgressHUD showHUDAddedTo:self.view animated:YES] retain];
    //HUD2.tag = HUD_SYNC_TAG;
    //HUD2.delegate = self;
    //HUD2.dimBackground = YES;
    //HUD2.labelText = @"資料同步中";
    
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        //BIG5
        //EncodingHelper* encodeHelper = [EncodingHelper new];
        //NSData *cleanData = [encodeHelper cleanBIG5:[request responseData]];
        //[encodeHelper release];
        NSData *cleanData = [request responseData];
        
        //NSString *str = [[NSString alloc] initWithData:cleanData encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5)];
        NSString *str = [[NSString alloc] initWithData:cleanData encoding:(NSUTF8StringEncoding)];
        str = @"";
        NSLog(@"str=%@", str);
        
        //去除空白
        NSString *trimmedString = [str stringByTrimmingCharactersInSet:
                                   [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [str release];
        
        NSLog(@"syncBooks html is:%@",trimmedString);
        
        if (trimmedString || [trimmedString length]>0) {
            
            //檢查回傳資料是否為登入頁面
            BOOL match = ([trimmedString rangeOfString:@"$MobiAppLoginFlag" options:NSCaseInsensitiveSearch].location != NSNotFound);
            
            //if loading page is logging page show app login view
            if (match) {
                
                NSLog(@"判斷為Session Time Out，重新導至登入頁面！");
                
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [appDelegate.logInOutAgent checkTimoutAndJumpLoginViewWithFlag:@"b2e" superController:self]; 
                return;
            }
        }
        
        NSMutableDictionary *jsonDic = [trimmedString JSONValue];
        
        NSLog(@"count is %d",[jsonDic count]);
        
        //檢核
        if (!jsonDic || [jsonDic count]==0) {
            NSLog(@"錯誤！書本同步資料為空。");
        } else {
            
            //取得本地端所有書籍ID
            NSMutableArray *localBookIDArray = [dao queryAllBookIDs];
            for (NSString *bookID in localBookIDArray) {
                
                NSMutableDictionary *cloudBookDic = [jsonDic objectForKey:bookID];
                
                //雲端有此書籍，強迫更新（包含重新上架）
                if (cloudBookDic && [cloudBookDic count]!=0) {
                    
                    NSString *title = [cloudBookDic valueForKey:@"TITLE"];
                    NSNumber *order = [cloudBookDic valueForKey:@"ORDER"];
                    NSString *forceDelete = [cloudBookDic valueForKey:@"FORCEDELETE"];
                    NSString *sharable = [cloudBookDic valueForKey:@"SHARABLE"];
                    [dao updateBookByBookID:bookID WithTitle:title Order:order Status:RemoteStatusInUse ForceDelete:forceDelete Sharable:sharable];
                    
                    //雲端無此書籍
                } else {
                    //TODO 取得本地端書本是否強制刪除，若需要刪除，便將bookID放到
                    
                    //下架
                    [dao updateBookStatus:RemoteStatusDeprecated ByBookID:bookID];
                }
            }
            
        }
        //HUD2.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] autorelease];
       // HUD2.mode = MBProgressHUDModeCustomView;
       // HUD2.labelText = @"同步完成";        
       // [HUD2 hide:YES afterDelay:2];
        //[self performSelector:@selector(hideDelayed:) withObject:[NSNumber numberWithBool:delay] afterDelay:delay];
    }];
    
    [request setFailedBlock:^{
        NSError *error = [request error];
        NSLog(@"取得書本同步資料 Connection Failed - %@, DOMAIN - %@, CODE - %d", [error localizedDescription] ,error.domain, error.code);
      //  [HUD2 hide:YES afterDelay:2];
    }];
    
    [request startAsynchronous];
}


//同步雲端及本地端公司別、類別資料
//
// 原則-以local資料為主，強迫update local資料
-(void) syncWithRemoteData {
    
    //TODO
    //讓他app啟動進來只跑一次
    //先從本地端取出所有公司、類別，再去跟雲端比
    
    //I. 比對公司別
    NSMutableDictionary *localCompaniesDic = [dao queryAllCompanies];  //公司清單
    
    for (NSString *cpyCode in [localCompaniesDic allKeys]) {
        NSArray *remoteCpyCodeArray =[self.menuDataDic allKeys];
        BOOL isExist = [remoteCpyCodeArray containsObject:cpyCode];
        
        //NSMutableDictionary *localCpyDic = [localCompaniesDic valueForKey:cpyCode];
        NSMutableDictionary *remoteCpyDic = [self.menuDataDic valueForKey:cpyCode];            
        
        
        //Local有雲端也有
        if (isExist) {
            
            //判斷是否有更新
            //NSNumber *localUptTime = [localCpyDic objectForKey:@"UPDATE_TIME"];
            //NSNumber *cloudUptTime = [remoteCpyDic objectForKey:@"UPDATE_TIME"];
            //BOOL hasUpdate = ([cloudUptTime compare:localUptTime] == NSOrderedDescending);
            
            //if (hasUpdate) {
            NSLog(@"子公司別：%@存在，強迫進行資料更新...", cpyCode);
            
            [dao updateCompanyWithDic:remoteCpyDic];
            //}
        }
        
        //II. 比對第一層類別
        NSMutableDictionary *remoteL1Categories = [remoteCpyDic objectForKey:@"subFolders"];
        NSMutableDictionary *localL1Categories = [dao queryCategoriesOfLevelOneByCpyCode:cpyCode];
        
        //第一層
        for (NSString *categoryID in [localL1Categories allKeys]) {
            
            NSArray *remoteCategoryIDArray =[remoteL1Categories allKeys];
            BOOL isExist = [remoteCategoryIDArray containsObject:categoryID];
            
            if (isExist) {
                NSLog(@"第一層 categoryID:%@ 存在，強迫更新", categoryID);
                
                NSMutableDictionary *remoteSubDict =[remoteL1Categories objectForKey:categoryID];
                [remoteSubDict setValue:cpyCode forKey:@"CPY_CODE"];
                [remoteSubDict setValue:categoryID forKey:@"CATEGORY_ID"];
                [remoteSubDict setValue:@"" forKey:@"UPPER_CATEGORY"];
                [dao updateCategoryWithDic:remoteSubDict];
                
                
                NSMutableDictionary *ctL1Dic = [localL1Categories valueForKey:categoryID];
                NSString *type = [ctL1Dic valueForKey:@"TYPE"];
                
                if([type isEqualToString:@"F"]) {
                    
                    //III. 比對第二層類別
                    NSMutableDictionary *remoteL2Categories = [remoteSubDict objectForKey:@"subFolders"];
                    NSMutableDictionary *categoriesL2Dic = [dao queryCategoriesOfLevelTwoByCpyCode:cpyCode upperCategoryID:categoryID];
                    
                    //第二層
                    for (NSString *categoryIDL2 in [categoriesL2Dic allKeys]) {
                        
                        NSArray *remoteCategoryIDL2Array =[remoteL2Categories allKeys];
                        BOOL isExist = [remoteCategoryIDL2Array containsObject:categoryIDL2];
                        
                        if (isExist) {
                            NSLog(@"第二層 categoryID:%@ 存在，強迫更新", categoryIDL2);
                            
                            NSMutableDictionary *remoteSubDict =[remoteL2Categories objectForKey:categoryIDL2];
                            [remoteSubDict setValue:cpyCode forKey:@"CPY_CODE"];
                            [remoteSubDict setValue:categoryIDL2 forKey:@"CATEGORY_ID"];
                            [remoteSubDict setValue:categoryID forKey:@"UPPER_CATEGORY"];
                            [dao updateCategoryWithDic:remoteSubDict];
                            
                        }
                    }//end of 第二層
                }
            }
        }//end of 第一層
    }//end of 公司別
    
}


//將雲端傳入的資料與本機端資料做比對，進行書本狀態的設定與更新
-(NSMutableArray *) parseCloudData:(NSMutableArray *) cloudBooksArray withCategory:(NSString *) categoryID{
    NSLog(@"cloudBooksArray.count is %d", cloudBooksArray.count);
    
    NSMutableDictionary *localCtBooksDic = [dao queryBooksDicByCategoryId:categoryID]; //依類別取得本地端書籍
    
    NSMutableSet *deprecatedBookIDs = [NSMutableSet setWithArray:[localCtBooksDic allKeys]]; //用於更新本地端下架（若雲端有便惕除，剩下的即是已下架的本地端書籍）
    NSMutableSet *recoverInUseBookIDs = [NSMutableSet setWithCapacity:5]; //存放回復成已上架狀態的本地端書籍清單
    
    //比對本機端是否已存有此筆資料，或是否已更新
    for (NSMutableDictionary *cloudBookDic in cloudBooksArray) {
        
        NSString *bookID = [cloudBookDic objectForKey:@"BOOK_ID"];
        NSMutableDictionary *localBookDic = [localCtBooksDic objectForKey:bookID];
        
        NSString *fileEXT = [cloudBookDic objectForKey:@"FILE_EXT"]; //取得附檔類型
        
        //a. 雲端有，本機也有
        if (localBookDic!=nil) {
            NSLog(@"本機端已有此BookID:%@ 的資料", bookID);
            
            //雲端有惕除，剩下的即是已下架的
            [deprecatedBookIDs removeObject:bookID];
            
            //若書本已重新上架，放入Set中
            RemoteStatus status = [[localBookDic objectForKey:@"STATUS"] intValue]; //取得本地書本狀態
            if (status == RemoteStatusDeprecated) {
                [recoverInUseBookIDs addObject:bookID];
            }
            
            
            //判斷是否有更新
            NSNumber *localUptTime = [localBookDic objectForKey:@"UPDATE_TIME"];
            NSNumber *cloudUptTime = [cloudBookDic objectForKey:@"UPDATE_TIME"];
            BOOL hasUpdate = ([cloudUptTime compare:localUptTime] == NSOrderedDescending);
            NSLog(@"判斷書本狀態是否有更新 localUptTime:%@, cloudUptTime:%@", localUptTime, cloudUptTime);
            
            if ([fileEXT isEqualToString:FILE_EXT_PDF]) {
                
                if (hasUpdate) {
                    [cloudBookDic setObject:[NSNumber numberWithInt:GridStatusHasNewUpdate] forKey:@"BookGridStatus"];
                } else {
                    [cloudBookDic setObject:[NSNumber numberWithInt:GridStatusAlreadyDowloaded] forKey:@"BookGridStatus"];
                }
                
            } else {
                
                [self showMessage:@"这个程序不能打开这种类型的文件"];
            }    
            
            //b. 雲端有，本機沒有 
        } else {
            
            //若為pdf格式
            if ([fileEXT isEqualToString:FILE_EXT_PDF]) {
                //設上正常標籤
                [cloudBookDic setObject:[NSNumber numberWithInt:GridStatusNormal] forKey:@"BookGridStatus"];
                
            } else {
                
                [self showMessage:@"这个程序不能打开这个格式的文件"];
            }    
        }
    }
    
    //c.雲端沒有，本地有 (已下架書籍處理，將本機標成已下架)
    for (NSString *bookID in  deprecatedBookIDs) {
        
        NSLog(@"發現已下架bookID:%@", bookID);
        
        //更新本地端下架資訊
        [dao updateBookStatus:RemoteStatusDeprecated ByBookID:bookID];
        
        //放入雲端清單中，這樣才會在雲端書架中顯示
        NSMutableDictionary *localDpBookDic = [localCtBooksDic objectForKey:bookID];
        [localDpBookDic setObject:[NSNumber numberWithInt:GridStatusInvalid] forKey:@"BookGridStatus"];         //標記成已下架
        if (!cloudBooksArray) {
            cloudBooksArray = [NSMutableArray arrayWithCapacity:[deprecatedBookIDs count]];
        }
        [cloudBooksArray addObject:localDpBookDic];
    }
    
    //若雲端又將書本重新放上
    //本地端書本重新上架
    [dao updateBookStatus:RemoteStatusInUse withBookIDs:recoverInUseBookIDs];
    
    //結果
    NSLog(@"印出parse完的結果");
    for (NSMutableDictionary *cloudBookDic in cloudBooksArray) {
        NSString *bookID = [cloudBookDic objectForKey:@"BOOK_ID"];
        NSNumber *order = [cloudBookDic objectForKey:@"ORDER"];
        NSLog(@"bookID:%@, order:%d", bookID, [order intValue]);
    }
    
    return cloudBooksArray;
}

#pragma mark - 下載

//單筆下載書籍
-(void) downloadFileWithUrlPath:(NSString *)urlPath savePath:(NSString *) savePath bookDic:(NSMutableDictionary *) bookDic{
    
    //下載網址有誤
    if (!urlPath && [urlPath length]==0) {
        
        [self showMessage:@"下载路径错误"];
        return;
    }
    
    //因為網址中的檔案名稱可能是中文，所以要做encodeURL處理
    //remoteFileUrl = [remoteFileUrl stringByAddingPercentEscapesUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5)];
    urlPath = [urlPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"pass savePath:%@", savePath);    
    
    downloadRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlPath]];
    [downloadRequest setDownloadDestinationPath:savePath];
    [downloadRequest setDownloadProgressDelegate:self];
    downloadRequest.showAccurateProgress = YES; 
    
    [downloadRequest setValidatesSecureCertificate:NO]; //取消HTTPS授權檢查
    
    NSLog(@"requestURL-->%@", [downloadRequest url]);
    
    //正常執行成功
    [downloadRequest setCompletionBlock:^{
        
        NSLog(@"書籍下載完成！開始寫入相關資訊至DB...");
        
        [self.down_StopBtn setTitle:DOWN_BTN_TEXT_CLOSE forState:UIControlStateNormal];
        
        //self.downloadMsgLabel.text = @"下載完成！開始寫入相關資訊...";
        self.downloadMsgTextView.text = [self.downloadMsgTextView.text stringByAppendingFormat:@"\n下载完成！开始写入相关资料..."];
        [self.downloadMsgTextView scrollRangeToVisible:NSMakeRange([self.downloadMsgTextView.text length], 0)];
        
        //執行下載檢核，比對下載之文件大小是否符合
        NSString *bookID = [bookDic objectForKey:@"BOOK_ID"];
        NSString *bookpath = [[[self getDocumentUserDirectoryPath]stringByAppendingPathComponent:PATH_PDF]stringByAppendingFormat:@"/%@.pdf",bookID];
        float booksize = [[bookDic objectForKey:@"FILE_SIZE"]floatValue];
        
        NSFileManager *fileManager = [NSFileManager defaultManager]; // File manager
       
        BOOL fileExists = [fileManager fileExistsAtPath:bookpath];
        if (fileExists) {
            NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:bookpath error:NULL];
            float fileSize = [[fileAttributes objectForKey:NSFileSize]floatValue]; // File size (bytes)
           // NSLog(@"bookID : %@, fileSize : %f",bookID,fileSize);
            if (fileSize == 0 || fileSize < booksize){
                
                NSLog(@"檔案大小不同  歸類為失敗！");
                //下載之檔案大小不等於後端提供之檔案大小 不合理 刪掉原有檔案 歸類為失敗檔案
                [CathayFileHelper deleteItem:bookpath];
                self.downloadMsgTextView.text = [self.downloadMsgTextView.text stringByAppendingFormat:@"\n下载失败，请重试！"];
                [self.downloadMsgTextView scrollRangeToVisible:NSMakeRange([self.downloadMsgTextView.text length], 0)];
                
                [self.docgridView reloadData];
                return;
            }
        }
        
        
        if ([self writeBookAndRelatedDataToDB:bookDic]) {
            //self.downloadMsgLabel.text = @"完成！";
            self.downloadMsgTextView.text = [self.downloadMsgTextView.text stringByAppendingFormat:@"\n写入成功!"];
            [self.downloadMsgTextView scrollRangeToVisible:NSMakeRange([self.downloadMsgTextView.text length], 0)];
            
            //設上已下載的標籤
            [bookDic setObject:[NSNumber numberWithInt:GridStatusAlreadyDowloaded] forKey:@"BookGridStatus"];
            
            [self hideDownloadView];
            
            
            //[NSTimer scheduledTimerWithTimeInterval:0.8
            //                                 target:self selector:@selector(hideDownloadView)
            //                               userInfo:nil repeats:NO];
            
        }else{
            //self.downloadMsgLabel.text = @"很抱歉，相關資訊寫入失敗，請重試！";
            self.downloadMsgTextView.text = [self.downloadMsgTextView.text stringByAppendingFormat:@"\n相关咨询写入失败，请重试！"];
            [self.downloadMsgTextView scrollRangeToVisible:NSMakeRange([self.downloadMsgTextView.text length], 0)];
        }
        
        [self.docgridView reloadData];
        
    }];
    
    //執行失敗
    [downloadRequest setFailedBlock:^{
        
        NSError *error = [downloadRequest error];
        NSLog(@"Connection Failed - %@, DOMAIN - %@, CODE - %d", [error localizedDescription] ,error.domain, error.code);
        
        if ([[error domain] isEqualToString:@"ASIHTTPRequestErrorDomain"]) {
            [self showMessage:ERROR_MSG_NET];
        }else{
            [self showMessage:ERROR_MSG_DEFAULT];
        }
        
        [self.down_StopBtn setTitle:DOWN_BTN_TEXT_CLOSE forState:UIControlStateNormal];
        [self.progressView setProgress:0];
        [self hideDownloadView];
        
        
    }];
    
    
    //當取得下載的檔案大小時會被呼叫到
    [downloadRequest setDownloadSizeIncrementedBlock :^(long long bytes){
        //NSLog(@"檔案下載 incrementDownloadSizeBy bytes: %llu", bytes);
        totalDownloadBytes = bytes;
        nowDownloadBytes = 0;
        self.downloadRcvMbytesLabel.text = [NSString stringWithFormat:@"%.1f MB/%.1f MB",nowDownloadBytes/1000000.0 , totalDownloadBytes/1000000.0];
    }];
    
    
    [downloadRequest setBytesReceivedBlock :^(unsigned long long size, unsigned long long total){
        //NSLog(@"檔案下載 didReceiveBytes bytes: %llu", size);
        nowDownloadBytes += size;
        self.downloadRcvMbytesLabel.text = [NSString stringWithFormat:@"%.1f MB/%.1f MB",nowDownloadBytes/1000000.0 , totalDownloadBytes/1000000.0];
        
    }];
    
    self.downloadMsgTextView.text = [NSString stringWithFormat:@"\"%@\" 下载中...", [bookDic objectForKey:@"TITLE"]];
    [self.downloadMsgTextView scrollRangeToVisible:NSMakeRange([self.downloadMsgTextView.text length], 0)];
    [self showDownloadView];
    
    [downloadRequest startAsynchronous];
    
}

- (void)downloadAllDoc{
    
    //測試目前網路是否有通
	NetDetectHelper *netDetecter = [[NetDetectHelper alloc]init];
	BOOL isConnected = [netDetecter connectedToNetwork];
	[netDetecter release];
	
    NSLog(@"networkStatus is %@", (isConnected? @"YES" : @"NO"));
    
	if(!isConnected){
		return;
	}

    
    //-----------------
    [cachefailedIndexs removeAllObjects];   //清空錯誤暫存
    
    //建立下載佇列
    downloadQueue = [ASINetworkQueue queue];
    downloadQueue.delegate = self;
    downloadQueue.showAccurateProgress = YES;
    downloadQueue.downloadProgressDelegate = self;
    [downloadQueue setRequestDidStartSelector:@selector(requestDidStart:)];
    [downloadQueue setRequestDidReceiveResponseHeadersSelector:@selector(requestDidReceiveResponseHeaders:)];
    [downloadQueue setRequestDidFinishSelector:@selector(requestDidFinish:)];
    [downloadQueue setRequestDidFailSelector:@selector(requestDidFail:)];
    [downloadQueue setQueueDidFinishSelector:@selector(queueDidFinish:)];
    [downloadQueue setShouldCancelAllRequestsOnFailure:NO];    //設為NO，當一筆錯誤時，其餘佇列仍會繼續執行
    
    
    //對選取的書本進行處理
    for (NSNumber *indexNum in cacheSelectedIndexs) {
        
        NSDictionary *bookDic = [self.documentsArray objectAtIndex:[indexNum intValue]];
        NSString *bookID = [bookDic objectForKey:@"BOOK_ID"];
        NSString *urlPath = [bookDic objectForKey:@"REMOTE_FILE_URL"];
        
        //檢核下載網址
        if (!urlPath && [urlPath length]==0) {
            
            NSLog(@"bookID:%@ selectedIndex:%d 下載網址有誤，略過！", bookID, [indexNum intValue]);
            
            //TODO
            //存此筆錯誤資訊，供後續重新下載
            
            continue;
        }
        
        NSString *savePath = [[[self getDocumentUserDirectoryPath]stringByAppendingPathComponent:PATH_PDF]stringByAppendingFormat:@"/%@.pdf",bookID];   //檔案存放路徑
        
        NSLog(@"加入下載佇列 bookID:%@ selectedIndex:%d url:%@", bookID, [indexNum intValue], urlPath);
        
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlPath]];
        [request setShouldContinueWhenAppEntersBackground:YES ];
        [request setDownloadDestinationPath:savePath];
        [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:indexNum,@"indexNum",nil]]; //放入資訊供成功寫入及錯誤處理
        
        //[request setValidatesSecureCertificate:NO]; //取消HTTPS授權檢查
        
        [downloadQueue addOperation:request]; 
    }
    
    self.downloadMsgTextView.text = @"开始下载...";    
    [self showDownloadView];
    
    [downloadQueue go];
    
}

- (IBAction)cancelDownload:(id)sender {
    
    UIButton *btn = (UIButton *)sender;
    
    if ([btn.titleLabel.text isEqualToString:DOWN_BTN_TEXT_CANCEL]) {
        
        [downloadQueue cancelAllOperations];
        self.downloadMsgTextView.text = [self.downloadMsgTextView.text stringByAppendingFormat:@"\n使用者中断了所有下载项目"];
        [self.downloadMsgTextView scrollRangeToVisible:NSMakeRange([self.downloadMsgTextView.text length], 0)];
        [self.progressView setProgress:0];
        [self.down_StopBtn setTitle:DOWN_BTN_TEXT_CLOSE forState:UIControlStateNormal];
        
    }
    
    [self hideDownloadView];
}



#pragma mark - DownloadView related

-(void) showDownloadView {
    
    [self.view bringSubviewToFront:self.downloadView];
    
    [self.down_StopBtn setTitle:DOWN_BTN_TEXT_CANCEL forState:UIControlStateNormal];
    self.downloadView.hidden = NO;
    
    UIView *blockBgView = [[UIView alloc] initWithFrame:self.view.bounds];
    blockBgView.tag = BLOCK_VIEW_TAG;
    blockBgView.backgroundColor = [UIColor colorWithRed:20/255.0 green:20/255.0 blue:20/255.0 alpha:0.6];
    blockBgView.exclusiveTouch = YES;   //攔截Touch事件，只允許這個View來處理
    blockBgView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:blockBgView belowSubview:self.downloadView];
    [blockBgView release];
    
    //動畫處理
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 0.3f;  
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.type = kCATransitionMoveIn; //kCATransitionPush, kCATransitionFade, kCATransitionMoveIn, kCATransitionReveal
    animation.subtype = kCATransitionFromTop;
    [animation setValue:@"showDownloadView" forKey:@"key"];
    [[downloadView layer] addAnimation:animation forKey:@"moveToTop"];
    
}

-(void) hideDownloadView {
    
    //動畫處理
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 0.3f;  
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.type = kCATransitionReveal; //kCATransitionPush, kCATransitionFade, kCATransitionMoveIn, kCATransitionReveal
    animation.subtype = kCATransitionFromBottom;
    [animation setValue:@"hideDownloadView" forKey:@"key"];
    [[downloadView layer] addAnimation:animation forKey:@"moveToBottom"];
    
    
    self.downloadView.hidden = YES;
    [self.view sendSubviewToBack:self.downloadView];
    [[self.view viewWithTag:BLOCK_VIEW_TAG]removeFromSuperview];
}

- (void)setProgress:(float)progress
{
    //currentProgress = progress;
    // NSLog(@"progress:%f", progress);
    
    [self.progressView setProgress:progress];
}

#pragma mark - ASINetworkQueues SEL

- (void)requestDidStart:(ASIHTTPRequest *)request{
    
    NSNumber *indexNum = [request.userInfo objectForKey:@"indexNum"];
    NSMutableDictionary *bookDic = [self.documentsArray objectAtIndex:[indexNum intValue]];
    NSString *bookID = [bookDic objectForKey:@"BOOK_ID"];
    NSString *title = [bookDic objectForKey:@"TITLE"];
    
    NSLog(@"** queue requestDidStart");
    NSLog(@"書籍開始下載, index:%d, bookID:%@, title:%@", [indexNum intValue], bookID, title);
    NSLog(@"下載佇列尚餘：%d 筆", [downloadQueue requestsCount]);
    
    //self.downloadMsgLabel.text = [NSString stringWithFormat:@"\"%@\" 開始下載..",title];
    self.downloadMsgTextView.text = [self.downloadMsgTextView.text stringByAppendingFormat:@"\n\"%@\" 开始下载..",title]; 
    [self.downloadMsgTextView scrollRangeToVisible:NSMakeRange([self.downloadMsgTextView.text length], 0)];
    self.downloadRcvMbytesLabel.text = [NSString stringWithFormat:@"%d/%d",[cacheSelectedIndexs count]-[downloadQueue requestsCount], [cacheSelectedIndexs count]];
}


- (void)requestDidReceiveResponseHeaders:(ASIHTTPRequest *)request{
    
    NSNumber *indexNum = [request.userInfo objectForKey:@"indexNum"];
    NSMutableDictionary *bookDic = [self.documentsArray objectAtIndex:[indexNum intValue]];
    NSString *bookID = [bookDic objectForKey:@"BOOK_ID"];
    NSString *title = [bookDic objectForKey:@"TITLE"];
    
    NSLog(@"** queue requestDidReceiveResponseHeaders");
    NSLog(@"書籍收到header, index:%d, bookID:%@, title:%@", [indexNum intValue], bookID, title);
    NSLog(@"%.1f MB/%.1f MB",downloadQueue.bytesDownloadedSoFar /1000000.0, downloadQueue.totalBytesToDownload /1000000.0);
    
    //self.downloadRcvMbytesLabel.text = [NSString stringWithFormat:@"%.1f MB/%.1f MB",downloadQueue.bytesDownloadedSoFar /1000000.0, downloadQueue.totalBytesToDownload /1000000.0];
}

- (void)requestDidFinish:(ASIHTTPRequest *)request{
    
    NSNumber *indexNum = [request.userInfo objectForKey:@"indexNum"];
    NSMutableDictionary *bookDic = [self.documentsArray objectAtIndex:[indexNum intValue]];
    NSString *bookID = [bookDic objectForKey:@"BOOK_ID"];
    NSString *title = [bookDic objectForKey:@"TITLE"];
    
    NSLog(@"** requestDidFinish");
    NSLog(@"書籍下載完成, index:%d, bookID:%@, title:%@", [indexNum intValue], bookID, title);
    NSLog(@"下載佇列尚餘：%d 筆", [downloadQueue requestsCount]);
    NSLog(@"%.1f MB/%.1f MB",downloadQueue.bytesDownloadedSoFar /1000000.0, downloadQueue.totalBytesToDownload /1000000.0);    
    
    //self.downloadMsgLabel.text = [NSString stringWithFormat:@"\"%@\" 下載完成",title];
    self.downloadMsgTextView.text = [self.downloadMsgTextView.text stringByAppendingFormat:@"\n\"%@\" 下载完成",title]; 
    [self.downloadMsgTextView scrollRangeToVisible:NSMakeRange([self.downloadMsgTextView.text length], 0)];
    self.downloadRcvMbytesLabel.text = [NSString stringWithFormat:@"%d/%d",[cacheSelectedIndexs count]-[downloadQueue requestsCount], [cacheSelectedIndexs count]];
    
}

- (void)requestDidFail:(ASIHTTPRequest *)request{
    
    NSError *error = [request error];
    NSNumber *indexNum = [request.userInfo objectForKey:@"indexNum"];
    NSDictionary *bookDic = [self.documentsArray objectAtIndex:[indexNum intValue]];
    NSString *bookID = [bookDic objectForKey:@"BOOK_ID"];
    NSString *title = [bookDic objectForKey:@"TITLE"];    
    
    NSLog(@"** requestDidFail");
    NSLog(@"書籍下載失敗, index:%d, bookID:%@, title:%@", [indexNum intValue], bookID, title);
    NSLog(@"錯誤原因 - %@, DOMAIN - %@, CODE - %d", [error localizedDescription] ,error.domain, error.code);
    NSLog(@"下載佇列尚餘：%d 筆", [downloadQueue requestsCount]);
    
    //self.downloadMsgLabel.text = [NSString stringWithFormat:@"\"%@\" 下載失敗", title];
    self.downloadMsgTextView.text = [self.downloadMsgTextView.text stringByAppendingFormat:@"\n\"%@\" 下载失败",title]; 
    [self.downloadMsgTextView scrollRangeToVisible:NSMakeRange([self.downloadMsgTextView.text length], 0)];
    self.downloadRcvMbytesLabel.text = [NSString stringWithFormat:@"%d/%d",[cacheSelectedIndexs count]-[downloadQueue requestsCount], [cacheSelectedIndexs count]];
    
    //存此筆錯誤資訊，供後續重新下載
    [cachefailedIndexs addObject:indexNum];
}

//當quene中所有request都執行完成
- (void)queueDidFinish:(ASIHTTPRequest *)request{
    NSLog(@"所有request皆下載完畢，開始執行寫入動作！");
    //self.downloadMsgLabel.text = @"下載動作完成，開始執行寫入動作！";
    //self.downloadMsgTextView.text = [self.downloadMsgTextView.text stringByAppendingFormat:@"\n下載動作完成，開始執行寫入動作！"]; 
    //[self.downloadMsgTextView scrollRangeToVisible:NSMakeRange([self.downloadMsgTextView.text length], 0)];
    self.downloadRcvMbytesLabel.text = [NSString stringWithFormat:@"%d/%d",[cacheSelectedIndexs count]-[downloadQueue requestsCount], [cacheSelectedIndexs count]];
    
    int totalCount = [cacheSelectedIndexs count];
    
    //執行下載檢核，比對下載之文件大小是否符合
    for (NSNumber *indexNum in cacheSelectedIndexs) {
        NSMutableDictionary *bookDic = [self.documentsArray objectAtIndex:[indexNum intValue]];
        NSString *bookID = [bookDic objectForKey:@"BOOK_ID"];
        NSString *bookpath = [[[self getDocumentUserDirectoryPath]stringByAppendingPathComponent:PATH_PDF]stringByAppendingFormat:@"/%@.pdf",bookID];
        float booksize = [[bookDic objectForKey:@"FILE_SIZE"]floatValue];
        //NSLog(@"bookID : %@",bookID);
        //NSLog(@"booksize : %f",booksize);
          
        NSFileManager *fileManager = [NSFileManager defaultManager]; // File manager
          
        BOOL fileExists = [fileManager fileExistsAtPath:bookpath];
        if (fileExists) {
            NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:bookpath error:NULL];
            float fileSize = [[fileAttributes objectForKey:NSFileSize]floatValue]; // File size (bytes)
            // NSLog(@"fileSize : %f",fileSize);
            if (fileSize == 0 || fileSize != booksize){
                NSLog(@"檔案大小不同  歸類為失敗！");
                //下載之檔案不等於後端傳來之檔案大小  歸類為失敗
                [CathayFileHelper deleteItem:bookpath];
                [cachefailedIndexs addObject:indexNum];
            }
        } else {
            NSLog(@"沒有檔案，歸類為下載失敗");
            [cachefailedIndexs addObject:indexNum];
        }

    }    
    
    //扣掉錯誤的set
    [cacheSelectedIndexs minusSet:cachefailedIndexs];
    
    //寫入下載成功的資料進DB
    for (NSNumber *indexNum in cacheSelectedIndexs) {
        
        NSMutableDictionary *bookDic = [self.documentsArray objectAtIndex:[indexNum intValue]];
        NSString *bookID = [bookDic objectForKey:@"BOOK_ID"];
        NSString *title = [bookDic objectForKey:@"TITLE"];
        
        if ([self writeBookAndRelatedDataToDB:bookDic]) {
            
            NSLog(@"書籍寫入成功, index:%d, bookID:%@, title:%@", [indexNum intValue], bookID, title);
            
            self.downloadMsgTextView.text = [self.downloadMsgTextView.text stringByAppendingFormat:@"\n\"%@\"写入成功！", title]; 
            [self.downloadMsgTextView scrollRangeToVisible:NSMakeRange([self.downloadMsgTextView.text length], 0)];
            [bookDic setObject:[NSNumber numberWithInt:GridStatusAlreadyDowloaded] forKey:@"BookGridStatus"];   //設上已下載的標籤
            
            
        } else{
            
            NSLog(@"書籍寫入失敗, index:%d, bookID:%@, title:%@", [indexNum intValue], bookID, title);
            
            self.downloadMsgTextView.text = [self.downloadMsgTextView.text stringByAppendingFormat:@"\n\"%@\"写入失败！", title];
            [self.downloadMsgTextView scrollRangeToVisible:NSMakeRange([self.downloadMsgTextView.text length], 0)];
            [cachefailedIndexs addObject:indexNum];
        }
        
    }
    
    int failCount = [cachefailedIndexs count];
    
    //錯誤筆數可供再次下載
    [cacheSelectedIndexs setSet:cachefailedIndexs];
    [cachefailedIndexs removeAllObjects];
    
    /////////////////
    // 更新畫面
    
    //self.downloadMsgLabel.text = [NSString stringWithFormat:@"執行完畢，總共下載%d筆 - %d筆成功，%d筆失敗", totalCount, totalCount - failCount, failCount];
    self.downloadMsgTextView.text = [self.downloadMsgTextView.text stringByAppendingFormat:@"\n执行完毕，总共下载%d笔 - %d笔成功，%d笔失败", totalCount, totalCount - failCount, failCount];
    [self.downloadMsgTextView scrollRangeToVisible:NSMakeRange([self.downloadMsgTextView.text length], 0)]; 
    
    if (failCount==0) {
        
        [cacheSelectedIndexs removeAllObjects];
        
        //刪除更新文件原有之筆跡
        if ([cacheUpdateIndexs count] != 0) {
            
            NSString *alertmessage = @"已为您更新以下文件：";
            
            for (NSNumber *indexNum in cacheUpdateIndexs) {
                NSDictionary *bookDic = [self.documentsArray objectAtIndex:[indexNum intValue]];
                [self deleteOldPageStrokeDict:bookDic];
                
                NSString *title = [bookDic objectForKey:@"TITLE"];
                alertmessage = [alertmessage stringByAppendingFormat:@"\n%@",title];
               
            }
            [cacheUpdateIndexs removeAllObjects];
            
            //通知使用者有更新
            UIAlertView *alert = [[UIAlertView alloc] 
                                  initWithTitle: @"信息" 
                                  message:alertmessage
                                  delegate:self 
                                  cancelButtonTitle:@"确定" 
                                  otherButtonTitles:nil];
            
            [alert show];
            [alert release];

        }
        
        [self hideDownloadView];        
        
    }else {
    
        //刪除更新文件原有之筆跡(如果更新文件不在失敗選單才刪除)
        if ([cacheUpdateIndexs count] != 0) {
            
            NSString *alertmessage = @"已为您更新以下文件：";
            
            for (NSNumber *indexNum in cacheUpdateIndexs) {
                if(![cachefailedIndexs containsObject:indexNum]){
                    NSDictionary *bookDic = [self.documentsArray objectAtIndex:[indexNum intValue]];
                    [self deleteOldPageStrokeDict:bookDic];
                    
                    NSString *title = [bookDic objectForKey:@"TITLE"];
                    alertmessage = [alertmessage stringByAppendingFormat:@"\n%@",title];

                    [cacheUpdateIndexs removeObject:indexNum];
                }
            }
            
            //通知使用者有更新
            UIAlertView *alert = [[UIAlertView alloc] 
                                  initWithTitle: @"信息" 
                                  message:alertmessage
                                  delegate:self 
                                  cancelButtonTitle:@"确定" 
                                  otherButtonTitles:nil];
            
            [alert show];
            [alert release];
            
        }

        [self.down_StopBtn setTitle:DOWN_BTN_TEXT_CLOSE forState:UIControlStateNormal];
        [self.progressView setProgress:0];
    }
    
    [cacheSelectedIndexs removeAllObjects];
    [self.docgridView reloadData];
    
    if ([self.documentsArray count] == 1) {
        
        //僅有一個檔案時自動開啟
        NSMutableDictionary *dic = [self.documentsArray objectAtIndex:0];
        
        NSString *bookID = [dic objectForKey:@"BOOK_ID"];        
        
        NSString *pdfPath = [[[self getDocumentUserDirectoryPath]stringByAppendingPathComponent:PATH_PDF]stringByAppendingFormat:@"/%@.pdf",bookID];
        
        //檢查檔案是否存在
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:pdfPath];
        
        if (fileExists) {
            [self autoOpenOnlyDoc:dic];
        }       
    }

    
}


#pragma mark - write / delete db related


//將書本資料及其所屬公司別、類別寫入資料庫
-(BOOL) writeBookAndRelatedDataToDB:(NSDictionary *) bookDic {
    
    //--------------------------
    //準備資料
    
    
    //1. 公司別
    NSMutableDictionary *companyDic = nil;   //公司資料
    NSDictionary *cpyDataDic = nil; //公司相關資料
    NSString *cpyCode = keepCompanyID ; //公司別代碼
    
    if (!self.meetingDict) {
        NSLog(@"選單列無資料，無法進行寫入");
        return NO;
    }
        
    companyDic = [NSMutableDictionary dictionaryWithCapacity:4];
    cpyDataDic = [self.menuDataDic valueForKey:cpyCode];
    [companyDic setValue:cpyCode forKey:@"CPY_CODE"];
    [companyDic setValue:[cpyDataDic objectForKey:@"CPY_NAME"] forKey:@"CPY_NAME"];
    [companyDic setValue:[cpyDataDic objectForKey:@"ORDER"] forKey:@"ORDER"];
    [companyDic setValue:[cpyDataDic objectForKey:@"UPDATE_TIME"] forKey:@"UPDATE_TIME"];
    
    //2. 類別（最多兩層）
    NSString *upperCategoryID = keepMeetID; //會議
    NSString *categoryID = keepDateID; //會期
    
    
    NSMutableDictionary *upperCategoryDic = nil;    //寫入資料 - 上層類別
    NSMutableDictionary *lowerCategoryDic = nil;    //寫入資料 - 下層類別
    
          
    //取得第一層類別
    NSDictionary *categoryDic = [cpyDataDic valueForKey:@"subFolders"];
        
    //2.1 若有兩層，先處理上層的資料
    if (upperCategoryID && [upperCategoryID length]>0) {
        upperCategoryDic = [NSMutableDictionary dictionaryWithCapacity:7];  //上層資料
            
        categoryDic = [categoryDic valueForKey:upperCategoryID];
        [upperCategoryDic setValue:upperCategoryID forKey:@"CATEGORY_ID"];
        [upperCategoryDic setValue:[categoryDic valueForKey:@"CATEGORY_NAME"] forKey:@"CATEGORY_NAME"];
        [upperCategoryDic setValue:[categoryDic valueForKey:@"TYPE"] forKey:@"TYPE"];
        [upperCategoryDic setValue:[categoryDic valueForKey:@"ORDER"] forKey:@"ORDER"]; //傳回資料無此值
        [upperCategoryDic setValue:[categoryDic valueForKey:@"UPDATE_TIME"] forKey:@"UPDATE_TIME"];
        [upperCategoryDic setValue:@"" forKey:@"UPPER_CATEGORY"];
        [upperCategoryDic setValue:cpyCode forKey:@"CPY_CODE"];
            
        //取得下一層類別資料
        categoryDic = [categoryDic valueForKey:@"subFolders"];
            
    }else {
        upperCategoryID = @"";
    }
        
    //2.2 處理下層的資料
    categoryDic = [categoryDic valueForKey:categoryID];
    lowerCategoryDic = [NSMutableDictionary dictionaryWithCapacity:7];  //下層資料
    [lowerCategoryDic setValue:categoryID forKey:@"CATEGORY_ID"];
    [lowerCategoryDic setValue:[categoryDic valueForKey:@"CATEGORY_NAME"] forKey:@"CATEGORY_NAME"];
    [lowerCategoryDic setValue:[categoryDic valueForKey:@"TYPE"] forKey:@"TYPE"];
    [lowerCategoryDic setValue:[categoryDic valueForKey:@"ORDER"] forKey:@"ORDER"]; //傳回資料無此值
    [lowerCategoryDic setValue:[categoryDic valueForKey:@"UPDATE_TIME"] forKey:@"UPDATE_TIME"];
    [lowerCategoryDic setValue:upperCategoryID forKey:@"UPPER_CATEGORY"];
    [lowerCategoryDic setValue:cpyCode forKey:@"CPY_CODE"];
    
    //----------------------------
    //開始寫入，有值改update
        
    NSString *bookID = [bookDic valueForKey:@"BOOK_ID"];
    
    [dao beginTransaction];
    @try
    {
        
        //公司別
        if ([dao getCountsOfCompanyByPK:cpyCode] == 0) {
            
            if (![dao insertCompanyWithDic:companyDic])
                [NSException raise:@"insert fail" format:@"insertCompany"];
            
        }else{
            
            if (![dao updateCompanyWithDic:companyDic])
                [NSException raise:@"update fail" format:@"updateCompany"];
            
        }
        
        //類別
        //若上層有值
        if (upperCategoryDic) {
            
            if ([dao getCountsOfCategoryByPK:upperCategoryID] == 0) {
                
                if (![dao insertCategoryWithDic:upperCategoryDic])
                    [NSException raise:@"insert fail" format:@"insertCategory"];
                
            }else{
                
                if (![dao updateCategoryWithDic:upperCategoryDic])
                    [NSException raise:@"update fail" format:@"updateCategory"];
                
            }
            
        }
        
        //下層
        if ([dao getCountsOfCategoryByPK:categoryID] == 0) {
            
            if (![dao insertCategoryWithDic:lowerCategoryDic])
                [NSException raise:@"insert fail" format:@"insertCategory"];
            
        }else{
            
            if (![dao updateCategoryWithDic:lowerCategoryDic])
                [NSException raise:@"update fail" format:@"updateCategory"];
            
        }
        
        
        //書本
        if ([dao getCountsOfBooksByPK:bookID] == 0) {
            
            if (![dao insertBookWithDic:bookDic])
                [NSException raise:@"insert fail" format:@"insertBook"];
            
        }else{
            
            if (![dao updateBookWithDic:bookDic])
                [NSException raise:@"update fail" format:@"updateBook"];
            
        }
        
        [dao commitTransaction];
    }
    @catch(NSException* e)
    {
        [dao rollbackTransaction];
        
        NSLog(@"writeBookAndRelatedDataToDB rollback, DB error:%@, reason:%@",[e name],[e reason]);
        
        return NO;
    }

    return YES;
}

-(void) deleteOldPageStrokeDict:(NSDictionary *) bookDic{
    
    NSString *bookid = [bookDic objectForKey:@"BOOK_ID"];
    
    //文件已更新，若原存有筆跡資料，則直接刪除 
    NSString *dataPath = [[[[CathayFileHelper getDocumentPath]stringByAppendingPathComponent:[dao getUserID]]stringByAppendingPathComponent:@"PDF"]stringByAppendingPathComponent:bookid];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:dataPath];
    if (fileExists) {
        [CathayFileHelper deleteItem:dataPath];
    }
    
}

-(BOOL) deleteBookAndRelatedDataFromDB:(NSDictionary *) bookDic {
    
    NSLog(@"deleteBookAndRelatedDataFromDB  bookDic:%@",bookDic);
    NSLog(@"deleteBookAndRelatedDataFromDB, CompanyID:%@, MeetID:%@, DateID:%@",keepCompanyID,keepMeetID,keepDateID);
    
    NSString *bookID = [bookDic valueForKey:@"BOOK_ID"];  //書本編號
    NSString *upperCategoryID = keepMeetID;  //上層類別（不一定有值）
    NSString *categoryID = keepDateID;   //第二層類別（一定有）
    NSString *cpyCode =keepCompanyID;   //公司別
    
    [dao beginTransaction];
    @try
    {
        
        //刪書
        if (![dao deleteBookWithBookID:bookID])
            [NSException raise:@"delete fail" format:@"deleteBook"];
        
        //若沒有書本屬於此類別
        if ([dao getCountsOfBooksByCategoryID:categoryID] == 0) {
            
            //刪類別
            if (![dao deleteCategoryWithCategoryID:categoryID])
                [NSException raise:@"delete fail" format:@"deleteCategory"];
        }
        
        //若上層類別下已沒有任何類別
        if (upperCategoryID && [dao getCountsOfCategoryByUpperCategoryID:upperCategoryID] == 0) {
            
            //刪上層類別
            if (![dao deleteCategoryWithCategoryID:upperCategoryID])
                [NSException raise:@"delete fail" format:@"deleteupperCategoryID"];
        }
        
        //若公司別下已無類別
        if ([dao getCountsOfCategoryByCompanyCode:cpyCode] == 0) {
            
            //刪公司別
            if (![dao deleteCompanyWithCompanyCode:cpyCode])
                [NSException raise:@"delete fail" format:@"deleteCompany"];
        }
        
        
        [dao commitTransaction];
    }
    @catch(NSException* e)
    {        
        [dao rollbackTransaction];
        
        NSLog(@"DB error:%@, reason:%@",[e name],[e reason]);
        
        return NO;
    }
    
    return YES;
    
}


#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    
    [HUD removeFromSuperview];
    [HUD release];
    HUD = nil;
    
    //寄送多選檔案之mail
    if (hud.tag == HUD_PDFLOADING_TAG) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        MFMailComposeViewController *mailComposer = [MFMailComposeViewController new];

        NSLog(@"xx cacheMailIndexs : %@",cacheMailIndexs);
        
        //處理附加檔案
        for (NSNumber *indexNum in cacheMailIndexs) {
            NSDictionary *bookDic = [self.documentsArray objectAtIndex:[indexNum intValue]];
            NSString *bookID = [bookDic objectForKey:@"BOOK_ID"];
            NSString *title = [bookDic objectForKey:@"TITLE"];
            
            NSString *filePath = [[[CathayFileHelper getDocumentPath]stringByAppendingPathComponent:@"mailTMP"]stringByAppendingPathComponent:bookID];   //檔案存放路徑
            NSURL *fullFileURL =  [[NSURL alloc] initFileURLWithPath:filePath isDirectory:NO]; 
            NSLog(@"fullFileURL : %@",fullFileURL);
            
            NSData *attachment = [NSData dataWithContentsOfURL:fullFileURL options:(NSDataReadingMapped|NSDataReadingUncached) error:nil];
            
            if (attachment != nil){
                [mailComposer addAttachmentData:attachment mimeType:@"application/pdf" fileName:[NSString stringWithFormat:@"%@.pdf",title]];
            }
            
            [fullFileURL release];
        }    
        
        NSString *meetName = [[self.meetingDict objectForKey:keepMeetID] objectForKey: @"CATEGORY_NAME"];
        NSString *dateName = [[self.dateDict objectForKey: keepDateID] objectForKey: @"CATEGORY_NAME"];
        
        NSString *doctitle = [NSString stringWithFormat:@"%@ : 会议日期 - %@",meetName,dateName];
        NSLog(@"Email title : %@", doctitle);
        
        [mailComposer setSubject:doctitle]; // Use the document file name for the subject
        
        NSString * body = @"";
        [mailComposer setMessageBody:body isHTML:YES];
        
        mailComposer.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        mailComposer.modalPresentationStyle = UIModalPresentationFormSheet;
        
        mailComposer.mailComposeDelegate = self; // Set the delegate
        
        [self presentModalViewController:mailComposer animated:YES];
        
        [mailComposer release]; // Cleanup
        
        [cacheMailIndexs removeAllObjects];
        /*   
         NSFileManager *fileManager = [NSFileManager defaultManager]; // File manager
         
         BOOL fileExists = [fileManager fileExistsAtPath:bookpath];
         if (fileExists) {
         NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:bookpath error:NULL];
         float fileSize = [[fileAttributes objectForKey:NSFileSize]floatValue]; // File size (bytes)
         // NSLog(@"bookID : %@, fileSize : %f",bookID,fileSize);
         if (fileSize < minSize){
         
         unsigned long long fileSize = [document.fileSize unsignedLongLongValue];
         
         if (fileSize < (unsigned long long)15728640) // Check attachment size limit (15MB)
         */
        
        [pool release];

    }
    
}

#pragma mark - 多選寄送

- (void)sendMultiEmail{
    
    HUD = [[MBProgressHUD alloc]initWithView:self.view.window];
    [self.view.window addSubview:HUD];
    HUD.tag = HUD_PDFLOADING_TAG;
    HUD.delegate = self;
    HUD.dimBackground = YES;
    HUD.labelText = @"资料处理中...";

    //因會用到同一執行緒，故需使用此寫法產生多執行緒處理資料
    [HUD showWhileExecuting:@selector(genEmailPDF) onTarget:self withObject:nil animated:YES];
            
   }

- (void)genEmailPDF{
    
    NSString *phrase = nil; // Document password (for unlocking most encrypted PDF files)
    CathayPDFGenerator *pdfGenerator = nil;
    NSMutableSet *cachePDFfailIndexs =  [[NSMutableSet alloc] init];  //多選 - 暫存PDF產生失敗之資料
    
    NSMutableSet *tempSet = [NSMutableSet setWithSet:cacheMailIndexs];
    
    for (NSNumber *indexNum in tempSet) {
        
        NSDictionary *bookDic = [self.documentsArray objectAtIndex:[indexNum intValue]];
        NSString *bookID = [bookDic objectForKey:@"BOOK_ID"];
        
        NSString *dataPath = [[[self getDocumentUserDirectoryPath]stringByAppendingPathComponent:PATH_PDF]stringByAppendingFormat:@"/%@.pdf",bookID];   //檔案存放路徑
        NSString *pageStrokePath = [[[self getDocumentUserDirectoryPath]stringByAppendingPathComponent:PATH_PDF]stringByAppendingFormat:@"/%@",bookID];   //筆跡檔案存放路徑
        NSURL *datapathURL =  [[NSURL alloc] initFileURLWithPath:dataPath isDirectory:NO]; 
        
        //若有筆跡，把筆跡加上後存檔;若沒有筆跡，則直接存檔
        
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:pageStrokePath];
        if (fileExists) {
            NSData *data = [[NSData alloc]initWithContentsOfFile:pageStrokePath];
            NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
            NSMutableDictionary *pageStrokeDict = [unarchiver decodeObjectForKey:@"pageStrokeDict"];
            
            [unarchiver finishDecoding];
            [unarchiver release];
            [data release];
            
            pdfGenerator = [[CathayPDFGenerator alloc] initWithURL:datapathURL password:phrase pageStrokeData:pageStrokeDict];
        }else {
            pdfGenerator = [[CathayPDFGenerator alloc] initWithURL:datapathURL password:phrase pageStrokeData:nil];
        }
        
        
        NSString *filePath = [[[CathayFileHelper getDocumentPath]stringByAppendingPathComponent:@"mailTMP"]stringByAppendingPathComponent:bookID];
        NSLog(@"Email寄送 --- 準備匯出PDF至%@", filePath);
        BOOL isOK = [pdfGenerator generatePdfWithFilePath:filePath];
        if(!isOK){
            [cachePDFfailIndexs addObject:indexNum];
        }
        
        [pdfGenerator release];
        pdfGenerator = nil;
        
    } 
    
    //通知使用者哪些檔案產生時有誤
    if ([cachePDFfailIndexs count] != 0) {

        NSLog(@"PDF產生有誤 cachePDFfailIndexs ： %@", cachePDFfailIndexs);
        
        NSString *alertmessage = @"以下资料产生PDF发生错误，无法寄送：";
        
        for (NSNumber *indexNum in cachePDFfailIndexs) {
            NSDictionary *bookDic = [self.documentsArray objectAtIndex:[indexNum intValue]];
            
            NSString *title = [bookDic objectForKey:@"TITLE"];
            alertmessage = [alertmessage stringByAppendingFormat:@"\n%@",title];
            
        }
        
        //通知使用者哪些檔案產生時有問題
        UIAlertView *alert = [[UIAlertView alloc] 
                              initWithTitle: @"信息" 
                              message:alertmessage
                              delegate:self 
                              cancelButtonTitle:@"确定" 
                              otherButtonTitles:nil];
        
        [alert show];
        [alert release];
        
        //把產檔失敗的文件扣掉
        [tempSet minusSet:cachePDFfailIndexs];
        
    }
    
    [cacheMailIndexs release];
    cacheMailIndexs = [[NSMutableSet alloc]initWithSet:tempSet];
    
    [cachePDFfailIndexs release];

}
    
#pragma mark MFMailComposeViewControllerDelegate methods
    
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
    {
		if ((result == MFMailComposeResultFailed) && (error != NULL)) NSLog(@"%@", error);
        [self dismissModalViewControllerAnimated:YES]; // Dismiss
    }
   
#pragma mark - 自動開啟文件
- (void)autoOpenOnlyDoc:(NSMutableDictionary*) documentDic {
    
   // NSString *bookID = [[self.documentsArray objectAtIndex:actionSheet.tag]objectForKey:@"BOOK_ID"];
    //NSMutableDictionary *documentDic = [self.documentsArray objectAtIndex:actionSheet.tag];
        
        NSString *bookID = [documentDic objectForKey:@"BOOK_ID"];        
        
        NSString *pdfPath = [[[self getDocumentUserDirectoryPath]stringByAppendingPathComponent:PATH_PDF]stringByAppendingFormat:@"/%@.pdf",bookID];
                
        NSString *phrase = nil; // Document password (for unlocking most encrypted PDF files)
        //init nextController
        ReaderDocument *document = [[ReaderDocument alloc] initWithFilePath:pdfPath password:phrase];
        document.title = [documentDic objectForKey:@"TITLE"];
        document.bookid = [documentDic objectForKey:@"BOOK_ID"];
        
        if (document != nil) // Must have a valid ReaderDocument object in order to proceed
        {
            ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];
            readerViewController.delegate = self; // Set the ReaderViewController delegate to self
            readerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
            readerViewController.noteid = keepDateID;
            readerViewController.noteTitle = [NSString stringWithFormat:@"%@_%@",[[self.meetingDict objectForKey:keepMeetID] objectForKey: @"CATEGORY_NAME"],[[self.dateDict objectForKey: keepDateID] objectForKey: @"CATEGORY_NAME"]];
            
            //若原存有筆跡資料，要把筆跡資料加回                    
            NSString *dataPath = [[[[CathayFileHelper getDocumentPath]stringByAppendingPathComponent:[dao getUserID]]stringByAppendingPathComponent:@"PDF"]stringByAppendingPathComponent:document.bookid];
            BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:dataPath];
            if (fileExists) {
                NSData *data = [[NSData alloc]initWithContentsOfFile:dataPath];
                NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
                readerViewController.pageStrokeDict = [unarchiver decodeObjectForKey:@"pageStrokeDict"];
                //NSLog(@"pageStrokeDict : %@",readerViewController.pageStrokeDict);
                
                [unarchiver finishDecoding];
                [unarchiver release];
                [data release];
            }
            
            //若原存有筆的使用資料，要設成最後使用狀態    
            NSString *pendataPath = [[[CathayFileHelper getDocumentPath]stringByAppendingPathComponent:@"mailTMP"]stringByAppendingPathComponent:@"pendata"];
            BOOL penfileExists = [[NSFileManager defaultManager] fileExistsAtPath:pendataPath];
            if (penfileExists) {
                NSData *data = [[NSData alloc]initWithContentsOfFile:pendataPath];
                NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
                readerViewController.penDic = [unarchiver decodeObjectForKey:@"pendata"];
                
                [unarchiver finishDecoding];
                [unarchiver release];
                [data release];
            }
            
            [self presentModalViewController:readerViewController animated:NO];
            [readerViewController release]; 
        }
        
        [document release];

}
@end
