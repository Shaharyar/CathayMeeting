//
//  CathayPDFGenerator.m
//  CathayLifeB2EPad
//
//  Created by dev1 on 12/5/3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CathayPDFGenerator.h"
#import "CGPDFDocument.h"
#import "CathayGlobalVariable.h"

@interface CathayPDFGenerator()
-(void) drawPDFPage:(CGPDFPageRef) drawPDFPageRef rect:(CGRect) rect;
-(void) drawUserStrokesWithDrawData:(NSMutableArray *) drawDataArray;
@end

@implementation CathayPDFGenerator

#pragma mark init

- (id)initWithURL:(NSURL *)fileURL password:(NSString *)password pageStrokeData:(NSMutableDictionary *)pageStrokeDict{
    
    
  	if ((self = [super init])) // Initialize
    {
        if (fileURL != nil) // Check for non-nil file URL
        {
            _PDFDocRef = CGPDFDocumentCreateX((CFURLRef)fileURL, password);
            
            if (_PDFDocRef == NULL) 
            {
                NSAssert(NO, @"CGPDFDocumentRef == NULL");                
                return nil;
            }
            
        }
        else // Error out with a diagnostic
        {
            NSAssert(NO, @"fileURL == nil");
            return nil;
        }

        _pageStrokeDict = [pageStrokeDict retain];
    }
    
    return self;
}


- (void)dealloc
{
    [_pageStrokeDict release];
	CGPDFDocumentRelease(_PDFDocRef), _PDFDocRef = NULL;
	[super dealloc];
}


#pragma mark generator Methods

- (BOOL) generatePdfWithFilePath:(NSString *)thefilePath {

    if (_PDFDocRef == NULL) 
    {
        NSAssert(NO, @"_PDFDocRef == NULL");                
        return NO;
    }else if(!thefilePath || [thefilePath length]==0){
        NSAssert(NO, @"thefilePath empty");                
        return NO;
    }

    #ifdef IS_DEBUG
    NSLog(@"filePath:%@", thefilePath);
    #endif
    
    //CGPDFDictionaryRef pdfMetaDataDic = CGPDFDocumentGetInfo(_PDFDocRef);
    
    
    //set metadata
    CFMutableDictionaryRef metaDataDic = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    //CFDictionarySetValue(metaDataDic, kCGPDFContextTitle, CFSTR("匯出文件"));
    CFDictionarySetValue(metaDataDic, kCGPDFContextCreator, CFSTR("行動會議"));    
    
    //
    BOOL createOK = UIGraphicsBeginPDFContextToFile(thefilePath, CGRectZero, metaDataDic);
    
    CFRelease(metaDataDic);
    
    NSInteger totalPages = CGPDFDocumentGetNumberOfPages(_PDFDocRef);
    
    for (int page = 1; page<=totalPages; page++) {
        

        CGPDFPageRef _PDFPageRef = CGPDFDocumentGetPage(_PDFDocRef, page); // Get page
        
        if (_PDFPageRef != NULL) // Check for non-NULL CGPDFPageRef
        {
            CGPDFPageRetain(_PDFPageRef); // Retain the PDF page
            
            CGRect cropBoxRect = CGPDFPageGetBoxRect(_PDFPageRef, kCGPDFCropBox);
            CGRect mediaBoxRect = CGPDFPageGetBoxRect(_PDFPageRef, kCGPDFMediaBox);
            CGRect effectiveRect = CGRectIntersection(cropBoxRect, mediaBoxRect);
            
            //Start a new page.
            UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, effectiveRect.size.width, effectiveRect.size.height), nil);
            
            
            [self drawPDFPage:_PDFPageRef rect:effectiveRect];  //繪製pdf頁面
            
            NSMutableArray *drawDataArray = [_pageStrokeDict objectForKey:[NSNumber numberWithInt:page]];
            //NSLog(@"page:%d ,drawDataArray count:%d", page, [drawDataArray count]);
            [self drawUserStrokesWithDrawData:drawDataArray]; //繪製使用者繪圖資訊
            
            CGPDFPageRelease(_PDFPageRef);
        }

    }
    
    // Close the PDF context and write the contents out.
    UIGraphicsEndPDFContext();
        
    return YES;

}


- (BOOL) generatePdfWithFilePath:(NSString *)thefilePath page:(NSInteger)page {
    
    if (_PDFDocRef == NULL) 
    {
        NSAssert(NO, @"_PDFDocRef == NULL");                
        return NO;
    }else if(!thefilePath || [thefilePath length]==0){
        NSAssert(NO, @"thefilePath empty");                
        return NO;
    }
    
    #ifdef IS_DEBUG
    NSLog(@"filePath:%@", thefilePath);
    #endif
    
    //metadata
    CFMutableDictionaryRef metaDataDic = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    //CFDictionarySetValue(metaDataDic, kCGPDFContextTitle, CFSTR("匯出文件"));
    CFDictionarySetValue(metaDataDic, kCGPDFContextCreator, CFSTR("行動會議"));    
    
    //
    UIGraphicsBeginPDFContextToFile(thefilePath, CGRectZero, metaDataDic);
    
    CFRelease(metaDataDic);
    
    CGPDFPageRef _PDFPageRef = CGPDFDocumentGetPage(_PDFDocRef, page); // Get page
    
    if (_PDFPageRef != NULL) // Check for non-NULL CGPDFPageRef
    {
        CGPDFPageRetain(_PDFPageRef); // Retain the PDF page
        
        CGRect cropBoxRect = CGPDFPageGetBoxRect(_PDFPageRef, kCGPDFCropBox);
        CGRect mediaBoxRect = CGPDFPageGetBoxRect(_PDFPageRef, kCGPDFMediaBox);
        CGRect effectiveRect = CGRectIntersection(cropBoxRect, mediaBoxRect);
        
        //Start a new page.
        UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, effectiveRect.size.width, effectiveRect.size.height), nil);
        
        
        [self drawPDFPage:_PDFPageRef rect:effectiveRect];  //繪製pdf頁面
        
        NSMutableArray *drawDataArray = [_pageStrokeDict objectForKey:[NSNumber numberWithInt:page]];
        //NSLog(@"page:%d ,drawDataArray count:%d", page, [drawDataArray count]);
        [self drawUserStrokesWithDrawData:drawDataArray]; //繪製使用者繪圖資訊
        
        CGPDFPageRelease(_PDFPageRef);
    
    }else {
        
        return NO;
    }
    
    // Close the PDF context and write the contents out.
    UIGraphicsEndPDFContext();
    
    return YES;
    
}

- (BOOL) generatePdfWithBlankFile:(NSString *)thefilePath pageNum:(NSInteger)pageNum {
    
    if (_PDFDocRef == NULL) 
    {
        NSAssert(NO, @"_PDFDocRef == NULL");                
        return NO;
    }else if(!thefilePath || [thefilePath length]==0){
        NSAssert(NO, @"thefilePath empty");                
        return NO;
    }
    
#ifdef IS_DEBUG
    NSLog(@"filePath:%@", thefilePath);
#endif
    
    //metadata
    CFMutableDictionaryRef metaDataDic = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    //CFDictionarySetValue(metaDataDic, kCGPDFContextTitle, CFSTR("匯出文件"));
    CFDictionarySetValue(metaDataDic, kCGPDFContextCreator, CFSTR("行動會議"));    
    
    UIGraphicsBeginPDFContextToFile(thefilePath, CGRectZero, metaDataDic);
    
    CFRelease(metaDataDic);
    
  //  NSLog(@"total page: %d",pageNo);
    
    for (int page = 0; page< pageNum; page++) {
        
        CGPDFPageRef _PDFPageRef = CGPDFDocumentGetPage(_PDFDocRef, 1); // Get first page
        
        if (_PDFPageRef != NULL) // Check for non-NULL CGPDFPageRef
        {
            CGPDFPageRetain(_PDFPageRef); // Retain the PDF page
            
            CGRect cropBoxRect = CGPDFPageGetBoxRect(_PDFPageRef, kCGPDFCropBox);
            CGRect mediaBoxRect = CGPDFPageGetBoxRect(_PDFPageRef, kCGPDFMediaBox);
            CGRect effectiveRect = CGRectIntersection(cropBoxRect, mediaBoxRect);
            
            //Start a new page.
            UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, effectiveRect.size.width, effectiveRect.size.height), nil);
            
            
            [self drawPDFPage:_PDFPageRef rect:effectiveRect];  //繪製pdf頁面
            
            NSMutableArray *drawDataArray = [_pageStrokeDict objectForKey:[NSNumber numberWithInt:page]];
            //NSLog(@"page:%d ,drawDataArray count:%d", page, [drawDataArray count]);
            [self drawUserStrokesWithDrawData:drawDataArray]; //繪製使用者繪圖資訊
            
            CGPDFPageRelease(_PDFPageRef);
        }else {
            return NO;
        }
        
    }

    // Close the PDF context and write the contents out.
    UIGraphicsEndPDFContext();
    
    return YES;
    
}

- (BOOL) generatePdfWithBlankFile:(NSString *)thefilePath pageNo:(NSInteger)pageNo {
    
    if (_PDFDocRef == NULL) 
    {
        NSAssert(NO, @"_PDFDocRef == NULL");                
        return NO;
    }else if(!thefilePath || [thefilePath length]==0){
        NSAssert(NO, @"thefilePath empty");                
        return NO;
    }
    
#ifdef IS_DEBUG
    NSLog(@"filePath:%@", thefilePath);
#endif
    
    //metadata
    CFMutableDictionaryRef metaDataDic = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    //CFDictionarySetValue(metaDataDic, kCGPDFContextTitle, CFSTR("匯出文件"));
    CFDictionarySetValue(metaDataDic, kCGPDFContextCreator, CFSTR("行動會議"));    
    
    UIGraphicsBeginPDFContextToFile(thefilePath, CGRectZero, metaDataDic);
    
    CFRelease(metaDataDic);
            
        CGPDFPageRef _PDFPageRef = CGPDFDocumentGetPage(_PDFDocRef, 1); // Get first page
        
        if (_PDFPageRef != NULL) // Check for non-NULL CGPDFPageRef
        {
            CGPDFPageRetain(_PDFPageRef); // Retain the PDF page
            
            CGRect cropBoxRect = CGPDFPageGetBoxRect(_PDFPageRef, kCGPDFCropBox);
            CGRect mediaBoxRect = CGPDFPageGetBoxRect(_PDFPageRef, kCGPDFMediaBox);
            CGRect effectiveRect = CGRectIntersection(cropBoxRect, mediaBoxRect);
            
            //Start a new page.
            UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, effectiveRect.size.width, effectiveRect.size.height), nil);
            
            
            [self drawPDFPage:_PDFPageRef rect:effectiveRect];  //繪製pdf頁面
            
            NSMutableArray *drawDataArray = [_pageStrokeDict objectForKey:[NSNumber numberWithInt:pageNo]];
            //NSLog(@"page:%d ,drawDataArray count:%d", page, [drawDataArray count]);
            [self drawUserStrokesWithDrawData:drawDataArray]; //繪製使用者繪圖資訊
            
            CGPDFPageRelease(_PDFPageRef);
        }else {
            return NO;
        }
    
    // Close the PDF context and write the contents out.
    UIGraphicsEndPDFContext();
    
    return YES;
    
}


-(void) drawPDFPage:(CGPDFPageRef) drawPDFPageRef rect:(CGRect) rect{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    
	CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f); // White
    
	CGContextFillRect(context, CGContextGetClipBoundingBox(context)); // Fill
    
	CGContextTranslateCTM(context, 0.0f, rect.size.height); 
    CGContextScaleCTM(context, 1.0f, -1.0f);
	CGContextConcatCTM(context, CGPDFPageGetDrawingTransform(drawPDFPageRef, kCGPDFCropBox, rect, 0, true));
	CGContextSetRenderingIntent(context, kCGRenderingIntentDefault); 
    CGContextSetInterpolationQuality(context, kCGInterpolationDefault);
	CGContextDrawPDFPage(context, drawPDFPageRef); // Render the PDF page into the context
    
    CGContextRestoreGState(context);
}


-(void) drawUserStrokesWithDrawData:(NSMutableArray *) drawDataArray{
    
    if (drawDataArray)
    {
        
        //Quarz2D
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetStrokeColorSpace(context, colorSpace);
        
        CGContextBeginPath(context);
        
        int arraynum = 0;
        // each iteration draw a stroke
        // line segments within a single stroke (path) has the same color and line width
        for (NSDictionary *dictStroke in drawDataArray)
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

@end
