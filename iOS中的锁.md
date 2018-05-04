# iOS中的锁

参考:
> [Synchronization][Synchronization] | [杨萧玉的中文翻译][Threading Programming Guide(3)]

> [iOS 的多线程同步][iOS 的多线程同步]

> [杨萧玉的关于 @synchronized][关于 @synchronized]

本文是参考一些文档和资料对iOS中的@synchronized，做了一个笔记，从而延伸了知识盲区（锁、栅栏／屏障（Barrier）、散列表）。

## @synchronized

- @synchronized 结构防止不同的线程同时执行同一段代码;
- @synchronized 用着更方便，可读性更高;
- @synchronized慢，但@synchronized和其他同步锁的性能相比并没有很夸张，对于使用者来说几乎忽略不计；
- 你调用 sychronized 的每个对象，Objective-C runtime 都会为其分配一个锁pthread_mutex（pthread_mutex锁的属性类型为PTHREAD_MUTEX_RECURSIVE支持递归）并存储在哈希表中。传入的object的内存地址，被用作key，通过一个哈希算法将映射到数组上的一个下标。
- Using the @synchronized Directive
  ```Objective-C
  - (void)myMethod:(id)anObj
  {
      @synchronized(anObj)
      {
          // Everything between the braces is protected by the @synchronized directive.
      }
  }
```

#### 锁是如何与你传入 @synchronized 的对象关联上的？

<objc/objc-sync.h>可看这两个函数。@synchronized block 会变成 objc_sync_enter 和 objc_sync_exit 的成对儿调用；

调用 objc_sync_enter(obj) 时，它用 obj 内存地址的哈希值查找合适的 SyncData，然后将其上锁。当你调用 objc_sync_exit(obj) 时，它查找合适的 SyncData 并将其解锁。

[objc-sync源码]
```Objective-C
typedef struct SyncData {
    id object;  // 我们给 @synchronized 传入的那个对象
    recursive_mutex_t mutex; // 跟 object 关联在一起的锁
    struct SyncData* nextData; // 指向另一个 SyncData 对象的指针
    int threadCount; // 线程数量，threadCount==0 就暗示了这个 SyncData 实例可以被复用
} SyncData
```

#### 假如你传入 @synchronized 的对象在 @synchronized 的 block 里面被释放或者被赋值为 nil 将会怎么样？

源码中，注意到 objc_sync_enter 里面没有 retain 和 release;

@synchronized不会保持（retain，增加引用计数）被锁住的对象;

如果你向 @synchronized 传递 nil，那么你就不会得到任何锁而且你的代码将不会是线程安全的！



## 知识盲区：

### 锁

在计算机科学中，锁是一种同步机制，用于多线程环境中对资源访问的限制。你可以理解成它用于排除并发的一种策略。

可以用它保护代码中的临界区域（critical section）。临界区域中的代码只允许同时被一个线程访问。

> **临界区域**指的是一块对公共资源进行存取的代码，并非一种机制或是算法;

#### 互斥锁（Mutual exclusion，缩写Mutex）
 - 是一种用于多线程编程中，防止两条线程同时对同一公共资源（比如全局变量）进行读写的机制。
 该目的通过将代码切片成一个一个的临界区域。

 - 互斥锁实际上是一种变量，在使用互斥锁时，实际上是对这个变量进行置0置1操作并进行判断使得线程能够获得锁或释放锁;

 - 互斥锁的作用是对临界区加以保护，以使任意时刻只有一个线程能够执行临界区的代码。实现了多线程之间的互斥;

 - macOS 和 iOS 都提供了基础的互斥锁。Foundation 框架定义了几种用于特别场景的互斥锁作为补充

  - ##### [POSIX][POSIX线程] 互斥锁

    pthread 表示 POSIX thread，定义了一组跨平台的线程相关的 API

    常见用法：
    ```Objective-C
    #import <pthread.h>
    pthread_mutexattr_t attr;
    pthread_mutexattr_init(&attr);
    pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_NORMAL);  // 定义锁的属性

    pthread_mutex_t mutex;
    pthread_mutex_init(&mutex, &attr); // 创建锁

    pthread_mutex_lock(&mutex); // 申请锁
    // 临界区
    pthread_mutex_unlock(&mutex); // 释放锁
    ```

  - ##### Cocoa 中基本的互斥锁 NSLock

    - NSLock 只是在内部封装了一个 pthread_mutex，属性为 PTHREAD_MUTEX_ERRORCHECK;
    - NSLock 的所有锁的接口实际上都由 NSLocking 协议定义，也就是 lock 和 unlock 这俩方法，对应功能是获取和释放锁。

      常见用法：
      ```Objective-C
      [_lock lock];
      // 临界区
      [_lock unlock];
      ```
    - NSLock 类还提供了 tryLock 和 lockBeforeDate: 方法
      - tryLock 方法尝试获取锁，但如果锁不可用，并不会阻塞，只是返回 NO 而已;
      - lockBeforeDate: 方法尝试获取锁，并一直阻塞线程，直到获取到锁（返回 YES）或达到限定的时间（返回 NO）。

  - ##### @synchronized


#### 递归锁
 - 是互斥锁的变种；

 - 如果，锁已经被使用了且没有解锁，此时需要一直等待锁被解除，这样就导致了**死锁**，线程被阻塞住了；

   死锁的两个常见场景：
   - 当两个不同的线程分别持有一个锁，并且尝试获取对方持有的锁，死锁就发生了。因为每个线程永远都获取不到另一个锁，结果就是永久阻塞；
   - 一个线程，线程抱着锁找锁；

 - 递归锁，这个锁可以被同一线程多次请求，而不会引起死锁。解决线程抱着锁找锁而造成死锁的问题；

 - 递归锁会跟踪它被lock的次数，每次成功的lock都必须平衡调用unlock操作。达到这种平衡，锁最后才能被释放，以供其它线程使用。应该小心权衡；

 - 主要是用在循环或递归操作中。

 - Cocoa 框架的NSRecursiveLock 类也就是递归锁

  使用实例参考：
  > [NSRecursiveLock递归锁的使用][NSRecursiveLock递归锁的使用]

  NSRecursiveLock也是通过POSIX来实现的。内部也是封装了一个 pthread_mutex，属性为类型为PTHREAD_MUTEX_RECURSIVE;


#### 条件锁

[生产者消费者问题][生产者消费者问题]

> - 也称有限缓冲问题（英语：Bounded-buffer problem），是一个多线程同步问题的经典案例;
- 该问题描述了共享固定大小缓冲区的两个线程——即所谓的“生产者”和“消费者”——在实际运行时会发生的问题;
- 生产者的主要作用是生成一定量的数据放到缓冲区中，然后重复此过程;
- 与此同时，消费者也在缓冲区消耗这些数据;
- 该问题的关键就是要保证生产者不会在缓冲区满时加入数据，消费者也不会在缓冲区中空时消耗数据。

条件锁主要为了解决生产者消费者问题：
- 它可以让一个线程等待某一条件，当条件满足时，会收到通知;
- 提供了线程阻塞与信号机制，因此可以用来阻塞某个线程，并等待某个数据就绪，随后唤醒线程；

##### POSIX 提供的相关函数如下：
```
pthread_cond_init 初始化
pthread_cond_wait 等待条件
pthread_cond_broadcast 发送广播，唤醒所有正在等待的线程
pthread_cond_signal 发送信号，唤醒第一个线程
pthread_cond_destroy 销毁
```

伪代码例子：
```
void consumer () { // 消费者
    pthread_mutex_lock(&mutex);
    while (data == NULL) {
        pthread_cond_wait(&condition_variable_signal, &mutex); // 等待数据
    }
    // --- 有新的数据，以下代码负责处理 ↓↓↓↓↓↓
    // temp = data;
    // --- 有新的数据，以上代码负责处理 ↑↑↑↑↑↑
    pthread_mutex_unlock(&mutex);
}

void producer () { // 生产者
    pthread_mutex_lock(&mutex);
    // 生产数据
    pthread_cond_signal(&condition_variable_signal); // 发出信号给消费者，告诉他们有了新的数据
    pthread_mutex_unlock(&mutex);
}
```

例子：
```
#include <pthread.h>

static pthread_mutex_t mutex;
static pthread_cond_t condition;

// ...

pthread_mutex_init(&mutex, NULL);
pthread_cond_init(&condition, NULL);

// ...

void waitCondition()
{
    pthread_mutex_lock(&mutex);
    while (value == 0) {
        pthread_cond_wait(&condition, &mutex);
    }
    pthread_mutex_unlock(&mutex);
}

void triggerCondition()
{
    pthread_mutex_lock(&mutex);

    value = 1;

    pthread_mutex_unlock(&mutex);
    pthread_cond_broadcast(&condition);
}

// ...

pthread_mutex_destroy(&mutex);
pthread_cond_destroy(&condition);
```

##### NSCondition
- NSCondition 是对 POSIX Condition 语法的封装，而且将锁和 condition 数据结构包含在一个对象里；
- 这使得可以用一个对象既能当做互斥锁 lock，又能像 Condition 一样继续 wait。

```Objective-C
[cocoaCondition lock];
while (timeToDoWork <= 0)
    [cocoaCondition wait];

timeToDoWork--;

// Do real work here.

[cocoaCondition unlock];
```
发送信号：
```Objective-C
[cocoaCondition lock];
timeToDoWork++;
[cocoaCondition signal];
[cocoaCondition unlock];
```

##### NSConditionLock
- 一般用于线程需要以特定的顺序执行任务时，例如生产者消费者问题;
- 当生产者执行时，消费者需要使用程序中特定的条件变量来获取锁。所谓的条件变量其实就是个程序员定义的整型数。当生产者完成后，它会 unlock 并更新条件变量，进而唤醒了消费者线程。消费者线程继续处理数据。

代码演示：

```Objective-C
NSConditionLock *cLock = [[NSConditionLock alloc] initWithCondition:0];

//线程1
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    if([cLock tryLockWhenCondition:0]){
        NSLog(@"线程1");
        [cLock unlockWithCondition:1];
    }else{
        NSLog(@"失败");
    }
});

//线程2
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [cLock lockWhenCondition:3];
    NSLog(@"线程2");
    [cLock unlockWithCondition:2];
});

//线程3
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [cLock lockWhenCondition:1];
    NSLog(@"线程3");
    [cLock unlockWithCondition:3];
});
/*
 打印：
 线程1
 线程3
 线程2
 */
```
- 初始化 NSConditionLock 对象，Condition标示为0
- 线程1执行tryLockWhenCondition:时，我们传入的条件标示也是0,所以线程1加锁成功；执行unlockWithCondition:时，这时候会把condition由0修改为1；
- 因为condition修改为了1，会先走到线程3；
- 然后线程3又将condition修改为3最后走了线程2的流程。

#### [读写锁][BD读写锁]

关于读写锁，百度百科写的非常清晰。

如下引用来自苹果官方文档[Synchronization][Synchronization]Table 4-1 Lock types

Read-write lock
> - 如果对一个临界区大部分是读操作而只有少量的写操作，在大规模操作上应用读写锁可以显著降低线程互斥产生的代价。
- 正常操作数据时，可以同时有多个读操作。线程想要做写操作时，需要等到所有的读操作完成并释放锁之后，然后写操作会获取锁并更新数据。
- 在写操作线程阻塞等待锁被释放时，新来的读操作线程在写操作完成前会一直阻塞。
- iOS系统只支持 POSIX 线程中使用读写锁

创建和关闭方法如下：
```Objective-C
#import <pthread.h>
```
```Objective-C
int pthread_rwlock_init(pthread_rwlock_t *restrict rwlock,
                        const pthread_rwlockattr_t *restrict attr);
int pthread_rwlock_destroy(pthread_rwlock_t *rwlock);
```
获得读写锁的方法如下：
```Objective-C
int pthread_rwlock_rdlock(pthread_rwlock_t *rwlock);
int pthread_rwlock_wrlock(pthread_rwlock_t *rwlock);
int pthread_rwlock_unlock(pthread_rwlock_t *rwlock);
int pthread_rwlock_tryrdlock(pthread_rwlock_t *rwlock);
int pthread_rwlock_trywrlock(pthread_rwlock_t *rwlock);
pthread_rwlock_rdlock：获得读锁
pthread_rwlock_wrlock：获得写锁
pthread_rwlock_unlock：释放锁，不管是读锁还是写锁都是调用此函数
```


#### [自旋锁][WIKI自旋锁]
- 自旋锁与互斥锁比较类似，它们都是为了解决对某项资源的互斥使用，目的都是为了确保临界区只有一个线程可以访问:
  - 对于互斥锁，如果资源已经被占用，资源申请者只能进入睡眠状态sleep-waiting
  - 自旋锁不会引起调用者睡眠，如果自旋锁已经被别的执行单元保持，调用者就一直循环在那里看是否该自旋锁的保持者已经释放了锁
- 自旋锁会重复查询锁的条件，直到为 true。自旋锁属于在施行**忙等busy-waiting**机制;
- 如果临界区的执行时间过长，不建议使用自旋锁，因为在 while 循环中，线程处于忙等状态，白白浪费 CPU 时间，最终因为超时被操作系统抢占时间片；


参考[这篇文章][bestswifter锁]来看自旋锁原理伪代码：

```
bool test_and_set (bool *target) {
    bool rv = *target;
    *target = TRUE;
    return rv;
}

bool lock = false; // 一开始没有锁上，任何线程都可以申请锁
do {
    while(test_and_set(&lock); // test_and_set 是一个原子操作
        Critical section  // 临界区
    lock = false; // 相当于释放锁，这样别的线程可以进入临界区
        Reminder section // 不需要锁保护的代码
}
```

使用示例
 - OSSpinLock
 ```Objective-C
 'OSSpinLock' is deprecated: first deprecated in iOS 10.0 - Use os_unfair_lock() from <os/lock.h> instead
 ```
 OSSpinLock在iOS10.0中已被弃用，具体原因可看这篇【[不再安全的 OSSpinLock][不再安全的 OSSpinLock]】，说到这个自旋锁OSSpinLock存在优先级反转的问题。

 苹果现在推荐使用os_unfair_lock实现自旋锁

 - os_unfair_lock
   ```Objective-C
   #import <os/lock.h>

  // 初始化
  os_unfair_lock_t unfairLock = &(OS_UNFAIR_LOCK_INIT);
  // 加锁
  os_unfair_lock_lock(unfairLock);
  // 解锁
  os_unfair_lock_unlock(unfairLock);
  // 尝试加锁
  BOOL b = os_unfair_lock_trylock(unfairLock);
   ```

#### [信号量][百度百科信号量]
通过控制**信号量**，我们可以控制能够同时进行的**并发数**
- 多个线程要访问同一个资源的时候，往往会设置一个信号量，当信号量大于0的时候，新的线程可以去操作这个资源
- 操作时信号量-1，操作完后信号量+1
- 信号量等于0的时候，必须等待

POSIX 提供的相关函数如下：
```
sem_init 初始化
sem_post 给信号量的值加一（V 操作）
sem_wait 给信号量的值减一（P 操作）
sem_getvalue 返回信号量的值
sem_destroy 销毁
```

iOS利用GCD信号量dispatch_semaphore控制并发
```Objective-C
 // 创建信号量。参数：信号量的初值，如果小于0则会返回NULL
 dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);

 // 等待降低信号量。可以理解为lock,会使得signal值-1; 第二个参数“超时时间”可自行设置，DISPATCH_TIME_FOREVER为永久等待。
 dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

 // 提高信号量。可以理解为unlock,会使得signal值+1
 dispatch_semaphore_signal(semaphore);
```

理解：
> 停车场剩余4个车位，那么即使同时来了四辆车也能停的下。如果此时来了五辆车，那么就有一辆需要等待。
**信号量的值**（signal）就相当于剩余车位的数目，dispatch_semaphore_wait函数就相当于来了一辆车，dispatch_semaphore_signal就相当于走了一辆车。停车位的剩余数目在初始化的时候就已经指明了（dispatch_semaphore_create（long value）），调用一次 dispatch_semaphore_signal，剩余的车位就增加一个；调用一次dispatch_semaphore_wait 剩余车位就减少一个；当剩余车位为 0 时，再来车（即调用 dispatch_semaphore_wait）就只能等待。有可能同时有几辆车等待一个停车位。有些车主没有耐心，给自己设定了一段等待时间，这段时间内等不到停车位就走了，如果等到了就开进去停车。而有些车主就像把车停在这，所以就一直等下去。

例子：
> [GCD - dispatch_semaphore（信号量）的理解及使用][dispatch_semaphore（信号量）的理解及使用]

> [iOS之利用GCD信号量控制并发网络请求][iOS之利用GCD信号量控制并发网络请求]

---
### 栅栏／屏障（Barrier）

如果一个线程需要等待另一个线程的某些操作之后才能继续执行，可以用上面所说的条件变量来实现，还有一种优雅的实现方式 —— Barrier。 形象点说，就是把线程挡在同一个 Barrier 之前，所有的线程都达到 Barrier 之后，统一放行。

同样，iOS 中有两种实现方式：

##### POSIX

相关函数如下：
```
pthread_barrier_init 创建 barrier
pthread_barrier_wait 告知当前线程已经到达 barrier，等所有线程都告知后，会继续往下执行
pthread_barrier_destroy 销毁
```

##### Dispatch Barrier
Dispatch Barrier 的概念跟 POSIX 类似，不同的是它是针对于 GCD 异步任务的。它可以让在它之前提交的异步任务都执行完成之后再执行。

例子：

```
dispatch_async(async_queue, block1);
dispatch_async(async_queue, block2);
// block3 会在 block1 和 block2 执行完成之后再执行
dispatch_barrier_async(async_queue, block3);
// block4 和 block5 会在 block3 之后执行
dispatch_async(async_queue, block4);
dispatch_async(async_queue, block5);
```

---

### [散列表（Hash table，也叫哈希表)][哈希表]
- Objective-C 中的字典 NSDictionary 底层其实是一个哈希表，是一种[数据结构][数据结构](是计算机中存储、组织数据的方式)，实现key-value的快速存取；

  [Dictionaries: Collections of Keys and Values][Dictionaries: Collections of Keys and Values]
  > Internally, a dictionary uses a hash table to organize its storage and to provide rapid access to a value given the corresponding key

- weak 实现原理也与哈希表有关：

  Runtime维护了一个weak表，用于存储指向某个对象的所有weak指针。weak表其实是一个hash（哈希）表，Key是所指对象的地址，
  Value是weak指针的地址（这个地址的值是所指对象的地址）数组。

  文章：
    >[runtime 如何实现 weak 属性][runtime 如何实现 weak 属性]

    >[iOS 底层解析weak的实现原理（包含weak对象的初始化，引用，释放的分析）][iOS 底层解析weak的实现原理]

- 哈希表的本质是一个数组，数组中每一个元素称为一个箱子(bin)，箱子中存放的是键值对；
- 哈希表的存储过程如下:

    - 根据 key 计算出它的哈希值 h。
    - 假设箱子的个数为 n，那么这个键值对应该放在第 (h % n) 个箱子中。
    - 如果该箱子中已经有了键值对，就使用**开放寻址法**或者**拉链法**等解决冲突。



[iOS 的多线程同步]: https://blog.zorro.im/posts/ios-muti-threading-synchronization.html
[生产者消费者问题]: https://zh.wikipedia.org/wiki/%E7%94%9F%E4%BA%A7%E8%80%85%E6%B6%88%E8%B4%B9%E8%80%85%E9%97%AE%E9%A2%98
[BD读写锁]: https://baike.baidu.com/item/%E8%AF%BB%E5%86%99%E9%94%81
[WIKI自旋锁]: https://zh.wikipedia.org/wiki/%E8%87%AA%E6%97%8B%E9%94%81
[bestswifter锁]: https://bestswifter.com/ios-lock/#
[不再安全的 OSSpinLock]: https://blog.ibireme.com/2016/01/16/spinlock_is_unsafe_in_ios/
[百度百科信号量]: https://baike.baidu.com/item/%E4%BF%A1%E5%8F%B7%E9%87%8F
[iOS之利用GCD信号量控制并发网络请求]: https://blog.csdn.net/Cloudox_/article/details/71107179
[dispatch_semaphore（信号量）的理解及使用]: https://www.cnblogs.com/yajunLi/p/6274282.html
[POSIX线程]: https://zh.wikipedia.org/wiki/POSIX%E7%BA%BF%E7%A8%8B
[Synchronization]: https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/Multithreading/ThreadSafety/ThreadSafety.html#//apple_ref/doc/uid/10000057i-CH8-SW3
[Threading Programming Guide(3)]: http://yulingtianxia.com/blog/2017/10/08/Threading-Programming-Guide-3/
[objc-sync源码]: https://opensource.apple.com/source/objc4/objc4-646/runtime/objc-sync.mm
[NSRecursiveLock递归锁的使用]: http://www.cocoachina.com/ios/20150513/11808.html
[数据结构]: https://baike.baidu.com/item/%E6%95%B0%E6%8D%AE%E7%BB%93%E6%9E%84/1450#7_2
[哈希表]: https://zh.wikipedia.org/wiki/%E5%93%88%E5%B8%8C%E8%A1%A8
[关于 @synchronized]: http://yulingtianxia.com/blog/2015/11/01/More-than-you-want-to-know-about-synchronized/
[Dictionaries: Collections of Keys and Values]: https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/Collections/Articles/Dictionaries.html
[runtime 如何实现 weak 属性]: https://github.com/ChenYilong/iOSInterviewQuestions/blob/master/01《招聘一个靠谱的iOS》面试题参考答案/《招聘一个靠谱的iOS》面试题参考答案（上）.md#8-runtime-如何实现-weak-属性
[iOS 底层解析weak的实现原理]: http://www.cocoachina.com/ios/20170328/18962.html
