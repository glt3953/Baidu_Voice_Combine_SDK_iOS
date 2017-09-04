//
//  VRFileManager.h
//  VoiceRecognitionClient
//
//  Created by houshaolong on 12-8-30.
//  Copyright (c) 2012年 Baidu Inc. All rights reserved.
//

// 头文件
#import <Foundation/Foundation.h>

// @class - VRFileManager
// @brief - 文件管理类
@interface TTDFileWriter : NSObject

@property (nonatomic, retain) NSString *fileName;

// 方法
- (id)initWithFileName:(NSString *)fileName;
- (id)initWithFileName:(NSString *)fileName isAppend:(BOOL)isAppend;
- (void)writeData:(NSData *)aData;
- (void)writeLine:(NSString *)content;
- (void)writeLine:(NSString *)content withEncoding:(NSStringEncoding)encoding;

@end // VRFileManager
