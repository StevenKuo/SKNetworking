//
//  SKImageManager.m
//  SKNetworkingDemo
//
//  Created by steven on 2015/6/2.
//  Copyright (c) 2015年 KKBOX. All rights reserved.
//

#import "SKImageManager.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>

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

- (NSString *)md5:(NSString *)str
{
	const char *cStr = [str UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5( cStr, (int)str.length, result);
	return [NSString
			stringWithFormat: @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1],
			result[2], result[3],
			result[4], result[5],
			result[6], result[7],
			result[8], result[9],
			result[10], result[11],
			result[12], result[13],
			result[14], result[15]
			];
	
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
	NSString *md5Key = [self md5:inKey];
	UIImage *cacheImage = [self imageWithFileKey:md5Key];
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
            if (!md5Key || ![md5Key length]) {
                callback([UIImage imageWithData:data]);
                return;
            }
        });
		
		NSMutableData *decodedData = [[NSMutableData alloc] initWithLength:[data length]];
		CCCryptorRef encryptor = NULL;
		const char *key = [md5Key UTF8String];
		__unused CCCryptorStatus result = CCCryptorCreate(kCCEncrypt, kCCAlgorithmRC4, 0, key, strlen(key), NULL, &encryptor);
		size_t outSize = 0;
		CCCryptorUpdate(encryptor, [data bytes], (size_t)[data length], [decodedData mutableBytes], (size_t)[data length], &outSize);
		
		NSString *filePath = [fileDirectoryPath stringByAppendingPathComponent:md5Key];
		[decodedData writeToFile:filePath atomically:YES];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            callback([UIImage imageWithData:data]);    
        });
        
	}];
	[task resume];
}

@end
