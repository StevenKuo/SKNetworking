//
//  SKImageManager.h
//  SKNetworkingDemo
//
//  Created by steven on 2015/6/2.
//  Copyright (c) 2015年 KKBOX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SKImageManager : NSObject

+ (SKImageManager *)sharedImageManager;

- (void)requestImageWithURL:(NSURL *)imageURL callback:(void(^)(UIImage *image))callback;
- (void)requestImageWithURL:(NSURL *)imageURL encryptKey:(NSString *)inKey callback:(void(^)(UIImage *image))callback;
- (UIImage *)imageWithFileKey:(NSString *)fileKey;
@end
