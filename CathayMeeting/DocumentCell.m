//
//  DocumentCell.m
//  InsProposal
//
//  Created by dev1 on 2012/5/29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DocumentCell.h"

@implementation DocumentCell
@synthesize nameLabel;
@synthesize noPicLabel;
@synthesize coverImg;
@synthesize statusImg;
@synthesize checkedImg;

- (void)dealloc {
    [nameLabel release];
    [coverImg release];
    [noPicLabel release];
    [statusImg release];
    [checkedImg release];
    [super dealloc];
}

-(void) setStatus:(GridStatus) in_status {
    
    status = in_status;
    
    switch (in_status) {
        case GridStatusNormal:
            self.statusImg.image = [UIImage imageNamed:@"label-undownload.png"];
            break;
        case GridStatusHasNewUpdate:
            self.statusImg.image = [UIImage imageNamed:@"label-update.png"];
            break;
        case GridStatusAlreadyDowloaded:
            self.statusImg.image = nil;
            break;
        case GridStatusInvalid:
            self.statusImg.image = [UIImage imageNamed:@"label-invalid.png"];
            break;
        default:
            self.statusImg.image = [UIImage imageNamed:@"label-undownload.png"];
            break;
    }
    
}

-(GridStatus) getStatus {
    
    return status;
}

-(void) checkCell {
    
    self.checkedImg.hidden = NO;
    
}


-(void) unCheckCell {
    self.checkedImg.hidden = YES;
}

@end
