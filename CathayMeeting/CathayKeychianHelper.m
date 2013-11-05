//
//  CathayKeychianHelper.m
//  InsProposal
//
//  Created by dev1 on 2012/3/8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CathayKeychianHelper.h"
#import "KeychainItemWrapper.h"
#import "CathayGlobalVariable.h"

#ifdef ENABLE_CRYPTO
#import "NSData+AESCrypt.h"
#import "GTMBase64.h"
#endif

@interface CathayKeychianHelper()
@property (nonatomic, retain) NSString *service;
@property (nonatomic, retain) NSString *account;
@end


@implementation CathayKeychianHelper
@synthesize keychain;
@synthesize service, account;
#ifdef ENABLE_CRYPTO
@synthesize cryptoKey;
#endif

- (id) initWithAccessGroup:(NSString *)accessGroup Identity:(NSString *) identity Service:(NSString *) _service{
    
    //AccessGroup 說明
    //If you want the new keychain item to be shared among multiple applications, include the kSecAttrAccessGroup 
    //key in the attributes dictionary. The value of this key must be the name of a keychain access group to which 
    //all of the programs that will share this item belong.
    
    @synchronized(self) {
        
        if (self = [super init])
        {
            
            @try {
                //identity , account , service 都要設，在APP中才會唯一
                self.keychain = [[KeychainItemWrapper alloc] initWithIdentifier:identity accessGroup:accessGroup];
                self.service = _service;
                self.account = @"secretValue";
            }
            @catch (NSException *exception) {
#ifdef IS_DEBUG
                NSLog(@"Cathay keyChain init Failed: %@", [exception description]);
#endif
                
                [self.keychain release];
                self.keychain = nil;
                
                return nil;
            }
            
#ifdef ENABLE_CRYPTO
            if (!cryptoKey) {
                self.cryptoKey = @"8504540110578641";
            }
#endif
            
        }
        
        return self;
    }
    
}

- (id) initWithIdentity:(NSString *) identity Service:(NSString *) _service{
    
    return [self initWithAccessGroup:nil Identity:identity Service:_service];
}


-(void) dealloc {
    
    [service release];
    [account release];
    
#ifdef ENABLE_CRYPTO    
    [cryptoKey release];
#endif
    
    [keychain release];
    [super dealloc];
}

#ifdef ENABLE_CRYPTO

#pragma - 加密取放

- (NSString *) getDecryptText {
    
    NSString *decryptText = nil;
    @try {
        
        NSString *encryptText = [self.keychain objectForKey:(id)kSecValueData];
        
        
        if (encryptText && [encryptText isKindOfClass:[NSString class]] && [encryptText length]>0) {
            NSData *encryptTextData = [GTMBase64 decodeString:encryptText];
            NSData *decryptData = [encryptTextData AES128DecryptWithKey:cryptoKey];
            decryptText = [[[NSString alloc]initWithData:decryptData encoding:NSUTF8StringEncoding]autorelease];
        }
        
        
    }
    @catch (NSException *exception) {
        
#ifdef IS_DEBUG
        NSLog(@"Cathay Keychian getDecryptText failed: %@", [exception description]);
#endif
    }
    
    return decryptText;
}

- (void) putPlainText:(NSString *)plainText {
    
    @try {
        NSData* keyData = [plainText dataUsingEncoding:NSUTF8StringEncoding];
        
        //Encrypt
        NSData *encryptData = [keyData AES128EncryptWithKey:cryptoKey];
        NSString *encryptBase64Str = [GTMBase64 stringByEncodingData:encryptData];
        //NSLog(@"encryptBase64Key:%@", encryptBase64Str);
        
        [self.keychain setObject:self.service forKey:(id)kSecAttrService];               //服務項目
        [self.keychain setObject:self.account forKey:(id)kSecAttrAccount];               //原本是用來記帳號
        [self.keychain setObject:encryptBase64Str forKey:(id)kSecValueData]; 
        
    }
    @catch (NSException *exception) {
        
#ifdef IS_DEBUG
        NSLog(@"Cathay Keychian putPlainText failed: %@", [exception description]);
#endif
        
    }
    
}
#endif

#pragma - 不加密取放

- (NSString *) getText {
    
    NSString *returnText = nil;
    @try {
        
        returnText = [self.keychain objectForKey:(id)kSecValueData];
        
    }
    @catch (NSException *exception) {
        
#ifdef IS_DEBUG
        NSLog(@"Cathay Keychian getText failed: %@", [exception description]);
#endif
    }
    
    return returnText;
}

- (void) putText:(NSString *)plainText {
    
    @try {
        [self.keychain setObject:self.service forKey:(id)kSecAttrService];               //服務項目
        [self.keychain setObject:self.account forKey:(id)kSecAttrAccount];               //原本是用來記帳號
        [self.keychain setObject:plainText forKey:(id)kSecValueData]; 
        
    }
    @catch (NSException *exception) {
        
#ifdef IS_DEBUG
        NSLog(@"Cathay Keychian putText failed: %@", [exception description]);
#endif
        
    }
    
}



@end
