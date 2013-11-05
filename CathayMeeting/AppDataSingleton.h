//
//  AppDataSingleton.h
//  CathayBookShelf
//
//  Created by dev1 on 2012/2/14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppDataSingleton : NSObject {
    
    //是否允許頁面開始載入資料
    BOOL okToLoad;
    
    //是否開啟國泰書櫃離線瀏覽模式
    BOOL cathayBooksOfflineModeEnabled;
}

@property (nonatomic, assign) BOOL okToLoad;
@property (nonatomic, assign) BOOL cathayBooksOfflineModeEnabled;


//-----------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark	Class methods
//-----------------------------------------------------------------------------------------------------------

+ (AppDataSingleton *)shareData;



@end
