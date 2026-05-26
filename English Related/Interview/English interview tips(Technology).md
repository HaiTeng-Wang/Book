# Basic

## Memory management(ARC)
1. iOS 内存管理机制  
iOS uses Automatic Reference Counting (ARC) to manage memory. ARC automatically tracks how many strong references point to an object. When the reference count drops to zero, ARC deallocates the object and releases its memory. In a normal situation, We don't need to manually call retain or release for memory management.

2. 内存泄漏的根本原因  
However, memory leaks happen when ARC cannot deallocate an object because the reference count never reaches zero, even though the app no longer needs the object. This is typically caused by the retain cycle (also called a circular reference). And (结果) over time, the app consumes more and more memory, which can lead to the app becomes slow or may crash.

3. 常见的循环引用场景  
Here are the most common causes of retain cycles in iOS development:  
  a.) Delegates:
    Delegate references should be weak references, otherwise there may be a retain cycle between the delegate object and its delegate (for example, both holding strong references to each other). However, if the delegate is a short-lived object (e.g., a method parameter or a temporary helper), a strong reference may be appropriate[əˈproʊpriət] and simpler.
      ```swift
      // Sample: retention cycle
      class ViewController: UIViewController, DataLoaderDelegate {
          let loader = DataLoader() // self -> loader
          init() { loader.delegate = self } // loader -> self
      }
      class DataLoader { var delegate: DataLoaderDelegate? }
      ```   
    b.) Closures:
      As we know, closures are reference types. If a closure is stored as a property and self is called within the closure, a retain cycle happens, that means self holds the closure, and the closure captures self. So, this is a retain cycle, we can fix this by using a capture list, such as [weak self] or [unowned self].  
    c. ) Two objects:   
      Two objects holding strong references to each other. For example, like the Person and Apartment example from Swift's official documentation, the Person class has an Apartment property, and the Apartment class has a Person property. When they hold references to each other, a strong reference cycle happens. In this case, we can use weak to break the cycle.  
    d.) Timer:  
      A Timer or CADisplayLink that holds a strong reference to its target (like self). If not invalidated properly, they keep self alive forever. So we need to call the invalidate function in the right place, like viewWillDisappear or deinit.
      Additionally, note that if we create a timer using a closure and the timer is stored as a property of the current class, we must capture self weakly within the closure body; otherwise, a retain cycle will still happen.  
    e.) Observer:  
      On iOS 11 and later, the new KVO observe API is automatically cleaned up. However, for NotificationCenter's block API, if we don't remove the token, it will not crash, but the block will stay alive and continue to execute, that leading to memory leaks. So we need to be careful about this — we still need to manually remove Observer when using the block API.  
    f.) CoreFundation Object:  
      For CoreFoundation objects like CFRunLoopObserver or CFNotificationCenter, there's no automatic cleanup, ARC doesn't cover them. We must manually remove them and call CFRelease. Otherwise, that will get leaks or crashes.

4. 如何检测内存泄漏  
a.) Instruments (Leaks tool)  
   We can use the Leaks tool to detect memory leaks while running an application. When a leak happens, it can display a red 'X'.
b.) Static analyzer  
   We can also try Xcode's static analyzer, which will also provide some code warnings, such as uncalled superclass methods and unused variables, and so on.  
c.) Xcode Memory Graph Debugger    
   This tool is very useful. It can visually displays object references and retain cycles. It can shows whether multiple instances of the same object appear in the memory graph. I have tested and confirmed it works effectively for identifying memory leaks.  
d.) Deinit Method Check  
   We can also add a breakpoint or log inside the deinit method to verify whether an object is properly released.


5. 其它注意  
Other notes: Besides memory leaks, there are other situations that increase memory usage.
  - `imageWithName`: loads images into RAM. For large images or images that are not frequently used, we can use `imageWithContentsOfFile` API instead.
  - Avoid creating too many singletons[ˈsɪŋˈɡlˈt(ə)n] or static instances. They live forever with the app. Also, they make testing harder.

### Week VS Unowend
- Weak and unowned both break retain cycles without increasing reference counts.   
- The main difference is that weak is optional — it becomes nil when the object is deallocated, so it's safe. Unowned is non-optional — it assumes the object always exists[ɪɡˈzaɪˈst], so if we access it after deallocation, the app will crashes.  
- Use weak for delegates and most cases. Use unowned only when we are absolutely[ˈæbsəˌlutli] sure the object lives as long as the reference, like two objects have the same lifetime.（A good example is a closure that is a property of self and captures self. The closure and self have the same lifetime — when self is deallocated, the closure is gone too. So [unowned self] is safe and more convenient, because we don't need to write self? every time. But we must be certain the closure will not outlive self）



## Multithreading And Data Race

### GCD VS OperationQueue
- GCD is a low-level C API. It provides queue[kju] groups to execute[x,cute] asynchronous code in block. With GCD we can easily use shared local variables and easily perform thread communication through[θru] blocks. We can use GCD for simple background tasks, like network callbacks or file saving. GCD also has rich functions (eg: semaphores[ˈsàiˌ么ˌfɔr]、barriers for thread-safe, dispatch_once for singleton creation, etc).
- OperationQueue is built based on GCD, it provides more control for complex operations(eg: it supports dependencies between operations, operation monitoring, it can cancel/pause[pào zi] operations, also can reusable operations, and set the maximum[ˈmæksəməm] number of concurrent, etc). when we need more control for background tasks. we can use OperationQueue.
#### Choose OperationQueue over GCD? (real example)
For example:
- Downloading multiple images from a server where image B depends on image A.   
- Or when a user can scroll through a list and I need to cancel loading images. OperationQueue makes it easy to cancel those operations. With GCD, cancelling a running task is difficult — almost impossible.
#### Semaphore[sàiˌ么ˌfɔr] and Dispatch Group
- Dispatch Group: It is often used when we need to run tasks in parallel and then perform some work after all tasks have completed. We can add tasks to a group, and when they are all completed, the completion handler callback will be executed, so we can do something in the callback.
- Semaphore[sàiˌ么ˌfɔr] : It is used to control access to a limited resource across multiple threads. It maintains a counter, and each time a thread tries to access the resource, the counter is decreased(semaphore.wait() -1), after the visit, the counter increases(semaphore.signal() +1). If the counter is zero, the thread must wait until another thread releases the resource.

### Thread - Safety?（Data race）
- Thread safety means that code can be executed by multiple threads at the same time without causing unexpected behavior or corrupting data.    
- To ensure thread safety, we can use synchronization methods such as locks, serial[sɪriəl] dispatch queues, or semaphores[sàiˌ么ˌfɔr] to control access for shared resources. Another way is to design code in a immutable way so that data cannot be modified concurrently. Or use Actor(Swift5.5+) to isolate[ˈaɪsəˌleɪt] the variable and wait for (serial) access.

### Deadlock[dàiˌdeˌlak]
#### What:
Deadlock[dàiˌdeˌlak] is a situation in multithreading where two or more threads are blocked forever, each waiting for the other to release a resource. As a result, none of them can proceed, and the application freezes or crashes.
#### Situation:
- A classic example is multiple locks acquired[额ˈkwaɪ(ə)r] by threads in different orders, eg: when Thread A holds Lock 1 and waits for Lock 2, while Thread B holds Lock 2 and waits for Lock 1. Neither thread can release its lock because they are both waiting. This is sometimes called a 'deadly embrace'. ****How to Solve:**** We need always acquire locks in the same order in this situation. And it is best to request a new lock only after releasing the current lock.

- Call sync func on the same serial queue.（eg: If you're on the main queue and you call DispatchQueue.main.sync func — that will deadlock[dàiˌdeˌlak] immediately. Because the main queue is serial. You're trying to wait for a task to finish, but that task cannot start until the current one finishes. It's waiting for itself. That's a deadlock[dàiˌdeˌlak]）****How to Solve:**** we should never call sync on the same serial queue that we're already on. This is the most common mistake in iOS. If we need to dispatch work on the same queue, use async instead.

- Deadlock[dàiˌdeˌlak] can also happen when a single thread tries to lock the same resource recursively — it's waiting for itself.（eg: if a function acquires a lock and then calls itself recursively — or calls another function that tries to acquire the same lock — the thread will wait for itself. That's a deadlock[dàiˌdeˌlak].）****How to Solve:**** We can use a recursive lock. In iOS, that's NSRecursiveLock. A recursive lock allows the same thread to lock the same resource multiple times. It keeps track of how many times the lock was acquired. As long as the number of unlocks matches the number of locks, the lock will eventually be released.
#### Debug a deadlock[dàiˌdeˌlak]?
- If the main thread deadlocks[dàiˌdeˌlak], the app usually shows a warning or crashes directly.
- If a child thread deadlocks[dàiˌdeˌlak], we can pause[pào,zi] the app, then go to the thread list on the left side of Xcode, find the corresponding thread, check the code execution, and see if the code is stuck.

### What kinds of locks are there?
- Mutex: Only one thread is allowed to enter the critical section at a time. In iOS, an example is NSLock.
- Recursive Lock: The same thread can acquire the lock multiple times without deadlocking[dàiˌdeˌlak]. It keeps a count of how many times it has been locked. As long as the unlock count matches the lock count, the lock is released. It solves deadlock[dàiˌdeˌlak] issues in recursive functions. In iOS, examples include NSRecursiveLock. Additionally, iOS has @synchronized, which is a recursive lock based on an Objective-C object.
- Condition Lock: Allows a thread to wait until a specific condition is met before continuing. In iOS, NSConditionLock is a condition lock. It has an Int condition value. When unlocking, we can set a new condition value to wake up threads that are waiting for that condition.
- Read-Write Lock: Allows multiple threads to read at the same time, but only one thread can write.
- Spin Lock: A spin lock makes the thread spin in a loop instead of sleeping. It's only good when the lock is held for a very short time.



## Concurrency
Swift Concurrency is a modern asynchronous programming framework. We can use this framework if the project's minimum target is iOS 15 or later. Actually, it is based on multithreading. It provides a safer and more readable way to write concurrent code compared to `GCD` or `OperationQueue`.

We can use `async/await` to write async code that looks synchronous, and create a `Task` to run async code from the sync context, like from a view controller. Tasks can be cancelled, we can check for cancellation inside the async work, and we can also set the priority for the Task. SwiftUI also provides the `Task` View Modifier to manage async work. Swift Concurrency uses `Actor` to protect shared data to avoid data race, Sendable for compile-time safety of shared data, And we can also use the `@MainActor` to execute code on the main thread.

It also provides `TaskGroup` and `async let` to support ****structured concurrency****. Through parent-child relationships, tasks can perform cooperative[koʊˈɑp(ə)rəˈdɪv] cancellation, child tasks inherit the parent task's priority by default, and child tasks can capture local variables from the parent scope.

In summary, Swift Concurrency can make async code safer, simpler, and more readable, effectively avoiding callback hell.

### `asyn/await`
`async` is used to mark async methods;  
`await` is used to call async methods, it indicating there is a potential pause[pào,zi] point (the task may be suspended).  
##### Deadlock[dàiˌdeˌlak] Warning ⚠️ ：
When the async method resumes execution, it may switch to a different thread. So, we should avoid use semaphores, and other sync methods in async methods, as this can easily lead to deadlocks[dàiˌdeˌlak]. That recommended to use `Actor` or async queues instead.

### Task
`Task` is actually a generic struct `Task<Success, Failure>` that contains two placeholder types, which are success and failure[fèi,ōu,liè,er]. And it is initialized[init,lized] with a trailing closure, within the closure we perform async work that eventually returns a specific success or failure value. Additionally, Task also provides configurations such as cancellability, suspendability, and priority. We can imagine it as an async executor that can create and manage async work within a sync context.
##### `.task`(SwiftUI)
`.task` is a SwiftUI view modifier used to start an async task when the view appears and automatically cancel the task when the view disappears. It supports setting the task priority and also supports an id parameter, which restarts the task when the id value changes.

### TaskGroup
Swift Concurrency provides `withTaskGroup` API to perform structured concurrent work. `withTaskGroup` API is actually a global function that provides a `TaskGroup` instance through a trailing closure, allowing us to dynamically add and manage child tasks within the closure. For example, it can be used to concurrently download images through an array of URLs. In addition, Swift Concurrency also provides the `withThrowingTaskGroup` variant function API, which is used in scenarios where child tasks may throw errors, And if any child task fails, the TaskGroup will automatically cancel the other tasks and throw the error upward.
##### TaskGroup Notes ⚠️: 
1. **All child tasks must return the same type** (enforced by the API)
   - Workaround: Use an enum to wrap different types, or use `Any` as the return type.
      ```swift
      enum Result { case int(Int), str(String) }
      withTaskGroup(of: Result.self) { ... }
      ```
2. **Both `TaskGroup` and `async let` will execute child tasks by default as soon as child tasks are added/defined.**
   - **`TaskGroup`**: Even if we don't write `await` keyword to wait for child task results, the child tasks will still execute by default once child tasks added. And the `await` on the `withTaskGroup` call will suspend the thread and implicitly wait for all child tasks to complete.
   - **`async let`**: Even if we don't write `await` keyword to wait for the result, the async function will execute by default as soon as it is defined. And the current thread does not suspend, and the task is automatically canceled when leaving the scope.

### Actor
An actor is a reference type. It is similar to a class, except that it does not support inheritance.   
The main difference is that actors ensure data safety through data isolation[aɪˈseˈleɪʃən]. This is achieved by maintaining an internal serial queue.  
By default, to access an actor's method or mutable property from outside, we must use `await`.
Actors also have nonisolated functions for operations that do not access mutable state, that can be called without await. For example, we can directly access an actor's constants from outside without `await`, or call a method marked as nonisolated. Of course, within a nonisolated method, we cannot access the isolated state. Inside the actor, all methods and properties, whether `isolated` or not, that can be accessed directly. But if we need to access across borders, for example, such as access another actor's mutable state from current actor's methods, await is still required.
#### Global Actors
In Swift concurrency, A regular actor can only protect its own instance state. If multiple contexts need to access the same globally shared data, a Global Actor is required.
A Global Actor is a singleton actor. All the code and data isolated[ˈaɪsəˌleɪt] by it are executed serially through this single instance.
We can create a custom Global Actor with the @globalActor modifier. That type will conform to the GlobalActor protocol automatically to provide a shared static property as a shared instance. It is commonly used to protect global variables, static properties, and other data shared across contexts. We can mark a whole class or individual functions and properties with the global actor.
- `@MainActor`
   `@MainActor` is an important built-in global actor. It ensures that code runs on the main thread. In addition to `@MainActor`, we can also execute code on the main thread using the `MainActor.run` function.
#### Tips:
When using an Actor, be careful. It's best not to manually start child threads within an Actor, as that will break the Actor's data safety guarantees and may cause data races. Also, pay attention to reentrancy[re,an,tren,cy].   
##### Reentrancy[re,an,tren,cy]:
An actor ensures that only one task can modify its state at a time, but it does not ensure that asynchronous methods execute atomically. Reentrancy means that when an actor's asynchronous method is paused due to await, the thread is temporarily yielded, that will allow other tasks to enter the same method and interleave execution.  
Example:   
A bank account has 100RMB and a withdrawal method. The withdrawal method first checks the balance, then asynchronously authorizes, and finally withdraws the money. Two tasks each try to withdraw 60RMB: Task A passes the balance check and then suspends (waiting for authorization), So at this time it will yield the current thread. In the meantime, Task B also enters and passes the balance check. Eventually, both authorizations succeed, so the balance has gone to minus[ˈmaɪ,nəs] 20RMB. How to Fix: Check the balance again before actually withdrawing the money. 

### Sendable
Sendable is a safety marker protocol in Swift concurrency used to identify types that can be safely passed across concurrency boundaries (such as between different Tasks or Actor method calls).    
It is a semantic protocol, that does not require any properties or methods. It can help developers detect potential thread-safety issues (such as data races or unexpected behavior) at compile time.
##### Quick Reference Table For Sendable Protocol
| Type Category | Is Sendable? | Conditions / Notes |
|---------------|--------------|---------------------|
| **Basic Value Types** | ✅ Always | • e.g: <br> `Int`, `String`, `Bool`, <br> `Array`, `Dictionary`, `Set` (if elements are Sendable, like `[Int]`, `[String: User]`) <br> • Conform implicitly. <br> • Because these are value types(Struct) and marked as `@frozen`. |
| **Actor** | ✅ Always | All actor types automatically conform (because actors isolate[ˈaɪsəˌleɪt] mutable state). |
| **Struct** | ✅ Conditional | All stored properties must be `Sendable`.<br>• `internal` and below: implicitly conforms<br>• `public`: requires explicit `: Sendable` declaration |
| **Enum** | ✅ Conditional | • No associated values: always `Sendable`<br>• With associated values: all associated value types must be `Sendable`<br>• Implicit/explicit rules follow the same pattern as structs |
| **Class** | ✅ Conditional | • Marked `final`<br>• All stored properties are `let` and `Sendable` type<br>• Superclass can only be `NSObject` or none<br><br>Classes marked `@MainActor`: automatically implicitly `Sendable` (allows `var`) |
| **Function / Closure** | ✅ Requires Marking | Mark with `@Sendable` keyword (e.g., Task's operation parameter is `@Sendable`).<br>• All captured values must be `Sendable`<br>• Cannot capture mutable state |
| **Tuple** | ✅ Conditional | All element types must be `Sendable`<br>Conforms implicitly when conditions are met |
| **Optional** | ✅ Conditional | when `Wrapped: Sendable`, `Optional<Wrapped>` is `Sendable` |
| **Opaque[oʊˈpeɪk] Type** | ✅ Conditional | `some Protocol` is usable when the underlying type is `Sendable` |
##### Key Keywords
- ****`@Sendable`****: Marks a function or closure as concurrency-safe. That requires all values captured by the closure are `Sendable` and that it cannot capture mutable state. (e.g., Task's `operation` parameter is `@Sendable`)
- ****`@unchecked Sendable`****: Used to skip compiler checks. The developer make sure the type is concurrency-safe (e.g., a class that uses its own locks or queues to ensure thread safety).
- ****`@preconcurrency import`****: Used to reduce the concurrency checking level of old modules, such as handling third-party libraries that are not Sendable during migration. (Swift 5.7)
- ****`nonisolated(unsafe)`****: Skips concurrency safety checks at a fine-grained level, such as manually ensuring the safety of certain stored properties. (Swift 5.7)

### Continuation
Swift Concurrency provides the function `withCheckedContinuation` API, which can bridge traditional closure callbacks to modern asynchronous functions. For example, if there is a legacy network library where data request results are returned in closures, we can wrap it into an async function using the Continuation function. Actualy, the Continuation function passes a Continuation instance through a trailing closure, and then we use this instance to call the resume method to deliver the result (success value or error).

(Function differences:) Swift provides four global Continuation functions: `withCheckedContinuation` API, `withCheckedThrowingContinuation` API, and their corresponding `Unsafe` versions. Since a function can only return once, So when using Continuation, we must ensure that `resume` function can only be called once and that the result is passed only once. Based on this rule, the difference between Checked and Unsafe lies in runtime checks. The Checked function will verify whether we have correctly called resume function and will provide clear crash information and hints if there is an error, while the Unsafe version performs no checks. About the Throwing function, that can pass or throw an error through `resume(throwing:)` API.

### Concurrency Thread Flow Analysis
Q: Does an `async` function or `Task` always create a background thread?  
A: Whether the `async` function or `Task` starts a new thread depends on the current context and the specific behavior of the task and concurrency configuration.
##### Task
1. By default, a `Task` does not automatically create a new thread. After a `Task` is created, it depends on the execution context (i.e., actor or thread), that use the cooperative thread pool.
   - (1) If created on the main thread, the `Task` runs on the main thread. For example, creat a `Task` inside a view controller's `viewDidLoad` method. 
   - (2) If created on a background thread, the `Task` runs on a background thread. For example, creat a `Task` inside a `DispatchQueue.global().async` closure, or inside an actor. (Whether to open a new thread is decided by the system. Sometimes it executes directly in the current child thread, and sometimes it executes in another child thread.)
   - (3) Special：If you create a `Task` on an async function, it always runs on a background thread.

2. `Task(priority: .background)` Same with `Task`，it also depends on the current context.(Whether to open a new thread is decided by the system.)
3. `Task.detached` It always runs on a background thread.(Whether to open a new thread is decided by the system.)
4. `withTaskGroup`: Whether the `body` closure is executed on the main thread or a child thread depends on the context of the current function call. But the operation closure of TaskGroup's `addTask` is always executed on a background thread. (Whether to open a new thread is decided by the system)
5. SwiftUI's `.task` view modifier inherits the current View's `@MainActor` context, so by default it executes tasks on the main thread.
##### async Functions
Whether an async function runs on a background thread depends on its ****isolation state**** and the ****Concurrency configuration****.
1. If an async function is `@MainActor`-isolated, it runs on the main thread.  
For example:
    - (1) Async methods in `ViewController` or `SwiftUI's View`, because `VC` and `SwiftUI's View` are `@MainActor` isolated by default, so their internal members are also `@MainActor` isolated, running on the main thread.
    - (2) Manually marked custom types or specific functions as `@MainActor`.running on the main thread.
    - (3) Concurrency configuration - ****Default Actor Isolation****: We can configure concurrency in ****Xcode Build Settings**** or ****Swift Package****. If *****Default Actor Isolation***** is set to `MainActor`, then custom types (such as custom classes or structs) or global functions, ect. They are implicitly to be `@MainActor`-isolated types. Running on the main thread. (Verification: Pressing the option key and clicking on a type's property or function — we'll see it automatically implicitly marked as `@MainActor`).
  2. Concurrency configuration - ****Approachable Concurrency****:   
  *****Approachable Concurrency***** will control *****nonisolated (nonsending) By default***** and other compilation options.  
  The *****nonisolated(nonsending)***** compilation option can control whether an async method inherits the thread context of its caller (similar to marking an async function with `nonsolated` keyword). 
      - If *****Default Actor Isolation***** is `nonisolated` and *****nonisolated (nonsending)***** is `NO`, then async functions of custom types, global functions, etc. will run on the same thread as in Swift 5 — they will always run on a ****background thread****.
      - If *****Default Actor Isolation***** is `nonisolated`, but *****Approachable Concurrency*****is `YES`, then async functions of custom types, global functions, etc. will run on the thread that depends on the ****current context****.
      - If *****Default Actor Isolation***** is `MainActor`, regardless of whether *****Approachable Concurrency***** is `YES` or `NO`, the type is protected by `@MainActor`, that running on ****main thread****. (If an async function needs to inherit the caller's context, you can manually mark the async function with `nonisolated`.)
##### Actor
- For `actor` or a custom `@globalActor`, Calls to its isolated methods from outside will run on a background thread.
##### Keyword
- `@MainActor`: Types or functions marked with `@MainActor` run on the main thread.
- `nonisolated`: Means removes the current Actor isolation, that method inherits the caller's thread.
- **`@concurrent`**: Methods marked with `@concurrent` execute on a background thread（Available starting from Swift 6.2）.



---
# Swift
## Swift VC OC
Swift is a modern, safe, and fast language introduced in 2014. Objective-C is an older language.  
Swift has cleaner syntax — for example, we only write code in one .swift file, but Objective-C requires both .h and .m files. So Swift requires less code than Objective-C.  
Swift is also safer — for example, optionals help handle null values better, and stored properties must have a value during initialization.
Swift also has better performance than Objective-C. For example, many types in Swift are designed as value types (like structs and enums). Value types avoid memory leaks because they are copied instead of shared. This also helps optimize memory usage and makes Swift faster.

## Structs VS Classes
- Struct: value type; stack memory; immutable by default, copied on assignment; no inheritance. 
- Class: reference type; heap memory; mutable, shared reference; supports inheritance.
### Value Type vs Reference Type
Value types like structs, enums, and tuples are copied when assigned. Reference types like classes are shared.
With value types, changing one variable doesn't affect others. With reference types, all references use the same data.
For example, if I pass a struct to a function and modify it, the original value doesn't change. But if I pass a class, the original object changes.

## Closure
- Trailing closures: When a closure is the last argument, write it outside the parentheses. If it's the only argument, we can omit `()`. (eg: map, filter, etc)
- Escaping closures: A closure that outlives the function, and executed later (e.g. stored for async callback). Must be marked `@escaping`. (@escaping)
- Auto closures: `@autoclosure` automatically wraps expressions (eg: assert(condition: a > b)), the expression isn't evaluated until the closure is called.

## Optional?
An Optional means a value can be nil or have a value. It's written as Type?. It avoids directly accessing null objects, making the program safer.  
In order to obtain the actual value, we need to unwrap an optional type, we can use: `if let`, `guard let`, or force unwrap (`!`), Only when we're 100% sure that value is not nil, Otherwise the app will be Crash.

## Protocol
A protocol defines a blueprint of methods and properties. Any type can conform to a protocol.(like: Class、Struct、Enum, etc). For example, we can declare a protocol for the ability to dance. If both dogs and humans follow this protocol, it means that both dogs and humans can dance.

## Extension：
An extension adds new functionality to an existing type, even system types like `Int` or `String`. For example, we can extend `Collection` to add a custom `isEmpty` API to check for all collection types.  
We can also implementation the Protocol extensions, that allow us to provide default implementations for protocol methods.



---
# SwiftUI

## What is SwiftUI?
SwiftUI is Apple's modern framework for building user interfaces across all Apple platforms. It uses a declarative syntax, meaning I describe something, then UI should look like something, and based on the state to change UI, that automatically updates the UI when the state changes. SwiftUI keeps the code simple and clear.

## Difference between `SwiftUI` and `UIKit`?
- SwiftUI = declarative (what you want) → less code, newer
- UIKit = imperative (how to do it) → more code, older, more control

## Property wrappers
A Property Wrapper is a feature in Swift that let us add extra behavior to a property (like validation, caching, or UI updates) without writing repetitive code. We can reuse the setting and getting logic. (like @State, @Binding, @Published, @AppStorage etc.)
### What are `@State`, `@Binding`, `@ObservedObject`, `@StateObject`, `@EnvironmentObject`, `@Environment`?
- `@StateObject`: Used to observe an `ObservableObject`. The marked instance is stored outside the `Struct` and is only `initialized` when the view ****first appears****, So when the view refreshes, the instance remains unchanged. It is suitable for data models that the view needs to hold for a long time.
- `@ObservedObject`: Used to observe an `ObservableObject`. If the instance is created within the view, it will be ****reinitialized**** when the view refreshes, so the marked instance usually depends on an external owner and is passed in from an external view. Suitable for observing data models passed in from a parent view.
- `@State`: Used inside a view to manage simple local state like `Int`, `String`, `Bool`. Same as `@StateObject`, the value is stored outside the `Struct`, so the state will not be lost when the view rebuilds.
- `@Binding`: Used for two-way communication between a parent view and a child view. It wraps a `get` closure and a `set` closure. Use `$` to pass the binding. When the child view changes the value, the parent view's state updates automatically.
- `@EnvironmentObject`： Used to share a data model across all views. Any view can read it. And don't need to pass it manually from view to view.
- `@Environment`: Used to access system or framework predefined environment values (e.g., current system language, colorScheme, etc.).

## What is `some` View?
`some` View is an opaque[oʊˈpeɪk] return type. It means the function returns some type that conforms to the View protocol, but I don't need to specify the exact type. SwiftUI uses this to hide complex generic types like `TupleView` or `ModifiedContent`
- `TupleView`: is a generic structure that conforms to the `View` protocol, which can ****unify**** return types and combine multiple different views into a single type.
- `ModifiedContent`: is a generic structure that represents a new view obtained after applying a modifier to an original view.

## What is a `ViewBuilder`?
It is a result builder that allows us to write multiple views inside closures like `VStack`, `List`, Or `if / for`.   
It automatically collects up to 10 views into a TupleView.  
we don't need to return a single view or wrap them manually. It keeps declarative syntax simple and clear.

## How does SwiftUI handle layout?
SwiftUI layout has three steps:  
 - (1) Parent offers a size to the child.
 - (2) hild chooses its own size based on that offer.
 - (3) Parent places the child at a position.  
 - Common layout components: `HStack, VStack, ZStack, Spacer, frame, padding`,etc.
    ```swift
    VStack { // (3). VStack puts the Text in the center by defaule
        Text("Hello")
        .frame(width: 50, height: 20) // (2). Text looks at its own .frame and says: "OK, I choose 50 width and 20 height."
        .background(Color.red)
    }
    .frame(width: 100, height: 100) // (1). VStack says to Text: "You can have up to 100 width and 100 height."
    .background(Color.yellow)
    ```

## 生命周期
SwiftUI views are structs, not classes. So no `viewDidLoad` or `viewWillAppear`. Instead, use these modifiers:
- `.onAppear`	When the view appears on screen
- `.onDisappear`	When the view leaves the screen
- `.task`	When view appears, for async work
- `.onChange(of:)`	When a value changes  

Scene Lifecycle (App-level)   
Use `@Environment(\.scenePhase)` to know our app's state:
- `.active`	App is running in foreground
- `.inactive`	App is switching state
- `.background`	App is in background



---
# Combine
### What is Combine?
Combine is Apple’s framework for handling asynchronous events. It uses Publisher(eg: Timer.publish sends time every second) to send values over time, and Subscriber(eg: `sink`) to receive them. We can use operators like `map` or `filter` to change the data.
#### Why do you use Combine?(Your Experience)
I use Combine to react to data changes, like text field input、network responses、Timer, etc. It helps avoid nested callbacks(like block) and makes code more readable. Also, it works well with SwiftUI.
##### SwiftUI
SwiftUI uses Combine to observe data changes and update the UI automatically. In SwiftUI, we create a class conforming to `ObservableObject`, and mark properties with `@Published.` SwiftUI automatically uses Combine to observe changes. When the property changes, the view re-renders.

### Subject
Subject: Special Publisher that can manually send values(eg: PassthroughSubject and CurrentValueSubject).
##### PassthroughSubject vs CurrentValueSubject
PassthroughSubject has no initial value and only sends new values to subscribers.
CurrentValueSubject has an initial value and also sends the current value to new subscribers immediately.

### What is `sink` and `assign`?
`sink` and `assign` are two ways to receive values from a publisher.
#### `sink`：
`sink` takes a closure that receives each value. I use it when I need to perform some logic, like updating a variable or calling a function.
#### `assign`
`assign` directly writes the value to a property on an object. It's shorter and cleaner for simple cases, like binding to a label's text or a boolean.

### What is `AnyPublisher`? (`eraseToAnyPublisher`)
`AnyPublisher` is a type-erased wrapper for a publisher. It hides the details of the underlying publisher, like its specific type (such as `CurrentValueSubject`). It's useful when we want to return a publisher from a function without exposing the implementation details.  
For example, instead of returning `CurrentValueSubject<String, Never>`, we can use the `eraseToAnyPublisher` API to turn `CurrentValueSubject<String, Never>` into `AnyPublisher<String, Never>`. The caller only knows they can subscribe, and can only perform operations like `sink`, `map`, etc. They don't have to care, and don't need to know, exactly what's inside.

### What is `Cancellable`? How to avoid memory leaks?
`Cancellable` is a protocol that allows me to cancel a subscription and stop receiving values. Every call to `sink` or `assign` returns a `Cancellable` object.  
To avoid ****memory leaks****, we can store all `Cancellable` objects in a `Set<AnyCancellable>`. When the object holding the set is deallocated, all subscriptions are automatically cancelled.
Also, inside the sink closure, we need use `[weak self]` to avoid retain cycles when capturing self.

### What are common operators?
- `map`: transform each value
- `filter`: only pass values that meet a condition
- `debounce`: wait for a pause before sending
- `removeDuplicates`: skip equal consecutive[kənˈsaikjʊ,tɪv] values
- `combineLatest`: It is used for combining multiple publishers, and returns the ****latest combined value**** whenever any one of the publishers changes
  ```swift
    let publisher1 = PassthroughSubject<Int, Never>()
    let publisher2 = PassthroughSubject<String, Never>()

    publisher1
        .combineLatest(publisher2)
        .sink { print("CombineLatest: ($0), ($1)") }

    publisher1.send(1)
    publisher2.send("A")  // 输出: CombineLatest: 1, A
    publisher1.send(2)    // 输出: CombineLatest: 2, A
    publisher2.send("B")  // 输出: CombineLatest: 2, B
  ```
- `merge`: It is suitable for ****merging**** multiple data streams of the ****same**** type and sending their values to subscribers ****in order****.
    ```swift
    let publisherA = PassthroughSubject<Int, Never>()
    let publisherB = PassthroughSubject<Int, Never>()

    publisherA
        .merge(with: publisherB)
        .sink { print("Merged: ($0)") }

    publisherA.send(1)  // 输出: Merged: 1
    publisherB.send(2)  // 输出: Merged: 2
    publisherA.send(3)  // 输出: Merged: 3
    ```
- `zip`: The `zip` method pairs elements from multiple data streams two by two and only emits data when ****all streams have new values****.
    ```swift
    let zipPublisher1 = PassthroughSubject&lt;String,Never&gt;()
    let zipPublisher2 = PassthroughSubject&lt;String,Never&gt;()

    let zipped = zipPublisher1.zip(zipPublisher2)

    let cancellable3 = zipped.sink{value in
      print("配对数据：",value)
    }

    zipPublisher1.send("A")
    zipPublisher2.send("1")
    // 输出：配对数据：("A","1")

    zipPublisher1.send("B")
    zipPublisher2.send("2")
    // 输出 配对数据：("B","2")
    ```


---
# Performance Optimization
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

## Briefly describe the causes of off - screen rendering and its optimization methods.
Off-screen rendering happens when the system cannot draw a layer directly on the frame buffer and needs to render it into an off-screen buffer first, then composite[kəmˈpɑzət] it back. These operations force[fɔːs] the GPU to do extra work, which may cause dropped frames. eg:
  - Configured layer content(if an ImageView has cornerRadius set, or a view(eg: button, label) has masksToBounds called on it).
  - Configured layer shadow via offset property.
  - Configured layer's mask property.
  - Configured layer's rasterize property.
  - The alpha property of the parent view is configured to be not 1.  
  Optimization:
  - We can use pre-processed rounded corner images or draw rounded corner images asynchronously.
  - We can use the shadowPath property instead of offset to set the view's shadow.
  - Although the rasterize attribute will cache the layer for 100 milliseconds, it will also have additional overhead and should not be used unless necessary. Also avoid unnecessary masking and alpha.
