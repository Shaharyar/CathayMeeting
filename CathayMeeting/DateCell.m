//
//  DateCell.m
//  CathayMeeting
//
//  Created by dev1 on 2012/5/29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DateCell.h"

@implementation DateCell
@synthesize nameLabel;
@synthesize noPicLabel;
@synthesize coverImg;


- (void)dealloc {
    [nameLabel release];
    [coverImg release];
    [noPicLabel release];
    [super dealloc];
}
@end
