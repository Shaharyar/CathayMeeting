//
//  MethodMasters.h
//  CathayInsB2C
//
//  Created by Liu Bruce on 11/10/25.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CathayFileHelper : NSObject{
    
}


//取得Documents路徑
+(NSString *)getDocumentPath;   

//取得Documents\folderName路徑
+(NSString *)getDocumentPathWithFolder:(NSString *)folderName;  

//////////////////////////////////////////////


//建立Doc下新資料夾
//在Document\folderName
+(BOOL) createFolderUnderDocument:(NSString *)folderName;

/////////////////////////////////////////////

//刪除檔案或資料夾
+(BOOL) deleteItem:(NSString *) path;

//刪除資料夾底下所有檔案(不包含資料夾)
+(BOOL) deleteFilesUnderFolder:(NSString *) folderPath;


/////////////////////////////////////////////

//若檔案不存在於doc下，將檔案從mainBundle中複製至Doc下
+(void)copyNeededFileToDocIfNeededWithFileName:(NSString *)fileName;

//無論檔案是否存在於doc下，將檔案從mainBundle中複製至Doc下
+(BOOL)forceCopyFileToDocWithFileName:(NSString *)fileName;
@end
