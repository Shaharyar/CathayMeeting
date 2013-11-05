//
//  NoteContentView.m
//  CathayMeeting
//
//  Created by Fanny Sheng on 12/7/30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NoteContentView.h"
#import "CathayCanvas.h"

#import <QuartzCore/QuartzCore.h>

@implementation NoteContentView

#pragma mark Constants

#define ZOOM_LEVELS 1

#if (READER_SHOW_SHADOWS == TRUE) // Option
#define CONTENT_INSET 4.0f
#else
#define CONTENT_INSET 2.0f
#endif // end of READER_SHOW_SHADOWS Option

#define PAGE_THUMB_LARGE 240
#define PAGE_THUMB_SMALL 144

#pragma mark Properties
@synthesize message;
@synthesize theContainerView, canvasView;

#pragma mark ReaderContentView functions

static inline CGFloat ZoomScaleThatFits(CGSize target, CGSize source)
{
    //Yu Jen Wang
    //改成僅以寬度決定ZoomScale
    CGFloat w_scale = (target.width / source.width);
	//CGFloat h_scale = (target.height / source.height);
    
	//return ((w_scale < h_scale) ? w_scale : h_scale);
    return w_scale;
}

#pragma mark ReaderContentView instance methods

- (void)updateMinimumMaximumZoom
{
	CGRect targetRect = CGRectInset(self.bounds, CONTENT_INSET, CONTENT_INSET);
    CGRect boundsRect = CGRectMake(0,0,594,840);//A4大小
    
	CGFloat zoomScale = ZoomScaleThatFits(targetRect.size, boundsRect.size);
    
	self.minimumZoomScale = zoomScale; // Set the minimum and maximum zoom scales
    
	self.maximumZoomScale = (zoomScale * ZOOM_LEVELS); // Max number of zoom levels
    
	zoomAmount = ((self.maximumZoomScale - self.minimumZoomScale) / ZOOM_LEVELS);
}


- (id)initWithFrame:(CGRect)frame drawData:(NSMutableArray *) _drawDataArray brushSize:(float) _brushSize brushColor:(UIColor *) _brushColor {
    
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
	if ((self = [super initWithFrame:frame]))
	{
        
        CGRect boundsRect = CGRectMake(0,0,594,840);//A4大小
        
        self.scrollsToTop = NO;
		self.delaysContentTouches = NO;
		self.showsVerticalScrollIndicator = NO;
		self.showsHorizontalScrollIndicator = NO;
		self.contentMode = UIViewContentModeRedraw;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.backgroundColor = [UIColor clearColor];
		self.userInteractionEnabled = YES;
		self.autoresizesSubviews = YES; //Wang
        self.scrollEnabled = NO; //Wang
		self.bouncesZoom = YES;
		self.delegate = self;
    
        UIImageView *imageView = [[[UIImageView alloc]initWithImage:[UIImage imageNamed: @"paper1.jpg"]]autorelease];        
        
        self.theContainerView = [[UIView alloc] initWithFrame:boundsRect];
       // theContainerView.autoresizesSubviews = YES;
       // theContainerView.userInteractionEnabled = NO;
       // theContainerView.contentMode = UIViewContentModeRedraw;
       // theContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
         [theContainerView addSubview:imageView]; 
        
        
        self.contentSize = boundsRect.size; // Content size same as view size
        self.contentOffset = CGPointMake((0.0f - CONTENT_INSET), (0.0f - CONTENT_INSET)); // Offset
        self.contentInset = UIEdgeInsetsMake(CONTENT_INSET, CONTENT_INSET, CONTENT_INSET, CONTENT_INSET); 

        
        //畫布
        self.canvasView = [[CathayCanvas alloc]initWithFrame:boundsRect DrawData:_drawDataArray brushSize:_brushSize brushColor:_brushColor];
        canvasView.userInteractionEnabled = YES;
        //self.canvasView.autoresizingMask =  UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        //self.canvasView.backgroundColor = [UIColor yellowColor];
        
         [theContainerView addSubview:canvasView]; 
         [self addSubview:theContainerView]; // Add the container view to the scroll view
        
        //Yu Jen Wang 強迫頁面拉到上面(頁面初始)
        [self setContentOffset:CGPointMake(0.0,0.0) animated:NO];       
        
        [self updateMinimumMaximumZoom]; // Update the minimum and maximum zoom scales
        
        self.zoomScale = self.minimumZoomScale; // Set zoom to fit page content
        
            
    }
        
	[self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:NULL];
        
//		self.tag = page; // Tag the view with the page number
	
    
	return self;
    
    
}


- (void)dealloc
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
	[self removeObserver:self forKeyPath:@"frame"];
    
	[theContainerView release], theContainerView = nil;
        
    [canvasView release], canvasView = nil;
        
	[super dealloc];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
        
    
	if ((object == self) && [keyPath isEqualToString:@"frame"])
	{
		CGFloat oldMinimumZoomScale = self.minimumZoomScale;
        
		[self updateMinimumMaximumZoom]; // Update zoom scale limits
        
		if (self.zoomScale == oldMinimumZoomScale) // Old minimum
		{
			self.zoomScale = self.minimumZoomScale;
		}
		else // Check against minimum zoom scale
		{
			if (self.zoomScale < self.minimumZoomScale)
			{
				self.zoomScale = self.minimumZoomScale;
			}
			else // Check against maximum zoom scale
			{
				if (self.zoomScale > self.maximumZoomScale)
				{
					self.zoomScale = self.maximumZoomScale;
				}
			}
		}
	}
    
    
    //self.zoomScale = 1.1;
    
}
/*
- (void)layoutSubviews
{

	[super layoutSubviews];
    
	CGSize boundsSize = self.bounds.size;
	CGRect viewFrame = theContainerView.frame;
    
	if (viewFrame.size.width < boundsSize.width)
		viewFrame.origin.x = (((boundsSize.width - viewFrame.size.width) / 2.0f) + self.contentOffset.x);
	else
		viewFrame.origin.x = 0.0f;
    
	if (viewFrame.size.height < boundsSize.height)
		viewFrame.origin.y = (((boundsSize.height - viewFrame.size.height) / 2.0f) + self.contentOffset.y);
	else
		viewFrame.origin.y = 0.0f;
    
	theContainerView.frame = viewFrame;
}
*/
/*
 - (id)singleTap:(UITapGestureRecognizer *)recognizer
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
	return [theContentView singleTap:recognizer];
}

 
- (void)zoomIncrement
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
	CGFloat zoomScale = self.zoomScale;
    
	if (zoomScale < self.maximumZoomScale)
	{
		zoomScale += zoomAmount; // += value
        
		if (zoomScale > self.maximumZoomScale)
		{
			zoomScale = self.maximumZoomScale;
		}
        
		[self setZoomScale:zoomScale animated:YES];
	}
}

- (void)zoomDecrement
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
	CGFloat zoomScale = self.zoomScale;
    
	if (zoomScale > self.minimumZoomScale)
	{
		zoomScale -= zoomAmount; // -= value
        
		if (zoomScale < self.minimumZoomScale)
		{
			zoomScale = self.minimumZoomScale;
		}
        
		[self setZoomScale:zoomScale animated:YES];
	}
}
*/
 
- (void)zoomReset
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
	if (self.zoomScale > self.minimumZoomScale)
	{
		self.zoomScale = self.minimumZoomScale;
	}
}


 
#pragma mark UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return theContainerView;
}

#pragma mark UIResponder instance methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event]; // Message superclass
    
	[message contentView:self touchesBegan:touches]; // Message delegate
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesCancelled:touches withEvent:event]; // Message superclass
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent:event]; // Message superclass
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesMoved:touches withEvent:event]; // Message superclass
}


@end


