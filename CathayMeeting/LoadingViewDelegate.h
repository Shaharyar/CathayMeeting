//
//  LoadingViewDelegate.h
//  CathayLifeB2EPad
//
//  Created by dev1 on 2011/5/16.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol LoadingViewDelegate <NSObject>
@required
-(void) showLoadViewWithText:(NSString *)text;
-(void) hideLoadView;
@end
