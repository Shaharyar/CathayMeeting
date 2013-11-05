//
//	ThumbsMainToolbar.h
//	Reader v2.5.0
//
//	Created by Julius Oklamcak on 2011-09-01.
//	Copyright © 2011 Julius Oklamcak. All rights reserved.
//
//	This work is being made available under a Creative Commons Attribution license:
//		«http://creativecommons.org/licenses/by/3.0/»
//	You are free to use this work and any derivatives of this work in personal and/or
//	commercial products and projects as long as the above copyright is maintained and
//	the original author is attributed.
//

//----------------------------
//  2011/11/24
//  Yu Jen Wang
//  調整Done名稱為返回，顯示標題列改為縮圖目錄
//----------------------------


#import <UIKit/UIKit.h>

#import "UIXToolbarView.h"

@class ThumbsMainToolbar;

@protocol ThumbsMainToolbarDelegate <NSObject>

@required // Delegate protocols

- (void)tappedInToolbar:(ThumbsMainToolbar *)toolbar doneButton:(UIButton *)button;

- (void)tappedInToolbar:(ThumbsMainToolbar *)toolbar showControl:(UISegmentedControl *)control;

@end

@interface ThumbsMainToolbar : UIXToolbarView
{
@private // Instance variables
}

@property (nonatomic, assign, readwrite) id <ThumbsMainToolbarDelegate> delegate;

- (id)initWithFrame:(CGRect)frame title:(NSString *)title;

@end