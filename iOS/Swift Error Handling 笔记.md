# Swift Error Handling 笔记

文档：
  - [Error Handling](https://docs.swift.org/swift-book/LanguageGuide/ErrorHandling.html)
  - [中文](https://www.cnswift.org/error-handling)

阅读时间：3个小时。

读完须知：

> 当一个错误被抛出，周围的某些代码必须为处理错误响应——比如说，为了纠正错误，尝试替代方案，或者把错误通知用户。
> 在 Swift 中有四种方式来处理错误。你可以将来自函数的错误传递给调用函数的代码中，使用 do-catch 语句来处理错误，把错误作为可选项的值，或者错误不会发生的断言。
> 当函数抛出一个错误，它就改变了你程序的流，所以能够快速定位错误就显得格外重要。要定位你代码中的这些位置，使用 try 关键字——或者 try? 或 try! 变体——放在调用函数、方法或者会抛出错误的初始化器代码之前。
> - try? 通过将错误转换为可选项来处理一个错误。如果一个错误在 try?表达式中抛出，则表达式的值为 nil
> - try! 来取消错误传递并且把调用放进不会有错误抛出的运行时断言当中。如果错误真的抛出了，你会得到一个运行时错误。

总结如下：


## swift中的四种处理错误方式

1. 使用抛出函数传递错误

    即：将来自函数的错误传递给调用函数的代码中

    ```swift
            enum CustomError: Error {
                case error1
            }

            func throwErrorFunction() throws {
                throw CustomError.error1
            }
            
            func throwFunctionDeliveryError() throws {
                try throwErrorFunction() 
                /*注意：这里要使用try，而不是try? 或 try! 去修饰抛出错误函数。*/
                print("Continue to execute some code ...") // 注意：如果 `try throwErrorFunction()` 抛出错误，此时会改变程序流，这行代码不会执行
            }
            
    ```
    如上代码，使用 `try`，会如期进行**错误传递**。`try?` 则会忽略错误，`try！` 如果有错误程序会crash。
    
2. 使用 `do-catch` 语句来处理错

    ```swift
            do {
                try throwFunctionDeliveryError() 
            } catch CustomError.error1 {
                print("The specified error was caught here")
            } catch {
                print("Unexpected error: \(error).")
            }
    ```
    同样，这里也要使用try，而不是try? 或 try! 关键字，最终才会在`do..catch..`中捕获到错误。

3. 把错误当做可选值（此时用 `try?` 关键字）

    ```swift
        try? throwErrorFunction()
        print("Continue to execute some code ...")
    ```

    如果 `throwErrorFunction` 抛出一个错误，使用try?修饰，会忽略错误，代码会继续向下执行。
    
    如果 `throwErrorFunction` 有返回值，使用try?修饰，会返回一个可选值。
    ```swift
        func throwErrorFunction() throws -> Int {
            throw CustomError.error1
        }
    ```
    ```swift
        let value = try? throwErrorFunction() // value为可选值
    ```

4. 假设错误不会发生的断言（此时用 `try!` 关键字）
    > 假设我们已经知道一个抛出错误或者方法不会在运行时抛出错误。在这种情况下，你可以在表达式前写 try! 来取消错误传递并且把调用放进不会有错误抛出的运行时断言当中。如果错误真的抛出了，你得到一会个运行时错误。

    ```swift
        try! throwErrorFunction()
        print("Continue to execute some code ...")
    ```

    如果 `throwErrorFunction` 抛出一个错误，使用 `try!` 修饰，程序会` crash` ，得到一个运行时错误
    
    如果 `throwErrorFunction` 有返回值，使用 `try!` 修饰，会返回一个不为空的隐士强制解析值。
    ```swift
        func throwErrorFunction() throws -> Int {
            throw CustomError.error1
        }
    ```
    ```swift
        let value = try! throwErrorFunction() // value 为普通值
    ```

## try try? try! 的区别
 - try 出现异常处理异常
 - try? 不处理异常,返回一个可选值类型,出现异常返回nil
 - try! 不让异常继续传播,一旦出现异常程序停止,类似NSAssert()
