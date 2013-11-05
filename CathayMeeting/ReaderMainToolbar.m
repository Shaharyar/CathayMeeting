//
//	ReaderMainToolbar.m
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
#import "ReaderMainToolbar.h"
#import "ReaderDocument.h"

#import <MessageUI/MessageUI.h>

@implementation ReaderMainToolbar

#pragma mark Constants

#define BUTTON_X 8.0f
#define BUTTON_Y 8.0f
#define BUTTON_SPACE 8.0f
#define BUTTON_HEIGHT 30.0f

#define DONE_BUTTON_WIDTH 56.0f
#define THUMBS_BUTTON_WIDTH 40.0f
#define PRINT_BUTTON_WIDTH 40.0f
#define EMAIL_BUTTON_WIDTH 40.0f
#define MARK_BUTTON_WIDTH 40.0f

#define TITLE_HEIGHT 28.0f

#pragma mark Properties

@synthesize delegate;

#pragma mark ReaderMainToolbar instance methods

- (id)initWithFrame:(CGRect)frame
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	return [self initWithFrame:frame document:nil];
}

- (id)initWithFrame:(CGRect)frame document:(ReaderDocument *)object
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	assert(object != nil); // Check

	if ((self = [super initWithFrame:frame]))
	{
		CGFloat viewWidth = self.bounds.size.width;

		UIImage *imageH = [UIImage imageNamed:@"Reader-Button-H.png"];
		UIImage *imageN = [UIImage imageNamed:@"Reader-Button-N.png"];

		UIImage *buttonH = [imageH stretchableImageWithLeftCapWidth:5 topCapHeight:0];
		UIImage *buttonN = [imageN stretchableImageWithLeftCapWidth:5 topCapHeight:0];

		CGFloat titleX = BUTTON_X; 
        CGFloat titleWidth = (viewWidth - (titleX + titleX));
        
        //////////////////////////////
        // 左邊區塊按鈕
        
		CGFloat leftButtonX = BUTTON_X; // Left button start X position

        #if (READER_STANDALONE == FALSE) // Option

		UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];

		doneButton.frame = CGRectMake(leftButtonX, BUTTON_Y, DONE_BUTTON_WIDTH, BUTTON_HEIGHT);
        //Yu Jen Wang, 更改中文
		//[doneButton setTitle:NSLocalizedString(@"Done", @"button") forState:UIControlStateNormal];
        [doneButton setTitle:@"關閉" forState:UIControlStateNormal];
		[doneButton setTitleColor:[UIColor colorWithWhite:0.0f alpha:1.0f] forState:UIControlStateNormal];
		[doneButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:1.0f] forState:UIControlStateHighlighted];
		[doneButton addTarget:self action:@selector(doneButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		[doneButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
		[doneButton setBackgroundImage:buttonN forState:UIControlStateNormal];
		doneButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
		doneButton.autoresizingMask = UIViewAutoresizingNone;

		[self addSubview:doneButton]; leftButtonX += (DONE_BUTTON_WIDTH + BUTTON_SPACE);

		titleX += (DONE_BUTTON_WIDTH + BUTTON_SPACE); titleWidth -= (DONE_BUTTON_WIDTH + BUTTON_SPACE);

        #endif // end of READER_STANDALONE Option

        #if (READER_ENABLE_THUMBS == TRUE) // Option

		UIButton *thumbsButton = [UIButton buttonWithType:UIButtonTypeCustom];

		thumbsButton.frame = CGRectMake(leftButtonX, BUTTON_Y, THUMBS_BUTTON_WIDTH, BUTTON_HEIGHT);
		[thumbsButton setImage:[UIImage imageNamed:@"Reader-Thumbs.png"] forState:UIControlStateNormal];
		[thumbsButton addTarget:self action:@selector(thumbsButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		[thumbsButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
		[thumbsButton setBackgroundImage:buttonN forState:UIControlStateNormal];
		thumbsButton.autoresizingMask = UIViewAutoresizingNone;

		[self addSubview:thumbsButton]; //leftButtonX += (THUMBS_BUTTON_WIDTH + BUTTON_SPACE);

		titleX += (THUMBS_BUTTON_WIDTH + BUTTON_SPACE); titleWidth -= (THUMBS_BUTTON_WIDTH + BUTTON_SPACE);

        #endif // end of READER_ENABLE_THUMBS Option
        
        
        //////////////////////////////
        // 右邊區塊按鈕
        
		CGFloat rightButtonX = viewWidth; // Right button start X position

        //繪圖按鈕
        #if (READER_EDIT == TRUE) 
        
		rightButtonX -= (DONE_BUTTON_WIDTH + BUTTON_SPACE);
        
		UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
		editButton.frame = CGRectMake(rightButtonX, BUTTON_Y, DONE_BUTTON_WIDTH, BUTTON_HEIGHT);
		//[editButton setImage:[UIImage imageNamed:@"Reader-Mark-N.png"] forState:UIControlStateNormal];
		[editButton addTarget:self action:@selector(editButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [editButton setTitle:@"彩色筆" forState:UIControlStateNormal];
		[editButton setTitleColor:[UIColor colorWithWhite:0.0f alpha:1.0f] forState:UIControlStateNormal];
		[editButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:1.0f] forState:UIControlStateHighlighted];
        editButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
		[editButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
		[editButton setBackgroundImage:buttonN forState:UIControlStateNormal];
		editButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        
		[self addSubview:editButton]; 
        
        titleWidth -= (DONE_BUTTON_WIDTH + BUTTON_SPACE);
        
        #endif 
        
        //計算機按鈕
        #if (READER_CALCULATOR == TRUE) 
        
		rightButtonX -= (DONE_BUTTON_WIDTH + BUTTON_SPACE);
        
        UIButton *caculatorButton = [UIButton buttonWithType:UIButtonTypeCustom];
        caculatorButton.frame = CGRectMake(rightButtonX, BUTTON_Y, DONE_BUTTON_WIDTH, BUTTON_HEIGHT);
        [caculatorButton setTitle:@"計算機" forState:UIControlStateNormal];
		[caculatorButton setTitleColor:[UIColor colorWithWhite:0.0f alpha:1.0f] forState:UIControlStateNormal];
		[caculatorButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:1.0f] forState:UIControlStateHighlighted];
		[caculatorButton addTarget:self action:@selector(caculatorButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        //[caculatorButton setImage:[UIImage imageNamed:@"canvas_pen.png"] forState:UIControlStateNormal];
        //[caculatorButton setImage:[UIImage imageNamed:@"canvas_pen_click.png"] forState:UIControlStateHighlighted];
        //[caculatorButton setImage:[UIImage imageNamed:@"canvas_pen_click.png"] forState:UIControlStateSelected];
		[caculatorButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
		[caculatorButton setBackgroundImage:buttonN forState:UIControlStateNormal];
		caculatorButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
		caculatorButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		[self addSubview:caculatorButton]; 
        
        titleWidth -= (DONE_BUTTON_WIDTH + BUTTON_SPACE);
        
        #endif 
        
        //Mail按鈕
        #if (READER_ENABLE_MAIL == TRUE) // Option
        
		if ([MFMailComposeViewController canSendMail] == YES) // Can email
		{
			unsigned long long fileSize = [object.fileSize unsignedLongLongValue];
            
			if (fileSize < (unsigned long long)15728640) // Check attachment size limit (15MB)
			{
				rightButtonX -= (EMAIL_BUTTON_WIDTH + BUTTON_SPACE);
                
				UIButton *emailButton = [UIButton buttonWithType:UIButtonTypeCustom];
                
				emailButton.frame = CGRectMake(rightButtonX, BUTTON_Y, EMAIL_BUTTON_WIDTH, BUTTON_HEIGHT);
				[emailButton setImage:[UIImage imageNamed:@"Reader-Email.png"] forState:UIControlStateNormal];
				[emailButton addTarget:self action:@selector(emailButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
				[emailButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
				[emailButton setBackgroundImage:buttonN forState:UIControlStateNormal];
				emailButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
                
				[self addSubview:emailButton]; titleWidth -= (EMAIL_BUTTON_WIDTH + BUTTON_SPACE);
			}
		}
        
        #endif // end of READER_ENABLE_MAIL Option


        //匯出按鈕
        #if (READER_EXPORT == TRUE) 
        
		rightButtonX -= (MARK_BUTTON_WIDTH + BUTTON_SPACE);
        
		UIButton *exportButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
		exportButton.frame = CGRectMake(rightButtonX, BUTTON_Y, MARK_BUTTON_WIDTH, BUTTON_HEIGHT);
		//[exportButton setImage:[UIImage imageNamed:@"Reader-Mark-N.png"] forState:UIControlStateNormal];
		[exportButton addTarget:self action:@selector(exportButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [exportButton setTitle:@"另存" forState:UIControlStateNormal];
		[exportButton setTitleColor:[UIColor colorWithWhite:0.0f alpha:1.0f] forState:UIControlStateNormal];
		[exportButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:1.0f] forState:UIControlStateHighlighted];
        exportButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
		[exportButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
		[exportButton setBackgroundImage:buttonN forState:UIControlStateNormal];
		exportButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        
		[self addSubview:exportButton]; 
        
        titleWidth -= (MARK_BUTTON_WIDTH + BUTTON_SPACE);
        
        #endif 

            
        
        //書籤按鈕
        #if (READER_BOOKMARKS == TRUE) // Option

		rightButtonX -= (MARK_BUTTON_WIDTH + BUTTON_SPACE);

		UIButton *flagButton = [UIButton buttonWithType:UIButtonTypeCustom];

		flagButton.frame = CGRectMake(rightButtonX, BUTTON_Y, MARK_BUTTON_WIDTH, BUTTON_HEIGHT);
		//[flagButton setImage:[UIImage imageNamed:@"Reader-Mark-N.png"] forState:UIControlStateNormal];
		[flagButton addTarget:self action:@selector(markButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		[flagButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
		[flagButton setBackgroundImage:buttonN forState:UIControlStateNormal];
		flagButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;

		[self addSubview:flagButton]; titleWidth -= (MARK_BUTTON_WIDTH + BUTTON_SPACE);

		markButton = [flagButton retain]; markButton.enabled = NO; markButton.tag = NSIntegerMin;

		markImageN = [[UIImage imageNamed:@"Reader-Mark-N.png"] retain]; // N image
		markImageY = [[UIImage imageNamed:@"Reader-Mark-Y.png"] retain]; // Y image

        #endif // end of READER_BOOKMARKS Option
        
        
        //筆記頁按鈕
        #if (READER_NOTE == TRUE) 
        
		rightButtonX -= (DONE_BUTTON_WIDTH + BUTTON_SPACE);
        
		UIButton *noteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
		noteButton.frame = CGRectMake(rightButtonX, BUTTON_Y, DONE_BUTTON_WIDTH, BUTTON_HEIGHT);

		[noteButton addTarget:self action:@selector(noteButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [noteButton setTitle:@"筆記頁" forState:UIControlStateNormal];
		[noteButton setTitleColor:[UIColor colorWithWhite:0.0f alpha:1.0f] forState:UIControlStateNormal];
		[noteButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:1.0f] forState:UIControlStateHighlighted];
        noteButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
		[noteButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
		[noteButton setBackgroundImage:buttonN forState:UIControlStateNormal];
		noteButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        
		[self addSubview:noteButton]; 
        
        titleWidth -= (DONE_BUTTON_WIDTH + BUTTON_SPACE);
        
        #endif        
        
        
        //列印按鈕
        #if (READER_ENABLE_PRINT == TRUE) // Option

		if (object.password == nil) // We can only print documents without passwords
		{
			Class printInteractionController = NSClassFromString(@"UIPrintInteractionController");

			if ((printInteractionController != nil) && [printInteractionController isPrintingAvailable])
			{
				rightButtonX -= (PRINT_BUTTON_WIDTH + BUTTON_SPACE);

				UIButton *printButton = [UIButton buttonWithType:UIButtonTypeCustom];

				printButton.frame = CGRectMake(rightButtonX, BUTTON_Y, PRINT_BUTTON_WIDTH, BUTTON_HEIGHT);
				[printButton setImage:[UIImage imageNamed:@"Reader-Print.png"] forState:UIControlStateNormal];
				[printButton addTarget:self action:@selector(printButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
				[printButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
				[printButton setBackgroundImage:buttonN forState:UIControlStateNormal];
				printButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;

				[self addSubview:printButton]; titleWidth -= (PRINT_BUTTON_WIDTH + BUTTON_SPACE);
			}
		}

        #endif // end of READER_ENABLE_PRINT Option

		
        //標題
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
		{
			CGRect titleRect = CGRectMake(titleX, BUTTON_Y, titleWidth, TITLE_HEIGHT);

			UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleRect];

			titleLabel.textAlignment = UITextAlignmentCenter;
			titleLabel.font = [UIFont systemFontOfSize:19.0f]; // 19 pt
			titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
			titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
			titleLabel.textColor = [UIColor colorWithWhite:0.0f alpha:1.0f];
            //titleLabel.textColor = [UIColor colorWithRed:14/255.0 green:108/255.0 blue:8/255.0 alpha:1];
			titleLabel.shadowColor = [UIColor colorWithWhite:0.65f alpha:1.0f];
			titleLabel.backgroundColor = [UIColor clearColor];
			titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
			titleLabel.adjustsFontSizeToFitWidth = YES;
			titleLabel.minimumFontSize = 14.0f;
			//Yu Jen Wang, 更改
            //titleLabel.text = [object.fileName stringByDeletingPathExtension];
            //NSLog(@"title:%@", object.title);
            titleLabel.text = [object.title stringByDeletingPathExtension];
            
			[self addSubview:titleLabel]; [titleLabel release];
		}
        
	}

	return self;
}

- (void)dealloc
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[markButton release], markButton = nil;

	[markImageN release], markImageN = nil;
	[markImageY release], markImageY = nil;

	[super dealloc];
}

- (void)setBookmarkState:(BOOL)state
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

#if (READER_BOOKMARKS == TRUE) // Option

	if (state != markButton.tag) // Only if different state
	{
		if (self.hidden == NO) // Only if toolbar is visible
		{
			UIImage *image = (state ? markImageY : markImageN);

			[markButton setImage:image forState:UIControlStateNormal];
		}

		markButton.tag = state; // Update bookmarked state tag
	}

	if (markButton.enabled == NO) markButton.enabled = YES;

#endif // end of READER_BOOKMARKS Option
}

- (void)updateBookmarkImage
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

#if (READER_BOOKMARKS == TRUE) // Option

	if (markButton.tag != NSIntegerMin) // Valid tag
	{
		BOOL state = markButton.tag; // Bookmarked state

		UIImage *image = (state ? markImageY : markImageN);

		[markButton setImage:image forState:UIControlStateNormal];
	}

	if (markButton.enabled == NO) markButton.enabled = YES;

#endif // end of READER_BOOKMARKS Option
}

- (void)hideToolbar
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	if (self.hidden == NO)
	{
		[UIView animateWithDuration:0.25 delay:0.0
			options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
			animations:^(void)
			{
				self.alpha = 0.0f;
			}
			completion:^(BOOL finished)
			{
				self.hidden = YES;
			}
		];
	}
}

- (void)showToolbar
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	if (self.hidden == YES)
	{
		[self updateBookmarkImage]; // First

		[UIView animateWithDuration:0.25 delay:0.0
			options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
			animations:^(void)
			{
				self.hidden = NO;
				self.alpha = 1.0f;
			}
			completion:NULL
		];
	}
}

#pragma mark UIButton action methods

- (void)caculatorButtonTapped:(UIButton *)button {
    
  	[delegate tappedInToolbar:self calculatorButton:button];
}


- (void)exportButtonTapped:(UIButton *)button {

    [delegate tappedInToolbar:self exportButton:button];
}



- (void)editButtonTapped:(UIButton *)button {
    
  	[delegate tappedInToolbar:self editButton:button];
}


- (void)doneButtonTapped:(UIButton *)button
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[delegate tappedInToolbar:self doneButton:button];
}

- (void)thumbsButtonTapped:(UIButton *)button
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[delegate tappedInToolbar:self thumbsButton:button];
}

- (void)printButtonTapped:(UIButton *)button
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[delegate tappedInToolbar:self printButton:button];
}

- (void)emailButtonTapped:(UIButton *)button
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[delegate tappedInToolbar:self emailButton:button];
}

- (void)markButtonTapped:(UIButton *)button
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[delegate tappedInToolbar:self markButton:button];
}

- (void)noteButtonTapped:(UIButton *)button
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
	[delegate tappedInToolbar:self noteButton:button];
}

@end
