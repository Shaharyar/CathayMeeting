//
//  CathayCanvasToolBar.h
//  CathayLifeB2EPad
//
//  Created by dev1 on 12/4/25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CathayCanvasToolBar;

@protocol CathayCanvasToolBarDelegate <NSObject>

@required // Delegate protocols

- (void)tappedInCanvasToolBar:(CathayCanvasToolBar *)toolbar undoButton:(UIButton *)button;
- (void)tappedInCanvasToolBar:(CathayCanvasToolBar *)toolbar redoButton:(UIButton *)button;
- (void)tappedInCanvasToolBar:(CathayCanvasToolBar *)toolbar finishButton:(UIButton *)button;
- (void)tappedInCanvasToolBar:(CathayCanvasToolBar *)toolbar normalPenButton:(UIButton *)button;
- (void)tappedInCanvasToolBar:(CathayCanvasToolBar *)toolbar lightPenButton:(UIButton *)button;
- (void)tappedInCanvasToolBar:(CathayCanvasToolBar *)toolbar colorButton:(UIButton *)button; 
- (void)tappedInCanvasToolBar:(CathayCanvasToolBar *)toolbar sizeButton:(UIButton *)button; 
- (void)tappedInCanvasToolBar:(CathayCanvasToolBar *)toolbar eraserButton:(UIButton *)button; 
//- (void)tappedInCanvasToolBar:(CathayCanvasToolBar *)toolbar caculatorButton:(UIButton *)button; 

@end



@interface CathayCanvasToolBar : UIView {
    
    UIButton *cacheButton;  //cache last user pressed button 
}

@property (nonatomic, assign, readwrite) id <CathayCanvasToolBarDelegate> delegate;

-(void) resetStatus;
-(void) setStatus:(NSInteger)penButton;

@end
