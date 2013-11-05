//
//  PlistHelper.h
//  CathayInsTest
//
//  Created by Liu Bruce on 11/10/12.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlistHelper : NSObject{
    //NSMutableDictionary *typeCategorySettings;
    //NSArray *typeCategory;
    //NSMutableArray *typeValues;
}

//@property (nonatomic, retain) NSMutableDictionary *typeCategorySettings; 
//@property (nonatomic, retain) NSArray *typeCategory; 
//@property (nonatomic, retain) NSMutableArray *typeValues; 

//檢核plist文件是否存在
-(BOOL)checkPlist:(NSString *)plistName path:(NSString *)path;

//建立plist by filename, 路徑
-(void) createPlist:(NSString *)plistName path:(NSString *)path;

//取得plist Dic by 檔名、路徑
-(NSMutableDictionary *) getPlistDictionaryWithPlistName:(NSString *)plistName path:(NSString *)path;

//寫入plist by 資料、來源路徑、檔名
-(BOOL) writeDic:(NSMutableDictionary *) dataDic plistName:(NSString *)plistName path:(NSString *)path;

@end
