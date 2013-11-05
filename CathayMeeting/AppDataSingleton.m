//
//  AppDataSingleton.m
//  CathayBookShelf
//
//  Created by dev1 on 2012/2/14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AppDataSingleton.h"

@implementation AppDataSingleton
@synthesize okToLoad, cathayBooksOfflineModeEnabled;

static AppDataSingleton *theAppDataSingleton = nil;

+ (AppDataSingleton *)shareData
{
    if (theAppDataSingleton == nil) {
        theAppDataSingleton = [[super allocWithZone:NULL] init];
    }
    return theAppDataSingleton;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self shareData] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

@end
