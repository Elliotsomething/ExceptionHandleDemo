//
//  NSArray+ExceptionHandle.m
//  MOA
//
//  Created by yanghao on 2016/3/22.
//  Copyright © 2017年 moa. All rights reserved.
//

#import "NSArray+ExceptionHandle.h"
#import "NSObject+ExceptionHandle.h"
#import <objc/runtime.h>

//使用hook影响的类太多，怕引起其他系统crash，所以添加分类方法

@implementation NSArray (ExceptionHandle)

#if _INTERNAL_MLF_ENABLED
+ (void)load {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[objc_getClass("__NSArray0") swizzleSEL:@selector(objectAtIndex:) withSEL:@selector(moa_empty_objectAtIndex:)];
		[objc_getClass("__NSArrayI") swizzleSEL:@selector(objectAtIndex:) withSEL:@selector(moa_objectAtIndex:)];
		[objc_getClass("__NSPlaceholderArray") swizzleSEL:@selector(initWithObjects:count:) withSEL:@selector(moa_initWithObjects:count:)];
		[object_getClass((id)self) swizzleSEL:@selector(arrayWithObjects:count:) withSEL:@selector(moa_arrayWithObjects:count:)];
		
	});
	
}

- (instancetype)moa_initWithObjects:(id  _Nonnull const [])objects count:(NSUInteger)cnt
{
	id safeObjects[cnt];
	NSUInteger j = 0;
	for (NSUInteger i = 0; i < cnt; i++) {
		id obj = objects[i];

		if (!obj) {
			NSLog(@"error: anObject is nil");
			continue;
		}
		safeObjects[j] = obj;
		j++;
	}
	return [self moa_initWithObjects:safeObjects count:j];
}

+ (instancetype)moa_arrayWithObjects:(const id  _Nonnull __unsafe_unretained *)objects count:(NSUInteger)cnt
{
	id safeObjects[cnt];
	NSUInteger j = 0;
	for (NSUInteger i = 0; i < cnt; i++) {
		id obj = objects[i];
		
		if (!obj) {
			NSLog(@"error: anObject is nil");
			continue;
		}
		safeObjects[j] = obj;
		j++;
	}
	return [self moa_arrayWithObjects:safeObjects count:j];
}

- (id)moa_empty_objectAtIndex:(NSUInteger)index
{
	NSLog(@"数组越界");
	NSAssert(0, nil);
	return nil;
}

- (id)moa_objectAtIndex:(NSUInteger)index
{
	
	if (index >= [self count]) {
		NSAssert(0, nil);
		NSLog(@"数组越界");
		return nil;
	}
	return [self moa_objectAtIndex:index];

}

#endif

/*!
 @method objectAtIndexCheck:
 @abstract 检查是否越界和NSNull如果是返回nil
 @result 返回对象
 */
- (id)objectAtIndexCheck:(NSUInteger)index
{
	
	if (index >= [self count]) {
		NSAssert(0, nil);
		NSLog(@"数组越界");
		return nil;
	}
	id value = [self objectAtIndex:index];

	return value;
}

@end


//使用hook影响的类太多，怕引起其他系统crash，所以添加分类方法

@implementation NSMutableArray (ExceptionHandle)

#if _INTERNAL_MLF_ENABLED
+ (void)load {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[objc_getClass("__NSArrayM") swizzleSEL:@selector(objectAtIndex:) withSEL:@selector(moa_objectAtIndex:)];
		[objc_getClass("__NSArrayM") swizzleSEL:@selector(addObject:) withSEL:@selector(moa_addObject:)];
		[objc_getClass("__NSArrayM") swizzleSEL:@selector(removeObjectAtIndex:) withSEL:@selector(moa_removeObjectAtIndex:)];
		[objc_getClass("__NSArrayM") swizzleSEL:@selector(insertObject:atIndex:) withSEL:@selector(moa_insertObject:atIndex:)];
		[objc_getClass("__NSArrayM") swizzleSEL:@selector(replaceObjectAtIndex:withObject:) withSEL:@selector(moa_replaceObjectAtIndex:withObject:)];
	});
}



- (id)moa_objectAtIndex:(NSUInteger)index
{
	
	if (index >= [self count]) {
		NSLog(@"数组越界");
		NSAssert(0, nil);
		return nil;
	}
	return [self moa_objectAtIndex:index];
	
}

- (void)moa_addObject:(id)object
{
	if (!object) {
//		[self addObject:@"kong"];
		NSLog(@"object is nil");
		NSAssert(0, nil);
	} else {
		[self moa_addObject:object];
	}
}

- (void)moa_removeObjectAtIndex:(NSInteger)index
{
	if (index >= [self count]) {
		NSLog(@"数组越界");
		NSAssert(0, nil);
		return ;
	}
	
	[self moa_removeObjectAtIndex:index];
	
}

- (void)moa_insertObject:(id)anObject atIndex:(NSUInteger)index
{
	if (!anObject) {
		NSLog(@"object is nil");
		NSAssert(0, nil);
		return;
	}
	[self moa_insertObject:anObject atIndex:index];
	
}

- (void)moa_replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
	if (index >= [self count]) {
		NSLog(@"数组越界");
		NSAssert(0, nil);
		return ;
	}
	if (!anObject) {
		NSLog(@"object is nil");
		NSAssert(0, nil);
		return;
	}
	[self moa_replaceObjectAtIndex:index withObject:anObject];
}



#endif


/*!
 @method objectAtIndexCheck:
 @abstract 检查是否越界和NSNull如果是返回nil
 @result 返回对象
 */
- (id)objectAtIndexCheck:(NSUInteger)index
{
	
	if (index >= [self count]) {
		NSLog(@"数组越界");
		NSAssert(0, nil);
		return nil;
	}
	id value = [self objectAtIndex:index];

	return value;
}

- (void)addObjectCheck:(id)object
{
	if (!object) {
		//		[self addObject:@"kong"];
		NSLog(@"object is nil");
		NSAssert(0, nil);
	} else {
		[self addObject:object];
	}
}

- (void)removeObjectAtIndexCheck:(NSInteger)index
{
	if (index >= [self count]) {
		NSLog(@"数组越界");
		NSAssert(0, nil);
		return ;
	}
	
	[self removeObjectAtIndex:index];
	
}


@end
