# KVC

### KVC简介

KVC是Key-Value-Coding(KVC)的缩写，是NSObject的分类，所以只要继承NSObject的类都具有健值编码的功能。其.h文件如下:

![kvc头文件](/assets/kvc头文件_3jccigcan.png)

其常见操作如：
- 赋值取值`setValue:forKey:` `valueForKey:`，层层访问`setValue:forKeyPath:``valueForKeyPath:`。不仅可以访问基本类型和集合类型，同时也可以访问“非对象属性”如结构体；
- 字典转模型`setValuesForKeysWithDictionary:` `dictionaryWithValuesForKeys:`；
- 聚合操作符`@avg、@count、@max、@min、@sum`；
- 数组操作符`@distinctUnionOfObjects @unionOfObjects`；
-嵌套集合(array&set)操作 `@distinctUnionOfArrays @unionOfArrays @distinctUnionOfSets`

### KVC赋值取值原理探索

代码来自于Foundation框架，非开源，但可以先阅读其文档[Key-Value Coding Programming Guide](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/KeyValueCoding/index.html#//apple_ref/doc/uid/10000107i)进行探索

1. KVC 赋值的过程
![kvc-setter](/assets/kvc-setter.png)

- `setValue:forKey:` 调用顺序为

```
|- 先调用setter相关方法
   |- setter方法，先后顺序是：set<Key>: -> _set<Key> -> set<IsKey>
|- 如果没有相关方法：看 +(BOOL)accessInstanceVariablesDirectly 返回值
   |- YES（默认值） 找成员变量进行赋值，先后顺序是：_<key> -> _is<Key> -> <key> -> is<Key>
   |- NO  异常 valueForUndefinedKey
```

2. KVC 取值的过程
![kvc-Getter](/assets/kvc-Getter.png)

- `valueForKey:` 调用顺序为：

  ```
  |- 先调用相关相关方法，先后顺序是：
     |- getter方法： get<Key> -> <key> -> is<Key> -> _<Key>
     |- NSArray方法：countOfKey 和 objectInKeyAtIndex
  |- 如果没有相关方法：看 +(BOOL)accessInstanceVariablesDirectly 返回值
     |- YES 找成员变量，先后顺序是：_<key> -> _is<Key> -> <key> -> is<Key>，(需注意：如果已声明相关成员变量，不会按顺序依次去找相关值，会去找对应的成员变量，未赋值则返回null。若未声明，则会去按顺序间接去找值。)
     |- NO  异常 valueForUndefinedKey
  ```

### 自定义KVC

自定义kvc的`setValue:forKey:`方法：

```objective-c
- (void)setValue:(nullable id)value forKey:(NSString *)key{

    // KVC 自定义
    // 1: 判断什么 key
    if (key == nil || key.length == 0) {
        return;
    }

    // 2: setter set<Key>: or _set<Key>,
    // key 要大写
    NSString *Key = key.capitalizedString;
    // 拼接方法
    NSString *setKey = [NSString stringWithFormat:@"set%@:",Key];
    NSString *_setKey = [NSString stringWithFormat:@"_set%@:",Key];
    NSString *setIsKey = [NSString stringWithFormat:@"setIs%@:",Key];

    if ([self performSelectorWithMethodName:setKey value:value]) {
        NSLog(@"*********%@**********",setKey);
        return;
    }else if ([self performSelectorWithMethodName:_setKey value:value]) {
        NSLog(@"*********%@**********",_setKey);
        return;
    }else if ([self performSelectorWithMethodName:setIsKey value:value]) {
        NSLog(@"*********%@**********",setIsKey);
        return;
    }

    // 3: 判断是否响应 accessInstanceVariablesDirectly 返回YES NO 奔溃
    // 3:判断是否能够直接赋值实例变量
    if (![self.class accessInstanceVariablesDirectly] ) {
        @throw [NSException exceptionWithName:@"UnknownKeyException" reason:[NSString stringWithFormat:@"****[%@ valueForUndefinedKey:]: this class is not key value coding-compliant for the key name.****",self] userInfo:nil];
    }

    // 4: 间接变量
    // 获取 ivar -> 遍历 containsObjct -
    // 4.1 定义一个收集实例变量的可变数组
    NSMutableArray *mArray = [self getIvarListName];
    // _<key> _is<Key> <key> is<Key>
    NSString *_key = [NSString stringWithFormat:@"_%@",key];
    NSString *_isKey = [NSString stringWithFormat:@"_is%@",Key];
    NSString *isKey = [NSString stringWithFormat:@"is%@",Key];
    if ([mArray containsObject:_key]) {
        // 4.2 获取相应的 ivar
       Ivar ivar = class_getInstanceVariable([self class], _key.UTF8String);
        // 4.3 对相应的 ivar 设置值
       object_setIvar(self , ivar, value);
       return;
    }else if ([mArray containsObject:_isKey]) {
       Ivar ivar = class_getInstanceVariable([self class], _isKey.UTF8String);
       object_setIvar(self , ivar, value);
       return;
    }else if ([mArray containsObject:key]) {
       Ivar ivar = class_getInstanceVariable([self class], key.UTF8String);
       object_setIvar(self , ivar, value);
       return;
    }else if ([mArray containsObject:isKey]) {
       Ivar ivar = class_getInstanceVariable([self class], isKey.UTF8String);
       object_setIvar(self , ivar, value);
       return;
    }

    // 5:如果找不到相关实例
    @throw [NSException exceptionWithName:@"UnknownKeyException" reason:[NSString stringWithFormat:@"****[%@ %@]: this class is not key value coding-compliant for the key name.****",self,NSStringFromSelector(_cmd)] userInfo:nil];

}

- (NSMutableArray *)getIvarListName{

    NSMutableArray *mArray = [NSMutableArray arrayWithCapacity:1];
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([self class], &count);
    for (int i = 0; i<count; i++) {
        Ivar ivar = ivars[i];
        const char *ivarNameChar = ivar_getName(ivar);
        NSString *ivarName = [NSString stringWithUTF8String:ivarNameChar];
        NSLog(@"ivarName == %@",ivarName);
        [mArray addObject:ivarName];
    }
    free(ivars);
    return mArray;
}

- (BOOL)performSelectorWithMethodName:(NSString *)methodName value:(id)value{

    if ([self respondsToSelector:NSSelectorFromString(methodName)]) {
        [self performSelector:NSSelectorFromString(methodName) withObject:value];
        return YES;
    }
    return NO;
}
```
