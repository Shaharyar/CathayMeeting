//
//	ReaderViewController.h
//	Reader v2.5.1
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

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#import "ReaderDocument.h"
#import "ReaderContentView.h"
#import "ReaderMainToolbar.h"
#import "ReaderMainPagebar.h"
#import "ThumbsViewController.h"
#import "InfColorPicker.h"
#import "CathayCanvasToolBar.h"
#import "SizePopupViewController.h"
#import "CathayCalculatorView.h"
#import "NoteViewController.h"

@class ReaderViewController;
@class ReaderMainToolbar;
@class BookShelfDAO;

@protocol ReaderViewControllerDelegate <NSObject>

@optional // Delegate protocols

- (void)dismissReaderViewController:(ReaderViewController *)viewController;

@end

@interface ReaderViewController : UIViewController 
<   UIScrollViewDelegate, UIGestureRecognizerDelegate, 
    MFMailComposeViewControllerDelegate, ReaderMainToolbarDelegate, 
    ReaderMainPagebarDelegate, ReaderContentViewDelegate, 
    ThumbsViewControllerDelegate, CathayCanvasToolBarDelegate, 
    InfColorPickerControllerDelegate, UIPopoverControllerDelegate,
    SizePopupDelegate, UIActionSheetDelegate,
    CathayCalculatorViewDelegate,NoteViewControllerDelegate
>
{
@private // Instance variables

	ReaderDocument *document;

	UIScrollView *theScrollView;

	ReaderMainToolbar *mainToolbar;

	ReaderMainPagebar *mainPagebar;

	NSMutableDictionary *contentViews;
    
	NSMutableDictionary *pageStrokeDict;    //儲存所有頁面畫筆、圖片、文字等資訊
    
	UIPrintInteractionController *printInteraction;

	NSInteger currentPage;

	CGSize lastAppearSize;

	NSDate *lastHideTime;

	BOOL isVisible;
    
    BOOL isEdit;
    
    //繪圖Cache資訊
//    float lastBrushSize;
//    UIColor *lastBrushColor;
    BOOL eraserEnable;
    int lastCanvasButton;
    
    //分開記憶每支筆最後使用狀況
    float normalpenLastBrushSize;
    UIColor *normalpenLastBrushColor;
    
    float lightpenLastBrushSize;
    UIColor *lightpenLastBrushColor;
    
    
    BookShelfDAO *dao;
}

@property (nonatomic, assign, readwrite) id <ReaderViewControllerDelegate> delegate;

//popup
@property (nonatomic, retain) UIPopoverController *colorPopoverController;
@property (nonatomic, retain) UIPopoverController *sizePopoverController;
@property (nonatomic, retain) UIPopoverController *caculatorPopoverController;

@property (nonatomic, retain) NSMutableDictionary *pageStrokeDict; //提供外層匯進筆跡資料
@property (nonatomic, retain) NSMutableDictionary *penDic; //提供外層匯進筆的使用狀況資料


@property (nonatomic, retain) NSString *noteid; //提供筆記本使用的key
@property (nonatomic, retain) NSString *noteTitle; //提供筆記本使用的key



- (id)initWithReaderDocument:(ReaderDocument *)object;

@end
