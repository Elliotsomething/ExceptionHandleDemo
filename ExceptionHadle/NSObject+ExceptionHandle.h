//
//  NSObject+ExceptionHandle.h
//  ExceptionHandleDemo
//
//  Created by yanghao on 2016/3/23.
//  Copyright © 2017年 justlike. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef __OPTIMIZE__
#define _INTERNAL_MLF_ENABLED 1
#else
#define _INTERNAL_MLF_ENABLED 0
#endif


@interface NSObject (ExceptionHandle)

+ (void)swizzleSEL:(SEL)originalSEL withSEL:(SEL)swizzledSEL;


@end
