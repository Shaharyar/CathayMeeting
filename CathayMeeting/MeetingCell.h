//
//  MeetingCell.h
//  CathayMeeting
//
//  Created by dev1 on 2012/5/29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AQGridViewCell.h"


@interface MeetingCell : AQGridViewCell 

@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) IBOutlet UILabel *noPicLabel;
@property (retain, nonatomic) IBOutlet UIImageView *coverImg;



@end
