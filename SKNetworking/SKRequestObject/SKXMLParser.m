//
//  SKXMLParser.m
//  SKNetworking
//
//  Created by steven on 2015/4/30.
//  Copyright (c) 2015年 KKBOX. All rights reserved.
//

#import "SKXMLParser.h"

NSString *const tempElementTagKey = @"key";
NSString *const tempElementValueKey = @"value";

@interface SKXMLParser()<NSXMLParserDelegate>
{
	NSXMLParser *parser;
	NSMutableArray *elementStack;
	NSString *root;
	NSMutableDictionary *result;
	NSString *value;
	NSMutableArray *tempElement;
}
@end

@implementation SKXMLParser

- (instancetype)init
{
	self = [super init];
	if (self) {
		elementStack = [[NSMutableArray alloc] init];
		result = [[NSMutableDictionary alloc] init];
		tempElement = [[NSMutableArray alloc] init];
	}
	return self;
}
- (NSDictionary *)parseData:(NSData *)data
{
	parser = [[NSXMLParser alloc] initWithData:data];
	parser.delegate = self;
	[parser parse];
	return result;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	if (!root) {
		root = elementName;
		return;
	}
	[elementStack insertObject:elementName atIndex:0];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if (![[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]) {
		return;
	}
	value = string;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	if (![elementStack count]) {
		return;
	}
	[elementStack removeObjectAtIndex:0];
	if ([elementStack count]) {
		if (value) {
			[tempElement addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:elementName, tempElementTagKey, value, tempElementValueKey, nil]];
		}
		else {
			NSMutableDictionary *mergeElement = nil;
			for (NSMutableDictionary *element in tempElement) {
				if ([element[tempElementTagKey] isEqualToString:elementName]) {
					mergeElement = element;
				}
			}
			
			if (mergeElement) {
				for (NSUInteger index = 0; index < [tempElement count]; index ++) {
					NSMutableArray *newValue = [NSMutableArray arrayWithObjects:mergeElement[tempElementValueKey], nil];
					NSMutableDictionary *element = tempElement[index];
					if (![element[tempElementTagKey] isEqualToString:elementName]) {
						[newValue addObject:@{element[tempElementTagKey] : element[tempElementValueKey]}];
						[tempElement removeObject:element];
						[mergeElement setObject:newValue forKey:tempElementValueKey];
					}
				}
				return;
			}
			
			
			NSMutableDictionary *newValue = [[NSMutableDictionary alloc] init];
			for (NSDictionary *element in tempElement) {
				[newValue setObject:element[tempElementValueKey] forKey:element[tempElementTagKey]];
			}
			[tempElement removeAllObjects];
			[tempElement addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:elementName, tempElementTagKey, newValue, tempElementValueKey, nil]];
		}
	}
	else {
		if (result[elementName]) {
			if (value) {
				NSArray *newValue = @[result[elementName], value];
				[result setObject:newValue forKey:elementName];
			}
			else if ([tempElement count]) {
				NSMutableArray *newValue = nil;
				if (![result[elementName] isKindOfClass:[NSArray class]]) {
					newValue = [NSMutableArray arrayWithObjects:result[elementName], nil];
				}
				else {
					newValue = [NSMutableArray arrayWithArray:result[elementName]];
				}
				NSMutableDictionary *groupValue = [[NSMutableDictionary alloc] init];
				for (NSDictionary *element in tempElement) {
					[groupValue setObject:element[tempElementValueKey] forKey:element[tempElementTagKey]];
				}
				[newValue addObject:groupValue];
				[result setObject:newValue forKey:elementName];
				[tempElement removeAllObjects];
			}
		}
		else {
			if (value) {
				[result setObject:value forKey:elementName];
			}
			else if ([tempElement count]) {
				NSMutableDictionary *newValue = [[NSMutableDictionary alloc] init];
				for (NSDictionary *element in tempElement) {
					[newValue setObject:element[tempElementValueKey] forKey:element[tempElementTagKey]];
				}
				[result setObject:newValue forKey:elementName];
				[tempElement removeAllObjects];
			}
		}
	}
	value = nil;
}
@end
