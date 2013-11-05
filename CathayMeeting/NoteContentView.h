//
//  NoteContentView.h
//  CathayMeeting
//
//  Created by Fanny Sheng on 12/7/30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NoteContentView;
@class CathayCanvas;

@protocol NoteContentViewDelegate <NSObject>

@required // Delegate protocols

- (void)contentView:(NoteContentView *)contentView touchesBegan:(NSSet *)touches;

@end

@interface NoteContentView : UIScrollView <UIScrollViewDelegate>
{
@private // Instance variables
    
    UIView *theContainerView;
    
	CGFloat zoomAmount;
}

@property (nonatomic, assign, readwrite) id <NoteContentViewDelegate> message;
@property (nonatomic, assign) UIView *theContainerView;
@property (nonatomic, assign) CathayCanvas *canvasView;


- (id)initWithFrame:(CGRect)frame drawData:(NSMutableArray *) _drawDataArray brushSize:(float) _brushSize brushColor:(UIColor *) _brushColor;

//- (id)singleTap:(UITapGestureRecognizer *)recognizer;

//- (void)zoomIncrement;
//- (void)zoomDecrement;
- (void)zoomReset;


@end
