//
//  NSDictionary+ExceptionHandle.m
//  MOA
//
//  Created by yanghao on 2016/3/23.
//  Copyright © 2017年 moa. All rights reserved.
//

#import "NSDictionary+ExceptionHandle.h"
#import "NSObject+ExceptionHandle.h"
#import <objc/runtime.h>


@implementation NSDictionary (ExceptionHandle)
#if _INTERNAL_MLF_ENABLED

+ (void)load {
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[object_getClass((id)self) swizzleSEL:@selector(dictionaryWithObjects:forKeys:count:) withSEL:@selector(moa_dictionaryWithObjects:forKeys:count:)];
		[objc_getClass("__NSPlaceholderDictionary") swizzleSEL:@selector(initWithObjects:forKeys:count:) withSEL:@selector(moa_initWithObjects:forKeys:count:)];
		
		
	});
	
}

+ (instancetype)moa_dictionaryWithObjects:(const id [])objects forKeys:(const id<NSCopying> [])keys count:(NSUInteger)cnt
{
	id safeObjects[cnt];
	id safeKeys[cnt];
	NSUInteger j = 0;
	for (NSUInteger i = 0; i < cnt; i++) {
		id key = keys[i];
		id obj = objects[i];
		if (!key) {
			NSLog(@"error: key is nil");
			continue;
		}
		if (!obj) {
			NSLog(@"error: anObject is nil");
			continue;
		}
		safeKeys[j] = key;
		safeObjects[j] = obj;
		j++;
	}
	
	return [self moa_dictionaryWithObjects:safeObjects forKeys:safeKeys count:j];
}

- (instancetype)moa_initWithObjects:(const id [])objects forKeys:(const id<NSCopying> [])keys count:(NSUInteger)cnt {
	id safeObjects[cnt];
	id safeKeys[cnt];
	NSUInteger j = 0;
	for (NSUInteger i = 0; i < cnt; i++) {
		id key = keys[i];
		id obj = objects[i];
		if (!key) {
			NSLog(@"error: key is nil");
			continue;
		}
		if (!obj) {
			NSLog(@"error: anObject is nil");
			continue;
		}
		safeKeys[j] = key;
		safeObjects[j] = obj;
		j++;
	}
	return [self moa_initWithObjects:safeObjects forKeys:safeKeys count:j];
}


#endif

@end


@implementation NSMutableDictionary (ExceptionHandle)

#if _INTERNAL_MLF_ENABLED

+ (void)load {
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[objc_getClass("__NSDictionaryM") swizzleSEL:@selector(setObject:forKey:) withSEL:@selector(moa_setObject:forKey:)];
		[objc_getClass("__NSDictionaryM") swizzleSEL:@selector(setValue:forKey:) withSEL:@selector(moa_setValue:forKey:)];
		[objc_getClass("__NSDictionaryM") swizzleSEL:@selector(removeObjectForKey:) withSEL:@selector(moa_removeObjectForKey:)];
		[objc_getClass("__NSDictionaryM") swizzleSEL:@selector(setObject:forKeyedSubscript:) withSEL:@selector(moa_setObject:forKeyedSubscript:)];

	});
	
}

- (void)moa_setObject:(id)anObject forKey:(id<NSCopying>)aKey
{
	if (!anObject)
	{
		NSLog(@"error: anObject is nil");
//		NSAssert(0, nil);
		return;
	}
	if (!aKey)
	{
		NSLog(@"error: aKey is nil");
//		NSAssert(0, nil);
		return;
	}
	[self moa_setObject:anObject forKey:aKey];
}

- (void)moa_setValue:(id)value forKey:(NSString *)key
{
	if (!key)
	{
		NSLog(@"error: aKey is nil");
//		NSAssert(0, nil);
		return;
	}
	[self moa_setValue:value forKey:key];
}


- (void)moa_removeObjectForKey:(id)aKey
{
	if (!aKey)
	{
		NSLog(@"error: aKey is nil");
//		NSAssert(0, nil);
		return;
	}
	[self moa_removeObjectForKey:aKey];
}

- (void)moa_setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key {
	if (!obj)
	{
		NSLog(@"error: anObject is nil");
//		NSAssert(0, nil);
		return;
	}
	if (!key)
	{
		NSLog(@"error: aKey is nil");
//		NSAssert(0, nil);
		return;
	}
	[self moa_setObject:obj forKeyedSubscript:key];
}
#endif

@end

