//
//  TTDFileWriter.m
//  VoiceRecognitionClient
//
//  Created by houshaolong on 12-8-30.
//  Copyright (c) 2012年 Baidu Inc. All rights reserved.
//

// 头文件
#import "TTDFileWriter.h"
#import "fcntl.h"

@interface TTDFileWriter()
@property (nonatomic, retain) NSFileHandle *fileHandle;
@end

// 类实现
@implementation TTDFileWriter

@synthesize fileName = _fileName;
@synthesize fileHandle = _fileHandle;

- (id)init 
{
	if (self = [self initWithFileName:nil isAppend:NO])
	{
		
	}
	return self;
}

- (id)initWithFileName:(NSString *)fileName
{
    if (self = [self initWithFileName:fileName isAppend:NO])
    {

    }
    return self;
}

- (id)initWithFileName:(NSString *)fileName isAppend:(BOOL)append
{
    if (self = [super init])
    {
        self.fileName = fileName;
        self.fileHandle = [self createFileHandleWithName:self.fileName isAppend:append];
    }
    return self;
}

- (void)dealloc
{
    [_fileName release];
    [_fileHandle release];
	[super dealloc];
}

- (void)writeData:(NSData *)aData
{
    if (self.fileHandle) {
        [self.fileHandle writeData:aData];
    }
}

- (void)writeLine:(NSString *)content
{
    [self writeLine:content withEncoding:NSUTF8StringEncoding];
}

- (void)writeLine:(NSString *)content withEncoding:(NSStringEncoding)encoding
{
    NSString *newLine = [[NSString alloc] initWithFormat:@"%@\r\n",content];
    if (self.fileHandle) {
        [self.fileHandle writeData:[newLine dataUsingEncoding:encoding]];
    }
    [newLine release];
}

- (NSString *)getFilePath:(NSString *)fileName
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
	if (paths && [paths count])
	{
		return [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
	}
	else
	{
		return nil;
	}
}

#pragma mark - write handle

- (NSFileHandle *)createFileHandleWithName:(NSString *)aFileName isAppend:(BOOL)isAppend
{
    NSFileHandle *fileHandle = nil;
	NSString *fileName = [self getFilePath:aFileName];
    
	int fd = -1;
	if (fileName)
	{
        if ([[NSFileManager defaultManager] fileExistsAtPath:fileName]&& !isAppend)
        {
            [[NSFileManager defaultManager] removeItemAtPath:fileName error:nil];
        }
        
        int flags = O_WRONLY | O_APPEND | O_CREAT;
		fd = open([fileName fileSystemRepresentation], flags, 0644);
	}
    
	if (fd != -1)
	{
        fileHandle = [[NSFileHandle alloc] initWithFileDescriptor:fd closeOnDealloc:YES];
	}
    
    return [fileHandle autorelease];
}

@end // TTDFileWriter
