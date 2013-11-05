//
//  CathayDeviceUtil.h
//  CathayLifeAppStore
//
//  Created by dev1 on 2012/2/16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

//  請匯入 CoreTelephony.framework

#import <Foundation/Foundation.h>

@interface CathayDeviceUtil : NSObject

//App info
+(NSString *) appVersion;
+(NSString *) appUrlSchemes;
+(NSString *) appIdentifier;

//Device info
+(NSString *) osVersion;
+(NSString *) UDID;
+(NSString *) carrier;
+(NSString *) platform;

//地理位置(尚未實作)
//+(NSString *) country;
//+(NSString *) location;

@end
