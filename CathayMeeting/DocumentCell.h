//
//  DocumentCell.h
//  InsProposal
//
//  Created by dev1 on 2012/5/29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AQGridViewCell.h"

typedef enum {
	GridStatusNormal = 0,
	GridStatusHasNewUpdate = 1,
	GridStatusAlreadyDowloaded = 2,
    GridStatusInvalid = 3
} GridStatus;


@interface DocumentCell : AQGridViewCell {
    
     UILabel *bookStatusBarLabel;
     GridStatus status;

    
}

@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) IBOutlet UILabel *noPicLabel;
@property (retain, nonatomic) IBOutlet UIImageView *coverImg;
@property (retain, nonatomic) IBOutlet UIImageView *statusImg;
@property (retain, nonatomic) IBOutlet UIImageView *checkedImg;


-(void) setStatus:(GridStatus) in_status;
-(GridStatus) getStatus;

-(void) checkCell;
-(void) unCheckCell;



@end
