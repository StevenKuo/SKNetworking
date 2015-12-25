//
//  SKXMLParser.h
//  SKNetworking
//
//  Created by steven on 2015/4/30.
//  Copyright (c) 2015年 KKBOX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKXMLParser : NSObject
- (NSDictionary *)parseData:(NSData *)data;
@end
