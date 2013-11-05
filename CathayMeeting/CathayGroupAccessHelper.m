//
//  CathayGroupAccessHelper.m
//  CathayLifeAppStore
//
//  Created by dev1 on 2012/3/19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CathayGroupAccessHelper.h"
#import "CathayKeychianHelper.h"
#import "CathayGlobalVariable.h"

@implementation CathayGroupAccessHelper

#define ACCESS_GROUP @"67K3CN595T.tw.com.cathaylife.CathayLifeB2ESuite"

#pragma mark - App版本

- (NSString *) getAppVersionWithAppScheme:(NSString *) appScheme {
    
    if (!appScheme || [appScheme length]==0) {
        return nil;
    }
    
    NSString *versionIdentity = [NSString stringWithFormat:@"%@_ver", appScheme];
    
    CathayKeychianHelper *keychain = [[CathayKeychianHelper alloc] initWithAccessGroup:ACCESS_GROUP Identity:versionIdentity Service:versionIdentity];
    NSString *version = [keychain getText];
    [keychain release];
    
    #ifdef IS_DEBUG
    NSLog(@"取得已安裝app:%@ 版本號:%@", appScheme, version);
    #endif
    
    return version;
}

-(void) putAppVersion:(NSString *) version WithAppScheme:(NSString *) appScheme {
    
    if (!appScheme || [appScheme length]==0) {
        #ifdef IS_DEBUG
        NSLog(@"放入Group版本號，appScheme為空");
        #endif
        return;
    }

    if (!appScheme || [appScheme length]==0) {
        #ifdef IS_DEBUG
        NSLog(@"放入Group版本號，version為空");
        #endif
        return;
    }
    
    NSString *versionIdentity = [NSString stringWithFormat:@"%@_ver", appScheme];
    
    CathayKeychianHelper *keychain = [[CathayKeychianHelper alloc] initWithAccessGroup:ACCESS_GROUP Identity:versionIdentity Service:versionIdentity];
    [keychain putText:version];
    [keychain release];
}



@end
