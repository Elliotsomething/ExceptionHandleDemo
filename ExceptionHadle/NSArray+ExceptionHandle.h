//
//  NSArray+ExceptionHandle.h
//  MOA
//
//  Created by yanghao on 2016/3/22.
//  Copyright © 2017年 moa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (ExceptionHandle)

- (id)objectAtIndexCheck:(NSUInteger)index;

@end

@interface NSMutableArray (ExceptionHandle)

- (id)objectAtIndexCheck:(NSUInteger)index;
- (void)addObjectCheck:(id)object;
- (void)removeObjectAtIndexCheck:(NSInteger)index;

@end
