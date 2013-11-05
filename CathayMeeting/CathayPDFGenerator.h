//
//  CathayPDFGenerator.h
//  CathayLifeB2EPad
//
//  Created by dev1 on 12/5/3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CathayPDFGenerator : NSObject {
    
	CGPDFDocumentRef _PDFDocRef;
    NSMutableDictionary *_pageStrokeDict;
}

//@fileURL  PDF檔案路徑
//@password 密碼
//@pageStrokeData 繪圖資料
- (id)initWithURL:(NSURL *)fileURL password:(NSString *)password pageStrokeData:(NSMutableDictionary *)pageStrokeDict;

- (BOOL) generatePdfWithFilePath:(NSString *)thefilePath;
- (BOOL) generatePdfWithFilePath:(NSString *)thefilePath page:(NSInteger)page;
- (BOOL) generatePdfWithBlankFile:(NSString *)thefilePath pageNum:(NSInteger)pageNum; //筆記頁匯圖(全部)
- (BOOL) generatePdfWithBlankFile:(NSString *)thefilePath pageNo:(NSInteger)pageNo; //筆記頁匯圖(單頁)

@end
