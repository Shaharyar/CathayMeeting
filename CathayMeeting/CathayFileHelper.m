//
//  MethodMasters.m
//  CathayInsB2C
//
//  Created by Liu Bruce on 11/10/25.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "CathayFileHelper.h"
#import "PlistHelper.h"
#import "CathayGlobalVariable.h"

//-------------------------------------------------------------------------
//define

@interface CathayFileHelper ()

@end


//-------------------------------------------------------------------------
//implementation


@implementation CathayFileHelper

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

#pragma mark -
#pragma mark query

//取得Documents路徑
+(NSString *)getDocumentPath {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
}


//取得Documents\folderName路徑
+(NSString *)getDocumentPathWithFolder:(NSString *)folderName {
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:folderName];
}

#pragma mark -
#pragma mark create

//建立Doc下新資料夾
//在Document\folderName
+(BOOL) createFolderUnderDocument:(NSString *)folderName {
    

    NSFileManager *filemgr =[NSFileManager defaultManager];
    
    //建立資料夾(放圖片)
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    NSString *newDir = [docPath stringByAppendingPathComponent:folderName];
    
    #ifdef IS_DEBUG
    NSLog(@"建立新資料夾:%@",newDir);
    #endif
    
    NSError *error;
	if (![filemgr fileExistsAtPath:newDir])	//Does directory already exist?
	{
		if (![filemgr createDirectoryAtPath:newDir
                withIntermediateDirectories:YES
                                 attributes:nil
                                      error:&error])
		{
            #ifdef IS_DEBUG
            NSLog(@"Create directory(%@) error: %@", newDir, error);
            #endif
            
            return NO;
		}
	}
    
    return YES;
}

#pragma mark -
#pragma mark delete

+(BOOL) deleteItem:(NSString *) path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError* err = nil;
    BOOL success = [fileManager removeItemAtPath:path error:&err];
    if (!success && err) {
        #ifdef IS_DEBUG
        NSLog(@"remove path:%@ err:%@",path, err);
        #endif
    }
    
    return success;
}

+(BOOL) deleteFilesUnderFolder:(NSString *) folderPath {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator* enumerator = [fileManager enumeratorAtPath:folderPath];    
    NSError* err = nil;
    BOOL allSuccess = YES;
  
    NSString* file;
    while (file = [enumerator nextObject]) {
        BOOL success = [fileManager removeItemAtPath:[folderPath stringByAppendingPathComponent:file] error:&err];
        if (!success && err) {
            #ifdef IS_DEBUG
            NSLog(@"remove file:%@ at path:%@ err:%@",file, folderPath, err);
            #endif
            
            allSuccess = NO;
        }
    }
    
    return allSuccess;
}

#pragma mark -
#pragma mark copy

// Creates a writable copy of the bundled default database and plist in the application Documents directory.
+ (void)copyNeededFileToDocIfNeededWithFileName:(NSString *)fileName {
    
	// First, test for existence.
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:fileName];
    success = [fileManager fileExistsAtPath:writableDBPath];
    
	//file exist
	if (success) return;
    
    #ifdef IS_DEBUG
	NSLog(@"The writable file \"%@\" does not exist, so copy the default to the appropriate location.", fileName);
    #endif
    
	// The writable database does not exist, so copy the default to the appropriate location.
    NSError *error;
	
	NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fileName];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
}


+ (BOOL)forceCopyFileToDocWithFileName:(NSString *)fileName {
    #ifdef IS_DEBUG
	NSLog(@"強制複製\"%@\"至文件中！", fileName);
    #endif
    
	// The writable database does not exist, so copy the default to the appropriate location.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //因為要強制把pdf寫到documents下的\PDF中  所以這裡有改過
    NSString *writableDBPath = [[documentsDirectory  stringByAppendingPathComponent:@"PDF"]stringByAppendingPathComponent:fileName];
    
	NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fileName];
    
    NSData *dbData = [fileManager contentsAtPath:defaultDBPath];    
    
    BOOL success = [dbData writeToFile:writableDBPath atomically:YES];
    
    if (!success) {
        #ifdef IS_DEBUG
        NSLog(@"強制複製\"%@\"失敗!", fileName);
        #endif
    }
    
    return success;
    
}



@end
