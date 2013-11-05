//
//  NoteViewController.m
//  CathayMeeting
//
//  Created by Fanny Sheng on 12/7/27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NoteViewController.h"
#import "CathayCanvasToolBar.h"
#import "CathayCanvas.h"
#import "CathayGlobalVariable.h"
#import "CathayPDFGenerator.h"
#import "CathayFileHelper.h"
#import "AppDelegate.h"
#import "BookShelfDAO.h"
#import "WKVerticalScrollBar.h"
#import "NotePalmRestView.h"

#define ACTION_CLEAN_CANVAS_TAG 300
#define ACTION_EXPORT_TAG 301
#define ACTION_EMAIL_TAG 302
#define ACTION_PALMREST_TAG 303

#define VERTICAL_SCROLL_TAG 600

@implementation NoteViewController

#pragma mark Constants

#define PAGING_VIEWS 3

#define TOOLBAR_HEIGHT 44.0f
#define FOOTBAR_HEIGHT 48.0f
#define VERTICAL_SCROLL_BAR_WIDTH 50.0f


#define TAP_AREA_SIZE 48.0f

@synthesize bookID,bookTitle;
@synthesize editToolBar,mainToolBar;
@synthesize colorPopoverController, sizePopoverController, caculatorPopoverController;
@synthesize pageStrokeDict,penDic;
@synthesize noteContentView;
@synthesize delegate;
@synthesize handBoardView;
@synthesize currentPage;

#pragma mark UIViewController methods

- (id)initWithBookID:(NSString *)bookid
{
    
    self = [super initWithNibName:nil bundle:nil];// Designated initializer
    
    if (self) {
        // Custom initialization
        
        self.bookID = [NSString stringWithFormat:@"%@_NOTE",bookid];
        
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        
        [notificationCenter addObserver:self selector:@selector(applicationWill:) name:UIApplicationWillTerminateNotification object:nil];
        
        [notificationCenter addObserver:self selector:@selector(applicationWill:) name:UIApplicationWillResignActiveNotification object:nil];
        
        [notificationCenter addObserver:self selector:@selector(applicationWill:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //取得資料庫實體...
    dao = [BookShelfDAO sharedDAO];
    
    self.view.backgroundColor = [UIColor whiteColor];
    eraserEnable = NO;
    sumPage = 1;
    
    CGRect viewRect = self.view.bounds; // View controller's view bounds
    
    //編輯功能列
    self.editToolBar = [[CathayCanvasToolBar alloc]initWithFrame:CGRectMake(0, 0,  viewRect.size.width, TOOLBAR_HEIGHT)];
    editToolBar.delegate = self;
    editToolBar.hidden = NO;
    [self.view addSubview:editToolBar];
    
    
    if (self.pageStrokeDict == nil) {
        pageStrokeDict = [NSMutableDictionary new];
        self.currentPage = 0;
    }else {
        sumPage = [pageStrokeDict count];
        //NSLog(@"self. sumPage :  %d",sumPage);
    }
    
    //NSLog(@"self.penDic : %@",self.penDic);
    
    if (self.penDic == nil) {
        lastCanvasButton = 1;
        normalpenLastBrushSize = 2.0f;
        normalpenLastBrushColor = [UIColor blackColor];
        lightpenLastBrushSize = 13.0f;
        lightpenLastBrushColor = [UIColor greenColor];
        
    }else {
        
        lastCanvasButton = [[self.penDic objectForKey:@"lastCanvasButton"]intValue];
        //NSLog(@"lastCanvasButton : %d",lastCanvasButton);
        
        normalpenLastBrushSize =  [[self.penDic objectForKey:@"normalpenLastBrushSize"]floatValue];
        normalpenLastBrushColor = [self.penDic objectForKey:@"normalpenLastBrushColor"];
        lightpenLastBrushSize = [[self.penDic objectForKey:@"lightpenLastBrushSize"]floatValue];
        lightpenLastBrushColor = [self.penDic objectForKey:@"lightpenLastBrushColor"];
    }
    
    //NSLog(@"pageStrokeDict : %@",pageStrokeDict);
    
    NSNumber *key = [NSNumber numberWithInteger:currentPage]; 
    NSMutableArray *_drawDataArray = [pageStrokeDict objectForKey:key];
    
    //*******上次色筆資料及顏色
    
    //判斷最後一次資料
    float lastBrushSize;
    UIColor *lastBrushColor;
    
    if (lastCanvasButton == 1) {
        lastBrushColor = normalpenLastBrushColor;
        lastBrushSize = normalpenLastBrushSize;
    }else if(lastCanvasButton == 2){
        lastBrushColor = lightpenLastBrushColor;
        lastBrushSize = lightpenLastBrushSize;
    }else if(lastCanvasButton == 3){
        lastBrushColor = [UIColor clearColor];
        lastBrushSize = 13.0f;
    }
    //**************
    
    //建立ContentView(內含CanvasView)
    self.noteContentView = [[NoteContentView alloc]initWithFrame:CGRectMake(0, TOOLBAR_HEIGHT,  self.view.bounds.size.width, self.view.bounds.size.height-TOOLBAR_HEIGHT-FOOTBAR_HEIGHT) drawData:_drawDataArray brushSize:lastBrushSize brushColor:lastBrushColor];
        
    [self.editToolBar setStatus:lastCanvasButton];
    if (lastCanvasButton == 2) {
        self.noteContentView.canvasView.isHighlight = YES;
    }
    
    [self.view addSubview:self.noteContentView];

    
    CGRect pagebarRect = viewRect;
	pagebarRect.size.height = FOOTBAR_HEIGHT;
	pagebarRect.origin.y = (viewRect.size.height - FOOTBAR_HEIGHT);
    
    //編輯下方功能列
    self.mainToolBar = [[NoteMainToolBar alloc]initWithFrame:pagebarRect];
    mainToolBar.delegate = self;
    [self.view addSubview:mainToolBar];
    
    if (currentPage != 0) {
         [self showCurrentPage];
    }
    
    
    //加入自定垂直scrollBar
    WKVerticalScrollBar *_verticalScrollBar = [[WKVerticalScrollBar alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-VERTICAL_SCROLL_BAR_WIDTH, TOOLBAR_HEIGHT, VERTICAL_SCROLL_BAR_WIDTH, self.view.bounds.size.height-TOOLBAR_HEIGHT-FOOTBAR_HEIGHT)];
    [_verticalScrollBar setScrollView:noteContentView];
    _verticalScrollBar.tag = VERTICAL_SCROLL_TAG;
    
   // [_verticalScrollBar setHandleColor:[UIColor redColor] forState:UIControlStateNormal];
   // [_verticalScrollBar setHandleColor:[UIColor redColor] forState:UIControlStateSelected];
    
    [self.view addSubview:_verticalScrollBar];
    [_verticalScrollBar release];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    #ifdef DEBUGX
	NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(self.view.bounds));
    #endif
    
	[super viewWillAppear:animated];
    
	if (CGSizeEqualToSize(lastAppearSize, CGSizeZero) == false)
	{
		if (CGSizeEqualToSize(lastAppearSize, self.view.bounds.size) == false)
		{
		//	[self updateScrollViewContentViews]; // Update content views
		}
        
		lastAppearSize = CGSizeZero; // Reset view size tracking
	}
    
    ((AppDelegate *)[UIApplication sharedApplication].delegate).currentPresentedModalViewController = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    #ifdef DEBUGX
	NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(self.view.bounds));
    #endif
    
	[super viewDidAppear:animated];
    [self layoutViewsWithRotation];
    
}

- (void)viewWillDisappear:(BOOL)animated
{

	[super viewWillDisappear:animated];
	lastAppearSize = self.view.bounds.size; // Track view size

}

- (void)viewDidDisappear:(BOOL)animated
{
    
	[super viewDidDisappear:animated];
}

- (void)viewDidUnload
{    
    
    self.colorPopoverController = nil;
    self.sizePopoverController = nil;
    self.caculatorPopoverController = nil;
    self.pageStrokeDict = nil;
    self.penDic = nil;
    lastAppearSize = CGSizeZero; 
    currentPage = 0;
    self.handBoardView = nil;
    [editToolBar release]; editToolBar =nil;
    [mainToolBar release]; mainToolBar =nil;
    
	[super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{    
	return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    #ifdef DEBUGX
	NSLog(@"%s %@ (%d)", __FUNCTION__, NSStringFromCGRect(self.view.bounds), toInterfaceOrientation);
    #endif
    
	if (isVisible == NO) return; // iOS present modal bodge
    
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
	{
		if (printInteraction != nil) [printInteraction dismissAnimated:NO];
	}
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    #ifdef DEBUGX
	NSLog(@"%s %@ (%d)", __FUNCTION__, NSStringFromCGRect(self.view.bounds), interfaceOrientation);
    #endif
    
    [self layoutViewsWithRotation];
    
	//if (isVisible == NO) return; // iOS present modal bodge
	//lastAppearSize = CGSizeZero; // Reset view size tracking    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    #ifdef DEBUGX
	NSLog(@"%s %@ (%d to %d)", __FUNCTION__, NSStringFromCGRect(self.view.bounds), fromInterfaceOrientation, self.interfaceOrientation);
    #endif
    
	//if (isVisible == NO) return; // iOS present modal bodge
	//if (fromInterfaceOrientation == self.interfaceOrientation) return;
}

- (void)layoutViewsWithRotation{
    
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    CGRect viewRect = self.view.bounds; // View controller's view bounds
    CGRect pagebarRect = viewRect;
    pagebarRect.size.height = FOOTBAR_HEIGHT;
    pagebarRect.origin.y = (viewRect.size.height - FOOTBAR_HEIGHT);
    
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
		 
       // NSLog(@"contentView frame:%f %f", self.noteContentView.frame.size.width, self.noteContentView.frame.size.height);
        [self.noteContentView setContentOffset:CGPointMake(0.0,0.0) animated:NO];
        [self.noteContentView zoomReset];
        self.mainToolBar.frame = pagebarRect;
        
    }else {
       // NSLog(@"contentView frame:%f %f", self.noteContentView.frame.size.width, self.noteContentView.frame.size.height);
        [self.noteContentView setContentOffset:CGPointMake(0.0,0.0) animated:NO];
        [self.noteContentView zoomReset];
        self.mainToolBar.frame = pagebarRect;
    }
    
    WKVerticalScrollBar *_verticalScrollBar = (WKVerticalScrollBar *)[self.view viewWithTag:VERTICAL_SCROLL_TAG];
    _verticalScrollBar.frame = CGRectMake(self.view.bounds.size.width-VERTICAL_SCROLL_BAR_WIDTH, TOOLBAR_HEIGHT, VERTICAL_SCROLL_BAR_WIDTH, self.view.bounds.size.height-TOOLBAR_HEIGHT-FOOTBAR_HEIGHT);
    //NSLog(@"_verticalScrollBar %f %f", _verticalScrollBar.frame.size.width, _verticalScrollBar.frame.size.height);    
}

- (void)dealloc
{
    #ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
    #endif
    
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    ((AppDelegate *)[UIApplication sharedApplication].delegate).currentPresentedModalViewController = nil;
    
    [editToolBar release]; editToolBar =nil;     
    [mainToolBar release]; mainToolBar = nil;
    [pageStrokeDict release], pageStrokeDict = nil;
    [penDic release],penDic = nil;
    [colorPopoverController release];
    [sizePopoverController release];
    [caculatorPopoverController release];
    [noteContentView release]; noteContentView = nil;
    [bookID release];
    [bookTitle release];
    [handBoardView release]; handBoardView = nil;
    
	[super dealloc];
}



#pragma mark CathayCanvasToolbarDelegate methods

- (void)tappedInCanvasToolBar:(CathayCanvasToolBar *)toolbar undoButton:(UIButton *)button{
    [self.noteContentView.canvasView undo];
}

- (void)tappedInCanvasToolBar:(CathayCanvasToolBar *)toolbar redoButton:(UIButton *)button{
    [self.noteContentView.canvasView redo];
}

- (void)tappedInCanvasToolBar:(CathayCanvasToolBar *)toolbar finishButton:(UIButton *)button{
    /*    
     NSInteger page = [document.pageNumber integerValue]; // Current page #
     NSNumber *key = [NSNumber numberWithInteger:page]; 
     ReaderContentView *pageContentView = [contentViews objectForKey:key];
     
     //關閉繪圖能力
     theScrollView.scrollEnabled = YES;
     pageContentView.scrollEnabled = YES;
     pageContentView.theContainerView.userInteractionEnabled = NO;  
     */    
    
    NSNumber *key = [NSNumber numberWithInteger:currentPage]; 
    
    //將使用者繪製資訊寫入全域
    NSMutableArray *_drawDataArray= [self.noteContentView.canvasView.drawDataArray mutableCopy];
    [self.pageStrokeDict setObject:_drawDataArray forKey:key];
    [_drawDataArray release];
    
    
    //當筆跡軌跡不為空時，存檔
    if([self.pageStrokeDict count] != 0){
        
        NSMutableData *data = [[NSMutableData alloc]init];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
        
        NSString *dataPath = [[[[CathayFileHelper getDocumentPath]stringByAppendingPathComponent:[dao getUserID]]stringByAppendingPathComponent:@"PDF"]stringByAppendingPathComponent:bookID];
        
        [archiver encodeObject:self.pageStrokeDict forKey:@"pageStrokeDict"];
        [archiver encodeObject:[NSNumber numberWithInt:currentPage]  forKey:@"currentPage"];
        [archiver finishEncoding];
        [data writeToFile:dataPath atomically:YES];
        [archiver release];                      
        [data release];
        
        //儲存筆的最後使用狀況
        
        NSMutableData *data2 = [[NSMutableData alloc]init];
        NSKeyedArchiver *archiver2 = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data2];
        
        NSMutableDictionary *penDict = [[NSMutableDictionary alloc]init];
        [penDict setObject:[NSString stringWithFormat:@"%d",lastCanvasButton]  forKey:@"lastCanvasButton"];
        [penDict setObject:[NSString stringWithFormat:@"%f",normalpenLastBrushSize] forKey:@"normalpenLastBrushSize"];
        [penDict setObject:normalpenLastBrushColor  forKey:@"normalpenLastBrushColor"];
        [penDict setObject:[NSString stringWithFormat:@"%f",lightpenLastBrushSize] forKey:@"lightpenLastBrushSize"];
        [penDict setObject:lightpenLastBrushColor  forKey:@"lightpenLastBrushColor"];
        
        // NSLog(@"penDict:%@ ",penDict);
        
        NSString *pendataPath = [[[CathayFileHelper getDocumentPath]stringByAppendingPathComponent:@"mailTMP"]stringByAppendingPathComponent:@"pendata_NOTE"];
        
        [archiver2 encodeObject:penDict forKey:@"pendata"];
        [archiver2 finishEncoding];
        [data2 writeToFile:pendataPath atomically:YES];
        [archiver2 release];                      
        [data2 release];
        [penDict release];
        
    }else {
        //筆跡為空時，判斷是否舊有資料還在，若有需清除    
        
        NSString *dataPath = [[[[CathayFileHelper getDocumentPath]stringByAppendingPathComponent:[dao getUserID]]stringByAppendingPathComponent:@"PDF"]stringByAppendingPathComponent:bookID];
        
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:dataPath];
        if (fileExists) {
            [CathayFileHelper deleteItem:dataPath];
        }
    }
    
    
    [self dismissModalViewControllerAnimated:YES];
    
    
}

- (void)tappedInCanvasToolBar:(CathayCanvasToolBar *)toolbar normalPenButton:(UIButton *)button{
    
    eraserEnable = NO;
    self.noteContentView.canvasView.isHighlight = NO;
    
    //還原原本畫筆大小及顏色
    if (normalpenLastBrushColor) {
        self.noteContentView.canvasView.brushSize = normalpenLastBrushSize;    
        self.noteContentView.canvasView.brushColor = normalpenLastBrushColor;    
    }
    
    lastCanvasButton = 1; //設定最後一次的PenButton
    
}

- (void)tappedInCanvasToolBar:(CathayCanvasToolBar *)toolbar lightPenButton:(UIButton *)button{
    
    eraserEnable = NO;    
    self.noteContentView.canvasView.isHighlight = YES;
    
    //還原原本畫筆大小及顏色    
    if (lightpenLastBrushColor) {
        self.noteContentView.canvasView.brushSize = lightpenLastBrushSize;    
        self.noteContentView.canvasView.brushColor = lightpenLastBrushColor;
    }
    
    lastCanvasButton = 2; //設定最後一次的PenButton
    
}

- (void)tappedInCanvasToolBar:(CathayCanvasToolBar *)toolbar colorButton:(UIButton *)button{
    [self showHideColorPopUp:button];
}

- (void)tappedInCanvasToolBar:(CathayCanvasToolBar *)toolbar sizeButton:(UIButton *)button{
    [self showHideSizePopUp:button];
}

- (void)tappedInCanvasToolBar:(CathayCanvasToolBar *)toolbar eraserButton:(UIButton *)button{
    
    eraserEnable = YES;
    lastCanvasButton = 3; //設定最後一次的PenButton
    
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil
                                                        delegate:self
                                               cancelButtonTitle:nil
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:@"清除局部", @"清除此頁", @"清除整份文件", nil];
    
    //將selectedIndex放進Action供取出book資料
    action.tag = ACTION_CLEAN_CANVAS_TAG;
    
    //present the popover view non-modal with a
    //refrence to the button pressed within the current view
    CGRect popoverRect = [self.view convertRect:[button frame] 
                                       fromView:[button superview]];
    
    popoverRect.size.width = MIN(popoverRect.size.width, 200); 
    
    [action showFromRect:popoverRect inView:self.view animated:YES];
    [action release];
    
    
    
    if (![button isSelected]) {
        
        /*       NSInteger page = [document.pageNumber integerValue]; // Current page #
         NSNumber *key = [NSNumber numberWithInteger:page]; 
         ReaderContentView *pageContentView = [contentViews objectForKey:key];*/
        //       lastBrushSize = pageContentView.canvasView.brushSize; //暫存原本畫筆尺寸，供待會兒還原
        //       lastBrushColor = pageContentView.canvasView.brushColor;
        self.noteContentView.canvasView.brushSize = 20.0f;   //橡皮擦大小
        self.noteContentView.canvasView.brushColor = [UIColor clearColor];
        
        
    }
    
}

#pragma mark CathayCanvasToolbar Popup

- (void) showHideColorPopUp:(id)sender {
    
    UIButton *btn = (UIButton *)sender;
    
    if (self.colorPopoverController == nil) {
        
        UIColor *lastBrushColor;
        if (lastCanvasButton == 1) {
            lastBrushColor = normalpenLastBrushColor;
        }else if(lastCanvasButton == 2){
            lastBrushColor = lightpenLastBrushColor;
        }else if(lastCanvasButton == 3){
            lastBrushColor = [UIColor clearColor]; 
        }
        
        InfColorPickerController* picker = [ InfColorPickerController colorPickerViewController ];
        picker.sourceColor = lastBrushColor;
        picker.delegate = self;
        
        //set popover content size
        //picker.contentSizeForViewInPopover = CGSizeMake(450, 630);
        
        
        UIPopoverController *popover = 
        [[UIPopoverController alloc] 
         initWithContentViewController:picker]; 
        //popover.delegate = self;
        
        self.colorPopoverController = popover;
        [popover release];
        
    }else {
        //把brush color 指進picker中
        UIColor *lastBrushColor;
        if (lastCanvasButton == 1) {
            lastBrushColor = normalpenLastBrushColor;
        }else if(lastCanvasButton == 2){
            lastBrushColor = lightpenLastBrushColor;
        }else if(lastCanvasButton == 3){
            lastBrushColor = [UIColor clearColor]; 
        }
        
        ((InfColorPickerController*)self.colorPopoverController.contentViewController).sourceColor = lastBrushColor;
        
    }
    
    
    if([self.colorPopoverController isPopoverVisible])
	{
		[self.colorPopoverController dismissPopoverAnimated:YES];
		return;
	}
    
    //present the popover view non-modal with a
	//refrence to the button pressed within the current view
    CGRect popoverRect = [self.view convertRect:[btn frame] 
                                       fromView:[btn superview]];
    
    popoverRect.size.width = MIN(popoverRect.size.width, 100); 
    [self.colorPopoverController 
     presentPopoverFromRect:popoverRect 
     inView:self.view 
     permittedArrowDirections:UIPopoverArrowDirectionUp 
     animated:YES]; 
    
}

- (void) showHideSizePopUp:(id)sender {
    
    UIButton *btn = (UIButton *)sender;
    
    if (self.sizePopoverController == nil) {
        
        SizePopupViewController* popupViewController = [SizePopupViewController sizePopupViewController];
        popupViewController.delegate = self;
        
        //set popover content size
        //picker.contentSizeForViewInPopover = CGSizeMake(450, 630);
        
        
        float lastBrushSize;
        if (lastCanvasButton == 1) {
            lastBrushSize = normalpenLastBrushSize;
        }else if(lastCanvasButton == 2){
            lastBrushSize = lightpenLastBrushSize;
        }else if(lastCanvasButton == 3){
            lastBrushSize = 13.0f; 
        }
        
        //更新Brush size 的segment設定
        if (lastBrushSize == 2.0f) {
            popupViewController.initSize = @"0";
        }else if (lastBrushSize == 5.0f) {
            popupViewController.initSize = @"1";
        }else if (lastBrushSize == 8.0f) {
            popupViewController.initSize = @"2";
        }else if (lastBrushSize == 11.0f) {
            popupViewController.initSize = @"3";
        }else if (lastBrushSize == 13.0f) {
            popupViewController.initSize = @"4";
        }        
        
        UIPopoverController *popover = 
        [[UIPopoverController alloc] 
         initWithContentViewController:popupViewController]; 
        //popover.delegate = self;
        
        self.sizePopoverController = popover;
        [popover release];
        
    }else {
        //把brush size set SizePopupViewController 中
        float lastBrushSize;
        if (lastCanvasButton == 1) {
            lastBrushSize = normalpenLastBrushSize;
        }else if(lastCanvasButton == 2){
            lastBrushSize = lightpenLastBrushSize;
        }else if(lastCanvasButton == 3){
            lastBrushSize = 13.0f;
        }
        
        NSString *size;
        //更新Brush size 的segment設定
        if (lastBrushSize == 2.0f) {
            size = @"0";
        }else if (lastBrushSize == 5.0f) {
            size = @"1";
        }else if (lastBrushSize == 8.0f) {
            size = @"2";
        }else if (lastBrushSize == 11.0f) {
            size = @"3";        
        }else if (lastBrushSize == 13.0f) {
            size = @"4";
        }        
        
        [((SizePopupViewController*) self.sizePopoverController.contentViewController) setStatus: size];
    }
    
    
    if([self.sizePopoverController isPopoverVisible])
	{
		[self.sizePopoverController dismissPopoverAnimated:YES];
		return;
	}
    
    
    //present the popover view non-modal with a
	//refrence to the button pressed within the current view
    CGRect popoverRect = [self.view convertRect:[btn frame] 
                                       fromView:[btn superview]];
    
    popoverRect.size.width = MIN(popoverRect.size.width, 100); 
    [self.sizePopoverController 
     presentPopoverFromRect:popoverRect 
     inView:self.view 
     permittedArrowDirections:UIPopoverArrowDirectionUp 
     animated:YES]; 
    
    
    
}


#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex < 0) { 
        return;
    }
    
    //Action點選何項功能
	NSString *selectedValue = [actionSheet buttonTitleAtIndex:buttonIndex];
    
#ifdef IS_DEBUG    
    NSLog(@"click button:%d tag:%d title:%@", buttonIndex, actionSheet.tag, selectedValue);
#endif
    
    
    if (actionSheet.tag == ACTION_CLEAN_CANVAS_TAG) {
        
        if (buttonIndex == 1) {
            
            [self.noteContentView.canvasView clearCanvas];
            
        }else if(buttonIndex == 2){
            
            //先把此頁清掉
            [self.noteContentView.canvasView clearCanvas];
            
            //再把筆跡檔整個清空
            self.pageStrokeDict = [NSMutableDictionary new];
            
            //回到第一頁
            sumPage = 1;
            currentPage = 0;
            
            NSString *pageText = [NSString stringWithFormat:@"-- %d --",currentPage+1];
            self.mainToolBar.pageLabel.text = pageText;
            
        }
        
        
    }else if(actionSheet.tag == ACTION_EMAIL_TAG) {
        
        
        NSString *blankPdfPath = [[CathayFileHelper getDocumentPath]stringByAppendingFormat:@"/blankPage.pdf"];
        //NSLog(@"blankPdfPath : %@",blankPdfPath);
        
        
        NSURL *fileURL =  [[NSURL alloc] initFileURLWithPath:blankPdfPath isDirectory:NO]; 
        NSString *password = @"";
        NSString *title = [NSString stringWithFormat:@"%@_NOTE",self.bookTitle];
        
        CathayPDFGenerator *pdfGenerator = [[CathayPDFGenerator alloc] initWithURL:fileURL password:password pageStrokeData:pageStrokeDict];
        
        
        if (buttonIndex == 0) {
            title = [NSString stringWithFormat:@"%@_p%d",title,currentPage+1];
        }
        
        NSString *filePath = [[[CathayFileHelper getDocumentPath]stringByAppendingPathComponent:@"mailTMP"]stringByAppendingPathComponent:title];
        
#ifdef IS_DEBUG
        NSLog(@"Email寄送 --- 準備匯出筆記PDF至%@", filePath);
#endif
        
        BOOL isOK = NO;
        
        //Email此頁
        if (buttonIndex == 0) {
            isOK = [pdfGenerator generatePdfWithBlankFile:filePath pageNo:currentPage]; 
            
        }else if (buttonIndex == 1)  {
            //Email整份文件    
            isOK = [pdfGenerator generatePdfWithBlankFile:filePath pageNum:sumPage];
        }
        
        if (!isOK) {
            UIAlertView *alert = [[UIAlertView alloc] 
                                  initWithTitle: @"訊息" 
                                  message:@"寄送異常"
                                  delegate:nil 
                                  cancelButtonTitle:@"好" 
                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
            
            return;
        }
        
        [fileURL release];
        [pdfGenerator release];         
        
        
        //email寄送
        
        NSURL *fullFileURL =  [[NSURL alloc] initFileURLWithPath:filePath isDirectory:NO]; 
#ifdef IS_DEBUG
        NSLog(@"fullFileURL : %@",fullFileURL);
#endif

                        
         NSData *attachment = [NSData dataWithContentsOfURL:fullFileURL options:(NSDataReadingMapped|NSDataReadingUncached) error:nil];
         
         if (attachment != nil) // Ensure that we have valid document file attachment data
         {
         MFMailComposeViewController *mailComposer = [MFMailComposeViewController new];
         
         [mailComposer addAttachmentData:attachment mimeType:@"application/pdf" fileName:[NSString stringWithFormat:@"%@.pdf",title]];
         
         [mailComposer setSubject:title]; // Use the document file name for the subject
         
         mailComposer.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
         mailComposer.modalPresentationStyle = UIModalPresentationFormSheet;
         
         mailComposer.mailComposeDelegate = self; // Set the delegate
         
         [self presentModalViewController:mailComposer animated:YES];
         
         [mailComposer release]; // Cleanup
         }
         
         [fullFileURL release];
        
    }else  if (actionSheet.tag == ACTION_PALMREST_TAG) {
        
        if (self.handBoardView==nil) {
            
            UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
            
            CGRect frame = CGRectMake(120, 385, 650, 625); //直向
            
            if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
                frame = CGRectMake(160, 315, 650, 625); //橫向
            }
            
            self.handBoardView = [[NotePalmRestView alloc] initWithFrame:frame];
            self.handBoardView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"palmRest.png"]];
            [self.handBoardView.layer setCornerRadius: 30];
            
            //self.handBoardView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin |     UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleBottomMargin;
            self.handBoardView.autoresizingMask = UIViewAutoresizingNone;
            
            self.handBoardView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
            self.handBoardView.layer.shadowOpacity = 8.0f;
            self.handBoardView.layer.shadowOffset = CGSizeMake(4, 4);
                    
            
            //左撇子
            if (buttonIndex == 1) {
               self.handBoardView.transform = CGAffineTransformMakeRotation(3.1415975/8);
            }else{
               self.handBoardView.transform = CGAffineTransformMakeRotation(-3.1415975/8);
            }
            
            
            CGRect handlePanViewframe = CGRectMake(0, 0, 130, 105); //直向
            if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
                handlePanViewframe = CGRectMake(0, 0, 130, 105); //橫向
            }
            
            //增加一小塊view以拖拉
            UIView *handlePanView = [[UIView alloc]initWithFrame:handlePanViewframe];
            
            //增加拖移能力
            UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
            [panRecognizer setMinimumNumberOfTouches:1];
            [panRecognizer setMaximumNumberOfTouches:1];
            //[panRecognizer setDelegate:self];
            [handlePanView addGestureRecognizer:panRecognizer];
            [panRecognizer release];
            
            
            UITapGestureRecognizer *doubleTapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
            doubleTapOne.numberOfTouchesRequired = 1; doubleTapOne.numberOfTapsRequired = 2; doubleTapOne.delegate = self;
            [handlePanView addGestureRecognizer:doubleTapOne];
            [doubleTapOne release];
            
            [self.handBoardView addSubview:handlePanView];
            [self.view addSubview:self.handBoardView];
            
            //}
            
        }else {
            [self.handBoardView  removeFromSuperview];
            [self.handBoardView release];
            self.handBoardView = nil;
        }
        
    }
    
}

#pragma mark InfColorPickerControllerDelegate

- (void) colorPickerControllerDidChangeColor: (InfColorPickerController*) picker
{
    
    UIColor *lastBrushColor;
    
    if (eraserEnable) {
        lastBrushColor = picker.resultColor;
    }else {
        /*       NSInteger page = [document.pageNumber integerValue]; // Current page #
         NSNumber *key = [NSNumber numberWithInteger:page]; 
         ReaderContentView *pageContentView = [contentViews objectForKey:key];*/
        self.noteContentView.canvasView.brushColor = picker.resultColor;
        lastBrushColor = picker.resultColor;
    }
    
    if (lastCanvasButton == 1) {
        normalpenLastBrushColor = lastBrushColor;
    }else if(lastCanvasButton == 2){
        lightpenLastBrushColor = lastBrushColor;
    }
    
}

#pragma mark SizePopupDelegate

-(void) changeBrushSize:(float)size {
    
    float  lastBrushSize;
    
    if (eraserEnable) {
        lastBrushSize = size;
    }else {
        /*    NSInteger page = [document.pageNumber integerValue]; // Current page #
         NSNumber *key = [NSNumber numberWithInteger:page]; 
         ReaderContentView *pageContentView = [contentViews objectForKey:key];*/
        self.noteContentView.canvasView.brushSize = size;
        lastBrushSize = size;
    }
    
    if (lastCanvasButton == 1) {
        normalpenLastBrushSize = lastBrushSize;
    }else if(lastCanvasButton == 2){
        lightpenLastBrushSize = lastBrushSize;
    }
    
}

#pragma mark MFMailComposeViewControllerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
#ifdef DEBUG
    if ((result == MFMailComposeResultFailed) && (error != NULL)) NSLog(@"%@", error);
#endif
    
	[self dismissModalViewControllerAnimated:YES]; // Dismiss
}

#pragma mark UIApplication notification methods

- (void)applicationWill:(NSNotification *)notification
{
    
    // 儲存每頁軌跡
    NSNumber *key = [NSNumber numberWithInteger:currentPage]; 
    NSMutableArray *_drawDataArray= [self.noteContentView.canvasView.drawDataArray mutableCopy];
    [self.pageStrokeDict setObject:_drawDataArray forKey:key];
    [_drawDataArray release];
    
    
    
    //當筆跡軌跡不為空時，存檔
    if([pageStrokeDict count] != 0){
        
        NSMutableData *data = [[NSMutableData alloc]init];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
        
        NSString *dataPath = [[[[CathayFileHelper getDocumentPath]stringByAppendingPathComponent:[dao getUserID]]stringByAppendingPathComponent:@"PDF"]stringByAppendingPathComponent:bookID];
        //   NSLog(@"dataPath : %@",dataPath );
        //   NSLog(@"pageStrokeDict : %@",pageStrokeDict);
        
        [archiver encodeObject:pageStrokeDict forKey:@"pageStrokeDict"];
        [archiver encodeObject:[NSNumber numberWithInt:currentPage]  forKey:@"currentPage"];
        [archiver finishEncoding];
        [data writeToFile:dataPath atomically:YES];
        [archiver release];                      
        [data release];
        
        //儲存筆的最後使用狀況
        
        NSMutableData *data2 = [[NSMutableData alloc]init];
        NSKeyedArchiver *archiver2 = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data2];
        
        NSMutableDictionary *penDict = [[NSMutableDictionary alloc]init];
        [penDict setObject:[NSString stringWithFormat:@"%d",lastCanvasButton]  forKey:@"lastCanvasButton"];
        [penDict setObject:[NSString stringWithFormat:@"%f",normalpenLastBrushSize] forKey:@"normalpenLastBrushSize"];
        [penDict setObject:normalpenLastBrushColor  forKey:@"normalpenLastBrushColor"];
        [penDict setObject:[NSString stringWithFormat:@"%f",lightpenLastBrushSize] forKey:@"lightpenLastBrushSize"];
        [penDict setObject:lightpenLastBrushColor  forKey:@"lightpenLastBrushColor"];
        
        // NSLog(@"penDic:%@ ",penDic);
        
        NSString *pendataPath = [[[CathayFileHelper getDocumentPath]stringByAppendingPathComponent:@"mailTMP"]stringByAppendingPathComponent:@"pendata_NOTE"];
        
        [archiver2 encodeObject:penDict forKey:@"pendata"];
        [archiver2 finishEncoding];
        [data2 writeToFile:pendataPath atomically:YES];
        [archiver2 release];                      
        [data2 release];
        [penDict release];
        
    }else {
        //筆跡為空時，判斷是否舊有資料還在，若有需清除    
        
        NSString *dataPath = [[[[CathayFileHelper getDocumentPath]stringByAppendingPathComponent:[dao getUserID]]stringByAppendingPathComponent:@"PDF"]stringByAppendingPathComponent:bookID];
        
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:dataPath];
        if (fileExists) {
            [CathayFileHelper deleteItem:dataPath];
        }
    }
}

#pragma mark NoteMainToolbarDelegate methods

- (void)tappedInNoteToolBar:(NoteMainToolBar *)toolbar nextButton:(UIButton *)button{
    
    //先存這頁的檔
    NSNumber *key = [NSNumber numberWithInteger:currentPage]; 
    NSMutableArray *_drawDataArray= [self.noteContentView.canvasView.drawDataArray mutableCopy];
    [self.pageStrokeDict setObject:_drawDataArray forKey:key];
    [_drawDataArray release];
        
    self.currentPage = currentPage +1;
    
    if (currentPage == sumPage) {
    //表示為最末頁，需新增新的一頁
        sumPage = sumPage +1;
        //NSLog(@"newest sumPage : %d",sumPage);
        self.noteContentView.canvasView.drawDataArray = [NSMutableArray array];
        
    }else {
    //將下一頁的資料匯上去    
        key = [NSNumber numberWithInteger:currentPage]; 

        if ([self.pageStrokeDict objectForKey:key] != NULL) {
            self.noteContentView.canvasView.drawDataArray =  [self.pageStrokeDict objectForKey:key];
        }else {
             self.noteContentView.canvasView.drawDataArray = [NSMutableArray array];
        }
        
    }
    
    [self.noteContentView.canvasView setNeedsDisplay];
    
    //動畫處理
    
    CATransition *animation = [CATransition animation];
    //[animation setDelegate:self];
    [animation setDuration:0.3f];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    animation.type = @"pageCurl";
    
    animation.subtype = kCATransitionFromBottom;
    animation.fillMode = kCAFillModeForwards;
    animation.startProgress = 0.3f;
    [animation setRemovedOnCompletion:YES];
    
    [[self.noteContentView layer]  addAnimation:animation forKey:@"pageCurlAnimation"];   

    NSString *pageText = [NSString stringWithFormat:@"-- %d --",currentPage+1];
    self.mainToolBar.pageLabel.text = pageText;
    
}

- (void)tappedInNoteToolBar:(NoteMainToolBar *)toolbar previousButton:(UIButton *)button{
    
    //先存這頁的檔
    NSNumber *key = [NSNumber numberWithInteger:currentPage]; 
    NSMutableArray *_drawDataArray= [self.noteContentView.canvasView.drawDataArray mutableCopy];
    [self.pageStrokeDict setObject:_drawDataArray forKey:key];
    [_drawDataArray release];

    
    if (currentPage == 0) {
        //NSLog(@"已經在第一頁");
        return;
    }else {
                
        self.currentPage = currentPage - 1;
        
        //將上一頁的資料匯上去    
        key = [NSNumber numberWithInteger:currentPage]; 
        
        if ([self.pageStrokeDict objectForKey:key] != NULL) {
            self.noteContentView.canvasView.drawDataArray =  [self.pageStrokeDict objectForKey:key];
        }else {
            self.noteContentView.canvasView.drawDataArray = [NSMutableArray array];
        }
        
             
        //動畫處理
        
        CATransition *animation = [CATransition animation];
        [animation setDelegate:self];
        [animation setDuration:0.3f];
        [animation setTimingFunction:UIViewAnimationCurveEaseInOut];
        animation.type = @"pageUnCurl";
        
        animation.subtype = kCATransitionFromBottom;
        animation.fillMode = kCAFillModeForwards;
        //animation.startProgress = 0.3f;
        [animation setRemovedOnCompletion:YES];
        [[self.noteContentView layer]  addAnimation:animation forKey:@"pageUnCurlAnimation"];
    
        
        NSString *pageText = [NSString stringWithFormat:@"-- %d --",currentPage+1];
        self.mainToolBar.pageLabel.text = pageText;
        
    }   
    
}

- (void)tappedInNoteToolBar:(NoteMainToolBar *)toolbar emailButton:(UIButton *)button{
    
    if ([MFMailComposeViewController canSendMail] == NO) return;
        
    
    //先存這頁的檔
    NSNumber *key = [NSNumber numberWithInteger:currentPage]; 
    NSMutableArray *_drawDataArray= [self.noteContentView.canvasView.drawDataArray mutableCopy];
    [self.pageStrokeDict setObject:_drawDataArray forKey:key];
    [_drawDataArray release];
    
    
    //準備寄送
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil
                                                        delegate:self
                                               cancelButtonTitle:nil
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:@"Email此頁", @"Email完整筆記", nil];
    
    //將selectedIndex放進Action供取出book資料
    action.tag = ACTION_EMAIL_TAG;
    
    //present the popover view non-modal with a
    //refrence to the button pressed within the current view
    CGRect popoverRect = [self.view convertRect:[button frame] 
                                       fromView:[button superview]];
    
    popoverRect.size.width = MIN(popoverRect.size.width, 200); 
    
    [action showFromRect:popoverRect inView:self.view animated:YES];
    [action release];
    
}

- (void)tappedInNoteToolBar:(NoteMainToolBar *)toolbar handBoardButton:(UIButton *)button{
    
      if (self.handBoardView ==nil) {
          
          UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil
                                                              delegate:self
                                                     cancelButtonTitle:nil
                                                destructiveButtonTitle:nil
                                                     otherButtonTitles:@"右", @"左", nil];
          
          action.tag = ACTION_PALMREST_TAG;
          
          CGRect popoverRect = [self.view convertRect:[button frame]
                                             fromView:[button superview]];
          
          popoverRect.size.width = MIN(popoverRect.size.width, 200);
          
          [action showFromRect:popoverRect inView:self.view animated:YES];
          [action release];
          
      }else{
          
          [self.handBoardView removeFromSuperview];
          [self.handBoardView release];
          self.handBoardView = nil;
      
      }
    
}


#pragma mark - CAAnimation delegate

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag{
    
    [self.noteContentView.canvasView setNeedsDisplay];
    
}

#pragma mark - 處理手靠板

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    
    // Comment for panning
    // Uncomment for tickling
    //return;    
    
    CGPoint translation = [recognizer translationInView:self.view];
    
    //取得中心點
    recognizer.view.superview.center = CGPointMake(recognizer.view.superview.center.x + translation.x,
                                                   recognizer.view.superview.center.y + translation.y);

  //  recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,                                         recognizer.view.center.y + translation.y);
    
    //歸零
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        CGPoint velocity = [recognizer velocityInView:self.view];   //速率
        CGFloat magnitude = sqrtf((velocity.x * velocity.x) + (velocity.y * velocity.y));
        CGFloat slideMult = magnitude / 200;
        //NSLog(@"magnitude: %f, slideMult: %f", magnitude, slideMult);
        

        CGFloat diffWidth = recognizer.view.superview.bounds.size.width / 4;
        CGFloat diffHeight = recognizer.view.superview.bounds.size.height / 4;
       // NSLog(@"diffWidth:%f, diffHeight:%f", diffWidth, diffHeight);
        
        float slideFactor = 0.1 * slideMult; // Increase for more of a slide
        CGPoint finalPoint = CGPointMake(recognizer.view.superview.center.x,
                                         recognizer.view.superview.center.y);
       // NSLog(@"finalPoint.x:%f y:%f", finalPoint.x, finalPoint.y);
        finalPoint.x = MIN(finalPoint.x<=0?MAX(finalPoint.x-diffWidth,0-diffWidth):MAX(finalPoint.x,0), self.view.bounds.size.width+ diffWidth);
        finalPoint.y = MIN(finalPoint.y<=0?MAX(finalPoint.y-diffHeight,0-diffHeight):MAX(finalPoint.y,0), self.view.bounds.size.height+ diffHeight);
       // NSLog(@"## finalPoint.x:%f y:%f", finalPoint.x, finalPoint.y);

        [UIView animateWithDuration:slideFactor*2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            recognizer.view.superview.center = finalPoint;
        } completion:nil];
        
    }
    
}

- (void)handleDoubleTap:(UIPanGestureRecognizer *)recognizer {
    
    [self.handBoardView removeFromSuperview];
    [self.handBoardView release];
    self.handBoardView = nil;
    
}

- (void)showCurrentPage{
    
    NSNumber *key = [NSNumber numberWithInteger:currentPage]; 
    
    if ([self.pageStrokeDict objectForKey:key] != NULL) {
        self.noteContentView.canvasView.drawDataArray =  [self.pageStrokeDict objectForKey:key];
    }else {
        self.noteContentView.canvasView.drawDataArray = [NSMutableArray array];
    }
        
    NSString *pageText = [NSString stringWithFormat:@"-- %d --",currentPage+1];
    self.mainToolBar.pageLabel.text = pageText;
    
    [self.noteContentView.canvasView setNeedsDisplay];

}
@end
