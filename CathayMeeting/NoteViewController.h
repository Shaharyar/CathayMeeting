//
//  NoteViewController.h
//  CathayMeeting
//
//  Created by Fanny Sheng on 12/7/27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#import "CathayCanvasToolBar.h"
#import "CathayCanvas.h"
#import "InfColorPicker.h"
#import "CathayCanvasToolBar.h"
#import "SizePopupViewController.h"
#import "NoteContentView.h"
#import "NoteMainToolBar.h"

@class BookShelfDAO;
@class NoteViewController;
@class NotePalmRestView;


@protocol NoteViewControllerDelegate <NSObject>

- (void)dismissReaderViewController:(NoteViewController *)viewController;

@end

 
@interface NoteViewController : UIViewController<MFMailComposeViewControllerDelegate,CathayCanvasToolBarDelegate, InfColorPickerControllerDelegate, UIPopoverControllerDelegate,SizePopupDelegate, UIActionSheetDelegate,NoteMainToolBarDelegate,UIGestureRecognizerDelegate>
{
@private // Instance variables
    
   // UIScrollView *theScrollView;
    
	NSMutableDictionary *contentViews;
	NSMutableDictionary *pageStrokeDict;    //儲存所有頁面畫筆、圖片、文字等資訊
    
	UIPrintInteractionController *printInteraction;
	//NSInteger currentPage; //目前筆記頁頁數(由0開始)
   // int currentPage;
    int sumPage; //筆記總頁數
	CGSize lastAppearSize;
    
	BOOL isVisible;
    BOOL isEdit;
    
    //繪圖Cache資訊
    BOOL eraserEnable;
    int lastCanvasButton;
    
    //分開記憶每支筆最後使用狀況
    float normalpenLastBrushSize;
    UIColor *normalpenLastBrushColor;
    
    float lightpenLastBrushSize;
    UIColor *lightpenLastBrushColor;
    
    BookShelfDAO *dao;
}

@property (nonatomic, assign, readwrite) id <NoteViewControllerDelegate> delegate;

@property (nonatomic, retain) NSString *bookID;
@property (nonatomic, retain) NSString *bookTitle;
@property (nonatomic, retain) NoteContentView *noteContentView;
@property (nonatomic, assign) NotePalmRestView *handBoardView; //PalmRest
@property (nonatomic, assign) int currentPage;

//popup
@property (nonatomic, retain) UIPopoverController *colorPopoverController;
@property (nonatomic, retain) UIPopoverController *sizePopoverController;
@property (nonatomic, retain) UIPopoverController *caculatorPopoverController;

@property (nonatomic, retain) NSMutableDictionary *pageStrokeDict; //提供外層匯進筆跡資料
@property (nonatomic, retain) NSMutableDictionary *penDic; //提供外層匯進筆的使用狀況資料
@property (nonatomic, assign) CathayCanvasToolBar *editToolBar;
@property (nonatomic, assign) NoteMainToolBar *mainToolBar;

- (id)initWithBookID:(NSString *)bookid;

- (void) showHideColorPopUp:(id)sender;
- (void) showHideSizePopUp:(id)sender;

- (void) layoutViewsWithRotation;

- (void)applicationWill:(NSNotification *)notification;

- (void)handlePan:(UIPanGestureRecognizer *)recognizer;
- (void)handleDoubleTap:(UIPanGestureRecognizer *)recognizer;

- (void)showCurrentPage;

@end
