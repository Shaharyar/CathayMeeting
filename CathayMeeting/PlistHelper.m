//
//  PlistHelper.m
//  CathayInsTest
//
//  Created by Liu Bruce on 11/10/12.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "PlistHelper.h"
#import "CathayGlobalVariable.h"

@implementation PlistHelper

//@synthesize typeCategorySettings;
//@synthesize typeCategory;
//@synthesize typeValues;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}





//檢核plist文件是否存在
-(BOOL)checkPlist:(NSString *)plistName path:(NSString *)path{

    NSString *finalPath = [path stringByAppendingPathComponent:plistName];
    return [[NSFileManager defaultManager] fileExistsAtPath:finalPath];
}


//建立plist by filename, 路徑
-(void) createPlist:(NSString *)plistName path:(NSString *)path{
    
    //創建文件管理器
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSString *finalPath = [path stringByAppendingPathComponent:plistName];	

    //如果文件不存在則創建
    if ([fileManager fileExistsAtPath:finalPath] == NO) {
        
        //更改到待操作的目錄下 
        [fileManager changeCurrentDirectoryPath:[finalPath stringByExpandingTildeInPath]];
        [fileManager createFileAtPath:plistName contents:[NSData data] attributes:nil];
    }
}


//取得plist by 檔名、路徑
-(NSMutableDictionary *) getPlistDictionaryWithPlistName:(NSString *)plistName path:(NSString *)path{
	
	NSString *filePath = [path stringByAppendingPathComponent:plistName];
	BOOL success = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
	
	if(!success){
        #ifdef IS_DEBUG
        NSLog(@"plist is not Exist in path:%@", filePath);
        #endif
		return nil;
	}
	
	return [[[NSMutableDictionary alloc] initWithContentsOfFile:filePath] autorelease];
	
}

//寫入plist by 資料、來源路徑、檔名
-(BOOL) writeDic:(NSMutableDictionary *) dataDic plistName:(NSString *)plistName path:(NSString *)path{
    
    NSString *filePath = [path stringByAppendingPathComponent:plistName];
    [dataDic retain];
    BOOL sucess = [dataDic writeToFile:filePath atomically:YES];
    if (sucess) {
        #ifdef IS_DEBUG
        NSLog(@"writePlist success! filePath:%@",filePath);
        #endif
    }else{
        #ifdef IS_DEBUG
        NSLog(@"writePlist failed! filePath:%@",filePath);
        #endif
        
    }
    
    return sucess;
}

@end
