//
//  CathayCaculatorView.m
//  CathayLifeB2EPad
//
//  Created by dev1 on 12/5/4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CathayCalculatorView.h"
#import "CalculatorBrain.h"
#import <QuartzCore/QuartzCore.h>


#define PAGE_PAD 10
#define BTN_PAD 8
#define BTN_SIZE 54
#define DOUBLE_BTN_SIZE 116

#define DOT_TAG 888

@interface CathayCalculatorView()
@property (assign) UILabel *calculatorScreen;
@property (assign) CalculatorBrain *brain;
@property (assign) UIButton *lastOperationBtn;

-(UIButton *) generateBtnWithTitle:(NSString *) title action:(SEL)action;
@end

@implementation CathayCalculatorView
@synthesize delegate;
@synthesize calculatorScreen, brain;
@synthesize lastOperationBtn;

-(id) caculator {
    
    CGRect frame = CGRectMake(50, 100, 260, 370);
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        //self.backgroundColor = [UIColor colorWithWhite:0.6 alpha:0.9];
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"metal_bg.png"]];
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleBottomMargin;
        
        self.layer.shadowColor = [UIColor darkGrayColor].CGColor;
        self.layer.shadowOpacity = 8.0f;
        self.layer.shadowOffset = CGSizeMake(4, 4);
        
        
        self.brain = [[CalculatorBrain alloc] init];
        
        CGFloat beginY = PAGE_PAD;
        CGFloat beginX = PAGE_PAD;
        
        ///////////////
        // 建置按鈕
        //
        
        /////////////// 1
        
        //顯示窗
        self.calculatorScreen = [[UILabel alloc]initWithFrame:CGRectMake(beginX, beginY, 240, 40)];
        self.calculatorScreen.text = @"0";
        self.calculatorScreen.font= [UIFont boldSystemFontOfSize:26.0f];
        self.calculatorScreen.textAlignment = UITextAlignmentRight;
        [self addSubview:calculatorScreen];
        
        //關閉按鈕
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        closeBtn.frame = CGRectMake(-12, beginY - 25, 44, 44);        
		[closeBtn addTarget:self action:@selector(closeCaculator:) forControlEvents:UIControlEventTouchUpInside];
        [closeBtn setImage:[UIImage imageNamed:@"btn_close44.png"] forState:UIControlStateNormal];
        closeBtn.showsTouchWhenHighlighted = YES;
        [self addSubview:closeBtn];
        
        beginY = beginY + calculatorScreen.frame.size.height + BTN_PAD;

        /////////////// 2
        
        beginX = PAGE_PAD;
        
        //C
        UIButton *cButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[cButton addTarget:self action:@selector(buttonOperationPressed:) forControlEvents:UIControlEventTouchUpInside];
        [cButton setBackgroundImage:[UIImage imageNamed:@"c.png"] forState:UIControlStateNormal];
        //[self generateBtnWithTitle:@"C" action:@selector(buttonOperationPressed:)];
        cButton.frame = CGRectMake(beginX, beginY, BTN_SIZE, BTN_SIZE);   
        [cButton.layer setValue:@"C" forKey:@"operaton"];
        //cButton.tag = CLEAR_TAG;
		[self addSubview:cButton]; 

        beginX = beginX + cButton.frame.size.width + BTN_PAD;


        //divide
        UIButton *divideButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[divideButton addTarget:self action:@selector(buttonOperationPressed:) forControlEvents:UIControlEventTouchUpInside];
        [divideButton setBackgroundImage:[UIImage imageNamed:@"divide.png"] forState:UIControlStateNormal];
        [divideButton setBackgroundImage:[UIImage imageNamed:@"divide_selected.png"] forState:UIControlStateSelected];
        //UIButton *divideButton = [self generateBtnWithTitle:@"/" action:@selector(buttonOperationPressed:)];
        divideButton.frame = CGRectMake(beginX, beginY, BTN_SIZE, BTN_SIZE);        
        [divideButton.layer setValue:@"/" forKey:@"operaton"];
        divideButton.tag = 50;
		[self addSubview:divideButton]; 

        beginX = beginX + divideButton.frame.size.width + BTN_PAD;
        
        //x
        UIButton *multiplyButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[multiplyButton addTarget:self action:@selector(buttonOperationPressed:) forControlEvents:UIControlEventTouchUpInside];
        [multiplyButton setBackgroundImage:[UIImage imageNamed:@"times.png"] forState:UIControlStateNormal];
        [multiplyButton setBackgroundImage:[UIImage imageNamed:@"times_selected.png"] forState:UIControlStateSelected];
        //UIButton *multiplyButton = [self generateBtnWithTitle:@"*" action:@selector(buttonOperationPressed:)];
        multiplyButton.frame = CGRectMake(beginX, beginY, BTN_SIZE, BTN_SIZE);        
        [multiplyButton.layer setValue:@"*" forKey:@"operaton"];
        multiplyButton.tag = 51;
		[self addSubview:multiplyButton]; 

        beginX = beginX + multiplyButton.frame.size.width + BTN_PAD;
        
        //-
        UIButton *subtractButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[subtractButton addTarget:self action:@selector(buttonOperationPressed:) forControlEvents:UIControlEventTouchUpInside];
        [subtractButton setBackgroundImage:[UIImage imageNamed:@"minus.png"] forState:UIControlStateNormal];
        [subtractButton setBackgroundImage:[UIImage imageNamed:@"minus_selected.png"] forState:UIControlStateSelected];
        //UIButton *subtractButton = [self generateBtnWithTitle:@"-" action:@selector(buttonOperationPressed:)];
        subtractButton.frame = CGRectMake(beginX, beginY, BTN_SIZE, BTN_SIZE);        
        [subtractButton.layer setValue:@"-" forKey:@"operaton"];
        subtractButton.tag = 52;
		[self addSubview:subtractButton]; 
        
        beginY = beginY + BTN_SIZE + BTN_PAD;
        
        /////////////// 3
        
        beginX = PAGE_PAD;
        
        //7
        UIButton *_7Button = [self generateBtnWithTitle:@"7" action:@selector(buttonDigitPressed:)];
        _7Button.frame = CGRectMake(beginX, beginY, BTN_SIZE, BTN_SIZE);        
        _7Button.tag = 7;
		[self addSubview:_7Button]; 
        
        beginX = beginX + _7Button.frame.size.width + BTN_PAD;

        //8
        UIButton *_8Button = [self generateBtnWithTitle:@"8" action:@selector(buttonDigitPressed:)];
        _8Button.frame = CGRectMake(beginX, beginY, BTN_SIZE, BTN_SIZE);        
        _8Button.tag = 8;
		[self addSubview:_8Button]; 
        
        beginX = beginX + _8Button.frame.size.width + BTN_PAD;

        //9
        UIButton *_9Button = [self generateBtnWithTitle:@"9" action:@selector(buttonDigitPressed:)];
        _9Button.frame = CGRectMake(beginX, beginY, BTN_SIZE, BTN_SIZE);        
        _9Button.tag = 9;
		[self addSubview:_9Button]; 
        
        beginX = beginX + _9Button.frame.size.width + BTN_PAD;

        //+
        UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[addButton addTarget:self action:@selector(buttonOperationPressed:) forControlEvents:UIControlEventTouchUpInside];
        [addButton setBackgroundImage:[UIImage imageNamed:@"plus.png"] forState:UIControlStateNormal];
        [addButton setBackgroundImage:[UIImage imageNamed:@"plus_selected.png"] forState:UIControlStateSelected];
        //UIButton *addButton = [self generateBtnWithTitle:@"+" action:@selector(buttonOperationPressed:)];
        addButton.frame = CGRectMake(beginX, beginY, BTN_SIZE, DOUBLE_BTN_SIZE);        
        [addButton.layer setValue:@"+" forKey:@"operaton"];
        addButton.tag = 53;
		[self addSubview:addButton]; 
        
        beginY = beginY + BTN_SIZE + BTN_PAD;
        
        /////////////// 4
        
        beginX = PAGE_PAD;
        
        //4
        UIButton *_4Button = [self generateBtnWithTitle:@"4" action:@selector(buttonDigitPressed:)];
        _4Button.frame = CGRectMake(beginX, beginY, BTN_SIZE, BTN_SIZE);        
        _4Button.tag = 4;
		[self addSubview:_4Button]; 
        
        beginX = beginX + _4Button.frame.size.width + BTN_PAD;
        
        //5
        UIButton *_5Button = [self generateBtnWithTitle:@"5" action:@selector(buttonDigitPressed:)];
        _5Button.frame = CGRectMake(beginX, beginY, BTN_SIZE, BTN_SIZE);        
        _5Button.tag = 5;
		[self addSubview:_5Button]; 
        
        beginX = beginX + _5Button.frame.size.width + BTN_PAD;
        
        //6
        UIButton *_6Button = [self generateBtnWithTitle:@"6" action:@selector(buttonDigitPressed:)];
        _6Button.frame = CGRectMake(beginX, beginY, BTN_SIZE, BTN_SIZE);        
        _6Button.tag = 6;
		[self addSubview:_6Button]; 
        
        beginY = beginY + BTN_SIZE + BTN_PAD;
        
        /////////////// 5
        
        beginX = PAGE_PAD;
        
        //1
        UIButton *_1Button = [self generateBtnWithTitle:@"1" action:@selector(buttonDigitPressed:)];
        _1Button.frame = CGRectMake(beginX, beginY, BTN_SIZE, BTN_SIZE);        
        _1Button.tag = 1;
		[self addSubview:_1Button]; 
        
        beginX = beginX + _1Button.frame.size.width + BTN_PAD;
        
        //2
        UIButton *_2Button = [self generateBtnWithTitle:@"2" action:@selector(buttonDigitPressed:)];
        _2Button.frame = CGRectMake(beginX, beginY, BTN_SIZE, BTN_SIZE);        
        _2Button.tag = 2;
		[self addSubview:_2Button]; 
        
        beginX = beginX + _2Button.frame.size.width + BTN_PAD;
        
        //3
        UIButton *_3Button = [self generateBtnWithTitle:@"3" action:@selector(buttonDigitPressed:)];
        _3Button.frame = CGRectMake(beginX, beginY, BTN_SIZE, BTN_SIZE);        
        _3Button.tag = 3;
		[self addSubview:_3Button]; 
        
        beginX = beginX + _3Button.frame.size.width + BTN_PAD;

        //=
        UIButton *resultButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[resultButton addTarget:self action:@selector(buttonOperationPressed:) forControlEvents:UIControlEventTouchUpInside];
        [resultButton setBackgroundImage:[UIImage imageNamed:@"equal.png"] forState:UIControlStateNormal];
        //UIButton *resultButton = [self generateBtnWithTitle:@"=" action:@selector(buttonOperationPressed:)];
        resultButton.frame = CGRectMake(beginX, beginY, BTN_SIZE, DOUBLE_BTN_SIZE);        
        [resultButton.layer setValue:@"=" forKey:@"operaton"];        
		[self addSubview:resultButton]; 
        
        beginY = beginY + BTN_SIZE + BTN_PAD;
        
        /////////////// 6
        
        beginX = PAGE_PAD;
        
        //0
        UIButton *_0Button = [self generateBtnWithTitle:@"0" action:@selector(buttonDigitPressed:)];
        _0Button.frame = CGRectMake(beginX, beginY, DOUBLE_BTN_SIZE, BTN_SIZE);        
        _0Button.tag = 0;
		[self addSubview:_0Button]; 
        
        beginX = beginX + _0Button.frame.size.width + BTN_PAD;

        //.
        UIButton *decimalPointButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[decimalPointButton addTarget:self action:@selector(buttonDigitPressed:) forControlEvents:UIControlEventTouchUpInside];
        [decimalPointButton setBackgroundImage:[UIImage imageNamed:@"dot.png"] forState:UIControlStateNormal];
        //UIButton *decimalPointButton = [self generateBtnWithTitle:@"." action:@selector(buttonDigitPressed:)];
        decimalPointButton.frame = CGRectMake(beginX, beginY, BTN_SIZE, BTN_SIZE);        
        [decimalPointButton.layer setValue:@"." forKey:@"operaton"];
        decimalPointButton.tag = DOT_TAG;
		[self addSubview:decimalPointButton]; 
        
        beginX = beginX + decimalPointButton.frame.size.width + BTN_PAD;

        
    }
    return self;
    
}

-(UIButton *) generateBtnWithTitle:(NSString *) title action:(SEL)action{
    
//    UIImage *imageH = [UIImage imageNamed:@"Reader-Button-H.png"];
//    UIImage *imageN = [UIImage imageNamed:@"Reader-Button-N.png"];
//    UIImage *buttonH = [imageH stretchableImageWithLeftCapWidth:5 topCapHeight:0];
//    UIImage *buttonN = [imageN stretchableImageWithLeftCapWidth:5 topCapHeight:0];
    
    
    UIButton *templateButton = [UIButton buttonWithType:UIButtonTypeCustom];

    [templateButton setTitle:title forState:UIControlStateNormal];
    [templateButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:1.0f] forState:UIControlStateNormal];
    [templateButton setTitleColor:[UIColor colorWithWhite:0.3f alpha:1.0f] forState:UIControlStateHighlighted];
    [templateButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    //[templateButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
    UIImage *btnImg = nil;
    if ([title isEqualToString:@"0"]) {
        btnImg = [UIImage imageNamed:@"double_square.png"];
    }else {
        btnImg = [UIImage imageNamed:@"square.png"];
    }
    [templateButton setBackgroundImage:btnImg forState:UIControlStateNormal];
    templateButton.titleLabel.font = [UIFont boldSystemFontOfSize:24.0f];
    
    return templateButton;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (void)dealloc
{
	[calculatorScreen release];
    [brain release];
	[super dealloc];
}




// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    
    //畫邊框
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Add a color for red up where the colors are
    CGColorRef drawColor = [UIColor whiteColor].CGColor;
    
    // Add down at the bottom
    //CGRect strokeRect = CGRectInset(rect, 5.0, 5.0);  // 內縮5pt
    
    CGContextSetStrokeColorWithColor(context, drawColor);
    CGContextSetLineWidth(context, 5.0);
    CGContextStrokeRect(context, rect);
}


#pragma mark UIButton action methods

-(void) closeCaculator:(UIButton *)btn {
    
    //call delegate close
    
    [delegate removeCalculatorView:self];
}

-(void) buttonOperationPressed:(UIButton *)btn {
    
	if(userIsInTheMiddleOfTypingANumber)
	{
		self.brain.operand = [calculatorScreen.text doubleValue];
		userIsInTheMiddleOfTypingANumber = NO;
	}
    
	NSString *operation = [btn.layer valueForKey:@"operaton"];
    
    // +, -, *, /
    if (btn.tag >= 50 && btn.tag <= 53 ) {

        if (self.lastOperationBtn!=btn) {
            self.lastOperationBtn.selected = NO;
        }
        
        btn.selected = YES;
        self.lastOperationBtn = btn;
        
    }
    
    
	[self.brain performOperation:operation];
    //科學符號，最多16位，因為float精度為32bits
	self.calculatorScreen.text = [NSString stringWithFormat:@"%.9g", self.brain.operand];

}

-(void) buttonDigitPressed:(UIButton *)btn {
    
    /*
	NSString *digit = btn.titleLabel.text;
	//NSString *floatingPoint = [NSString stringWithFormat:@"%f", calculatorText];
	NSString *floatingPoint = self.calculatorScreen.text;
    
    NSLog(@"floatingPoint:%@", floatingPoint);
    
	if([floatingPoint rangeOfString:@"."].location == NSNotFound)
	{
		NSLog(@"add dot.");
        self.calculatorScreen.text = [self.calculatorScreen.text stringByAppendingString:@"."];
	}
	
	if(userIsInTheMiddleOfTypingANumber)
	{
		self.calculatorScreen.text = [self.calculatorScreen.text stringByAppendingString:digit];
	}
	else {
		self.calculatorScreen.text = digit;
		userIsInTheMiddleOfTypingANumber = YES;
	}
    */
    
    
    BOOL isDot = (btn.tag == DOT_TAG);
    NSString *digit = nil;
    if (isDot) {
        digit = [[btn layer]valueForKey:@"operaton"];   //.
    }else {
        digit = btn.titleLabel.text;       //按鈕數字 
    }
    
    //已經輸入過. 再按.便不再處理
    if ([self.calculatorScreen.text rangeOfString:@"."].location != NSNotFound && isDot) {
        return;
    }
    
    self.lastOperationBtn.selected = NO;
    
    
    //
    if (userIsInTheMiddleOfTypingANumber)
    {   
        if ([self.calculatorScreen.text isEqualToString:@"0"]) {
            
            self.calculatorScreen.text = isDot ? @"0." : digit;
            
        }else {
            self.calculatorScreen.text = [self.calculatorScreen.text stringByAppendingString:digit];
        }
        
    } 
    else 
    {   
        self.calculatorScreen.text = isDot ? @"0." : digit;
        userIsInTheMiddleOfTypingANumber = YES;
    }
    

}

@end
