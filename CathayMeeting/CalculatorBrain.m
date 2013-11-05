//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Raghav Gulati on 5/4/11.
//  Copyright 2011 BergBries/University of Georgia. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()
- (double)performWaitingOperation;
@end

@implementation CalculatorBrain

@synthesize operand, waitingOperand;

- (double)performWaitingOperation
{
	if([@"+" isEqual:waitingOperation])
	{
        operand = waitingOperand + operand;
//        return waitingOperand + operand;
        
	}
	else if([@"*" isEqual:waitingOperation])
	{
		operand = waitingOperand * operand;
//        return waitingOperand * operand;;
	}
	else if([@"-" isEqual:waitingOperation])
	{
		operand = waitingOperand - operand;
//        return waitingOperand - operand;
	}
	else if([@"/" isEqual:waitingOperation])
	{
		if(operand)
		{
			operand = waitingOperand / operand;
//            return waitingOperand / operand;
		}
	}
}

-(double)performOperation:(NSString *)operation;
{
    
    //single operand operation occuring here
//	if([operation isEqual:@"sqrt"])
//	{
//		operand = sqrt(operand);
//	}
//	else if ([@"+/-" isEqual:operation])
//	{
//		operand = - operand;
//	}
//	else if ([@"1/x" isEqual:operation])
//	{
//		if (operand) operand = 1/operand;
//	}
//	else if ([@"sin" isEqual:operation])
//	{
//		operand = sin(operand);
//	}
//	else if ([@"cos" isEqual:operation])
//	{
//		operand = cos(operand);
//	}
//	//operand operation involving memory
//	else if ([@"Store" isEqual:operation])
//	{
//		operandInMemory = operand;
//	}
//	else if ([@"Recall" isEqual:operation])
//	{
//		operand = operandInMemory; 
//	}
//	else if ([@"Mem+" isEqual:operation])
//	{
//		operandInMemory = operand + operandInMemory;
//	}
//	else if ([@"C" isEqual:operation])
	if ([@"C" isEqual:operation])    
	{
		operand = 0;
		waitingOperation = nil;
		waitingOperand = 0;
        
	}
	//if asking for 2-operand operation 
	else
	{
        if ([operation isEqualToString:@"="]) {
            
            //當連續按=，以最近一次計算的運算元進行計算，如：10 + 2 = 12，之後在按= 就會一直 + 2
            if ([waitingOperation isEqualToString:@"="]) {
                waitingOperation = lastOperation;
                operand = lastOperand;
            }else {
                lastOperation = waitingOperation;
                lastOperand = operand;
            }

            [self performWaitingOperation]; //當為=號時，進行實際計算動作
            //記錄運算元及目前數值
            waitingOperation = operation;
            waitingOperand = operand; 
            
        // + - * /
        }else {
            
            //避免連加、連除等
            if (![waitingOperation isEqualToString:operation]) {
                [self performWaitingOperation]; //當為=號時，進行實際計算動作
                //記錄運算元及目前數值
                waitingOperation = operation;
                waitingOperand = operand; 
            }
            
        }

		
	}	
	return operand;
	
}

@end
