//
//  SKURLSessionManager.m
//  SKNetworking
//
//  Created by steven on 2015/4/28.
//  Copyright (c) 2015年 KKBOX. All rights reserved.
//

#import "SKURLSessionManager.h"
#import "SKXMLParser.h"

#define SESSIONPARACALLBACK(x, y, ...) if(x) x((y),##__VA_ARGS__);
#define SESSIONCALLBACK(x) if(x) x();

@interface SKURLSessionManager() <NSURLSessionDelegate, NSXMLParserDelegate>
{
	NSURLSession *mainSession;
}
@end

@implementation SKURLSessionManager

+ (SKURLSessionManager *)sharedSessionManager
{
	static SKURLSessionManager *sharedSessionManager = nil;
	static dispatch_once_t token;
	dispatch_once(&token, ^{
		sharedSessionManager = [[SKURLSessionManager alloc] init];
	});
	return sharedSessionManager;
}

- (instancetype)init
{
	self = [super init];
	if (self) {
		NSURLSessionConfiguration *myConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
		NSOperationQueue *delegateQueue = [[NSOperationQueue alloc] init];
		mainSession = [NSURLSession sessionWithConfiguration:myConfiguration delegate:self delegateQueue:delegateQueue];
	}
	return self;
}
- (void)requestWithURL:(NSURL *)url HTTPMethod:(SKURLSessionManagerHTTPMethod)httpMethod postData:(NSData *)data dataType:(SKURLSessionManagerDataType)dataType callback:(SKURLSessionManagerCallback)callback
{
	[self _createURLSessionTaskWithURL:url HTTPMethod:httpMethod postData:data dataType:dataType taskIdentifier:nil callback:callback inMainThread:YES];
}

- (void)requestWithURL:(NSURL *)url HTTPMethod:(SKURLSessionManagerHTTPMethod)httpMethod postData:(NSData *)data dataType:(SKURLSessionManagerDataType)dataType taskIdentifier:(NSString *)identifier callback:(SKURLSessionManagerCallback)callback
{
	[self _createURLSessionTaskWithURL:url HTTPMethod:httpMethod postData:data dataType:dataType taskIdentifier:identifier callback:callback inMainThread:YES];
}
- (void)requestWithURL:(NSURL *)url HTTPMethod:(SKURLSessionManagerHTTPMethod)httpMethod postData:(NSData *)data dataType:(SKURLSessionManagerDataType)dataType callback:(SKURLSessionManagerCallback)callback callbackInMainThread:(BOOL)mainThread
{
	[self _createURLSessionTaskWithURL:url HTTPMethod:httpMethod postData:data dataType:dataType taskIdentifier:nil callback:callback inMainThread:mainThread];
}

- (void)_createURLSessionTaskWithURL:(NSURL *)url HTTPMethod:(SKURLSessionManagerHTTPMethod)httpMethod postData:(NSData *)data dataType:(SKURLSessionManagerDataType)dataType taskIdentifier:(NSString *)identifier callback:(SKURLSessionManagerCallback)callback inMainThread:(BOOL)mainThread
{
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	if (httpMethod == SKURLSessionManagerHTTPMethodGET) {
		[request setHTTPMethod:@"GET"];
	}
	else if (httpMethod == SKURLSessionManagerHTTPMethodPOST) {
		[request setHTTPMethod:@"POST"];
		[request setHTTPBody:data];
		[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	}
	
	NSURLSessionDataTask *task = [mainSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		if (error) {
			if (mainThread) {
				dispatch_async(dispatch_get_main_queue(), ^{
					SESSIONPARACALLBACK(callback, nil, error);
				});
				return ;
			}
			SESSIONPARACALLBACK(callback, nil, error);
		}
		else {
			NSError *parseError = nil;
			id response = nil;
			switch (dataType) {
				case SKURLSessionManagerDataTypeJSON:
					response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&parseError];
					break;
				case SKURLSessionManagerDataTypeXML:
				{
					SKXMLParser *parser = [[SKXMLParser alloc] init];
					response = [parser parseData:data];
				}
					break;
				case SKURLSessionManagerDataTypeText:
				{
					response = @{@"text":[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]};
				}
					break;
				default:
					break;
			}
			if (mainThread) {
				dispatch_async(dispatch_get_main_queue(), ^{
					if (parseError) {
						SESSIONPARACALLBACK(callback, nil, parseError);
					}
					else {
						SESSIONPARACALLBACK(callback, response, nil);
					}
				});
				return ;
			}
			if (parseError) {
				SESSIONPARACALLBACK(callback, nil, parseError);
			}
			else {
				SESSIONPARACALLBACK(callback, response, nil);
			}
		}
	}];
	
	if (identifier && [identifier length]) {
		task.taskDescription = identifier;
	}
	[task resume];
}

- (void)cancelRequestWithIdentifier:(NSString *)identifier callback:(void(^)(void))callback
{
	[mainSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
		if ([dataTasks count]) {
			for (NSURLSessionTask *task in dataTasks) {
				if ([task.taskDescription isEqualToString:identifier]) {
					[task cancel];
				}
			}
		}
		if ([uploadTasks count]) {
			for (NSURLSessionTask *task in uploadTasks) {
				if ([task.taskDescription isEqualToString:identifier]) {
					[task cancel];
				}
			}
		}
		if ([downloadTasks count]) {
			for (NSURLSessionTask *task in downloadTasks) {
				if ([task.taskDescription isEqualToString:identifier]) {
					[task cancel];
				}
			}
		}
		dispatch_async(dispatch_get_main_queue(), ^{
			SESSIONCALLBACK(callback);
		});
	}];
}
@end
