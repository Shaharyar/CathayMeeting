//
//  CathayDeviceUtil.m
//  CathayLifeAppStore
//
//  Created by dev1 on 2012/2/16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CathayDeviceUtil.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#include <sys/types.h>
#include <sys/sysctl.h>


@implementation CathayDeviceUtil

#pragma mark - App info

//程式版本
+(NSString *) appVersion {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

//App Scheme
+(NSString *) appUrlSchemes {
    
    NSBundle* mainBundle = [NSBundle mainBundle];
    NSArray* cfBundleURLTypes = [mainBundle objectForInfoDictionaryKey:@"CFBundleURLTypes"];
    
    if ([cfBundleURLTypes isKindOfClass:[NSArray class]] && [cfBundleURLTypes lastObject]) {
        NSDictionary* cfBundleURLTypes0 = [cfBundleURLTypes objectAtIndex:0];
        if ([cfBundleURLTypes0 isKindOfClass:[NSDictionary class]]) {
            NSArray* cfBundleURLSchemes = [cfBundleURLTypes0 objectForKey:@"CFBundleURLSchemes"];
            if ([cfBundleURLSchemes isKindOfClass:[NSArray class]]) {
                
                //只取第一筆
                NSString* scheme =  [cfBundleURLSchemes objectAtIndex:0];
                
                if ([scheme isKindOfClass:[NSString class]]) {
                    return scheme;
                }

            }
        }
    }
    
    return nil;
}


//App identifier
+(NSString *) appIdentifier {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
}

#pragma mark - Device info

//iOS version
+(NSString *) osVersion {
    return [[UIDevice currentDevice] systemVersion];
}

//UDID
//iOS 5已宣布棄用，未來需由App 自行建立
//https://developer.apple.com/library/IOs/#documentation/UIKit/Reference/UIDevice_Class/DeprecationAppendix/AppendixADeprecatedAPI.html
+(NSString *) UDID {
    
    return [[UIDevice currentDevice] uniqueIdentifier];
}

//電信商
+(NSString *) carrier {
    CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netinfo subscriberCellularProvider];
    [netinfo release];
    return [carrier carrierName];
}

//裝置名稱 
//參考自：https://gist.github.com/1323251
+(NSString *) platform {
    
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    
    
    //判斷裝置
    //在後端串規格
    /*
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
     */
    return platform;
}


#pragma mark - 地理位置

//國家
+(NSString *) country {
    
    return nil;
}

//縣市區，例："台北市內湖區"
+(NSString *) location {
    
    return nil;
}


+(void) test {
    NSLog(@"--------App Info-----------");
    NSLog(@"appVersion:%@, appUrlSchemes:%@, appIdentifier:%@", [self appVersion], [self appUrlSchemes], [self appIdentifier]);

    
    NSLog(@"--------Device Info--------");
    NSLog(@"osVersion:%@, UDID:%@, carrier:%@, platform:%@", [self osVersion], [self UDID], [self carrier], [self platform]);    
}


@end
