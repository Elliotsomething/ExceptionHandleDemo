//
//  NSObject+Forwarding.m
//  ExceptionHandleDemo
//
//  Created by yanghao on 2016/3/23.
//  Copyright © 2017年 justlike. All rights reserved.
//

#import "NSObject+Forwarding.h"
#import <objc/runtime.h>
#import "NSObject+ExceptionHandle.h"

@implementation NSObject (Forwarding)
#if _INTERNAL_MLF_ENABLED

/*!
 * 处理NSNull 异常
 */

+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[[self class] swizzleSEL:@selector(forwardingTargetForSelector:) withSEL:@selector(forwardingTargetForSelectorExchange:)];
	});
}

- (id)forwardingTargetForSelectorExchange:(SEL)aSelector {
	static NSArray *classes = nil;
	if(classes == nil) {
		classes = @[NSStringFromClass([NSNull class]),
					NSStringFromClass([NSDictionary class]),
					NSStringFromClass([NSArray class]),
					NSStringFromClass([NSNumber class])
					];
	}
	
	if([classes containsObject:NSStringFromClass([self class])] == NO) {
		return [self forwardingTargetForSelectorExchange:aSelector];
	}
	
	//    NSAssert(0, @"给对象发了不支持的消息");
	
	NSArray *objs = @[@{}, @[], @"", @0];
	for(id o in objs) {
		if([o respondsToSelector:aSelector]) {
			NSLog(@"Bug: %@ forwarding to %@", [self class], [o class]);
			return o;
		}
	}
	return [self forwardingTargetForSelectorExchange:aSelector];
}

#endif
@end
