//
//  CathayCaculatorView.h
//  CathayLifeB2EPad
//
//  Created by dev1 on 12/5/4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

///////////////////////////////////////////////////////////////
@class CathayCalculatorView;

@protocol CathayCalculatorViewDelegate <NSObject>

@required // Delegate protocols

- (void)removeCalculatorView:(CathayCalculatorView *)calculatorView;

@end



///////////////////////////////////////////////////////////////


@class CalculatorBrain, CathayCalculatorViewDelegate;

@interface CathayCalculatorView : UIView {
    @private
    float calculatorText;
	BOOL userIsInTheMiddleOfTypingANumber;

}

@property (nonatomic, assign) id<CathayCalculatorViewDelegate> delegate;

-(id) calculator;



@end
