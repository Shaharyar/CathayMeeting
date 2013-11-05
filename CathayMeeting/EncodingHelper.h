//
//  EncodingHelper.h
//  CathayLifeB2EPad
//
//  Created by dev1 on 2011/5/11.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//
//  說明：
//  因為NSString  initWithData: encoding: 遇到編碼錯誤便會丟回null，但我們仍須要其他符合編碼的資料
//  因此可以利用下面這個方法事先將不符編碼的字元替除
//
//  參考來源：http://stackoverflow.com/questions/3485190/nsstring-initwithdata-returns-null
//
//  使用上需添加“libiconv.dylib”



#import <Foundation/Foundation.h>


@interface EncodingHelper : NSObject {
    
}
//將Data中，不屬於BIG5編碼的剔除
- (NSData *)cleanBIG5:(NSData *)data;
@end
