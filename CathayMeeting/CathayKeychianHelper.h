//
//  CathayKeychianHelper.h
//  InsProposal
//
//  Created by dev1 on 2012/3/8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

//是否要啟用加密取放
//#define ENABLE_CRYPTO

@class KeychainItemWrapper;

@interface CathayKeychianHelper : NSObject

@property (nonatomic, assign) KeychainItemWrapper *keychain; 



//若要跨App存取要設這個，帶入accessGroup
- (id) initWithAccessGroup:(NSString *)accessGroup Identity:(NSString *) identity Service:(NSString *) service;
- (id) initWithIdentity:(NSString *) identity Service:(NSString *) service;


//不加密取放
- (NSString *) getText;
- (void) putText:(NSString *)plainText;

//加密取放
#ifdef ENABLE_CRYPTO
@property (nonatomic, retain) NSString  *cryptoKey; //加密金鑰，若不設，會用預設值進行加密

- (NSString *) getDecryptText;
- (void) putPlainText:(NSString *)plainText;
#endif



@end
