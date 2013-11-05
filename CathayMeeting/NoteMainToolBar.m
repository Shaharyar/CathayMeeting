//
//  NoteMainToolBar.m
//  CathayMeeting
//
//  Created by Fanny Sheng on 12/8/1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NoteMainToolBar.h"
#import <MessageUI/MessageUI.h>

#define BUTTON_X 8.0f
#define BUTTON_Y 8.0f
#define BUTTON_SPACE 10.0f
#define BUTTON_HEIGHT 35.0f
#define BUTTON_WIDTH 35.0f
#define BUTTON_WIDE_WIDTH 50.0f

@implementation NoteMainToolBar

@synthesize delegate;
@synthesize pageLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code
        self.backgroundColor = [UIColor colorWithRed:136/255.0 green:162/255.0 blue:111/255.0 alpha:0.8];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.autoresizesSubviews = YES;
        
        UIImage *imageH = [UIImage imageNamed:@"Reader-Button-H.png"];
		UIImage *imageN = [UIImage imageNamed:@"Reader-Button-N.png"];
        
		UIImage *buttonH = [imageH stretchableImageWithLeftCapWidth:5 topCapHeight:0];
		UIImage *buttonN = [imageN stretchableImageWithLeftCapWidth:5 topCapHeight:0];
  /*      
        
        ////////////////
        //左半邊按鈕
        
        CGFloat leftButtonX = BUTTON_X; // Left button start X position
        
        //上一步
		UIButton *undoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        undoButton.frame = CGRectMake(leftButtonX, BUTTON_Y, BUTTON_WIDE_WIDTH, BUTTON_HEIGHT);
        [undoButton setTitle:@"復原" forState:UIControlStateNormal];
		[undoButton setTitleColor:[UIColor colorWithWhite:0.0f alpha:1.0f] forState:UIControlStateNormal];
		[undoButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:1.0f] forState:UIControlStateHighlighted];
		[undoButton addTarget:self action:@selector(undoButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		[undoButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
		[undoButton setBackgroundImage:buttonN forState:UIControlStateNormal];
		undoButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
		//undoButton.autoresizingMask = UIViewAutoresizingNone;
		[self addSubview:undoButton]; 
        leftButtonX += (BUTTON_WIDE_WIDTH + BUTTON_SPACE);
        
        //下一步
		UIButton *redoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        redoButton.frame = CGRectMake(leftButtonX, BUTTON_Y, BUTTON_WIDE_WIDTH + 15, BUTTON_HEIGHT);
        [redoButton setTitle:@"取消復原" forState:UIControlStateNormal];
		[redoButton setTitleColor:[UIColor colorWithWhite:0.0f alpha:1.0f] forState:UIControlStateNormal];
		[redoButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:1.0f] forState:UIControlStateHighlighted];
		[redoButton addTarget:self action:@selector(redoButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		[redoButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
		[redoButton setBackgroundImage:buttonN forState:UIControlStateNormal];
		redoButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
		//redoButton.autoresizingMask = UIViewAutoresizingNone;
		[self addSubview:redoButton]; 
        
    */    
        //////////////////////////////
        // 右邊區塊按鈕
        
		CGFloat rightButtonX = self.bounds.size.width; // Right button start X position
        
		//rightButtonX -= (BUTTON_WIDTH + BUTTON_SPACE) + (BUTTON_WIDTH + 15 + BUTTON_SPACE);
        rightButtonX -= (BUTTON_WIDE_WIDTH + BUTTON_SPACE);
        
         
        //PalmRest按鈕
		UIButton *handBoardButton = [UIButton buttonWithType:UIButtonTypeCustom];
		handBoardButton.frame = CGRectMake(rightButtonX, BUTTON_Y, BUTTON_WIDE_WIDTH, BUTTON_HEIGHT);
		[handBoardButton addTarget:self action:@selector(handBoardButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [handBoardButton setTitle:@"墊板" forState:UIControlStateNormal];
		[handBoardButton setTitleColor:[UIColor colorWithWhite:0.0f alpha:1.0f] forState:UIControlStateNormal];
		[handBoardButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:1.0f] forState:UIControlStateHighlighted];
        handBoardButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
		[handBoardButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
		[handBoardButton setBackgroundImage:buttonN forState:UIControlStateNormal];
		handBoardButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        
		[self addSubview:handBoardButton];     
                  
       
       rightButtonX -= (handBoardButton.frame.size.width + BUTTON_SPACE);
        
        //email按鈕

        if ([MFMailComposeViewController canSendMail] == YES) // Can email
		{
			UIButton *emailButton = [UIButton buttonWithType:UIButtonTypeCustom];
            
            emailButton.frame = CGRectMake(rightButtonX, BUTTON_Y, BUTTON_WIDTH + 15, BUTTON_HEIGHT);
            [emailButton setImage:[UIImage imageNamed:@"Reader-Email.png"] forState:UIControlStateNormal];
			[emailButton addTarget:self action:@selector(emailButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
			[emailButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
			[emailButton setBackgroundImage:buttonN forState:UIControlStateNormal];
			emailButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            
			[self addSubview:emailButton]; 
        }

              
        ////////////////
        //中間按鈕群 
        
        //前一頁
		UIButton *previousButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [previousButton setImage:[UIImage imageNamed:@"nextPage_left.png"] forState:UIControlStateNormal];
        //[previousButton setTitle:@"前一頁" forState:UIControlStateNormal];
        //[previousButton setTitleColor:[UIColor colorWithWhite:0.0f alpha:1.0f] forState:UIControlStateNormal];
		//[previousButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:1.0f] forState:UIControlStateHighlighted];
		[previousButton addTarget:self action:@selector(previousButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		//previousButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
		[previousButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
		[previousButton setBackgroundImage:buttonN forState:UIControlStateNormal];
        
        //頁碼
        self.pageLabel = [[UILabel alloc]init];
        self.pageLabel.text = @"-- 1 --";
        self.pageLabel.font= [UIFont boldSystemFontOfSize:18.0f];
        self.pageLabel.textAlignment = UITextAlignmentCenter;
        [self.pageLabel setBackgroundColor: [UIColor clearColor]];


        //後一頁
		UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [nextButton setImage:[UIImage imageNamed:@"nextPage_right.png"] forState:UIControlStateNormal];
        //[nextButton setTitle:@"後一頁" forState:UIControlStateNormal];
		//[nextButton setTitleColor:[UIColor colorWithWhite:0.0f alpha:1.0f] forState:UIControlStateNormal];
		//[nextButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:1.0f] forState:UIControlStateHighlighted];
        [nextButton addTarget:self action:@selector(nextButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		//nextButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
		[nextButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
		[nextButton setBackgroundImage:buttonN forState:UIControlStateNormal];
        
        
        
        //////////////////
        //安排中間按鈕位置
        int btnNum = 4;
        CGFloat centerBtnsWidth = (BUTTON_WIDTH + BUTTON_SPACE) * btnNum - BUTTON_SPACE;    //按鈕群總寬 = (按鈕寬＋間距) * 按鈕數量  - 最後一個間距 
        CGFloat centerButtonX = self.bounds.size.width/2 - centerBtnsWidth / 2;         //計算中間按鈕群起始X ＝  view寬 / 2 -  按鈕群總寬 / 2
        
        //建立容器View
        UIView *centerBtnsContainer = [[UIView alloc] initWithFrame:CGRectMake(centerButtonX, 0, centerBtnsWidth, self.bounds.size.height)];
        centerBtnsContainer.backgroundColor = [UIColor clearColor];
        centerBtnsContainer.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        
        CGFloat beginX = 0.0f;
        
        previousButton.frame = CGRectMake(beginX, BUTTON_Y, BUTTON_WIDTH+15, BUTTON_HEIGHT);
        beginX += (BUTTON_WIDTH + 15 + BUTTON_SPACE);
       
        self.pageLabel.frame = CGRectMake(beginX, BUTTON_Y, BUTTON_WIDTH+25, BUTTON_HEIGHT);
        beginX += (BUTTON_WIDTH + 25 + BUTTON_SPACE);

        nextButton.frame = CGRectMake(beginX, BUTTON_Y, BUTTON_WIDTH+15, BUTTON_HEIGHT);
        
        [centerBtnsContainer addSubview:previousButton];
        [centerBtnsContainer addSubview:self.pageLabel];
        [centerBtnsContainer addSubview:nextButton];
        [self addSubview:centerBtnsContainer];
        [centerBtnsContainer release];
        

    }
    return self;
}

- (void)dealloc{
    
    [pageLabel release];
    [super dealloc];
}

#pragma mark UIButton action methods

- (void)previousButtonTapped:(UIButton *)button {
    
  	[delegate tappedInNoteToolBar:self previousButton:button];
}


- (void)nextButtonTapped:(UIButton *)button {
    
  	[delegate tappedInNoteToolBar:self nextButton:button];
}

- (void)emailButtonTapped:(UIButton *)button {
    
  	[delegate tappedInNoteToolBar:self emailButton:button];
}

- (void)handBoardButtonTapped:(UIButton *)button {
    
  	[delegate tappedInNoteToolBar:self handBoardButton:button];
}





@end
