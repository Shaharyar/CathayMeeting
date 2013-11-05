//
//  CathayCanvas.m
//  CathayLifeB2EPad
//
//  Created by dev1 on 12/4/24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CathayCanvas.h"

#define DEFAULT_BRUSH_SIZE 2.0f

@interface CathayCanvas()
@property (retain) NSMutableArray* abandonedDrawDataArray;
@end


@implementation CathayCanvas

@synthesize drawDataArray, abandonedDrawDataArray;
@synthesize brushColor, brushSize;
@synthesize isHighlight;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code
        self.drawDataArray = [NSMutableArray array];
        self.abandonedDrawDataArray = [NSMutableArray array];
        self.isHighlight = NO;
        self.brushSize = DEFAULT_BRUSH_SIZE;
        self.brushColor = [UIColor redColor];
        self.backgroundColor = [UIColor clearColor];
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame DrawData:(NSMutableArray *) _drawDataArray brushSize:(float) _brushSize brushColor:(UIColor *) _brushColor
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        if (_drawDataArray) {
            self.drawDataArray = _drawDataArray;
        }else {
            self.drawDataArray = [NSMutableArray array];
        }
        
        if (_brushSize) {
            self.brushSize = _brushSize;
        }else {
            self.brushSize = DEFAULT_BRUSH_SIZE;
        }
        
        
        if (_brushColor) {
            self.brushColor = _brushColor;
        }else {
            self.brushColor = [UIColor redColor];
        }
        
        self.isHighlight = NO;
        self.abandonedDrawDataArray = [NSMutableArray array];        
        self.backgroundColor = [UIColor clearColor];
        
    }
    return self;
}

- (void)dealloc
{
	[drawDataArray release];
    [abandonedDrawDataArray release];
	[brushColor release];    
	[super dealloc];
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
        
    if (self.drawDataArray)
    {

        //Quarz2D
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetStrokeColorSpace(context, colorSpace);
        
        CGContextBeginPath(context);
        
        int arraynum = 0;
        // each iteration draw a stroke
        // line segments within a single stroke (path) has the same color and line width
        for (NSDictionary *dictStroke in self.drawDataArray)
        {
            NSArray *arrayPointsInstroke = [dictStroke objectForKey:@"points"];
            UIColor *color = [dictStroke objectForKey:@"color"];
            float size = [[dictStroke objectForKey:@"size"] floatValue];
            NSString* highlight = [dictStroke objectForKey:@"highlight"];
            
            //[color set];		// equivalent to both setFill and setStroke
            
            if (color == [UIColor clearColor]) {

                CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0, 0, 0, 0);
                CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeCopy);

            }else {
                
                CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeNormal);
                CGContextSetStrokeColorWithColor(context, color.CGColor);
                
                if ([highlight isEqualToString:@"Y"]) {
                    CGContextSetAlpha(context, 0.5);
                }else {
                    CGContextSetAlpha(context, 1.0);
                }
            
            }
            
            
            
            //			// won't draw a line which is too short
            //			if (arrayPointsInstroke.count < 3)	{
            //				arraynum++; 
            //				continue;		// if continue is executed, the program jumps to the next dictStroke
            //			}
            
            
            //                 // UIBezierPath 方法
            //                 
            //                 // draw the stroke, line by line, with rounded joints
            //                 UIBezierPath* pathLines = [UIBezierPath bezierPath];
            //                 CGPoint pointStart = CGPointFromString([arrayPointsInstroke objectAtIndex:0]);
            //                 [pathLines moveToPoint:pointStart];
            //                 for (int i = 0; i < (arrayPointsInstroke.count - 1); i++)
            //                 {
            //                 CGPoint pointNext = CGPointFromString([arrayPointsInstroke objectAtIndex:i+1]);
            //                 [pathLines addLineToPoint:pointNext];
            //                 }
            //                 pathLines.lineWidth = size;
            //                 pathLines.lineJoinStyle = kCGLineJoinRound;
            //                 pathLines.lineCapStyle = kCGLineCapRound;
            //                 [pathLines stroke];
            
            // Quarz2D 
            CGPoint pointStart = CGPointFromString([arrayPointsInstroke objectAtIndex:0]);
            
            CGContextMoveToPoint(context, pointStart.x, pointStart.y);
            
            for (int i = 0; i < (arrayPointsInstroke.count - 1); i++)
            {
                CGPoint pointNext = CGPointFromString([arrayPointsInstroke objectAtIndex:i+1]);
                CGContextAddLineToPoint(context, pointNext.x, pointNext.y);
            }
            
            CGContextSetLineWidth(context, size);
            CGContextStrokePath(context);
            
            arraynum++;
        }

        CGColorSpaceRelease(colorSpace);
    }
    
}

#pragma mark UIResponder instance methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	//NSLog(@"CathayCanvas touchesBegan");
    
    NSMutableArray *arrayPointsInStroke = [NSMutableArray array];
    NSMutableDictionary *dictStroke = [NSMutableDictionary dictionary];
    [dictStroke setObject:arrayPointsInStroke forKey:@"points"];
    [dictStroke setObject:self.brushColor forKey:@"color"];
    [dictStroke setObject:[NSNumber numberWithFloat:self.brushSize] forKey:@"size"];
    
    if (isHighlight) {
        [dictStroke setObject:@"Y" forKey:@"highlight"];
    }else {
        [dictStroke setObject:@"N" forKey:@"highlight"];
    }
    
    
    CGPoint point = [[touches anyObject] locationInView:self];  //獲得觸摸點的座標 
    [arrayPointsInStroke addObject:NSStringFromCGPoint(point)];
    
    [self.drawDataArray addObject:dictStroke];
        
    [super touchesBegan:touches withEvent:event]; // Message superclass
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	//NSLog(@"CathayCanvas touchesCancelled");
    
    [super touchesCancelled:touches withEvent:event]; // Message superclass
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	//NSLog(@"CathayCanvas touchesEnded");
 
    [self.abandonedDrawDataArray removeAllObjects];
    
	[super touchesEnded:touches withEvent:event]; // Message superclass
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	//NSLog(@"CathayCanvas touchesMoved");
    
    CGPoint point = [[touches anyObject] locationInView:self];
	CGPoint prevPoint = [[touches anyObject] previousLocationInView:self];    
    
    NSMutableArray *arrayPointsInStroke = [[self.drawDataArray lastObject] objectForKey:@"points"];
    [arrayPointsInStroke addObject:NSStringFromCGPoint(point)];
	
	CGRect rectToRedraw = CGRectMake(\
									 ((prevPoint.x>point.x)?point.x:prevPoint.x)-brushSize,\
									 ((prevPoint.y>point.y)?point.y:prevPoint.y)-brushSize,\
									 fabs(point.x-prevPoint.x)+2*brushSize,\
									 fabs(point.y-prevPoint.y)+2*brushSize\
									 );
	[self setNeedsDisplayInRect:rectToRedraw];
    
    
	[super touchesMoved:touches withEvent:event]; // Message superclass
}

#pragma mark canvas Action

-(void) undo {
	if ([drawDataArray count]>0) {
		NSMutableDictionary* dictAbandonedStroke = [drawDataArray lastObject];
		[self.abandonedDrawDataArray addObject:dictAbandonedStroke];
		[self.drawDataArray removeLastObject];
		[self setNeedsDisplay];
	}
}

-(void) redo {
	if ([abandonedDrawDataArray count]>0) {
		NSMutableDictionary* dictReusedStroke = [abandonedDrawDataArray lastObject];
		[self.drawDataArray addObject:dictReusedStroke];
		[self.abandonedDrawDataArray removeLastObject];
		[self setNeedsDisplay];
	}
}

-(void) clearCanvas {
	//self.pickedImage = nil;
	[self.drawDataArray removeAllObjects];
	[self.abandonedDrawDataArray removeAllObjects];
	[self setNeedsDisplay];
}

@end
