//
//  EncodingHelper.m
//  CathayLifeB2EPad
//
//  Created by dev1 on 2011/5/11.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "EncodingHelper.h"
#import "iconv.h"

@implementation EncodingHelper


- (NSData *)cleanBIG5:(NSData *)data {
    iconv_t cd = iconv_open("BIG5", "BIG5"); // convert to BIG5 from BIG5
    int one = 1;
    iconvctl(cd, ICONV_SET_DISCARD_ILSEQ, &one); // discard invalid characters
    
    size_t inbytesleft, outbytesleft;
    inbytesleft = outbytesleft = data.length;
    char *inbuf  = (char *)data.bytes;
    char *outbuf = malloc(sizeof(char) * data.length);
    char *outptr = outbuf;
    
    if (iconv(cd, &inbuf, &inbytesleft, &outptr, &outbytesleft)
        == (size_t)-1) {
        
        NSLog(@"cleanBIG5 error!");
        return nil;
        
    }
    
    NSData *result = [NSData dataWithBytes:outbuf length:data.length - outbytesleft];
    iconv_close(cd);
    free(outbuf);
    return result;
}

@end
