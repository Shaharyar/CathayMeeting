//
//	ReaderViewController.m
//	Reader v2.5.3
//
//	Created by Julius Oklamcak on 2011-07-01.
//	Copyright © 2011 Julius Oklamcak. All rights reserved.
//
//	This work is being made available under a Creative Commons Attribution license:
//		«http://creativecommons.org/licenses/by/3.0/»
//	You are free to use this work and any derivatives of this work in personal and/or
//	commercial products and projects as long as the above copyright is maintained and
//	the original author is attributed.
//

#import "ReaderConstants.h"
#import "ReaderViewController.h"
#import "ReaderThumbCache.h"
#import "ReaderThumbQueue.h"
#import "CathayCanvasToolBar.h"
#import "CathayCanvas.h"
#import "CathayGlobalVariable.h"
#import "CathayPDFGenerator.h"
#import "CathayFileHelper.h"
#import "AppDelegate.h"
#import "PlistHelper.h"
#import "BookShelfDAO.h"
#import "NoteViewController.h"
#import "WKVerticalScrollBar.h"


#define ACTION_CLEAN_CANVAS_TAG 300
#define ACTION_EXPORT_TAG 301
#define ACTION_EMAIL_TAG 302
#define VERTICAL_SCROLL_TAG 600


#define VERTICAL_SCROLL_BAR_WIDTH 50.0f

@interface ReaderViewController()
@property (nonatomic, assign) CathayCanvasToolBar *editToolBar;

- (void) showHideColorPopUp:(id)sender;
- (void) showHideSizePopUp:(id)sender;

@end


@implementation ReaderViewController

#pragma mark Constants

#define PAGING_VIEWS 3

#define TOOLBAR_HEIGHT 44.0f
#define PAGEBAR_HEIGHT 48.0f

#define TAP_AREA_SIZE 48.0f

#pragma mark Properties

@synthesize delegate;
@synthesize editToolBar;
@synthesize colorPopoverController, sizePopoverController, caculatorPopoverController;
@synthesize pageStrokeDict,penDic;
@synthesize noteid,noteTitle;

#pragma mark Support methods

- (void)updateScrollViewContentSize
{
    #ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
    #endif

	NSInteger count = [document.pageCount integerValue];

	if (count > PAGING_VIEWS) count = PAGING_VIEWS; // Limit

	CGFloat contentHeight = theScrollView.bounds.size.height;

	CGFloat contentWidth = (theScrollView.bounds.size.width * count);

	theScrollView.contentSize = CGSizeMake(contentWidth, contentHeight);
}

- (void)updateScrollViewContentViews
{
    #ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
    #endif

	[self updateScrollViewContentSize]; // Update the content size

	NSMutableIndexSet *pageSet = [NSMutableIndexSet indexSet]; // Page set

	[contentViews enumerateKeysAndObjectsUsingBlock: // Enumerate content views
		^(id key, id object, BOOL *stop)
		{
			ReaderContentView *contentView = object; 
            [pageSet addIndex:contentView.tag];
		}
	];

	__block CGRect viewRect = CGRectZero; 
    viewRect.size = theScrollView.bounds.size;

	__block CGPoint contentOffset = CGPointZero; 
    NSInteger page = [document.pageNumber integerValue];

	[pageSet enumerateIndexesUsingBlock: // Enumerate page number set
		^(NSUInteger number, BOOL *stop)
		{
			NSNumber *key = [NSNumber numberWithInteger:number]; // # key

			ReaderContentView *contentView = [contentViews objectForKey:key];

			contentView.frame = viewRect; 
            
            if (page == number) contentOffset = viewRect.origin;

			viewRect.origin.x += viewRect.size.width; // Next view frame position
            
            //Yu Jen Wang 強迫頁面拉到上面(單頁旋轉時)
            [contentView zoomReset];
            [contentView setContentOffset:CGPointMake(0.0,0.0) animated:NO];
            
		}
	];

	if (CGPointEqualToPoint(theScrollView.contentOffset, contentOffset) == false)
	{
		theScrollView.contentOffset = contentOffset; // Update content offset
	}
}

- (void)updateToolbarBookmarkIcon
{
    #ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
    #endif

	NSInteger page = [document.pageNumber integerValue];

	BOOL bookmarked = [document.bookmarks containsIndex:page];

	[mainToolbar setBookmarkState:bookmarked]; // Update
}


//最多同時在記憶體暫存三頁
- (void)showDocumentPage:(NSInteger)page
{
    #ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
    #endif    

	if (page != currentPage) // Only if different
	{
		NSInteger minValue; NSInteger maxValue;
		NSInteger maxPage = [document.pageCount integerValue];
		NSInteger minPage = 1;

		if ((page < minPage) || (page > maxPage)) return;

		if (maxPage <= PAGING_VIEWS) // Few pages
		{
			minValue = minPage;
			maxValue = maxPage;
		}
		else // Handle more pages
		{
			minValue = (page - 1);
			maxValue = (page + 1);

			if (minValue < minPage)
				{minValue++; maxValue++;}
			else
				if (maxValue > maxPage)
					{minValue--; maxValue--;}
		}

		NSMutableIndexSet *newPageSet = [NSMutableIndexSet new];

		NSMutableDictionary *unusedViews = [contentViews mutableCopy];

		CGRect viewRect = CGRectZero; viewRect.size = theScrollView.bounds.size;

		for (NSInteger number = minValue; number <= maxValue; number++)
		{
			NSNumber *key = [NSNumber numberWithInteger:number]; // # key

			ReaderContentView *contentView = [contentViews objectForKey:key];
                        
			if (contentView == nil) //  當contentView已被回收，重新建立
			{
                
				NSURL *fileURL = document.fileURL; 
                NSString *phrase = document.password; // Document properties
                
                NSMutableArray *_drawDataArray = [pageStrokeDict objectForKey:key];
/*                
                if (_drawDataArray && [_drawDataArray count]>0) {
                    NSLog(@"page:%d, 已有繪圖資料:%@", number, _drawDataArray);
                }else {
                    NSLog(@"page:%d, 沒有繪圖資料", number);
                    _drawDataArray = nil;
                }
*/                
                
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
                    lastBrushSize = 18.0f; 
                }
                
				contentView = [[ReaderContentView alloc] initWithFrame:viewRect fileURL:fileURL page:number password:phrase drawData:_drawDataArray brushSize:lastBrushSize brushColor:lastBrushColor];
                
				[theScrollView addSubview:contentView]; 
                [contentViews setObject:contentView forKey:key];
				contentView.message = self; 
                [contentView release]; 
                [newPageSet addIndex:number];
                        
			}
            else // 未被回收，回該頁初始化
			{
                //筆跡若已經被清除，則已load進來的筆跡也需要清掉
                NSMutableArray *_drawDataArray = [pageStrokeDict objectForKey:key];
                if (!_drawDataArray) {
                    [contentView.canvasView clearCanvas];
                }
                
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
                    lastBrushSize = 18.0f; 
                }
                                
				contentView.frame = viewRect; 
                [contentView zoomReset];
                contentView.canvasView.brushSize = lastBrushSize;
                contentView.canvasView.brushColor = lastBrushColor;  
                eraserEnable = NO;               
                [unusedViews removeObjectForKey:key];
			}

			viewRect.origin.x += viewRect.size.width;
        
		}

		[unusedViews enumerateKeysAndObjectsUsingBlock: // Remove unused views
			^(id key, id object, BOOL *stop)
			{
				[contentViews removeObjectForKey:key];
				ReaderContentView *contentView = object;
				[contentView removeFromSuperview];
			}
		];

		[unusedViews release], unusedViews = nil; // Release unused views

		CGFloat viewWidthX1 = viewRect.size.width;
		CGFloat viewWidthX2 = (viewWidthX1 * 2.0f);

		CGPoint contentOffset = CGPointZero;

		if (maxPage >= PAGING_VIEWS)
		{
			if (page == maxPage)
				contentOffset.x = viewWidthX2;
			else
				if (page != minPage)
					contentOffset.x = viewWidthX1;
		}
		else
			if (page == (PAGING_VIEWS - 1))
				contentOffset.x = viewWidthX1;

		if (CGPointEqualToPoint(theScrollView.contentOffset, contentOffset) == false)
		{
			theScrollView.contentOffset = contentOffset; // Update content offset
		}

		if ([document.pageNumber integerValue] != page) // Only if different
		{
			document.pageNumber = [NSNumber numberWithInteger:page]; // Update page number
		}

		NSURL *fileURL = document.fileURL; NSString *phrase = document.password; NSString *guid = document.guid;

		if ([newPageSet containsIndex:page] == YES) // Preview visible pag4 e first
		{
			NSNumber *key = [NSNumber numberWithInteger:page]; // # key

			ReaderContentView *targetView = [contentViews objectForKey:key];

			[targetView showPageThumb:fileURL page:page password:phrase guid:guid];

			[newPageSet removeIndex:page]; // Remove visible page from set
		}

		[newPageSet enumerateIndexesWithOptions:NSEnumerationReverse usingBlock: // Show previews
			^(NSUInteger number, BOOL *stop)
			{
				NSNumber *key = [NSNumber numberWithInteger:number]; // # key

				ReaderContentView *targetView = [contentViews objectForKey:key];

				[targetView showPageThumb:fileURL page:number password:phrase guid:guid];
			}
		];

		[newPageSet release], newPageSet = nil; // Release new page set

		[mainPagebar updatePagebar]; // Update the pagebar display

		[self updateToolbarBookmarkIcon]; // Update bookmark

		currentPage = page; // Track current page number
	}
    
    NSNumber *key = [NSNumber numberWithInteger:page]; 
    ReaderContentView *pageContentView = [contentViews objectForKey:key];
    
    
    //如果還在編輯模式則繼續編輯
    if(isEdit == YES){
        
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
            lastBrushSize = 18.0f; 
        }
        
        theScrollView.scrollEnabled = NO;
        pageContentView.scrollEnabled = NO;
        pageContentView.theContainerView.userInteractionEnabled = YES;  //讓觸碰事件可傳導到CathayCanvas
        pageContentView.canvasView.brushSize = lastBrushSize;
        pageContentView.canvasView.brushColor = lastBrushColor;   
        
        editToolBar.hidden = NO;
        [mainToolbar hideToolbar];
        
        [self.editToolBar setStatus:lastCanvasButton];
        if (lastCanvasButton == 2) {
            pageContentView.canvasView.isHighlight = YES;
        }
        
        WKVerticalScrollBar *_verticalScrollBar = (WKVerticalScrollBar *)[self.view viewWithTag:VERTICAL_SCROLL_TAG];
        [_verticalScrollBar setScrollView:pageContentView];

        
    }
    //else {
    //    [self.editToolBar resetStatus];
    //}
    
}

- (void)showDocument:(id)object
{
    #ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
    #endif

	[self updateScrollViewContentSize]; // Set content size

	[self showDocumentPage:[document.pageNumber integerValue]]; // Show

	document.lastOpen = [NSDate date]; // Update last opened date

	isVisible = YES; // iOS present modal bodge
}

#pragma mark UIViewController methods

- (id)initWithReaderDocument:(ReaderDocument *)object
{
    #ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
    #endif

	id reader = nil; // ReaderViewController object

	if ((object != nil) && ([object isKindOfClass:[ReaderDocument class]]))
	{
		if ((self = [super initWithNibName:nil bundle:nil])) // Designated initializer
		{
			NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

			[notificationCenter addObserver:self selector:@selector(applicationWill:) name:UIApplicationWillTerminateNotification object:nil];

			[notificationCenter addObserver:self selector:@selector(applicationWill:) name:UIApplicationWillResignActiveNotification object:nil];
            
            [notificationCenter addObserver:self selector:@selector(applicationWill:) name:UIApplicationDidEnterBackgroundNotification object:nil];
            
             //註冊接收 縮至背景通知
          //  [notificationCenter addObserver:self selector:@selector(enteredBackground:)                                        name:@"didEnterBackground"  object:nil];

			[object updateProperties]; document = [object retain]; // Retain the supplied ReaderDocument object for our use

			[ReaderThumbCache touchThumbCacheWithGUID:object.guid]; // Touch the document thumb cache

			reader = self; // Return an initialized ReaderViewController object
            
		}
	}

	return reader;
}

/*
- (void)loadView
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	// Implement loadView to create a view hierarchy programmatically, without using a nib.
}
*/

- (void)viewDidLoad
{
    #ifdef DEBUGX
	NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(self.view.bounds));
    #endif

	[super viewDidLoad];
    
    //取得資料庫實體...
    dao = [BookShelfDAO sharedDAO];

	NSAssert(!(document == nil), @"ReaderDocument == nil");

	assert(self.splitViewController == nil); // Not supported (sorry)

	self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];

	CGRect viewRect = self.view.bounds; // View controller's view bounds

	//theScrollView = [[UIScrollView alloc] initWithFrame:viewRect]; // All
    //因為上方tool bar固定常駐  故把空間留出來
    theScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,TOOLBAR_HEIGHT, self.view.bounds.size.width, self.view.bounds.size.height-TOOLBAR_HEIGHT)];
	theScrollView.scrollsToTop = NO;
	theScrollView.pagingEnabled = YES;
	theScrollView.delaysContentTouches = NO;
	theScrollView.showsVerticalScrollIndicator = NO;
	theScrollView.showsHorizontalScrollIndicator = NO;
	theScrollView.contentMode = UIViewContentModeRedraw;
	theScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	theScrollView.backgroundColor = [UIColor clearColor];
	theScrollView.userInteractionEnabled = YES;
	theScrollView.autoresizesSubviews = NO;
	theScrollView.delegate = self;
    
	[self.view addSubview:theScrollView];

	CGRect toolbarRect = viewRect;
	toolbarRect.size.height = TOOLBAR_HEIGHT;

	mainToolbar = [[ReaderMainToolbar alloc] initWithFrame:toolbarRect document:document]; // At top
    
	mainToolbar.delegate = self;

	[self.view addSubview:mainToolbar];

	CGRect pagebarRect = viewRect;
	pagebarRect.size.height = PAGEBAR_HEIGHT;
	pagebarRect.origin.y = (viewRect.size.height - PAGEBAR_HEIGHT);

	mainPagebar = [[ReaderMainPagebar alloc] initWithFrame:pagebarRect document:document]; // At bottom

	mainPagebar.delegate = self;

	[self.view addSubview:mainPagebar];

	UITapGestureRecognizer *singleTapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
	singleTapOne.numberOfTouchesRequired = 1; singleTapOne.numberOfTapsRequired = 1; singleTapOne.delegate = self;

	UITapGestureRecognizer *doubleTapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
	doubleTapOne.numberOfTouchesRequired = 1; doubleTapOne.numberOfTapsRequired = 2; doubleTapOne.delegate = self;

	UITapGestureRecognizer *doubleTapTwo = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
	doubleTapTwo.numberOfTouchesRequired = 2; doubleTapTwo.numberOfTapsRequired = 2; doubleTapTwo.delegate = self;

	[singleTapOne requireGestureRecognizerToFail:doubleTapOne]; // Single tap requires double tap to fail

	[self.view addGestureRecognizer:singleTapOne]; [singleTapOne release];
	[self.view addGestureRecognizer:doubleTapOne]; [doubleTapOne release];
	[self.view addGestureRecognizer:doubleTapTwo]; [doubleTapTwo release];
    
    //資料初始
	contentViews = [NSMutableDictionary new]; 
    lastHideTime = [NSDate new];
    eraserEnable = NO;
    
    //編輯功能列
    self.editToolBar = [[CathayCanvasToolBar alloc]initWithFrame:CGRectMake(0, 0, theScrollView.bounds.size.width, 45)];
    editToolBar.delegate = self;
    editToolBar.hidden = YES;
    [self.view addSubview:editToolBar];

    
    if (self.pageStrokeDict == nil) {
        pageStrokeDict = [NSMutableDictionary new];
    }
    
    if (self.penDic == nil) {
        lastCanvasButton = 1;
        normalpenLastBrushSize = 2.0f;
        normalpenLastBrushColor = [UIColor redColor];
        lightpenLastBrushSize = 13.0f;
        lightpenLastBrushColor = [UIColor yellowColor];
        
    }else {
        
        lastCanvasButton = [[self.penDic objectForKey:@"lastCanvasButton"]intValue];
        //NSLog(@"lastCanvasButton : %d",lastCanvasButton);
        [self.editToolBar setStatus:lastCanvasButton];
    
        normalpenLastBrushSize =  [[self.penDic objectForKey:@"normalpenLastBrushSize"]floatValue];
        normalpenLastBrushColor = [self.penDic objectForKey:@"normalpenLastBrushColor"];
        lightpenLastBrushSize = [[self.penDic objectForKey:@"lightpenLastBrushSize"]floatValue];
        lightpenLastBrushColor = [self.penDic objectForKey:@"lightpenLastBrushColor"];
        
    }
    
    //簡單換頁列
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
			[self updateScrollViewContentViews]; // Update content views
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

	if (CGSizeEqualToSize(theScrollView.contentSize, CGSizeZero)) // First time
	{
		[self performSelector:@selector(showDocument:) withObject:nil afterDelay:0.02];
	}

    #if (READER_DISABLE_IDLE == TRUE) // Option

	[UIApplication sharedApplication].idleTimerDisabled = YES;

    #endif // end of READER_DISABLE_IDLE Option
}

- (void)viewWillDisappear:(BOOL)animated
{
    #ifdef DEBUGX
	NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(self.view.bounds));
    #endif

	[super viewWillDisappear:animated];

	lastAppearSize = self.view.bounds.size; // Track view size

    #if (READER_DISABLE_IDLE == TRUE) // Option

	[UIApplication sharedApplication].idleTimerDisabled = NO;

    #endif // end of READER_DISABLE_IDLE Option
}

- (void)viewDidDisappear:(BOOL)animated
{
    #ifdef DEBUGX
	NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(self.view.bounds));
    #endif

	[super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    #ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
    #endif

	[mainToolbar release], mainToolbar = nil; 
    [editToolBar release]; editToolBar =nil;    
    [mainPagebar release], mainPagebar = nil;
	[theScrollView release], theScrollView = nil; 
    [contentViews release], contentViews = nil;
	[lastHideTime release], lastHideTime = nil; 
    self.colorPopoverController = nil;
    self.sizePopoverController = nil;
    self.caculatorPopoverController = nil;
    self.pageStrokeDict = nil;
    self.penDic = nil;
    lastAppearSize = CGSizeZero; 
    currentPage = 0;
    
	[super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    #ifdef DEBUGX
	NSLog(@"%s (%d)", __FUNCTION__, interfaceOrientation);
    #endif

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

	if (isVisible == NO) return; // iOS present modal bodge

	[self updateScrollViewContentViews]; // Update content views

	lastAppearSize = CGSizeZero; // Reset view size tracking
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    #ifdef DEBUGX
	NSLog(@"%s %@ (%d to %d)", __FUNCTION__, NSStringFromCGRect(self.view.bounds), fromInterfaceOrientation, self.interfaceOrientation);
    #endif

	//if (isVisible == NO) return; // iOS present modal bodge

	//if (fromInterfaceOrientation == self.interfaceOrientation) return;
    
    NSInteger page = [document.pageNumber integerValue]; // Current page #
    NSNumber *key = [NSNumber numberWithInteger:page]; 
    ReaderContentView *pageContentView = [contentViews objectForKey:key];
    
    WKVerticalScrollBar *_verticalScrollBar = (WKVerticalScrollBar *)[self.view viewWithTag:VERTICAL_SCROLL_TAG];
    _verticalScrollBar.frame = CGRectMake(pageContentView.frame.size.width-VERTICAL_SCROLL_BAR_WIDTH, TOOLBAR_HEIGHT, VERTICAL_SCROLL_BAR_WIDTH, self.view.bounds.size.height-TOOLBAR_HEIGHT);

}

- (void)didReceiveMemoryWarning
{
    #ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
    #endif

	[super didReceiveMemoryWarning];
}

- (void)dealloc
{
    #ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
    #endif

	[[NSNotificationCenter defaultCenter] removeObserver:self];
    ((AppDelegate *)[UIApplication sharedApplication].delegate).currentPresentedModalViewController = nil;
    
	[mainToolbar release], mainToolbar = nil; 
    [editToolBar release]; editToolBar =nil;        
    [mainPagebar release], mainPagebar = nil;
	[theScrollView release], theScrollView = nil; 
    [contentViews release], contentViews = nil;
    [pageStrokeDict release], pageStrokeDict = nil;
    [penDic release],penDic = nil;
	[lastHideTime release], lastHideTime = nil; 
    [document release], document = nil;
    [colorPopoverController release];
    [sizePopoverController release];
    [caculatorPopoverController release];
    [noteid release];
    [noteTitle release];
    
	[super dealloc];
}

#pragma mark UIScrollViewDelegate methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	__block NSInteger page = 0;

	CGFloat contentOffsetX = scrollView.contentOffset.x;

	[contentViews enumerateKeysAndObjectsUsingBlock: // Enumerate content views
		^(id key, id object, BOOL *stop)
		{
			ReaderContentView *contentView = object;

			if (contentView.frame.origin.x == contentOffsetX)
			{
				page = contentView.tag; *stop = YES;
			}
		}
	];

	if (page != 0) [self showDocumentPage:page]; // Show the page
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[self showDocumentPage:theScrollView.tag]; // Show page

	theScrollView.tag = 0; // Clear page number tag
}

#pragma mark UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)recognizer shouldReceiveTouch:(UITouch *)touch
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	if ([touch.view isKindOfClass:[UIScrollView class]]) return YES;

	return NO;
}

#pragma mark UIGestureRecognizer action methods

- (void)decrementPageNumber
{
    #ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
    #endif

	if (theScrollView.tag == 0) // Scroll view did end
	{
		NSInteger page = [document.pageNumber integerValue];
		NSInteger maxPage = [document.pageCount integerValue];
		NSInteger minPage = 1; // Minimum

		if ((maxPage > minPage) && (page != minPage))
		{
			CGPoint contentOffset = theScrollView.contentOffset;

			contentOffset.x -= theScrollView.bounds.size.width; // -= 1

			[theScrollView setContentOffset:contentOffset animated:YES];

			theScrollView.tag = (page - 1); // Decrement page number
		}
	}
}

- (void)incrementPageNumber
{
    #ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
    #endif

	if (theScrollView.tag == 0) // Scroll view did end
	{
		NSInteger page = [document.pageNumber integerValue];
		NSInteger maxPage = [document.pageCount integerValue];
		NSInteger minPage = 1; // Minimum

		if ((maxPage > minPage) && (page != maxPage))
		{
			CGPoint contentOffset = theScrollView.contentOffset;

			contentOffset.x += theScrollView.bounds.size.width; // += 1

			[theScrollView setContentOffset:contentOffset animated:YES];

			theScrollView.tag = (page + 1); // Increment page number
		}
	}
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    //NSLog(@"handleSingleTap mainPagebar.hidden: %@",(mainPagebar.hidden ? @"YES" : @"NO"));
    //NSLog(@"ReaderViewControler  handleSingleTap");

    #ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
    #endif

    //當處於編輯模式時，不允許換頁
    if (editToolBar.hidden==NO) {
        return;
    }
    
	if (recognizer.state == UIGestureRecognizerStateRecognized)
	{
		CGRect viewRect = recognizer.view.bounds; // View bounds

		CGPoint point = [recognizer locationInView:recognizer.view];

		CGRect areaRect = CGRectInset(viewRect, TAP_AREA_SIZE, 0.0f); // Area

		if (CGRectContainsPoint(areaRect, point)) // Single tap is inside the area
		{
			NSInteger page = [document.pageNumber integerValue]; // Current page #

			NSNumber *key = [NSNumber numberWithInteger:page]; // Page number key

			ReaderContentView *targetView = [contentViews objectForKey:key];

			id target = [targetView singleTap:recognizer]; // Process tap

			if (target != nil) // Handle the returned target object
			{
				if ([target isKindOfClass:[NSURL class]]) // Open a URL
				{
					NSURL *url = (NSURL *)target; // Cast to a NSURL object
                    
					if (url.scheme == nil) // Handle a missing URL scheme
					{
						NSString *www = url.absoluteString; // Get URL string
                        
						if ([www hasPrefix:@"www"] == YES) // Check for 'www' prefix
						{
							NSString *http = [NSString stringWithFormat:@"http://%@", www];
                            
							url = [NSURL URLWithString:http]; // Proper http-based URL
						}
					}
                    
					if ([[UIApplication sharedApplication] openURL:url] == NO)
					{
#ifdef DEBUG
                        NSLog(@"%s '%@'", __FUNCTION__, url); // Bad or unknown URL
#endif
					}
				}

				else // Not a URL, so check for other possible object type
				{
					if ([target isKindOfClass:[NSNumber class]]) // Goto page
					{
						NSInteger value = [target integerValue]; // Number

						[self showDocumentPage:value]; // Show the page
					}
				}
			}
			else // Nothing active tapped in the target content view
			{
				if ([lastHideTime timeIntervalSinceNow] < -0.5) // Delay since hide
				{
					
                    //if ((mainToolbar.hidden == YES) || (mainPagebar.hidden == YES))
                    if ((mainPagebar.hidden == YES))
					{
						//[mainToolbar showToolbar]; 
                        [mainPagebar showPagebar]; // Show
					}
				}
			}

			return;
		}
        
        /////////////////////////////
        //上下頁區塊處理，左右兩邊的空間處
		CGRect nextPageRect = viewRect;
		nextPageRect.size.width = TAP_AREA_SIZE;
		nextPageRect.origin.x = (viewRect.size.width - TAP_AREA_SIZE);

		if (CGRectContainsPoint(nextPageRect, point)) // page++ area
		{
			[self incrementPageNumber]; return;
		}

		CGRect prevPageRect = viewRect;
		prevPageRect.size.width = TAP_AREA_SIZE;

		if (CGRectContainsPoint(prevPageRect, point)) // page-- area
		{
			[self decrementPageNumber]; return;
		}
	}
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer
{
    
    //NSLog(@"ReaderViewControler  handleDoubleTap");
    
    #ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
    #endif

    //當處於編輯模式時，不允許動作
    if (editToolBar.hidden==NO) {
        return;
    }
    
	if (recognizer.state == UIGestureRecognizerStateRecognized)
	{
		CGRect viewRect = recognizer.view.bounds; // View bounds

		CGPoint point = [recognizer locationInView:recognizer.view];

		CGRect zoomArea = CGRectInset(viewRect, TAP_AREA_SIZE, TAP_AREA_SIZE);

		if (CGRectContainsPoint(zoomArea, point)) // Double tap is in the zoom area
		{
			NSInteger page = [document.pageNumber integerValue]; // Current page #

			NSNumber *key = [NSNumber numberWithInteger:page]; // Page number key

			ReaderContentView *targetView = [contentViews objectForKey:key];

			switch (recognizer.numberOfTouchesRequired) // Touches count
			{
				case 1: // One finger double tap: zoom ++
				{
					[targetView zoomIncrement]; break;
				}

				case 2: // Two finger double tap: zoom --
				{
					[targetView zoomDecrement]; break;
				}
			}

			return;
		}

		CGRect nextPageRect = viewRect;
		nextPageRect.size.width = TAP_AREA_SIZE;
		nextPageRect.origin.x = (viewRect.size.width - TAP_AREA_SIZE);

		if (CGRectContainsPoint(nextPageRect, point)) // page++ area
		{
			[self incrementPageNumber]; return;
		}

		CGRect prevPageRect = viewRect;
		prevPageRect.size.width = TAP_AREA_SIZE;

		if (CGRectContainsPoint(prevPageRect, point)) // page-- area
		{
			[self decrementPageNumber]; return;
		}
	}
}

#pragma mark ReaderContentViewDelegate methods

- (void)contentView:(ReaderContentView *)contentView touchesBegan:(NSSet *)touches
{
    #ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
    #endif
    
 //   NSLog(@"touchesBegan mainPagebar.hidden: %@",(mainPagebar.hidden ? @"YES" : @"NO"));
    
    if (editToolBar.hidden == NO) {
        //do nothing
    }
	//else if ((mainToolbar.hidden == NO) || (mainPagebar.hidden == NO))
    else if ((mainPagebar.hidden == NO))
	{
		if (touches.count == 1) // Single touches only
		{
			UITouch *touch = [touches anyObject]; // Touch info

			CGPoint point = [touch locationInView:self.view]; // Touch location

			CGRect areaRect = CGRectInset(self.view.bounds, TAP_AREA_SIZE, TAP_AREA_SIZE);

			if (CGRectContainsPoint(areaRect, point) == false) return;
		}

		//[mainToolbar hideToolbar]; 
        [mainPagebar hidePagebar]; // Hide

		[lastHideTime release]; lastHideTime = [NSDate new];
	}
}

#pragma mark ReaderMainToolbarDelegate methods

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar doneButton:(UIButton *)button
{
    #ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
    #endif

    #if (READER_STANDALONE == FALSE) // Option

	[document saveReaderDocument]; // Save any ReaderDocument object changes

	[[ReaderThumbQueue sharedInstance] cancelOperationsWithGUID:document.guid];

	[[ReaderThumbCache sharedInstance] removeAllObjects]; // Empty the thumb cache
    
    //當筆跡軌跡不為空時，存檔
    if([pageStrokeDict count] != 0){
        
        NSMutableData *data = [[NSMutableData alloc]init];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
        
        NSString *dataPath = [[[[CathayFileHelper getDocumentPath]stringByAppendingPathComponent:[dao getUserID]]stringByAppendingPathComponent:@"PDF"]stringByAppendingPathComponent:document.bookid];
       // NSLog(@"dataPath : %@",dataPath );
       // NSLog(@"pageStrokeDict : %@",pageStrokeDict);

        [archiver encodeObject:pageStrokeDict forKey:@"pageStrokeDict"];
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
        
        NSString *pendataPath = [[[CathayFileHelper getDocumentPath]stringByAppendingPathComponent:@"mailTMP"]stringByAppendingPathComponent:@"pendata"];
        
        [archiver2 encodeObject:penDict forKey:@"pendata"];
        [archiver2 finishEncoding];
        [data2 writeToFile:pendataPath atomically:YES];
        [archiver2 release];                      
        [data2 release];
        [penDict release];
        
    }else {
    //筆跡為空時，判斷是否舊有資料還在，若有需清除    
        
        
        NSString *dataPath = [[[[CathayFileHelper getDocumentPath]stringByAppendingPathComponent:[dao getUserID]]stringByAppendingPathComponent:@"PDF"]stringByAppendingPathComponent:document.bookid];

          BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:dataPath];
          if (fileExists) {
                [CathayFileHelper deleteItem:dataPath];
           }
    }
    

	if (printInteraction != nil) [printInteraction dismissAnimated:NO]; // Dismiss

	if ([delegate respondsToSelector:@selector(dismissReaderViewController:)] == YES)
	{
		[delegate dismissReaderViewController:self]; // Dismiss the ReaderViewController
	}
	else // We have a "Delegate must respond to -dismissReaderViewController: error"
	{
		[self dismissModalViewControllerAnimated:YES];
        
	}

    #endif // end of READER_STANDALONE Option
}

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar thumbsButton:(UIButton *)button
{
    #ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
    #endif

	if (printInteraction != nil) [printInteraction dismissAnimated:NO]; // Dismiss

	ThumbsViewController *thumbsViewController = [[ThumbsViewController alloc] initWithReaderDocument:document];

	thumbsViewController.delegate = self; thumbsViewController.title = self.title;

	thumbsViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	thumbsViewController.modalPresentationStyle = UIModalPresentationFullScreen;

	[self presentModalViewController:thumbsViewController animated:NO];

	[thumbsViewController release]; // Release ThumbsViewController
}

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar printButton:(UIButton *)button
{
    #ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
    #endif

    #if (READER_ENABLE_PRINT == TRUE) // Option

	Class printInteractionController = NSClassFromString(@"UIPrintInteractionController");

	if ((printInteractionController != nil) && [printInteractionController isPrintingAvailable])
	{
		NSURL *fileURL = document.fileURL; // Document file URL

		printInteraction = [printInteractionController sharedPrintController];

		if ([printInteractionController canPrintURL:fileURL] == YES) // Check first
		{
			UIPrintInfo *printInfo = [NSClassFromString(@"UIPrintInfo") printInfo];

			printInfo.duplex = UIPrintInfoDuplexLongEdge;
			printInfo.outputType = UIPrintInfoOutputGeneral;
			printInfo.jobName = document.fileName;

			printInteraction.printInfo = printInfo;
			printInteraction.printingItem = fileURL;
			printInteraction.showsPageRange = YES;

			if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
			{
				[printInteraction presentFromRect:button.bounds inView:button animated:YES completionHandler:
					^(UIPrintInteractionController *pic, BOOL completed, NSError *error)
					{
						#ifdef DEBUG
							if ((completed == NO) && (error != nil)) NSLog(@"%s %@", __FUNCTION__, error);
						#endif
					}
				];
			}
			else // Presume UIUserInterfaceIdiomPhone
			{
				[printInteraction presentAnimated:YES completionHandler:
					^(UIPrintInteractionController *pic, BOOL completed, NSError *error)
					{
						#ifdef DEBUG
							if ((completed == NO) && (error != nil)) NSLog(@"%s %@", __FUNCTION__, error);
						#endif
					}
				];
			}
		}
	}

    #endif // end of READER_ENABLE_PRINT Option
}

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar emailButton:(UIButton *)button
{
    #ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
    #endif    
    
    #if (READER_ENABLE_MAIL == TRUE) // Option

	if ([MFMailComposeViewController canSendMail] == NO) return;

	if (printInteraction != nil) [printInteraction dismissAnimated:YES];
    
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil
                                                        delegate:self
                                               cancelButtonTitle:nil
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:@"Email此頁", @"Email完整文件",
                             @"Email此頁(不含筆跡)",@"Email完整文件(不含筆跡)", nil];
    
    //將selectedIndex放進Action供取出book資料
    action.tag = ACTION_EMAIL_TAG;
    
    //present the popover view non-modal with a
    //refrence to the button pressed within the current view
    CGRect popoverRect = [self.view convertRect:[button frame] 
                                       fromView:[button superview]];
    
    popoverRect.size.width = MIN(popoverRect.size.width, 200); 
    
    [action showFromRect:popoverRect inView:self.view animated:YES];
    [action release];
    
    #endif // end of READER_ENABLE_MAIL Option
}

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar markButton:(UIButton *)button
{
    #ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
    #endif

	if (printInteraction != nil) [printInteraction dismissAnimated:YES];

	NSInteger page = [document.pageNumber integerValue];

	if ([document.bookmarks containsIndex:page])
	{
		[mainToolbar setBookmarkState:NO];

		[document.bookmarks removeIndex:page];
	}
	else // Add the bookmarked page index
	{
		[mainToolbar setBookmarkState:YES];

		[document.bookmarks addIndex:page];
	}
    
}

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar noteButton:(UIButton *)button
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
    NoteViewController *noteViewController = [[NoteViewController alloc] initWithBookID:noteid];
    noteViewController.delegate = self;
    noteViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    noteViewController.bookTitle = noteTitle;
    
    //若原存有筆記資料，要把筆記資料加回    
    NSString *dataPath = [[[[CathayFileHelper getDocumentPath]stringByAppendingPathComponent:[dao getUserID]]stringByAppendingPathComponent:@"PDF"]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_NOTE",noteid]];
        
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:dataPath];
    if (fileExists) {
        NSData *data = [[NSData alloc]initWithContentsOfFile:dataPath];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
        noteViewController.pageStrokeDict = [unarchiver decodeObjectForKey:@"pageStrokeDict"];
        
        noteViewController.currentPage = [[unarchiver decodeObjectForKey:@"currentPage"] intValue];
                
        [unarchiver finishDecoding];
        [unarchiver release];
        [data release];
    }
    
    //若原存有筆的使用資料，要設成最後使用狀態    
    NSString *pendataPath = [[[CathayFileHelper getDocumentPath]stringByAppendingPathComponent:@"mailTMP"]stringByAppendingPathComponent:@"pendata_NOTE"];
    BOOL penfileExists = [[NSFileManager defaultManager] fileExistsAtPath:pendataPath];
    if (penfileExists) {
        NSData *data = [[NSData alloc]initWithContentsOfFile:pendataPath];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
        noteViewController.penDic = [unarchiver decodeObjectForKey:@"pendata"];
        
        [unarchiver finishDecoding];
        [unarchiver release];
        [data release];
    }
    
    [self presentModalViewController:noteViewController animated:NO];
     
    [noteViewController release]; 
    
}


- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar editButton:(UIButton *)button {
    
    //NSLog(@"tappedInToolbar editButton");
    
    isEdit = TRUE;

    NSInteger page = [document.pageNumber integerValue]; // Current page #
    NSNumber *key = [NSNumber numberWithInteger:page]; 
    ReaderContentView *pageContentView = [contentViews objectForKey:key];

    //加入自定垂直scrollBar
    WKVerticalScrollBar *_verticalScrollBar = [[WKVerticalScrollBar alloc] initWithFrame:CGRectMake(pageContentView.frame.size.width-VERTICAL_SCROLL_BAR_WIDTH, TOOLBAR_HEIGHT, VERTICAL_SCROLL_BAR_WIDTH, self.view.bounds.size.height-TOOLBAR_HEIGHT)];
    [_verticalScrollBar setScrollView:pageContentView];
    _verticalScrollBar.tag = VERTICAL_SCROLL_TAG;
    
    [self.view insertSubview:_verticalScrollBar belowSubview:mainPagebar];
    [_verticalScrollBar release];

    
    //開啟繪圖能力
    theScrollView.scrollEnabled = NO;
    pageContentView.scrollEnabled = NO;
    pageContentView.theContainerView.userInteractionEnabled = YES;  //讓觸碰事件可傳導到CathayCanvas
    
    if (lastCanvasButton == 2) {
        [self.editToolBar setStatus:lastCanvasButton];
        pageContentView.canvasView.isHighlight = YES;
    }
    
    editToolBar.hidden = NO;
    [mainToolbar hideToolbar];
    [mainPagebar showPagebar];//為確認繪圖時可換頁，故特別開啟換頁bar
   // [mainPagebar hidePagebar];
    
}


- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar exportButton:(UIButton *)button {
    
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil
                                                        delegate:self
                                               cancelButtonTitle:nil
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:@"另存此頁", @"另存完整文件", nil];
    
    //將selectedIndex放進Action供取出book資料
    action.tag = ACTION_EXPORT_TAG;
    
    //present the popover view non-modal with a
    //refrence to the button pressed within the current view
    CGRect popoverRect = [self.view convertRect:[button frame] 
                                       fromView:[button superview]];
    
    popoverRect.size.width = MIN(popoverRect.size.width, 200); 
    
    [action showFromRect:popoverRect inView:self.view animated:YES];
    [action release];

}


-(void) tappedInToolbar:(ReaderMainToolbar *)toolbar calculatorButton:(UIButton *)button {
    
    int caculatorViewTag = 862;
    
    if ([self.view viewWithTag:caculatorViewTag]==nil) {
        CathayCalculatorView *calculatorView = [[CathayCalculatorView alloc]caculator];
        calculatorView.tag = caculatorViewTag;
        calculatorView.delegate = self;
        
        //增加拖移能力
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [panRecognizer setMinimumNumberOfTouches:1];
        [panRecognizer setMaximumNumberOfTouches:1];
        //[panRecognizer setDelegate:self];
        [calculatorView addGestureRecognizer:panRecognizer];
        [panRecognizer release];
        
        [self.view addSubview:calculatorView];
        [calculatorView release];
    }else {
        [[self.view viewWithTag:caculatorViewTag] removeFromSuperview];
    }
}

#pragma mark CathayCanvasToolbarDelegate methods

- (void)tappedInCanvasToolBar:(CathayCanvasToolBar *)toolbar undoButton:(UIButton *)button{
    NSInteger page = [document.pageNumber integerValue]; // Current page #
    NSNumber *key = [NSNumber numberWithInteger:page]; 
    ReaderContentView *pageContentView = [contentViews objectForKey:key];
    [pageContentView.canvasView undo];
}

- (void)tappedInCanvasToolBar:(CathayCanvasToolBar *)toolbar redoButton:(UIButton *)button{
    NSInteger page = [document.pageNumber integerValue]; // Current page #
    NSNumber *key = [NSNumber numberWithInteger:page]; 
    ReaderContentView *pageContentView = [contentViews objectForKey:key];
    [pageContentView.canvasView redo];
}

- (void)tappedInCanvasToolBar:(CathayCanvasToolBar *)toolbar finishButton:(UIButton *)button{

    NSInteger page = [document.pageNumber integerValue]; // Current page #
    NSNumber *key = [NSNumber numberWithInteger:page]; 
    ReaderContentView *pageContentView = [contentViews objectForKey:key];
    
    //關閉繪圖能力
    theScrollView.scrollEnabled = YES;
    pageContentView.scrollEnabled = YES;
    pageContentView.theContainerView.userInteractionEnabled = NO;  
    
    //將使用者繪製資訊寫入全域
    NSMutableArray *_drawDataArray= [pageContentView.canvasView.drawDataArray mutableCopy];
    [self.pageStrokeDict setObject:_drawDataArray forKey:key];
    [_drawDataArray release];

    editToolBar.hidden = YES;
  //  [mainPagebar hidePagebar];
    [mainToolbar showToolbar];
    isEdit = FALSE;
    
    //將vertical scroll去除
    [[self.view viewWithTag:VERTICAL_SCROLL_TAG]removeFromSuperview];
}

- (void)tappedInCanvasToolBar:(CathayCanvasToolBar *)toolbar normalPenButton:(UIButton *)button{

    eraserEnable = NO;
    
    NSInteger page = [document.pageNumber integerValue]; // Current page #
    NSNumber *key = [NSNumber numberWithInteger:page]; 
    ReaderContentView *pageContentView = [contentViews objectForKey:key];
    pageContentView.canvasView.isHighlight = NO;
    
    //還原原本畫筆大小及顏色
    if (normalpenLastBrushColor) {
        pageContentView.canvasView.brushSize = normalpenLastBrushSize;    
        pageContentView.canvasView.brushColor = normalpenLastBrushColor;    
    }
    
    lastCanvasButton = 1; //設定最後一次的PenButton
    
}

- (void)tappedInCanvasToolBar:(CathayCanvasToolBar *)toolbar lightPenButton:(UIButton *)button{

    eraserEnable = NO;    
    
    NSInteger page = [document.pageNumber integerValue]; // Current page #
    NSNumber *key = [NSNumber numberWithInteger:page]; 
    ReaderContentView *pageContentView = [contentViews objectForKey:key];
    pageContentView.canvasView.isHighlight = YES;
    
    //還原原本畫筆大小及顏色    
    if (lightpenLastBrushColor) {
        pageContentView.canvasView.brushSize = lightpenLastBrushSize;    
        pageContentView.canvasView.brushColor = lightpenLastBrushColor;
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
        
        NSInteger page = [document.pageNumber integerValue]; // Current page #
        NSNumber *key = [NSNumber numberWithInteger:page]; 
        ReaderContentView *pageContentView = [contentViews objectForKey:key];
 //       lastBrushSize = pageContentView.canvasView.brushSize; //暫存原本畫筆尺寸，供待會兒還原
 //       lastBrushColor = pageContentView.canvasView.brushColor;
        pageContentView.canvasView.brushSize = 18.0f;   //橡皮擦大小
        pageContentView.canvasView.brushColor = [UIColor clearColor];


    }

      
    
}

/*
- (void)tappedInCanvasToolBar:(CathayCanvasToolBar *)toolbar caculatorButton:(UIButton *)button{
    
    int caculatorViewTag = 862;
    
    if ([self.view viewWithTag:caculatorViewTag]==nil) {
        CathayCalculatorView *calculatorView = [[CathayCalculatorView alloc]caculator];
        calculatorView.tag = caculatorViewTag;
        calculatorView.delegate = self;
        
        //增加拖移能力
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [panRecognizer setMinimumNumberOfTouches:1];
        [panRecognizer setMaximumNumberOfTouches:1];
        //[panRecognizer setDelegate:self];
        [calculatorView addGestureRecognizer:panRecognizer];
        [panRecognizer release];
        
        [self.view addSubview:calculatorView];
        [calculatorView release];
    }
    
}
*/

- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer {
    
    // Comment for panning
    // Uncomment for tickling
    //return;
    
    CGPoint translation = [recognizer translationInView:self.view];
    
    //取得中心點
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x, 
                                         recognizer.view.center.y + translation.y);
    //歸零
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        CGPoint velocity = [recognizer velocityInView:self.view];   //速率
        CGFloat magnitude = sqrtf((velocity.x * velocity.x) + (velocity.y * velocity.y));
        CGFloat slideMult = magnitude / 200;
        //NSLog(@"magnitude: %f, slideMult: %f", magnitude, slideMult);
        
        float slideFactor = 0.1 * slideMult; // Increase for more of a slide
        CGPoint finalPoint = CGPointMake(recognizer.view.center.x + (velocity.x * slideFactor), 
                                         recognizer.view.center.y + (velocity.y * slideFactor));
        finalPoint.x = MIN(MAX(finalPoint.x, 0), self.view.bounds.size.width);
        finalPoint.y = MIN(MAX(finalPoint.y, 0), self.view.bounds.size.height);
        
        [UIView animateWithDuration:slideFactor*2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            recognizer.view.center = finalPoint;
        } completion:nil];
        
    }
    
}

#pragma mark CathayCalculatorViewDelegate

- (void)removeCalculatorView:(CathayCalculatorView *)calculatorView {
    
    [calculatorView removeFromSuperview];
    
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

            NSInteger page = [document.pageNumber integerValue]; // Current page #
            NSNumber *key = [NSNumber numberWithInteger:page]; 
            ReaderContentView *pageContentView = [contentViews objectForKey:key];
            [pageContentView.canvasView clearCanvas];
            
        }else if(buttonIndex == 2){
            
            //先把此頁清掉
            NSInteger page = [document.pageNumber integerValue]; // Current page #
            NSNumber *key = [NSNumber numberWithInteger:page]; 
            ReaderContentView *pageContentView = [contentViews objectForKey:key];
            [pageContentView.canvasView clearCanvas];

            //再把筆跡檔整個清空
            self.pageStrokeDict = [NSMutableDictionary new];
        
        }
        

    }else if(actionSheet.tag == ACTION_EXPORT_TAG) {
        
        NSInteger page = [document.pageNumber integerValue]; // Current page #
        NSURL *fileURL = document.fileURL; // Document file URL
        NSString *password = document.password;
        NSString *title = document.title;
        NSString *bookid = document.bookid;
        NSString *fileName = @"";
        NSRange onePagerange = [bookid rangeOfString:@"_exportOne"];
        NSRange range = [bookid rangeOfString:@"_export"];          
        
        CathayPDFGenerator *pdfGenerator = [[CathayPDFGenerator alloc] initWithURL:fileURL password:password pageStrokeData:pageStrokeDict];
        
        //確定是否為原稿匯出，or已是匯出版重新匯出
        if (buttonIndex == 0) {   
            if (onePagerange.length != 0) {
                fileName = [NSString stringWithFormat:@"%@.pdf", bookid];
            }else {
                fileName = [NSString stringWithFormat:@"%@_exportOne_p%d.pdf", bookid,page];
            }
        }else { 
            if (range.length != 0) {
                fileName = [NSString stringWithFormat:@"%@.pdf", bookid];
            }else {
                fileName = [NSString stringWithFormat:@"%@_export.pdf", bookid];
            }

        }
        
        NSString *filePath = [[[CathayFileHelper getDocumentPath]stringByAppendingPathComponent:@"PDF"]stringByAppendingPathComponent:fileName];
        
        #ifdef IS_DEBUG
        NSLog(@"準備匯出PDF至%@", filePath);
        #endif
        
        BOOL isOK = NO;

        //匯出此頁
        if (buttonIndex == 0) {

            NSInteger page = [document.pageNumber integerValue]; // Current page #
            isOK = [pdfGenerator generatePdfWithFilePath:filePath page:page]; 
            
            if(isOK){
#ifdef IS_DEBUG
                NSLog(@"匯出單頁PDF成功，把檔案資料寫回plist");
#endif
                
                //把匯出資訊寫回plist檔: BookID,Title,Updatetime,Order
                NSDate *updatetime = [NSDate date];
                
                //取得最後一份文件之Order
                NSMutableDictionary *documentsPlistDict = [self getDocumentsPlistDictUnderDoc];
                // NSLog(@"%@",documentsPlistDict);
                NSMutableDictionary *documentsDict = [documentsPlistDict objectForKey:@"Documents"];
                NSArray *sortedDocumentKeys =  [self sortedDicByKey:@"Order" dic:documentsDict ascending:YES];
                NSString *lastBookid = sortedDocumentKeys.lastObject;
                // NSLog(@"lastBookid : %@",lastBookid);
                
                NSMutableDictionary *dataDict = [documentsDict objectForKey:lastBookid];
                int order = [[dataDict objectForKey:@"Order"]intValue]+1;
                NSNumber *lastOrder = [NSNumber numberWithInt:order]; 
                // NSLog(@"目前這份文件的order: %@",lastOrder);
                
                NSMutableDictionary *_tempDic = [[NSMutableDictionary alloc]init];
                [_tempDic setObject:updatetime forKey:@"Updatetime"];
                [_tempDic setObject:lastOrder forKey:@"Order"];
                
                if (onePagerange.length != 0) {
                    //已有匯出檔
#ifdef IS_DEBUG
               NSLog(@"已有匯出檔  BOOKID : %@ , TITLE : %@",bookid,title);
#endif
                    
                }else {
                    
#ifdef IS_DEBUG
               NSLog(@"BOOKID : %@ , TITLE : %@",[NSString stringWithFormat:@"%@_exportOne",bookid],[NSString stringWithFormat:@"%@_exportOne",title]);
#endif
                    bookid = [NSString stringWithFormat:@"%@_exportOne_p%d",bookid,page];
                    title = [NSString stringWithFormat:@"%@_exportOne_p%d",title,page];
                }
                
                [_tempDic setObject:bookid forKey:@"BookID"];
                [_tempDic setObject:title forKey:@"Title"];
                
                [documentsDict setObject:_tempDic forKey:bookid];
                [documentsPlistDict setObject:documentsDict forKey:@"Documents"];
                
#ifdef IS_DEBUG
                NSLog(@"documentsPlistDict : %@",documentsPlistDict);
#endif                
                [self writeDocumentsPlistDictToDoc:documentsPlistDict];
                
                [_tempDic release];
                
            }

            
        //匯出完整文件
        }else if(buttonIndex == 1){
            
            isOK = [pdfGenerator generatePdfWithFilePath:filePath];
            
            if(isOK){
                #ifdef IS_DEBUG
                NSLog(@"匯出PDF成功，把檔案資料寫回plist");
                #endif
                
                //把匯出資訊寫回plist檔: BookID,Title,Updatetime,Order
                NSDate *updatetime = [NSDate date];
                
                //取得最後一份文件之Order
                NSMutableDictionary *documentsPlistDict = [self getDocumentsPlistDictUnderDoc];
                // NSLog(@"%@",documentsPlistDict);
                NSMutableDictionary *documentsDict = [documentsPlistDict objectForKey:@"Documents"];
                NSArray *sortedDocumentKeys =  [self sortedDicByKey:@"Order" dic:documentsDict ascending:YES];
                NSString *lastBookid = sortedDocumentKeys.lastObject;
                // NSLog(@"lastBookid : %@",lastBookid);
                
                NSMutableDictionary *dataDict = [documentsDict objectForKey:lastBookid];
                int order = [[dataDict objectForKey:@"Order"]intValue]+1;
                NSNumber *lastOrder = [NSNumber numberWithInt:order]; 
                // NSLog(@"目前這份文件的order: %@",lastOrder);
                
                NSMutableDictionary *_tempDic = [[NSMutableDictionary alloc]init];
                [_tempDic setObject:updatetime forKey:@"Updatetime"];
                [_tempDic setObject:lastOrder forKey:@"Order"];

                if (range.length != 0) {
                    //已有匯出檔
#ifdef IS_DEBUG
                NSLog(@"已有匯出檔  BOOKID : %@ , TITLE : %@",bookid,title);
#endif

                }else {
                    
#ifdef IS_DEBUG
                NSLog(@"BOOKID : %@ , TITLE : %@",[NSString stringWithFormat:@"%@_export",bookid]
                ,[NSString stringWithFormat:@"%@_export",title]);
#endif
                    bookid = [NSString stringWithFormat:@"%@_export",bookid];
                    title = [NSString stringWithFormat:@"%@_export",title];
                }
                
                [_tempDic setObject:bookid forKey:@"BookID"];
                [_tempDic setObject:title forKey:@"Title"];
                
                [documentsDict setObject:_tempDic forKey:bookid];
                [documentsPlistDict setObject:documentsDict forKey:@"Documents"];
                
#ifdef IS_DEBUG
                NSLog(@"documentsPlistDict : %@",documentsPlistDict);
#endif                
                 [self writeDocumentsPlistDictToDoc:documentsPlistDict];

                [_tempDic release];
                              
            }
        }

        [pdfGenerator release];
        
        NSString *message = isOK?@"另存成功，檔案可於塗鴉本首頁查看":@"匯出失敗";
        UIAlertView *alert = [[UIAlertView alloc] 
                              initWithTitle: @"訊息" 
                              message:message
                              delegate:nil 
                              cancelButtonTitle:@"好" 
                              otherButtonTitles:nil];
        [alert show];
        [alert release];

    }else if(actionSheet.tag == ACTION_EMAIL_TAG) {
        
        //寄送email之前先匯檔出來至mailTMP下面
        
        NSURL *fileURL = document.fileURL; // Document file URL
        NSString *password = document.password;
        NSString *title = document.title;
        
        CathayPDFGenerator *pdfGenerator = [[CathayPDFGenerator alloc] initWithURL:fileURL password:password pageStrokeData:pageStrokeDict];
        CathayPDFGenerator *pdfGeneratorNoStroke = [[CathayPDFGenerator alloc] initWithURL:fileURL password:password pageStrokeData:nil];
        
        if (buttonIndex == 0 || buttonIndex == 2) {
            title = [NSString stringWithFormat:@"%@_p%d",title,[document.pageNumber intValue]];
        }

        NSString *filePath = [[[CathayFileHelper getDocumentPath]stringByAppendingPathComponent:@"mailTMP"]stringByAppendingPathComponent:title];
        
#ifdef IS_DEBUG
        NSLog(@"Email寄送 --- 準備匯出PDF至%@", filePath);
#endif

        BOOL isOK = NO;
        NSInteger page = [document.pageNumber integerValue]; // Current page #
        
        //Email此頁
        if (buttonIndex == 0) {
            isOK = [pdfGenerator generatePdfWithFilePath:filePath page:page]; 

        }else if (buttonIndex == 1)  {
        //Email整份文件    
            isOK = [pdfGenerator generatePdfWithFilePath:filePath];
            
        }else if (buttonIndex == 2)  {
        //Email此頁(不含筆跡)   
             isOK = [pdfGeneratorNoStroke generatePdfWithFilePath:filePath page:page];
            
        }else if (buttonIndex == 3)  {
        //Email整份文件(不含筆跡)   
             isOK = [pdfGeneratorNoStroke generatePdfWithFilePath:filePath];

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
        
        [pdfGenerator release];
        [pdfGeneratorNoStroke release];
        
        
        NSURL *fullFileURL =  [[NSURL alloc] initFileURLWithPath:filePath isDirectory:NO]; 
#ifdef IS_DEBUG
        NSLog(@"fullFileURL : %@",fullFileURL);
#endif
        
        unsigned long long fileSize = [document.fileSize unsignedLongLongValue];
        
        if (fileSize < (unsigned long long)15728640) // Check attachment size limit (15MB)
        {
            //	NSURL *fileURL = document.fileURL; NSString *fileName = document.fileName; // Document
            
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
        }
        
        [fullFileURL release];
    }
    
}

#pragma mark InfColorPickerControllerDelegate

- (void) colorPickerControllerDidChangeColor: (InfColorPickerController*) picker
{
    
    UIColor *lastBrushColor;
    
    if (eraserEnable) {
        lastBrushColor = picker.resultColor;
    }else {
        NSInteger page = [document.pageNumber integerValue]; // Current page #
        NSNumber *key = [NSNumber numberWithInteger:page]; 
        ReaderContentView *pageContentView = [contentViews objectForKey:key];
        pageContentView.canvasView.brushColor = picker.resultColor;
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
        NSInteger page = [document.pageNumber integerValue]; // Current page #
        NSNumber *key = [NSNumber numberWithInteger:page]; 
        ReaderContentView *pageContentView = [contentViews objectForKey:key];
        pageContentView.canvasView.brushSize = size;
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

#pragma mark ThumbsViewControllerDelegate methods

- (void)dismissThumbsViewController:(ThumbsViewController *)viewController
{
    #ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
    #endif

	[self updateToolbarBookmarkIcon]; // Update bookmark icon

	[self dismissModalViewControllerAnimated:NO]; // Dismiss
}

- (void)thumbsViewController:(ThumbsViewController *)viewController gotoPage:(NSInteger)page
{
    #ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
    #endif

	[self showDocumentPage:page]; // Show the page
}

#pragma mark ReaderMainPagebarDelegate methods

- (void)pagebar:(ReaderMainPagebar *)pagebar gotoPage:(NSInteger)page
{
    #ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
    #endif

    NSInteger nowpage = [document.pageNumber integerValue]; // Current page #
    NSNumber *key = [NSNumber numberWithInteger:nowpage]; 
    ReaderContentView *pageContentView = [contentViews objectForKey:key];

    //仍在編輯模式  儲存每頁軌跡
    if(isEdit == YES){
        NSMutableArray *_drawDataArray= [pageContentView.canvasView.drawDataArray mutableCopy];
        [self.pageStrokeDict setObject:_drawDataArray forKey:key];
        [_drawDataArray release];
    }    
    
	[self showDocumentPage:page]; // Show the page
}

#pragma mark UIApplication notification methods

- (void)applicationWill:(NSNotification *)notification
{
    #ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
    #endif

	[document saveReaderDocument]; // Save any ReaderDocument object changes

	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
	{
		if (printInteraction != nil) [printInteraction dismissAnimated:NO];
	}
    
    //仍在編輯模式  儲存每頁軌跡
    if(isEdit == YES){
        
        NSInteger page = [document.pageNumber integerValue]; // Current page #
        NSNumber *key = [NSNumber numberWithInteger:page]; 
        ReaderContentView *pageContentView = [contentViews objectForKey:key];

        NSMutableArray *_drawDataArray= [pageContentView.canvasView.drawDataArray mutableCopy];
        [self.pageStrokeDict setObject:_drawDataArray forKey:key];
        [_drawDataArray release];
    }    
    
    //當筆跡軌跡不為空時，存檔
    if([pageStrokeDict count] != 0){
        
        NSMutableData *data = [[NSMutableData alloc]init];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
        
        NSString *dataPath = [[[[CathayFileHelper getDocumentPath]stringByAppendingPathComponent:[dao getUserID]]stringByAppendingPathComponent:@"PDF"]stringByAppendingPathComponent:document.bookid];
      //   NSLog(@"dataPath : %@",dataPath );
      //   NSLog(@"pageStrokeDict : %@",pageStrokeDict);
        
        [archiver encodeObject:pageStrokeDict forKey:@"pageStrokeDict"];
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
        
        NSString *pendataPath = [[[CathayFileHelper getDocumentPath]stringByAppendingPathComponent:@"mailTMP"]stringByAppendingPathComponent:@"pendata"];
        
        [archiver2 encodeObject:penDict forKey:@"pendata"];
        [archiver2 finishEncoding];
        [data2 writeToFile:pendataPath atomically:YES];
        [archiver2 release];                      
        [data2 release];
        [penDict release];
        
    }else {
        //筆跡為空時，判斷是否舊有資料還在，若有需清除    
        
        
        NSString *dataPath = [[[[CathayFileHelper getDocumentPath]stringByAppendingPathComponent:[dao getUserID]]stringByAppendingPathComponent:@"PDF"]stringByAppendingPathComponent:document.bookid];
        
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:dataPath];
        if (fileExists) {
            [CathayFileHelper deleteItem:dataPath];
        }
    }
}

#pragma mark -
#pragma mark 商品資料Plist 

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

#pragma mark - Sorted related

//
//根據Dictionary中的"ORDER"欄位（數值）進行排序（由小到大）
//將排序後的key值傳回
//
//orderBy : NSOrderedDescending / NSOrderedAscending
//
-(NSArray *) sortedDicByKey:(NSString *) key dic:(NSDictionary *)dict ascending:(BOOL) ascending{
    
    NSArray *blockSortedKeys = [dict keysSortedByValueUsingComparator: ^(id obj1, id obj2) {
        
        NSDictionary *dic1 = (NSDictionary *)obj1;
        NSDictionary *dic2 = (NSDictionary *)obj2;
        
        id data1 = [dic1 objectForKey:key];
        id data2 = [dic2 objectForKey:key];
        
        if ([data1 isKindOfClass:[NSNumber class]]) {
            
            int dic1value = [data1 floatValue];
            int dic2value = [data2 floatValue];
            
            if (dic1value > dic2value) {
                return (NSComparisonResult)ascending?NSOrderedDescending:NSOrderedAscending;
            } else if (dic1value < dic2value) {
                return (NSComparisonResult)ascending?NSOrderedAscending:NSOrderedDescending;
            } else {
                //return (NSComparisonResult)NSOrderedSame;
                return NSOrderedSame;
            }
        } else if([data1 isKindOfClass:[NSString class]]){
            
            NSComparisonResult result = [data1 compare:data2];
            
            if(result==NSOrderedSame){
                //return result;
                return NSOrderedSame;
            }else{
                return ascending?result*-1:result;
            }
        } else {
            //僅支援NSNumber與NSString，其他先暫時不排序
            //return (NSComparisonResult)NSOrderedSame;
            return NSOrderedSame;
        }
        
        
    }];
    
    
    return blockSortedKeys;
}


@end
