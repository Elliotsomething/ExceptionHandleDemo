//
//  ViewController.m
//  ExceptionHandleDemo
//
//  Created by yanghao on 2016/3/23.
//  Copyright © 2017年 justlike. All rights reserved.
//

#import "ViewController.h"
#import "NSArray+ExceptionHandle.h"
#import "NSDictionary+ExceptionHandle.h"
#import "NSObject+Forwarding.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];


//	NSDictionary *dic = @{@"key":[NSNull null]};
//
//	[dic[@"key"] UTF8String];
	
	
	
//
//	
//	NSMutableDictionary *diddd = [NSMutableDictionary dictionary];
//	NSString *key = nil;
//	NSString *str = nil;
//	NSDictionary *dic = @{key:str};
//	NSArray *arr = @[str];
	
//	diddd[@"key"] = str;
//	
//	[dic setValue:str forKey:key];


//	NSArray *arr = @[];
//	NSNumber *num= arr[0];
	
//	NSNull *null = [NSNull null];
	
	
//	NSMutableArray *arr = @[str].mutableCopy;
//	
//	NSArray *arr1 = [NSArray arrayWithObject:str];
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}


@end
