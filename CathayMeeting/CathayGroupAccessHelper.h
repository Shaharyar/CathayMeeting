//
//  CathayGroupAccessHelper.h
//  CathayLifeAppStore
//
//  Created by dev1 on 2012/3/19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
//  國泰人壽系列APP 資料Share存取

#import <Foundation/Foundation.h>

@interface CathayGroupAccessHelper : NSObject


- (NSString *) getAppVersionWithAppScheme:(NSString *) appScheme;
-(void) putAppVersion:(NSString *) version WithAppScheme:(NSString *) appScheme;

@end
