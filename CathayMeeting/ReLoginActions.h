//
//  ReLoginActions.h
//  CathayLifeB2EPad
//
//  Created by dev1 on 2011/5/5.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ReLoginActions <NSObject>

@required
-(void) reloadContent;
@optional
-(UIWebView *)getWebView;


@end
