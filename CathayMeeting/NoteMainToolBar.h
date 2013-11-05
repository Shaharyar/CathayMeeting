//
//  NoteMainToolBar.h
//  CathayMeeting
//
//  Created by Fanny Sheng on 12/8/1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NoteMainToolBar;

@protocol NoteMainToolBarDelegate <NSObject>

@required // Delegate protocols

- (void)tappedInNoteToolBar:(NoteMainToolBar *)toolbar nextButton:(UIButton *)button;
- (void)tappedInNoteToolBar:(NoteMainToolBar *)toolbar previousButton:(UIButton *)button;
- (void)tappedInNoteToolBar:(NoteMainToolBar *)toolbar emailButton:(UIButton *)button;
- (void)tappedInNoteToolBar:(NoteMainToolBar *)toolbar handBoardButton:(UIButton *)button;

@end


@interface NoteMainToolBar : UIView


@property (nonatomic, retain) UILabel *pageLabel;
@property (nonatomic, assign, readwrite) id <NoteMainToolBarDelegate> delegate;



//-(void) resetStatus;
//-(void) setStatus:(NSInteger)penButton;

@end


