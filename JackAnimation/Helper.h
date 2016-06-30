//
//  Helper.h
//  JackAnimation
//
//  Created by 李策 on 16/6/30.
//  Copyright © 2016年 app.yasn.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "zlib.h"

@interface Helper : NSObject
//普通base64加密
+(NSString *)jackBase64Encode:(NSString *)string;
//普通base64解密
+(NSString *)jackBase64Decode:(NSString *)string;

//压缩
+(NSData *)compressData:(NSData *)uncompressedData;

//解压缩
+(NSData *)uncompressZippedData:(NSData *)compressedData;

//高级base64加密
+ (NSString*) base64Encode:(NSData *)data;

//高级base64解密
+ (NSData*) base64Decode:(NSString *)string;


@end
