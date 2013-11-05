//
//  PushNotification.h
//  InsProposal
//
//  Created by dev1 on 2012/07/05.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PushNotificationDelegate.h"

@interface PushNotification : NSObject <PushNotificationDelegate> {
    
    //判斷是否沒有要更換使用者
    BOOL isNotChange;

}

-(void)callPushNotification;


@end
