//
//  NetDetectHelper.h
//  CathayMobiLife
//
//  Created by dev1 on 2011/2/16.
//  Copyright 2011 國泰人壽. All rights reserved.
//


#import <SystemConfiguration/SCNetworkReachability.h>
#include <netinet/in.h>

@interface NetDetectHelper : NSObject {

}
-(BOOL) connectedToNetwork;
@end
