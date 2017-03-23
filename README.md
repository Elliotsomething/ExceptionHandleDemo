# ExceptionHandleDemo

### iOS 之 基本的异常处理

一般的崩溃分为3种情况，一是系统本身的崩溃，一是第三方库的崩溃，一是应用本身的崩溃，前面两种我们是基本没办法处理，且能处理的情况非常少；就第三种情况比较常见，是因为写代码时出现出现失误导致的bug，智者千虑必有一失，再厉害的高手也有失误的时候；所以为了处理这种bug，不至于`crash`，提高用户体验，我们可以主动的处理这种异常；

**异常主要分为以下几种：(可能还有补充)**

1. 数组越界
2. 数组、字典插入`nil`
3. 对象调用未知方法
4. 监听未移除

**注：因为set不常用，并且处理方法基本和数组一样，所以这里不讲；**

#### 1、数组越界
数组越界是最常见的一种`crash`，也就是对数组的访问超出了数组长度的范围，这种情况是很容易被忽视的，下面的例子是最简单的数组越界

```objective_c
NSArray *arr = @[];
NSString *str= arr[0];
```

**一般报错如下：**

```objective_c
'*** -[__NSArray0 objectAtIndex:]: index 0 beyond bounds for empty NSArray'
```
这种情况的处理其实很简单，只要判断一下访问数组的边界值长度就行了，但是难保以后不会出现这种情况，所以用hook是最便捷的办法，代码如下：

```objective_c
+ (void)load {
     static dispatch_once_t onceToken;
     dispatch_once(&onceToken, ^{
          [objc_getClass("__NSArray0") swizzleSEL:@selector(objectAtIndex:) withSEL:@selector(moa_empty_objectAtIndex:)];
          [objc_getClass("__NSArrayI") swizzleSEL:@selector(objectAtIndex:) withSEL:@selector(moa_objectAtIndex:)];
          [objc_getClass("__NSArrayM") swizzleSEL:@selector(objectAtIndex:) withSEL:@selector(moa_objectAtIndex:)];
          [objc_getClass("__NSArrayM") swizzleSEL:@selector(removeObjectAtIndex:) withSEL:@selector(moa_removeObjectAtIndex:)];
          [objc_getClass("__NSArrayM") swizzleSEL:@selector(insertObject:atIndex:) withSEL:@selector(moa_insertObject:atIndex:)];
          [objc_getClass("__NSArrayM") swizzleSEL:@selector(replaceObjectAtIndex:withObject:) withSEL:@selector(moa_replaceObjectAtIndex:withObject:)];
     });
}
- (id)moa_empty_objectAtIndex:(NSUInteger)index
{
     NSLog(@"数组越界");
     return nil;
}
- (id)moa_objectAtIndex:(NSUInteger)index
{
     if (index >= [self count]) {
          NSLog(@"数组越界");
          return nil;
     }
     return [self moa_objectAtIndex:index];
}
- (void)moa_removeObjectAtIndex:(NSInteger)index
{
     if (index >= [self count]) {
          NSLog(@"数组越界");
          return ;
     }
     [self moa_removeObjectAtIndex:index];
}
- (void)moa_insertObject:(id)anObject atIndex:(NSUInteger)index
{
     if (!anObject) {
          NSLog(@"object is nil");
          return;
     }
     [self moa_insertObject:anObject atIndex:index];
}
- (void)moa_replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
     if (index >= [self count]) {
          NSLog(@"数组越界");
          return ;
     }
     if (!anObject) {
          NSLog(@"object is nil");
          return;
     }
     [self moa_replaceObjectAtIndex:index withObject:anObject];
}
```

ok，以上代码完成后，只要以后有访问数组的，都会通过`hook`之后的方法，该方法都加入了边界值判断，这样就一劳永逸的解决问题了；但是，but，因为各个项目业务逻辑以及使用的技术不同，有那么一点点可能使用`hook`方法，会造成其他崩溃，所以使用`hook`需谨慎；

所以我这里也提供了另一种方案，那就是添加分类方法，此方案完全无害，唯一不足就是使用没有`hook`方案那么便捷

**代码如下：**

```objective_c
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
```
数组越界的异常处理到此结束！

#### 2、数组、字典插入nil
数组或者字典中插入`nil`引起的`crash`也是非常常见，一般来说，老手写代码在数组或者字典中插入值，通常都会先校验一遍值是否为`nil`（最常见的是三元运算符），但是也跟数组越界一样，这种crash往往也是最容易忽视的，只在某种特定的环境下才会出现，一旦出现就是`crash`；

所以跟数组越界一样做好异常处理，不轻易让应用crash是一个coder的基本要求；

**下面的例子是最简单的数组、字典插入`nil`**

```objective_c
NSString *key = nil;
NSString *str = nil;
NSArray *arr = @[str];
NSDictionary *dic = @{key:str};
```
**报错日志如下：**

```objective_c
'*** -[__NSPlaceholderArray initWithObjects:count:]: attempt to insert nil object from objects[0]'
'*** -[__NSPlaceholderDictionary initWithObjects:forKeys:count:]: attempt to insert nil object from objects[0]'
```

一般性的如果在插入值之前检验一下需要插入的值是否为nil，是可以避免这种crash的，但是也是因为粗心，或者业务逻辑较强，存在隐秘的bug，这种情况就算老手都会犯错；

所以同样的方案，hook一下（如果造成其他bug的请不要找我，这个坑我也遇到过，解决办法就是不要用hook，用方案二，添加分类方法）

**处理这种异常的代码如下：**

**首先是数组/*NSArray*/**

```objective_c
+ (void)load {
     static dispatch_once_t onceToken;
     dispatch_once(&onceToken, ^{
          [objc_getClass("__NSPlaceholderArray") swizzleSEL:@selector(initWithObjects:count:) withSEL:@selector(moa_initWithObjects:count:)];
          [object_getClass((id)self) swizzleSEL:@selector(arrayWithObjects:count:) withSEL:@selector(moa_arrayWithObjects:count:)];
          [objc_getClass("__NSArrayM") swizzleSEL:@selector(addObject:) withSEL:@selector(moa_addObject:)];
          [objc_getClass("__NSArrayM") swizzleSEL:@selector(insertObject:atIndex:) withSEL:@selector(moa_insertObject:atIndex:)];
          [objc_getClass("__NSArrayM") swizzleSEL:@selector(replaceObjectAtIndex:withObject:) withSEL:@selector(moa_replaceObjectAtIndex:withObject:)];
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
- (void)moa_addObject:(id)object
{
     if (!object) {
          NSLog(@"object is nil");
          NSAssert(0, nil);
     } else {
          [self moa_addObject:object];
     }
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
```
**然后是字典/*NSDictionary*/**

```objective_c
+ (void)load {
     static dispatch_once_t onceToken;
     dispatch_once(&onceToken, ^{
          [object_getClass((id)self) swizzleSEL:@selector(dictionaryWithObjects:forKeys:count:) withSEL:@selector(moa_dictionaryWithObjects:forKeys:count:)];
          [objc_getClass("__NSPlaceholderDictionary") swizzleSEL:@selector(initWithObjects:forKeys:count:) withSEL:@selector(moa_initWithObjects:forKeys:count:)];
          [objc_getClass("__NSDictionaryM") swizzleSEL:@selector(setObject:forKey:) withSEL:@selector(moa_setObject:forKey:)];
          [objc_getClass("__NSDictionaryM") swizzleSEL:@selector(setValue:forKey:) withSEL:@selector(moa_setValue:forKey:)];
          [objc_getClass("__NSDictionaryM") swizzleSEL:@selector(removeObjectForKey:) withSEL:@selector(moa_removeObjectForKey:)];
          [objc_getClass("__NSDictionaryM") swizzleSEL:@selector(setObject:forKeyedSubscript:) withSEL:@selector(moa_setObject:forKeyedSubscript:)];
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
- (void)moa_setObject:(id)anObject forKey:(id<NSCopying>)aKey
{
     if (!anObject)
     {
          NSLog(@"error: anObject is nil");
          return;
     }
     if (!aKey)
     {
          NSLog(@"error: aKey is nil");
          return;
     }
     [self moa_setObject:anObject forKey:aKey];
}
- (void)moa_setValue:(id)value forKey:(NSString *)key
{
     if (!key)
     {
          NSLog(@"error: aKey is nil");
          return;
     }
     [self moa_setValue:value forKey:key];
}

- (void)moa_removeObjectForKey:(id)aKey
{
     if (!aKey)
     {
          NSLog(@"error: aKey is nil");
          return;
     }
     [self moa_removeObjectForKey:aKey];
}
- (void)moa_setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key {
     if (!obj)
     {
          NSLog(@"error: anObject is nil");
          return;
     }
     if (!key)
     {
          NSLog(@"error: aKey is nil");
          return;
     }
     [self moa_setObject:obj forKeyedSubscript:key];
}
```

#### 3、对象调用未知方法
对象调用未知方法，也可以说是给未知对象发送了消息，这种`crash`可以说是最常见的，上面两种在`review`时还是有可能被发现的，但是这种就比较难发现了，因为一般能发现的都在自测阶段发现了，发现不了的都是隐藏很深的`bug`，一旦出现了，肯定是必现的`bug`；

**下面的例子是最简单的数组、字典插入nil**

```objective_c
NSDictionary *dic = @{@"key":[NSNull null]};
[dic[@"key"] UTF8String];
```
**`crash`信息如下：**

```objective_c
unrecognized selector sent to instance
```

这里只对一般性处理，也就是对`NSNull`、`NSDictionary`、`NSArray`、`NSNumber`、`NSString`这些类提供消息转发处理
解决的代码如下：

```objective_c
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
```

#### 4、监听未移除
监听未移除造成的`crash`虽然不常见，但是也很麻烦，因为有些`crash`由于业务逻辑的原因藏得非常隐秘，只有在特定的情况下才会出现；本人不幸曾遇到过一次，重现bug花了老长时间，所以有必要还是需要处理一下这种`crash`；

监听未移除会造成的`crash`是对已释放对象发送了消息；当然系统级的监听是不会crash的，但是也还是要移除，这是一个好习惯，因为不移除该监听还是一直存在，系统不会帮忙移除，平白耗内存；

crash信息如下：

```objective_c

```

处理这种异常的代码如下：

```objective_c
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
```

到这里基本的异常处理就结束了，以后可能还会有补充，这些代码加上之后，可以让你的应用网上`crash`率降低很多；

本篇主要讲了如何处理常见的crash，涉及到的基本知识有runtime，数组、字典、KVO等
