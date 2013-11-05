//
//  NetDetectHelper.m
//  CathayMobiLife
//
//  Created by dev1 on 2011/2/16.
//  Copyright 2011 國泰人壽. All rights reserved.
//

#import "NetDetectHelper.h"


@implementation NetDetectHelper

// Courtesy of Apple
- (BOOL) connectedToNetwork
{
	// Create zero addy
	//ºô¸ô§PÂ_³sµ²
	struct sockaddr_in Addr;
	bzero(&Addr, sizeof(Addr));
	Addr.sin_len = sizeof(Addr);
	Addr.sin_family = AF_INET;
	
	SCNetworkReachabilityRef target = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *) &Addr);
	SCNetworkReachabilityFlags flags;
	SCNetworkReachabilityGetFlags(target, &flags);
	
	BOOL isConnected = NO;
	
	//wifi
	if (flags & kSCNetworkFlagsReachable){
		isConnected = YES;
	}
	//3G
	else if (flags & kSCNetworkReachabilityFlagsIsWWAN){
		isConnected = YES;
	}else{//
		isConnected = NO;
	}
	
	if (!isConnected) {
		UIAlertView *alert = [[UIAlertView alloc] 
							  initWithTitle: @"無網路連線" 
							  message:@"目前無網路連線，請開啟wifi或3G網路!" 
							  delegate:nil 
							  cancelButtonTitle:@"確定" 
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	
	return isConnected;
}

@end
