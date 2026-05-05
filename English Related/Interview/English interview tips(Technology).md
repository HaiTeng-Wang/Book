# Must-Know Vocabulary
## A
Associated(associated value) \ argument
## B
## C
Cycle(retain cycle, lifecycle) \ Capture(capture list) \ Constraint \ Convenience \ Compute (computed properties) \ Constant \ Conform(conform to the Hashable protocol, and meet requirements)

## D
Declare \ Define \ Describe (Describes what the function does) \ Designated \ Dot(dot syntax chain)
## E
Especially \ Escaping(escaping closure) \ Exit(eraly exit) \ Execute(Execute the code.) \ External \ Entity
## F
Force(force unwrapping)
## G
Generic (generic collection)
## H
## I
Improve (improveing readability) \ In Summary \ Indicate \ Implicit(Implicit Or Explicit)
## J
## K
## L
## M
Manual \ Multiple(multiple values) \ Mutable And Immutable(mutable variable, mutable state) \ Modern
## N
Nested(Nested Functions) \ Nil-coalescing (??)
## O
Otherwise(otherwise, the else block executes.) \ Omit(omit lable) \ Opaque(Opaque Types and Boxed Protocol Types) \ Optional(optional chaining)
## P
Parameter \ Principle
## Q
## R
regardless of(The system will retry regardless of the error type.) \ Represent
## S
Serial(serial queue) \ statement (if statement, switch statement) \ Symbol \ Syntax \ Subscript \ Subscription \ Several
## T
Trailing(trailing closure)
## U
Unique(unique key) \ Unwrap(force unwarp, implicitly unwrapped optional)
## V
Variable \  
## W
## X
## Y
## Z

| 符号 | 英文名称 | 中文名称 |
| ----------- | ----------- | ----------- |
| &	| ampersand | & 和号 |
| @	| at sign	| @ 符号 |
| #	| hash(pound sign)	| 井号 |
| *	| asterisk	| * 星号 |
| ; | semicolons | 分号 |
| !	| exclamation mark	| 感叹号 |
| ?	| question mark	| 问号 |
| () | parentheses / round brackets	 | 圆括号 / 小括号 |
| {}	| braces / curly braces	| 花括号 / 大括号 |
| [] |	brackets / square brackets |	方括号 / 中括号 |
| <> |	angle brackets	| 尖括号 |


# Basic

## Memory management(ARC)
1. iOS 内存管理机制  
iOS uses Automatic Reference Counting (ARC) to manage memory. ARC automatically tracks how many strong references point to an object. When the reference count drops to zero, ARC deallocates the object and releases its memory. In a normal situation, We don't need to manually call retain or release for memory management.

2. 内存泄漏的根本原因  
However, memory leaks happen when ARC cannot deallocate an object because the reference count never reaches zero, even though the app no longer needs the object. This is typically caused by the retain cycle (also called a circular reference). And (结果) over time, the app consumes more and more memory, which can lead to the app becomes slow or may crash.

3. 常见的循环引用场景  
Here are the most common causes of retain cycles in iOS development:  
  a.) Delegates: Using a strong reference for a delegate.  
    If there's a potential retain cycle between the delegating object and its delegate (e.g., both hold strong references to each other), the delegate reference should be weak. However, if the delegate is a short-lived object (e.g., a method parameter or a temporary helper), a strong reference may be appropriate and simpler.  
      ```swift
      // Sample
      class ViewController: UIViewController, DataLoaderDelegate {
          let loader = DataLoader() // self -> loader
          init() { loader.delegate = self } // loader -> self
      }
      class DataLoader { var delegate: DataLoaderDelegate? }
      ```   
    b.) Closures: Capturing self strongly inside a closure.    
      As we know, closures are reference types. If a closure is stored as a property and self is called within the closure, a retain cycle occurs, that means self holds the closure, and the closure captures self, or we can say, holds self. So, this is a retain cycle, we can fix this by using a capture list, such as [weak self] or [unowned self].  
    c. ) Two objects holding strong references to each other.   
      For example, like the Person and Apartment example from Swift's official documentation, the Person class has an Apartment property, and the Apartment class has a Person property. When they hold references to each other, a strong reference cycle occurs. In this case, we can use weak to break the cycle.  
    d.) Timer:  
      A Timer or CADisplayLink that holds a strong reference to its target (like self). If not invalidated properly, they keep self alive forever. So we need to call the invalidate function in the right place, like viewWillDisappear or deinit.
      Additionally, note that if we create a timer using a closure and the timer is stored as a property of the current class, we must capture self weakly within the closure body; otherwise, a retain cycle will still occur.  
    e.) Observer:  
      On iOS 11 and later, the new KVO observe API is automatically cleaned up. However, for NotificationCenter's block API, if we don't remove the token, it will not crash, but the block will stay alive and continue to execute, leading to memory leaks. So we need to be careful about this — we still need to manually remove it in this situation.  
    f.) CoreFundation Object:  
      For CoreFoundation objects like CFRunLoopObserver or CFNotificationCenter, there's no automatic cleanup, ARC doesn't cover them. We must manually remove them and call CFRelease. Otherwise, that will get leaks or crashes.

4. 如何检测内存泄漏  
a.) Instruments (Leaks tool)  
   Detects leaked memory while running the app. It can show a red "X" when a leak occurs. However, when I simulated a closure's retain cycle, this，tool is ineffective for me that failed to detect memory leaks.  
b.) Static analyzer  
   I also tried Xcode's static analyzer, but the result was not ideal — it didn't detect the memory leak. It only gave some code warnings, like uncalled supers methods, unused variable declarations, and so on.  
c.) Xcode Memory Graph Debugger    
   This tool is very useful. Visually displays object references and retain cycles. It can shows whether multiple instances of the same object appear in the memory graph. I have tested and confirmed it works effectively for identifying memory leaks.  
d.) Deinit Method Check  
   We can add a breakpoint or log inside the deinit method to verify whether an object is properly released.


5. 其它注意  
Other notes: Besides memory leaks, there are other situations that increase memory usage.
  - `imageWithName`: loads images into RAM. For large images or images that are not frequently used, we can use `imageWithContentsOfFile` API instead:.
  - Avoid creating too many singletons or static instances. They live forever with the app. Also, they make testing harder.
  - Don't use UIWebView, It has poor performance It's deprecated by Apple. Use WKWebView instead.

### Week VS Unowend
- Weak and unowned both break retain cycles without increasing reference counts.   
- The main difference is that weak is optional — it becomes nil when the object is deallocated, so it's safe. Unowned is non-optional — it assumes the object always exists[ɪɡˈzɪst], so if we access it after deallocation, the app will crashes.  
- Use weak for delegates and most cases. Use unowned only when we are absolutely sure the object lives as long as the reference, like two objects with the same lifetime.（A good example is a closure that is a property of self and captures self. The closure and self have the same lifetime — when self is deallocated, the closure is gone too. So [unowned self] is safe and more convenient because we don't need to write self?. every time. But we must be certain the closure will not outlive self）



## Multithreading And Concurrency

### GCD VS OperationQueue
- GCD is a low-level C API. It provides queue[kju] groups to execute[x,cute] asynchronous code in block. With GCD we can easily use shared local variables and easily perform thread communication through blocks. We can use GCD for simple background tasks, like network callbacks or file saving. GCD also has rich functions (eg: semaphores[ˈsɛməˌfɔr]、barriers for thread-safe, dispatch_once for singleton creation, etc).
- OperationQueue is built based on GCD, it provides more control for complex operations(eg: it supports dependencies between operations, operation monitoring, it can cancel/pause operations, also can reusable operations, and set the maximum[ˈmæksəməm] number of concurrent, etc). when we need more control for background tasks. we can use OperationQueue.

#### Choose OperationQueue over GCD? (real example)
For example:
- Downloading multiple images from a server where image B depends on image A.   
- Or when a user can scroll through a list and I need to cancel loading images that are no longer visible. OperationQueue makes it easy to cancel those operations. With GCD, cancelling a running task is difficult — almost impossible.

#### Semaphore and Dispatch Group
- Dispatch Group: It is often used when we need to run tasks in parallel and then perform some work after all tasks have completed. We can add tasks to a group, and when they are all completed, the completion handler callback will be executed, so we can do something in the callback.
- Semaphore: It is used to control access to a limited resource across multiple threads. It maintains a counter, and each time a thread tries to access the resource, the counter is decreased(semaphore.wait() -1), after the visit, the counter increases(semaphore.signal() +1). If the counter is zero, the thread waits until another thread releases the resource.


### Thread - Safety?（Data race）
- Thread safety means that code can be executed by multiple threads at the same time without causing unexpected behavior or corrupting data.    
- To ensure thread safety, we can use synchronization methods such as locks, serial[sɪriəl] dispatch queues, or semaphores[sɛməˌfɔrˌs] to control access to shared resources. Another way is to design code in a immutable way so that data cannot be modified concurrently. Or use Actor(Swift5.5+) to isolate the variable and wait for (serial) access.

### Deadlock
#### What:
Deadlock is a situation in multithreading where two or more threads are blocked forever, each waiting for the other to release a resource. As a result, none of them can proceed, and the application freezes or crashes.

#### Situation:
- A classic example is multiple locks acquired by threads in different orders, eg: when Thread A holds Lock 1 and waits for Lock 2, while Thread B holds Lock 2 and waits for Lock 1. Neither thread can release its lock because they are both waiting. This is sometimes called a 'deadly embrace'. ****How to Solve:**** We need always acquire locks in the same order in this situation. And it is best to request a new lock only after releasing the current lock.

- Call sync on the same serial queue.（eg: If you're on the main queue and you call DispatchQueue.main.sync — that will deadlock immediately. Because the main queue is serial. You're trying to wait for a task to finish, but that task cannot start until the current one finishes. It's waiting for itself. That's a deadlock）****How to Solve:**** we should never call sync on the same serial queue that we're already on. This is the most common mistake in iOS. If we need to dispatch work on the same queue, use async instead.

- Deadlock can also happen when a single thread tries to lock the same resource recursively — it's waiting for itself.（eg: if a function acquires a lock and then calls itself recursively — or calls another function that tries to acquire the same lock — the thread will wait for itself. That's a deadlock.）****How to Solve:**** We can use a recursive lock. In iOS, that's NSRecursiveLock. A recursive lock allows the same thread to lock the same resource multiple times. It keeps track of how many times the lock was acquired. As long as the number of unlocks matches the number of locks, the lock will eventually be released.

#### Debug a deadlock?
- If the main thread deadlocks, the app usually shows a warning or crashes directly.
- If a child thread deadlocks, we can pause the app, then go to the thread list on the left side of Xcode, find the corresponding thread, check the code execution, and see if the code is stuck.

#### What kinds of locks are there?
- Mutex: Only one thread is allowed to enter the critical section at a time. In iOS, an example is NSLock.
- Recursive Lock: The same thread can acquire the lock multiple times without deadlocking. It keeps a count of how many times it has been locked. As long as the unlock count matches the lock count, the lock is released. It solves deadlock issues in recursive functions. In iOS, examples include NSRecursiveLock. Additionally, iOS has @synchronized, which is a recursive lock based on an Objective-C object.
- Condition Lock: Allows a thread to wait until a specific condition is met before continuing. In iOS, NSConditionLock is a condition lock. It has an Int condition value. When unlocking, we can set a new condition value to wake up threads that are waiting for that condition.
- Read-Write Lock: Allows multiple threads to read at the same time, but only one thread can write.
- Spin Lock: A spin lock makes the thread spin in a loop instead of sleeping. It's only good when the lock is held for a very short time.


### Concurrency

#### "Explain async/await 
async/await provides a way to write asynchronous code in a more readable and maintainable way. It allows we to write asynchronous network requests without using callback closures, which helps avoid callback hell. 

#### 并行

#### 结构化并发

#### Actor
- Main Actor
- Global Actor


# Swift

## Structs VS Classes
- Struct: value type; stack memory; immutable by default, copied on assignment; no inheritance. 
- Class: reference type; heap memory; mutable, shared reference; supports inheritance.

## Optional type

## Generics
Generics enable type safe code reuse across different data types.

## Protocol
A protocol in Swift defines a blueprint of methods, properties, or other requirements that a class, struct, or enum can adopt.  
Protocol extensions allow we to provide default method implementations or add functionality to all types that conform to a protocol. This reduces code duplication and makes protocols more powerful.

## Closure
- Trailing closures: When a closure is the last argument, write it outside the parentheses. If it's the only argument, we can omit `()`. (eg: map, filter, etc)
- Escaping closures: A closure that outlives the function, and executed later (e.g. stored for async callback). Must be marked `@escaping`. (@escaping)
- Auto closures: `@autoclosure` automatically wraps expressions (eg: assert(condition: a > b)), the expression isn't evaluated until the closure is called.

# SwiftUI
## @State

# Combine
### Publisher, Subscriber, Subject
- Publisher: Data source that emits values.
- Subscriber: Receives and processes values from Publisher.
- Subject: Special Publisher that can manually send values.(eg: PassthroughSubject, CurrentValueSubject)

### @Publisher

# Chanllege or critical issue or Crash

# Performance Optimization
## Briefly describe the causes of off - screen rendering and its optimization methods.
Off-screen rendering happens when the system cannot draw a layer directly on the frame buffer and needs to render it into an off-screen buffer first, then composite it back. These operations force the GPU to do extra work, which may cause dropped frames. eg:
  - Configured layer content(if an ImageView has cornerRadius set, or a view(eg: button, label) has masksToBounds called on it).
  - Configured layer shadow via offset property.
  - Configured layer's mask property.
  - Configured layer's rasterize property.
  - The alpha property of the parent view is configured to be not 1.  
  Optimization:
  - We can use pre-processed rounded corner images or draw rounded corner images asynchronously.
  - We can use the shadowPath property instead of offset to set the view's shadow.
  - Although the rasterize attribute will cache the layer for 100 milliseconds, it will also have additional overhead and should not be used unless necessary. Also avoid unnecessary masking and alpha.

## How do you optimize the scrolling performance of UlTableView?
We need to pay attention to the delegate methods that the table view must implement, which are also the most frequently called methods by the table view.  
1. HeightForRow: If the row height is fixed, we can set a fixed height. If the row height is dynamic, we can set an estimated row height, or in more complex cases, we can calculate the row height after the data is requested and put it into the data model.  
2. CellForRow: 
    - Reuse cells to avoid creating new cells repeatedly(Don't forget to set the reuse flag in XIB. We can check the view hierarchy through the debug panel); 
    - Avoid expensive operations in cellForRowAt. 
        eg: 
        - If we need to config a view's layer, be aware of the off-screen rendering issues.
        - Use simple cell layouts, reduce the number of subviews, try not to add views dynamically using addView, can use hide to control whether to display them;
    - Load images asynchronously. eg: if we need to assign a value to ImageView via a URL, do not assign it directly in the main thread, recommended to use a third-party library such as SDWebImage to assign the value.
    - If we need to repeatedly load small local images, recommended to use the imageNamed method. This method automatically caches the loaded images (the default method for XIB). imageWithContentsOfFile and imageWithData do not cache.

# Testing Framework

# Pod
