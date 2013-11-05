//
//  PushNotificationDelegate.h
//  InsProposal
//
//  Created by dev1 on 2012/07/05.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PushNotificationDelegate <NSObject>

- (void) returnAPNStoken:(NSString *)token;


@end
