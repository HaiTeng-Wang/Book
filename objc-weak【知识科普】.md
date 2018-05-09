# objc-weak【知识科普】

[objc-weak.h]

- Runtime维护了一个weak表，用于存储指向某个对象的所有weak指针;

- weak表是由单个自旋锁管理的散列表;

-  weak指向的对象内存地址作为key。

### 数据结构

```Objective-C
typedef objc_object ** weak_referrer_t;
```

```Objective-C
struct weak_table_t {
    weak_entry_t *weak_entries;  //  values
    size_t    num_entries;
    uintptr_t mask;
    uintptr_t max_hash_displacement;
};
```

```Objective-C
struct weak_entry_t {
    DisguisedPtr<objc_object> referent;
    union {
        struct {
            weak_referrer_t *referrers;
            uintptr_t        out_of_line : 1;
            uintptr_t        num_refs : PTR_MINUS_1;
            uintptr_t        mask;
            uintptr_t        max_hash_displacement;
        };
        struct {
            // out_of_line=0 is LSB of one of these (don't care which)
            weak_referrer_t  inline_referrers[WEAK_INLINE_COUNT];
        };
    };
};
```

### 相关函数：

weak表中添加一对(object, weak pointer)：

```Objective-C
id weak_register_no_lock(weak_table_t *weak_table, id referent, id *referrer);
```

weak表中移除一对(object, weak pointer)：
```Objective-C
void weak_unregister_no_lock(weak_table_t *weak_table, id referent, id *referrer);
```

主要用于调试，判断一个对象是否为弱引用
```Objective-C
bool weak_is_registered_no_lock(weak_table_t *weak_table, id referent);
```
weak表中读取值
```Objective-C
id weak_read_no_lock(weak_table_t *weak_table, id *referrer);
```

弱指针设置为零
```Objective-C
void weak_clear_no_lock(weak_table_t *weak_table, id referent);
```

[objc-weak.h]: https://opensource.apple.com/source/objc4/objc4-646/runtime/objc-weak.h
