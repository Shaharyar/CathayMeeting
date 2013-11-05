//
//  CathayChangePageBar.h
//  CathayMeeting
//
//  Created by Fanny Sheng on 12/6/5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CathayChangePageBar;

@protocol CathayCanvasToolBarDelegate <NSObject>

@required // Delegate protocols

- (void)tappedInChangePageBar:(CathayChangePageBar *)toolbar nextButton:(UIButton *)button;
- (void)tappedInChangePageBar:(CathayChangePageBar *)toolbar prevButton:(UIButton *)button;
- (void)tappedInChangePageBar:(CathayChangePageBar *)toolbar showToolbarButton:(UIButton *)button;

@end

@interface CathayChangePageBar : UIView{

    UILabel *nowPage;

}


@property (nonatomic, assign, readwrite) id <CathayCanvasToolBarDelegate> delegate;


@end
