//
//  TTDFileReader.m
//  TestTagDemo
//
//  Created by  段弘 on 14-1-2.
//  Copyright (c) 2014年 百度. All rights reserved.
//

#import "TTDFileReader.h"

@interface NSData (DDAdditions)

- (NSRange) rangeOfData_dd:(NSData *)dataToFind;

@end

@implementation NSData (DDAdditions)

- (NSRange) rangeOfData_dd:(NSData *)dataToFind {
    
    const void * bytes = [self bytes];
    NSUInteger length = [self length];
    
    const void * searchBytes = [dataToFind bytes];
    NSUInteger searchLength = [dataToFind length];
    NSUInteger searchIndex = 0;
    
    NSRange foundRange = {NSNotFound, searchLength};
    for (NSUInteger index = 0; index < length; index++) {
        if (((char *)bytes)[index] == ((char *)searchBytes)[searchIndex]) {
            //the current character matches
            if (foundRange.location == NSNotFound) {
                foundRange.location = index;
            }
            searchIndex++;
            if (searchIndex >= searchLength) { return foundRange; }
        } else {
            searchIndex = 0;
            foundRange.location = NSNotFound;
        }
    }
    return foundRange;
}

@end

@implementation TTDFileReader
@synthesize lineDelimiter, chunkSize;

- (id) initWithFilePath:(NSString *)aPath {
    if (self = [super init]) {
        fileHandle = [NSFileHandle fileHandleForReadingAtPath:aPath];
        if (fileHandle == nil) {
            NSLog(@"fileHandle is nil!");
            [self release];
            return nil;
        }
        
        lineDelimiter = [[NSString alloc] initWithString:@"\n"];
        [fileHandle retain];
        filePath = [aPath retain];
        currentOffset = 0ULL;
        chunkSize = 10;
        [fileHandle seekToEndOfFile];
        totalFileLength = [fileHandle offsetInFile];
        //we don't need to seek back, since readLine will do that.
    }
    return self;
}

- (void) dealloc {
    [fileHandle closeFile];
    [fileHandle release], fileHandle = nil;
    [filePath release], filePath = nil;
    [lineDelimiter release], lineDelimiter = nil;
    currentOffset = 0ULL;
    [super dealloc];
}

- (NSString *) readLineWithEncoding:(NSStringEncoding)encoding {
    if (currentOffset >= totalFileLength) { return nil; }
    
    NSData * newLineData = [lineDelimiter dataUsingEncoding:encoding];
    [fileHandle seekToFileOffset:currentOffset];
    NSMutableData * currentData = [[NSMutableData alloc] init];
    BOOL shouldReadMore = YES;
    
    NSAutoreleasePool * readPool = [[NSAutoreleasePool alloc] init];
    while (shouldReadMore) {
        if (currentOffset >= totalFileLength) { break; }
        NSData * chunk = [fileHandle readDataOfLength:chunkSize];
        NSRange newLineRange = [chunk rangeOfData_dd:newLineData];
        if (newLineRange.location != NSNotFound) {
            
            //include the length so we can include the delimiter in the string
            chunk = [chunk subdataWithRange:NSMakeRange(0, newLineRange.location+[newLineData length])];
            shouldReadMore = NO;
        }
        [currentData appendData:chunk];
        currentOffset += [chunk length];
    }
    [readPool release];
    
    NSString * line = [[NSString alloc] initWithData:currentData encoding:encoding];
    [currentData release];
    return [line autorelease];
}

- (NSString *) readTrimmedLineWithEncoding:(NSStringEncoding)encoding {
    return [[self readLineWithEncoding:encoding] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
}

@end
