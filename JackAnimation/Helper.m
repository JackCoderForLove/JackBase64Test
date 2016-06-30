//
//  Helper.m
//  JackAnimation
//
//  Created by 李策 on 16/6/30.
//  Copyright © 2016年 app.yasn.com. All rights reserved.
//

#import "Helper.h"

@implementation Helper
//普通base64加密
+(NSString *)jackBase64Encode:(NSString *)string
{
    NSData * data = [string dataUsingEncoding:NSUTF8StringEncoding];
    //将nsdata进行base64加密
    NSString * jcSecretStr = [data base64EncodedStringWithOptions:0];
   // NSLog(@"普通base64加密后的字符串为:-----%@",jcSecretStr);
    return jcSecretStr.length>0 ?jcSecretStr:@"";

}
//普通base64解密
+(NSString *)jackBase64Decode:(NSString *)string
{
    NSData * base64Data = [[NSData alloc]initWithBase64EncodedString:string options:0];
   // NSLog(@"普通base64解密后的data为:-----%@",base64Data);
    
    //将base64加密的data解密，并转为nsstring
    NSString * unSecretStr = [[NSString alloc]initWithData:base64Data encoding:NSUTF8StringEncoding];
    return unSecretStr>0?unSecretStr:@"";

}
//压缩
+(NSData *)compressData:(NSData *)uncompressedData
{
    if ([uncompressedData length] == 0) return uncompressedData;
    
    z_stream strm;
    
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    strm.total_out = 0;
    strm.next_in=(Bytef *)[uncompressedData bytes];
    strm.avail_in = (unsigned int)[uncompressedData length];
    
    if (deflateInit2(&strm, Z_DEFAULT_COMPRESSION, Z_DEFLATED, (15+16), 8, Z_DEFAULT_STRATEGY) != Z_OK) return nil;
    
    NSMutableData *compressed = [NSMutableData dataWithLength:16384];  // 16K chunks for expansion
    
    do {
        
        if (strm.total_out >= [compressed length])
            [compressed increaseLengthBy: 16384];
        
        strm.next_out = [compressed mutableBytes] + strm.total_out;
        strm.avail_out = (unsigned int)([compressed length] - strm.total_out);
        
        deflate(&strm, Z_FINISH);
        
    } while (strm.avail_out == 0);
    
    deflateEnd(&strm);
    
    [compressed setLength: strm.total_out];
    return [NSData dataWithData:compressed];
}
//解压缩
+(NSData *)uncompressZippedData:(NSData *)compressedData
{
    
    if ([compressedData length] == 0) return compressedData;
    
    unsigned full_length = [compressedData length];
    
    unsigned half_length = [compressedData length] / 2;
    NSMutableData *decompressed = [NSMutableData dataWithLength: full_length + half_length];
    BOOL done = NO;
    int status;
    z_stream strm;
    strm.next_in = (Bytef *)[compressedData bytes];
    strm.avail_in = [compressedData length];
    strm.total_out = 0;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    if (inflateInit2(&strm, (15+32)) != Z_OK) return nil;
    while (!done) {
        // Make sure we have enough room and reset the lengths.
        if (strm.total_out >= [decompressed length]) {
            [decompressed increaseLengthBy: half_length];
        }
        strm.next_out = [decompressed mutableBytes] + strm.total_out;
        strm.avail_out = [decompressed length] - strm.total_out;
        // Inflate another chunk.
        status = inflate (&strm, Z_SYNC_FLUSH);
        if (status == Z_STREAM_END) {
            done = YES;
        } else if (status != Z_OK) {
            break;
        }
        
    }
    if (inflateEnd (&strm) != Z_OK) return nil;
    // Set real length.
    if (done) {
        [decompressed setLength: strm.total_out];
        return [NSData dataWithData: decompressed];
    } else {
        return nil;
    }    
}
//高级base64加密
+ (NSString*) base64Encode:(NSData *)data
{
    static char base64EncodingTable[64] = {
        'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
        'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
        'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
        'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'
    };
    int length = [data length];
    unsigned long ixtext, lentext;
    long ctremaining;
    unsigned char input[3], output[4];
    short i, charsonline = 0, ctcopy;
    const unsigned char *raw;
    NSMutableString *result;
    
    lentext = [data length];
    if (lentext < 1)
        return @"";
    result = [NSMutableString stringWithCapacity: lentext];
    raw = [data bytes];
    ixtext = 0;
    
    while (true) {
        ctremaining = lentext - ixtext;
        if (ctremaining <= 0)
            break;
        for (i = 0; i < 3; i++) {
            unsigned long ix = ixtext + i;
            if (ix < lentext)
                input[i] = raw[ix];
            else
                input[i] = 0;
        }
        output[0] = (input[0] & 0xFC) >> 2;
        output[1] = ((input[0] & 0x03) << 4) | ((input[1] & 0xF0) >> 4);
        output[2] = ((input[1] & 0x0F) << 2) | ((input[2] & 0xC0) >> 6);
        output[3] = input[2] & 0x3F;
        ctcopy = 4;
        switch (ctremaining) {
            case 1:
                ctcopy = 2;
                break;
            case 2:
                ctcopy = 3;
                break;
        }
        
        for (i = 0; i < ctcopy; i++)
            [result appendString: [NSString stringWithFormat: @"%c", base64EncodingTable[output[i]]]];
        
        for (i = ctcopy; i < 4; i++)
            [result appendString: @"="];
        
        ixtext += 3;
        charsonline += 4;
        
        if ((length > 0) && (charsonline >= length))
            charsonline = 0;
    }
    return result;
}
//高级base64解密
+ (NSData*) base64Decode:(NSString *)string
{
    unsigned long ixtext, lentext;
    unsigned char ch, inbuf[4], outbuf[4];
    short i, ixinbuf;
    Boolean flignore, flendtext = false;
    const unsigned char *tempcstring;
    NSMutableData *theData;
    
    if (string == nil) {
        return [NSData data];
    }
    
    ixtext = 0;
    
    tempcstring = (const unsigned char *)[string UTF8String];
    
    lentext = [string length];
    
    theData = [NSMutableData dataWithCapacity: lentext];
    
    ixinbuf = 0;
    
    while (true) {
        if (ixtext >= lentext){
            break;
        }
        
        ch = tempcstring [ixtext++];
        
        flignore = false;
        
        if ((ch >= 'A') && (ch <= 'Z')) {
            ch = ch - 'A';
        } else if ((ch >= 'a') && (ch <= 'z')) {
            ch = ch - 'a' + 26;
        } else if ((ch >= '0') && (ch <= '9')) {
            ch = ch - '0' + 52;
        } else if (ch == '+') {
            ch = 62;
        } else if (ch == '=') {
            flendtext = true;
        } else if (ch == '/') {
            ch = 63;
        } else {
            flignore = true;
        }
        
        if (!flignore) {
            short ctcharsinbuf = 3;
            Boolean flbreak = false;
            
            if (flendtext) {
                if (ixinbuf == 0) {
                    break;
                }
                
                if ((ixinbuf == 1) || (ixinbuf == 2)) {
                    ctcharsinbuf = 1;
                } else {
                    ctcharsinbuf = 2;
                }
                
                ixinbuf = 3;
                
                flbreak = true;
            }
            
            inbuf [ixinbuf++] = ch;
            
            if (ixinbuf == 4) {
                ixinbuf = 0;
                
                outbuf[0] = (inbuf[0] << 2) | ((inbuf[1] & 0x30) >> 4);
                outbuf[1] = ((inbuf[1] & 0x0F) << 4) | ((inbuf[2] & 0x3C) >> 2);
                outbuf[2] = ((inbuf[2] & 0x03) << 6) | (inbuf[3] & 0x3F);
                
                for (i = 0; i < ctcharsinbuf; i++) {
                    [theData appendBytes: &outbuf[i] length: 1];
                }
            }
            
            if (flbreak) {  
                break;  
            }  
        }  
    }  
    
    return theData;  
}

@end
