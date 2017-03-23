//
//  NSObject+observer.m
//  ExceptionHandleDemo
//
//  Created by yanghao on 2016/3/23.
//  Copyright © 2017年 justlike. All rights reserved.
//

#import "NSObject+observer.h"
#import <objc/runtime.h>
#import "NSObject+ExceptionHandle.h"

@implementation NSObject (observer)
#if _INTERNAL_MLF_ENABLED

+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[[self class] swizzleSEL:@selector(removeObserver:forKeyPath:) withSEL:@selector(safeRemoveObserver:forKeyPath:)];
	});
}


- (void)safeRemoveObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath
{
	@try {
		[self safeRemoveObserver:observer forKeyPath:keyPath];
	}
	@catch (NSException *exception) {
		if(_INTERNAL_MLF_ENABLED)
		{
			[exception raise];
		}
		else
		{
			NSLog(@"\nreason:\n%@\nobservationInfo:\n%@\n", exception.reason, [self observationInfo]);
		}
	}
	@finally {
		
	}
}

#endif

@end
