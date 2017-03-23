//
//  NSObject+ExceptionHandle.m
//  ExceptionHandleDemo
//
//  Created by yanghao on 2016/3/23.
//  Copyright © 2017年 justlike. All rights reserved.
//

#import "NSObject+ExceptionHandle.h"
#import <objc/runtime.h>


@implementation NSObject (ExceptionHandle)

+ (void)swizzleSEL:(SEL)originalSEL withSEL:(SEL)swizzledSEL {
#if _INTERNAL_MLF_ENABLED
	
	
	Class class = [self class];
	
	Method originalMethod = class_getInstanceMethod(class, originalSEL);
	Method swizzledMethod = class_getInstanceMethod(class, swizzledSEL);
	
	BOOL didAddMethod =
	class_addMethod(class,
					originalSEL,
					method_getImplementation(swizzledMethod),
					method_getTypeEncoding(swizzledMethod));
	
	if (didAddMethod) {
		class_replaceMethod(class,
							swizzledSEL,
							method_getImplementation(originalMethod),
							method_getTypeEncoding(originalMethod));
	} else {
		method_exchangeImplementations(originalMethod, swizzledMethod);
	}
#endif
}


@end
