//
//  TTDFileReader.h
//  TestTagDemo
//
//  Created by  段弘 on 14-1-2.
//  Copyright (c) 2014年 百度. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTDFileReader : NSObject {
    NSString * filePath;
    
    NSFileHandle * fileHandle;
    unsigned long long currentOffset;
    unsigned long long totalFileLength;
    
    NSString * lineDelimiter;
    NSUInteger chunkSize;
}

@property (nonatomic, copy) NSString * lineDelimiter;
@property (nonatomic) NSUInteger chunkSize;

- (id) initWithFilePath:(NSString *)aPath;

- (NSString *) readLineWithEncoding:(NSStringEncoding)encoding;
- (NSString *) readTrimmedLineWithEncoding:(NSStringEncoding)encoding;

@end