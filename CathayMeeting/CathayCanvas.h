//
//  CathayCanvas.h
//  CathayLifeB2EPad
//
//  Created by dev1 on 12/4/24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	CathayCanvasDrawTypeStroke,
	CathayCanvasDrawTypeImg,
	CathayCanvasDrawTypeText
} CathayCanvasDrawType; //繪圖型別

@interface CathayCanvas : UIView {
    
}

@property (retain) NSMutableArray* drawDataArray;
@property (retain) UIColor* brushColor;
@property float brushSize;
@property BOOL isHighlight;

//根據傳入的繪圖資料進行初始繪圖，當傳入nil時，會以預設值進行設定
- (id)initWithFrame:(CGRect)frame DrawData:(NSMutableArray *) _drawDataArray brushSize:(float) _brushSize brushColor:(UIColor *) _brushColor;   

//canvas Action
-(void) undo;
-(void) redo;
-(void) clearCanvas;

@end
