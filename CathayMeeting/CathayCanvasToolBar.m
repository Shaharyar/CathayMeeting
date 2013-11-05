//
//  CathayCanvasToolBar.m
//  CathayLifeB2EPad
//
//  Created by dev1 on 12/4/25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CathayCanvasToolBar.h"

#define BUTTON_X 8.0f
#define BUTTON_Y 8.0f
#define BUTTON_SPACE 10.0f
#define BUTTON_HEIGHT 35.0f
#define BUTTON_WIDTH 35.0f
#define BUTTON_WIDE_WIDTH 50.0f

@interface CathayCanvasToolBar()
@property (retain) UIButton *normalPenButton;
@property (retain) UIButton *lightPenButton;
@property (retain) UIButton *eraserButton;
@end

@implementation CathayCanvasToolBar

@synthesize delegate;
@synthesize normalPenButton,lightPenButton,eraserButton;

- (id)initWithFrame:(CGRect)frame
{
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
        
        
        //////////////////////////////
        // 右邊區塊按鈕
        
		CGFloat rightButtonX = self.bounds.size.width; // Right button start X position

		//rightButtonX -= (BUTTON_WIDTH + BUTTON_SPACE) + (BUTTON_WIDTH + 15 + BUTTON_SPACE);
        rightButtonX -= (BUTTON_WIDE_WIDTH + BUTTON_SPACE);
        
        /*
        
        //計算機
		UIButton *caculatorButton = [UIButton buttonWithType:UIButtonTypeCustom];
        caculatorButton.frame = CGRectMake(rightButtonX, BUTTON_Y, BUTTON_WIDTH + 15, BUTTON_HEIGHT);
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
        
         rightButtonX += (caculatorButton.frame.size.width + BUTTON_SPACE);
         
         */
        
        
        
        //完成按鈕
		UIButton *finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
		finishButton.frame = CGRectMake(rightButtonX, BUTTON_Y, BUTTON_WIDE_WIDTH, BUTTON_HEIGHT);
		[finishButton addTarget:self action:@selector(finishButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [finishButton setTitle:@"完成" forState:UIControlStateNormal];
		[finishButton setTitleColor:[UIColor colorWithWhite:0.0f alpha:1.0f] forState:UIControlStateNormal];
		[finishButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:1.0f] forState:UIControlStateHighlighted];
        finishButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
		[finishButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
		[finishButton setBackgroundImage:buttonN forState:UIControlStateNormal];
		finishButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        
		[self addSubview:finishButton]; 
        

        ////////////////
        //中間按鈕群
        
        //一般筆
		self.normalPenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        //[normalPenButton setTitle:@"鉛筆" forState:UIControlStateNormal];
		[normalPenButton setTitleColor:[UIColor colorWithWhite:0.0f alpha:1.0f] forState:UIControlStateNormal];
		[normalPenButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:1.0f] forState:UIControlStateHighlighted];
		[normalPenButton addTarget:self action:@selector(normalPenButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		[normalPenButton setImage:[UIImage imageNamed:@"canvas_pen.png"] forState:UIControlStateNormal];
        [normalPenButton setImage:[UIImage imageNamed:@"canvas_pen_click.png"] forState:UIControlStateHighlighted];
        [normalPenButton setImage:[UIImage imageNamed:@"canvas_pen_click.png"] forState:UIControlStateSelected];
		normalPenButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
		//normalPenButton.autoresizingMask = UIViewAutoresizingNone;
		//[self addSubview:normalPenButton]; 
        
        
        //螢光筆
		self.lightPenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        //[lightPenButton setTitle:@"光筆" forState:UIControlStateNormal];
		[lightPenButton setTitleColor:[UIColor colorWithWhite:0.0f alpha:1.0f] forState:UIControlStateNormal];
		[lightPenButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:1.0f] forState:UIControlStateHighlighted];
		[lightPenButton addTarget:self action:@selector(lightPenButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		[lightPenButton setImage:[UIImage imageNamed:@"canvas_light.png"] forState:UIControlStateNormal];
        [lightPenButton setImage:[UIImage imageNamed:@"canvas_light_click.png"] forState:UIControlStateHighlighted];
        [lightPenButton setImage:[UIImage imageNamed:@"canvas_light_click.png"] forState:UIControlStateSelected];
		lightPenButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
		//lightPenButton.autoresizingMask = UIViewAutoresizingNone;
		//[self addSubview:lightPenButton]; 


        //顏色
		UIButton *colorButton = [UIButton buttonWithType:UIButtonTypeCustom];
        //[colorButton setTitle:@"顏色" forState:UIControlStateNormal];
		[colorButton setTitleColor:[UIColor colorWithWhite:0.0f alpha:1.0f] forState:UIControlStateNormal];
		[colorButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:1.0f] forState:UIControlStateHighlighted];
		[colorButton addTarget:self action:@selector(colorButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		[colorButton setImage:[UIImage imageNamed:@"canvas_color.png"] forState:UIControlStateNormal];
        [colorButton setImage:[UIImage imageNamed:@"canvas_color_click.png"] forState:UIControlStateHighlighted];
        [colorButton setImage:[UIImage imageNamed:@"canvas_color_click.png"] forState:UIControlStateSelected];
		colorButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
		//sizeButton.autoresizingMask = UIViewAutoresizingNone;
		//[self addSubview:sizeButton]; 

        
        //尺寸
		UIButton *sizeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        //[sizeButton setTitle:@"尺寸" forState:UIControlStateNormal];
		[sizeButton setTitleColor:[UIColor colorWithWhite:0.0f alpha:1.0f] forState:UIControlStateNormal];
		[sizeButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:1.0f] forState:UIControlStateHighlighted];
		[sizeButton addTarget:self action:@selector(sizeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		[sizeButton setImage:[UIImage imageNamed:@"canvas_strokes.png"] forState:UIControlStateNormal];
        [sizeButton setImage:[UIImage imageNamed:@"canvas_strokes_click.png"] forState:UIControlStateHighlighted];
        [sizeButton setImage:[UIImage imageNamed:@"canvas_strokes_click.png"] forState:UIControlStateSelected];
		sizeButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
		//sizeButton.autoresizingMask = UIViewAutoresizingNone;
		//[self addSubview:sizeButton]; 

        //擦子
		self.eraserButton = [UIButton buttonWithType:UIButtonTypeCustom];
        //[eraserButton setTitle:@"擦子" forState:UIControlStateNormal];
		[eraserButton setTitleColor:[UIColor colorWithWhite:0.0f alpha:1.0f] forState:UIControlStateNormal];
		[eraserButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:1.0f] forState:UIControlStateHighlighted];
		[eraserButton addTarget:self action:@selector(eraserButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		[eraserButton setImage:[UIImage imageNamed:@"canvas_eraser.png"] forState:UIControlStateNormal];
        [eraserButton setImage:[UIImage imageNamed:@"canvas_eraser_click.png"] forState:UIControlStateHighlighted];
        [eraserButton setImage:[UIImage imageNamed:@"canvas_eraser_click.png"] forState:UIControlStateSelected];
		eraserButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
		//eraserButton.autoresizingMask = UIViewAutoresizingNone;
		//[self addSubview:eraserButton]; 
        
        
        
        //////////////////
        //安排中間按鈕位置
        int btnNum = 6;
        CGFloat centerBtnsWidth = (BUTTON_WIDTH + BUTTON_SPACE) * btnNum - BUTTON_SPACE;    //按鈕群總寬 = (按鈕寬＋間距) * 按鈕數量  - 最後一個間距 
        CGFloat centerButtonX = self.bounds.size.width/2 - centerBtnsWidth / 2;         //計算中間按鈕群起始X ＝  view寬 / 2 -  按鈕群總寬 / 2
        
        //建立容器View
        UIView *centerBtnsContainer = [[UIView alloc] initWithFrame:CGRectMake(centerButtonX, 0, centerBtnsWidth, self.bounds.size.height)];
        centerBtnsContainer.backgroundColor = [UIColor clearColor];
        centerBtnsContainer.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;

        CGFloat beginX = 0.0f;
        normalPenButton.frame = CGRectMake(beginX, BUTTON_Y, BUTTON_WIDTH, BUTTON_HEIGHT);
        beginX += (BUTTON_WIDTH + BUTTON_SPACE);
        lightPenButton.frame = CGRectMake(beginX, BUTTON_Y, BUTTON_WIDTH, BUTTON_HEIGHT);
        beginX += (BUTTON_WIDTH + BUTTON_SPACE);
        colorButton.frame = CGRectMake(beginX, BUTTON_Y, BUTTON_WIDTH, BUTTON_HEIGHT);
        beginX += (BUTTON_WIDTH + BUTTON_SPACE);
        sizeButton.frame = CGRectMake(beginX, BUTTON_Y, BUTTON_WIDTH, BUTTON_HEIGHT);
        beginX += (BUTTON_WIDTH + BUTTON_SPACE);
        eraserButton.frame = CGRectMake(beginX, BUTTON_Y, BUTTON_WIDTH, BUTTON_HEIGHT);
        //beginX += (BUTTON_WIDTH + BUTTON_SPACE);
        //caculatorButton.frame = CGRectMake(beginX, BUTTON_Y, BUTTON_WIDTH, BUTTON_HEIGHT);
        
        [centerBtnsContainer addSubview:normalPenButton];
        [centerBtnsContainer addSubview:lightPenButton];
        [centerBtnsContainer addSubview:colorButton];
        [centerBtnsContainer addSubview:sizeButton];
        [centerBtnsContainer addSubview:eraserButton];
        //[centerBtnsContainer addSubview:caculatorButton];  
        [self addSubview:centerBtnsContainer];
        [centerBtnsContainer release];
        
        //預設用一般筆
        [normalPenButton setSelected:YES];
        cacheButton = normalPenButton;
    }
    return self;
}

//回復初始狀態
-(void) resetStatus {
    
    [cacheButton setSelected:NO];
    [normalPenButton setSelected:YES];
    cacheButton = normalPenButton;
}

//設定使用狀態
-(void) setStatus:(int)penButton {
    
    if (penButton == 2) {
        [cacheButton setSelected:NO];
        [lightPenButton setSelected:YES];
        cacheButton = lightPenButton;
    }else if(penButton == 3){
        [cacheButton setSelected:NO];
        [eraserButton setSelected:YES];
        cacheButton = eraserButton;
    }else {
        [cacheButton setSelected:NO];
        [normalPenButton setSelected:YES];
        cacheButton = normalPenButton;
    }
   
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark UIButton action methods

- (void)undoButtonTapped:(UIButton *)button {
    
  	[delegate tappedInCanvasToolBar:self undoButton:button];
}


- (void)redoButtonTapped:(UIButton *)button {
    
  	[delegate tappedInCanvasToolBar:self redoButton:button];
}

- (void)normalPenButtonTapped:(UIButton *)button {
    
    if(cacheButton){
        [cacheButton setSelected:NO];
		cacheButton = button;
		// first time pressed slideMenu button
	}else {
		cacheButton = button;
	}
    
    [button setSelected:YES];
    
    [delegate tappedInCanvasToolBar:self normalPenButton:button];
}

- (void)lightPenButtonTapped:(UIButton *)button {
    
    if(cacheButton){
        [cacheButton setSelected:NO];
		cacheButton = button;
		// first time pressed slideMenu button
	}else {
		cacheButton = button;
	}
    
    [button setSelected:YES];
    
  	[delegate tappedInCanvasToolBar:self lightPenButton:button];
}

- (void)colorButtonTapped:(UIButton *)button {
    
  	[delegate tappedInCanvasToolBar:self colorButton:button];
}

- (void)sizeButtonTapped:(UIButton *)button {
    
  	[delegate tappedInCanvasToolBar:self sizeButton:button];
}

- (void)eraserButtonTapped:(UIButton *)button {

  	[delegate tappedInCanvasToolBar:self eraserButton:button];
    
    if(cacheButton){
        [cacheButton setSelected:NO];
		cacheButton = button;
		// first time pressed slideMenu button
	}else {
		cacheButton = button;
	}
    
    [button setSelected:YES];
}

/*
- (void)caculatorButtonTapped:(UIButton *)button {
    
  	[delegate tappedInCanvasToolBar:self caculatorButton:button];
}
*/

- (void)finishButtonTapped:(UIButton *)button {
    
  	[delegate tappedInCanvasToolBar:self finishButton:button];
}


@end
