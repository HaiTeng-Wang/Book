
# 渣打笔试：Questions 

## 渣打笔试：Questions (Score: 100)
### Swift (Score: 6)
****1.In iOS, which of the following classes is typically used to handle the layout andinteraction of the user interface? (UIView).****   

****2.Among the lifecycle methods of UlViewController, which method is used toperform some initialization operations after the view is loaded? (ViewDidLoad()).****  

****3.In iOS, which of the following layout methods realizes view layout based onconstraints? (AutoLayout).****  

****4.Regarding UlTableView, which of the following statements is incorrect? (The height of UITableView cells must be fixed).****

### Memory Management (Score: 4)
****5. How do you detect memory leaks? What tools in Xcode can assist in the analysis?****  
We need to ensure that all reference types are released and that the deinit method of custom classes is called. Also, be careful of circular reference cycles.  

Detection Methods:  
1. Breakpoint: Make sure the deinit method is called (eg: After the page view controller is popped from the stack).
2. Debug Memory Graph: we can check the object relationships and find retain cycles(If the object is deallocated, it should not appear here).
3. Static Analysis(Cmd + Shift + B): Detect potential issues in code(But it will also detect other potential code problems, eg: variables are declared but not used, parent class methods are not called, etc. And it is useful for C language objects).
4. Xcode Debug Navigator: Monitor memory usage.
5. Instruments - Leaks & Allocations: Leaks can help check for object leaks; Allocations can help check the analyze memory behavior.

### Multithreading And Concurrency (Score: 24)
****6. Briefly describe the differences between GCD and OperationQueue and their usage scenarios. (3/3).****    
Key Difference:
- GCD is lighter for simple tasks, provides queue groups to execute asynchronous code in block, share local variables, and simplify thread communication. It also has rich functions (eg: semaphores, barriers, DispatchOnece, etc).
- OperationQueue is built on GCD, and provides more control for complex operations(eg: supports dependencies between operations, operation monitoring, can cancel/pause operations, reusable operations, and set the maximum number of concurrent, etc).

****7. What is thread - safety? How can you ensure thread - safety? (2/3)****  
- Thread safety means that code can be executed by multiple threads at the same time without causing unexpected behavior or corrupting data.    
- To ensure thread safety, we can use synchronization methods such as locks, serial dispatch queues, or semaphores to control access to shared resources. Another way is to design code in a immutable way so that data cannot be modified concurrently. Or use Actor(Swift5.5+) to isolate the variable and wait for (serial) access.

****8. Explain the functions of Semaphore and Dispatch Group. (2/3)****
- Dispatch Group: It is often used when we need to run tasks in parallel and then perform some work after all tasks have completed. We can add tasks to a group, and when all of them finish, the group notifies we with a completion handler.
- Semaphore: It is used to control access to a limited resource across multiple threads. It maintains a counter, and each time a thread tries to access the resource, the counter is decreased(semaphore.wait() -1), after the visit, the counter increases(semaphore.signal() +1). If the counter is zero, the thread waits until another thread releases the resource.

****9. How do you switch between the main thread and a child thread? (3/3)****  
Always keep UI on main thread(eg: UI updates, user interactions, UIKit operations), and long time tasks in child threads(eg: Network requests, heavy computations, file I/O, etc), this ensures that long-running tasks don’t block the UI.  
Sample:  
```swift
DispatchQueue.global().async {
    // Work on a background thread
    let data = heavyComputation()
    
    DispatchQueue.main.async {
        // Update UI on the main thread
        self.label.text = "\(data)"
    }
}
```

****10. How do you optimize the scrolling performance of UlTableView? (3/3)****  
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

****11.Briefly describe the causes of off - screen rendering and its optimization methods. (2/3).****  
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

****12. How do you detect lag? What tools in Xcode can be used to analyze performance bottlenecks?****  
Lag in an iOS app is usually detected when the UI does not respond smoothly, such as dropped frames or delayed touch events.
We can use the CADisplayLink custom FPS monitoring control to monitor the page FPS status, and use the Xcode tool:
  - Instruments - Time Profiler: check the specific time-consuming function.
  - Simulator - Debug - Color Off-Screen Renderd: Detecting off-screen rendering.
  - Debug Navigator: Monitor CPU/Memory usage in real-time.
By combining these tools, we can identify whether lag is caused by CPU overload, GPU rendering issues, or memory problems.

****13. How do you avoid memory peaks during image loading?****  
- Use cache wisely. Release unused images promptly. Also, note that the imageNamed method caches images in memory.
- Asynchronous loading avoids blocking the main thread, and large size images can be scaled or cropped(eg: config the contentMode property) as needed.


### Swift Language Features (Score: 16)
****14. What are the differences between Swift structs and classes? (4/4)****  
- Struct: value type; stack memory; immutable by default, copied on assignment; no inheritance. 
- Class: reference type; heap memory; mutable, shared reference; supports inheritance.

****15. What is a protocol? How do you implement protocol extensions? (2/4)****  
A protocol in Swift defines a blueprint of methods, properties, or other requirements that a class, struct, or enum can adopt.
Protocol extensions allow we to provide default method implementations or add functionality to all types that conform to a protocol. This reduces code duplication and makes protocols more powerful.
Sample:  
```swift
protocol MyProtocol {
    func doSomething()
}

extension MyProtocol {
    func doSomething() {
        print("Default implementation")
    }
}
```

****16. What are the three forms of closures? What is the difference between escaping and non - escaping closures? (3/4)****  
Three closure forms:
- Trailing closures - Closure as last parameter: someFunc { } (eg: map, filter, etc)
- Escaping closures - Can be stored and executed later (@escaping)
- Auto closures - @autoclosure automatically wraps expressions (eg: assert(condition: a > b))
Escaping vs Non-escaping:
- Non-escaping: Executes within function scope (default)
- Escaping: Can be stored and executed later (@escaping)

****17. What is the role of generics? Please give an example.  (4/4)****  
Generics enable type safe code reuse across different data types.
Sample:
```swift
func swapValues<T>(_ a: inout T, _ b: inout T) {
    let temp = a
    a = b
    b = temp
}

var x = 5, y = 10
swapValues(&x, &y)  // Works with Int

var str1 = "Hello", str2 = "World"
swapValues(&str1, &str2)  // Works with String
```

### Coding (Score: 38)
****18. Please do the coding for infinite banner view by Swift (required) or SwiftUl. (38)****
```swift
struct InfiniteBannerView: View {
    let images = ["banner1", "banner2", "banner3"]
    @State private var currentIndex = 0
    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()

    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(0..<images.count, id: \.self) { index in
                Image(images[index])
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width, height: 200)
                    .clipped()
                    .tag(index)
            }
        }
        .tabViewStyle(.page)
        .onReceive(timer) { _ in
            withAnimation {
                currentIndex = (currentIndex + 1) % images.count
            }
        }
    }
}
```

### New Technologies And Frameworks (Score: 12)
****19. What are the core concepts (Publisher, Subscriber, Subject) of the Combine framework? (6)****  
Publisher: Data source that emits values.
Subscriber: Receives and processes values from Publisher.
Subject: Special Publisher that can manually send values.(eg: PassthroughSubject, CurrentValueSubject)
Sample:
```swift
// Publisher
let publisher = [1, 2, 3].publisher

// Subscriber
publisher.sink { value in
    print(value)
}

// Subject
let subject = PassthroughSubject<Int, Never>()
subject.send(1)
```

****20. Briefly describe how to use async/await in network requests. (6)****  
async/await provides a way to write asynchronous code in a more readable and maintainable way. It allows we to write asynchronous network requests without using callback closures, which helps avoid callback hell.  

```swift
func fetchData() async throws -> Data { // async marks the function as asynchronous
    try await URLSession.shared.data(from: url) 
}
// Call the function in an async context
Task {
    do {
        let data = try await fetchData() // await pauses the function until the result is returned.
        print("Data received: \(data)")
    } catch {
        print("Error: \(error)")
    }
}
```