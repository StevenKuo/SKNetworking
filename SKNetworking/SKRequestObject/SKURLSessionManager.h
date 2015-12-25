//
//  SKURLSessionManager.h
//  SKNetworking
//
//  Created by steven on 2015/4/28.
//  Copyright (c) 2015年 KKBOX. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^SKURLSessionManagerCallback)(NSDictionary *response, NSError *error);

typedef enum : NSUInteger {
	SKURLSessionManagerHTTPMethodGET = 0,
	SKURLSessionManagerHTTPMethodPOST = 1,
} SKURLSessionManagerHTTPMethod;

typedef enum : NSUInteger {
	SKURLSessionManagerDataTypeJSON = 0,
	SKURLSessionManagerDataTypeXML = 1,
	SKURLSessionManagerDataTypeText = 2,
} SKURLSessionManagerDataType;

@interface SKURLSessionManager : NSObject

+ (SKURLSessionManager *)sharedSessionManager;

- (void)requestWithURL:(NSURL *)url HTTPMethod:(SKURLSessionManagerHTTPMethod)httpMethod postData:(NSData *)data dataType:(SKURLSessionManagerDataType)dataType callback:(SKURLSessionManagerCallback)callback;
- (void)requestWithURL:(NSURL *)url HTTPMethod:(SKURLSessionManagerHTTPMethod)httpMethod postData:(NSData *)data dataType:(SKURLSessionManagerDataType)dataType taskIdentifier:(NSString *)identifier callback:(SKURLSessionManagerCallback)callback;
- (void)requestWithURL:(NSURL *)url HTTPMethod:(SKURLSessionManagerHTTPMethod)httpMethod postData:(NSData *)data dataType:(SKURLSessionManagerDataType)dataType callback:(SKURLSessionManagerCallback)callback callbackInMainThread:(BOOL)mainThread;

- (void)cancelRequestWithIdentifier:(NSString *)identifier callback:(void(^)(void))callback;
@end
