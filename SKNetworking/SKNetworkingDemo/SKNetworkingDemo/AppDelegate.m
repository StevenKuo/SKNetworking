//
//  AppDelegate.m
//  SKNetworkingDemo
//
//  Created by steven on 2015/12/25.
//  Copyright © 2015年 KKBOX. All rights reserved.
//

#import "AppDelegate.h"
#import "SKURLSessionManager.h"
#import "SKImageManager.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Override point for customization after application launch.
	
	// HTTP GET, response format is JSON
	NSURL *getURL = [NSURL URLWithString:@"https://boiling-fjord-8215.herokuapp.com/testJSON"];
	[[SKURLSessionManager sharedSessionManager] requestWithURL:getURL HTTPMethod:SKURLSessionManagerHTTPMethodGET postData:nil dataType:SKURLSessionManagerDataTypeJSON callback:^(NSDictionary *response, NSError *error) {
		if (!error) {
			NSLog(@"\nHTTP GET Sample :\n%@\n ====================================",response);
		}
	}];
	
	// HTTP POST, response formet is Text
	NSURL *postURL = [NSURL URLWithString:@"https://boiling-fjord-8215.herokuapp.com/postJSONTest"];
	NSDictionary *post = @{@"testKey":@"testValue"};
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:post options:NSJSONWritingPrettyPrinted error:nil];
	[[SKURLSessionManager sharedSessionManager] requestWithURL:postURL HTTPMethod:SKURLSessionManagerHTTPMethodPOST postData:jsonData dataType:SKURLSessionManagerDataTypeText callback:^(NSDictionary *response, NSError *error) {
		if (!error) {
			NSLog(@"\nHTTP POST Sample :\n%@\n ====================================",response);
		}
	}];
	
	// HTTP GET, response format is XML
	NSURL *getXMLURL = [NSURL URLWithString:@"https://boiling-fjord-8215.herokuapp.com/testXML"];
	[[SKURLSessionManager sharedSessionManager] requestWithURL:getXMLURL HTTPMethod:SKURLSessionManagerHTTPMethodGET postData:nil dataType:SKURLSessionManagerDataTypeXML callback:^(NSDictionary *response, NSError *error) {
		if (!error) {
			NSLog(@"\nHTTP GET Sample :\n%@\n ====================================",response);
		}
	}];
	
	// HTTP GET, response format is image data
	NSURL *getImageURL = [NSURL URLWithString:@"https://boiling-fjord-8215.herokuapp.com/testImage"];
	[[SKImageManager sharedImageManager] requestImageWithURL:getImageURL callback:^(UIImage *image) {
		if (image) {
			NSLog(@"\nHTTP GET Sample :\n%@\n ====================================",image);
		}
	}];
	
	// HTTP GET, response format is image data, keep image with RC4 key
	[[SKImageManager sharedImageManager] requestImageWithURL:getImageURL encryptKey:@"test" callback:^(UIImage *image) {
		if (image) {
			UIImage *cacheImage = [[SKImageManager sharedImageManager] imageWithFileKey:@"test"];
			NSLog(@"\nHTTP GET Sample :\n%@\n ====================================",cacheImage);
		}
	}];
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
