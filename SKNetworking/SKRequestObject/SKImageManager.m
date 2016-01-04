//
//  SKImageManager.m
//  SKNetworkingDemo
//
//  Created by steven on 2015/6/2.
//  Copyright (c) 2015年 KKBOX. All rights reserved.
//

#import "SKImageManager.h"
#import <CommonCrypto/CommonCryptor.h>

@interface SKImageManager() <NSURLSessionDelegate>
{
	NSURLSession *mainSession;
	NSString *fileDirectoryPath;
}
@end

@implementation SKImageManager


+ (SKImageManager *)sharedImageManager
{
	static SKImageManager *sharedImageManager = nil;
	static dispatch_once_t token;
	dispatch_once(&token, ^{
		sharedImageManager = [[SKImageManager alloc] init];
	});
	return sharedImageManager;
}

- (instancetype)init
{
	self = [super init];
	if (self) {
		NSURLSessionConfiguration *myConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
		NSOperationQueue *delegateQueue = [[NSOperationQueue alloc] init];
		mainSession = [NSURLSession sessionWithConfiguration:myConfiguration delegate:self delegateQueue:delegateQueue];
		
		NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
		fileDirectoryPath = [documentsDirectory stringByAppendingPathComponent:@"image"];
		BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:fileDirectoryPath];
		if (!fileExists) {
			NSError *error;
			[[NSFileManager defaultManager] createDirectoryAtPath:fileDirectoryPath withIntermediateDirectories:NO attributes:nil error:&error];
		}
		
	}
	return self;
}

- (UIImage *)imageWithFileKey:(NSString *)fileKey
{
	if (!fileKey || ![fileKey length]) {
		return nil;
	}
	NSString *filePath = [fileDirectoryPath stringByAppendingPathComponent:fileKey];
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
	if (!fileExists) {
		return nil;
	}
	NSData *encodedData = [[NSFileManager defaultManager] contentsAtPath:filePath];
	NSMutableData *decodedData = [[NSMutableData alloc] initWithLength:[encodedData length]];
	CCCryptorRef encryptor = NULL;
	const char *key = [fileKey UTF8String];
	__unused CCCryptorStatus result = CCCryptorCreate(kCCEncrypt, kCCAlgorithmRC4, 0, key, strlen(key), NULL, &encryptor);
	size_t outSize = 0;
	CCCryptorUpdate(encryptor, [encodedData bytes], (size_t)[encodedData length], [decodedData mutableBytes], (size_t)[encodedData length], &outSize);
	
	return [UIImage imageWithData:decodedData];
}

- (void)requestImageWithURL:(NSURL *)imageURL callback:(void(^)(UIImage *image))callback
{
	NSURLSessionTask *task = [mainSession dataTaskWithRequest:[NSURLRequest requestWithURL:imageURL] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                callback(nil);
                return ;
            }
            callback([UIImage imageWithData:data]);
        });
	}];
	[task resume];
}

- (void)requestImageWithURL:(NSURL *)imageURL encryptKey:(NSString *)inKey callback:(void(^)(UIImage *image))callback
{
	UIImage *cacheImage = [self imageWithFileKey:inKey];
	if (cacheImage) {
		callback(cacheImage);
		return;
	}
	NSURLSessionTask *task = [mainSession dataTaskWithRequest:[NSURLRequest requestWithURL:imageURL] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                callback(nil);
                return ;
            }
            if (!inKey || ![inKey length]) {
                callback([UIImage imageWithData:data]);
                return;
            }
        });
		
		NSMutableData *decodedData = [[NSMutableData alloc] initWithLength:[data length]];
		CCCryptorRef encryptor = NULL;
		const char *key = [inKey UTF8String];
		__unused CCCryptorStatus result = CCCryptorCreate(kCCEncrypt, kCCAlgorithmRC4, 0, key, strlen(key), NULL, &encryptor);
		size_t outSize = 0;
		CCCryptorUpdate(encryptor, [data bytes], (size_t)[data length], [decodedData mutableBytes], (size_t)[data length], &outSize);
		
		NSString *filePath = [fileDirectoryPath stringByAppendingPathComponent:inKey];
		[decodedData writeToFile:filePath atomically:YES];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            callback([UIImage imageWithData:data]);    
        });
        
	}];
	[task resume];
}

@end
