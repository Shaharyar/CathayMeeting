//
//  CalculatorBrain.h
//  Calculator
//
//  Created by Raghav Gulati on 5/4/11.
//  Copyright 2011 BergBries/University of Georgia. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface CalculatorBrain : NSObject {
@private
	double operand;
	NSString *waitingOperation;
	double waitingOperand;
	double operandInMemory;
    
    
    //
    NSString *lastOperation;
    double lastOperand;
}

//lets us set an operand
@property double operand;
@property double waitingOperand;
//lets us perform an operation
-(double)performOperation:(NSString *)operation;
@end
