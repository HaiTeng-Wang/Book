//
//  ArrayTests.swift
//  CoreDataDemoTests
//
//  Created by Hunter on 2025/6/14.
//

import XCTest

// https://doc.swiftgg.team/documentation/the-swift-programming-language/collectiontypes

/*
 Array<Element>    ContiguousArray<Element>    ArraySlice<Element>

 let array = [1, 2, 3, 4, 5] // 默认Array
 let slice = array[1...3] // 此时为ArraySlice 不拥有存储，引用原数组部分，避免不必要的内存拷贝 https://developer.apple.com/documentation/swift/arrayslice
 let contiguous = ContiguousArray(array)

 区别：
 https://developer.apple.com/documentation/swift/contiguousarray
 The ContiguousArray type is a specialized array that always stores its elements in a contiguous region of memory. This contrasts with Array, which can store its elements in either a contiguous region of memory or an NSArray instance if its Element type is a class or @objc protocol.

 If your array’s Element type is a class or @objc protocol and you do not need to bridge the array to NSArray or pass the array to Objective-C APIs, using ContiguousArray may be more efficient and have more predictable performance than Array. If the array’s Element type is a struct or enumeration, Array and ContiguousArray should have similar efficiency.


 https://developer.apple.com/documentation/swift/array
 The ContiguousArray and ArraySlice types are not bridged; instances of those types always have a contiguous block of memory as their storage.

 eg:
 let colors = ["periwinkle", "rose", "moss"]
 let moreColors: ContiguousArray = [3, 4, 5, 6]

 let url = URL(fileURLWithPath: "names.plist")
 (colors as NSArray).write(to: url, atomically: true)
 (moreColors as NSArray).write(to: url, atomically: true) // 此时会报Error. Cannot convert value of type 'ContiguousArray<Int>' to type 'NSArray' in coercion

 ----------
 `mutating func reserveCapacity(_ minimumCapacity: Int)`
 Reserves enough space to store the specified number of elements.
 If you are adding a known number of elements to an array, use this method to avoid multiple reallocations. This method ensures that the array has unique, mutable, contiguous storage, with space allocated for at least the requested number of elements.
 */

func arrayPractice() {
    // init
    print([1, 2, 3])
    print([Int](repeating: 0, count: 5))
    var strs = ["3", "1", "2", "3", "2"]

    // append
    strs.append("4")

    // sort
    strs.sort()
    strs.sort(by: >)
    print(Array(strs[0..<strs.count - 1]))

    /* 注意：Swift 字典没有sort方法，但是有sorted方法，此方法会返回[(key: Key, value: Value)] 如
     let dictionary:[String:Int] = [
         "Five": 5,
         "Three": 3,
         "One": 1,
         "Two": 2,
         "Four": 4
     ]

     let result = dictionary.sorted{$0.value < $1.value}
     print(result)

     Output:
     [(key: "One", value: 1), (key: "Two", value: 2), (key: "Three", value: 3), (key: "Four", value: 4), (key: "Five", value: 5)]
     字典和集合是无序的
    */

    func testReduce() {
        /*
         reduce(into:) vs reduce：https://juejin.cn/post/7219712310586982457
         reduce定义：可以为一个序列产出一个来自这个序列节点的值，通过第一个initResult参数，以及第二个参数类型为闭包的参数，这个闭包拥有Result和Element参数, reduce(into) 无闭包返回值，但是第一个参数有inout修饰，reduce第一个参数无inout修饰，返回值为Result。
         实现如下：
         https://github.com/swiftlang/swift/blob/665515c781999a81094bbe4f8302a7cb1a6a6b39/stdlib/public/core/SequenceAlgorithms.swift#L668
         public func reduce<Result>(
             _ initialResult: Result,
             _ nextPartialResult: (Result, Element) throws -> Result
         ) rethrows -> Result {
             var accumulator = initialResult
             for element in self {
                 accumulator = try nextPartialResult(accumulator, element)
             }
             return accumulator
         }

         func reduce<Result>(
             into initialResult: __owned Result,
             _ updateAccumulatingResult: (inout Result, Element) throws -> Void
         ) rethrows -> Result {
             var result = initialResult
             for element in self {
                 try updateAccumulatingResult(&result, element)
             }
             return result
         }

         *区别*：函数第二个参数类型，闭包的第一个参数有无inout修饰符，以及闭包有无result返回值。reduce(into:)有inout修饰，所以在reduce(into:)调用处第二个类型参数闭包的第一个参数result访问为var，无返回值。reduce无inout修饰，返回值为第一个参数result。
          reduce(into:)性能要好一些，因为reduce(into:) 的 result 是通过 inout 参数传递的，直接修改原值（直接操作原始值的内存），没有中间临时值的生成和复制(https://chat.deepseek.com/a/chat/s/31d3d9c0-1362-4794-940a-a05574a8c623)。
         reduce适用于Result为简单的值类型（如整数、字符串等）拼接(写起来简单)，reduce(into:)适用于Array Dic。
         */

        // 使用例子
        //eg1: 元素相加
        print("reduce +: \(strs.reduce("initialResult+", +))")
        print("reducinto + \(strs.reduce(into: "initialResult+"){ $0 += $1})")

        //////////////////////////////
        // eg2：合并数组
        let arrays = [[1, 2], [3, 4], [5, 6]]
        print("reduce merge array: \(arrays.reduce([], +))") // 这里是 +
        print("reduce(into:) merge array: \(arrays.reduce(into: []) { $0 += $1 })") // 这里是 +=

        //////////////////////////////
        //eg3: 计算元素出现次数
        let reduceLetterCount = strs.reduce([String: Int]()) { result, element in //
              var result = result // 效率低，result 是 let，所以必须创建临时副本
              result[element, default: 0] += 1
              return result // 返回临时副本 result
        }
        print("reduce Letter Count---:\(reduceLetterCount)")
        // 这里$0是var，所以reduce into操作COW类型结果时(如Array，Dic)性能好于reduce。直接writ$0
        print("reduce(into:) Letter Count---:\(strs.reduce(into: [:]) { $0[$1, default: 0] += 1 })")
        //////////////////////////////

        //eg4: Using reduce(into:_:) to filter adjacent equal elements
        let filtered = [1, 1, 2, 2, 2, 3, 4, 4, 5, 4, 3].reduce(into: [Int]()) { newArray, number in
            if newArray.last != number { newArray.append(number) }
        }
        print("Using reduce(into:_:) to filter adjacent equal elements\(filtered)") // [1, 2, 3, 4, 5, 4, 3]
    }

    testReduce()
}

final class ArrayTests: XCTestCase {

    func testTwoSum() {
        func twoSum(nums: [Int], target: Int) -> Bool {
            var set = Set<Int>()

            for num in nums {
                if set.contains(target - num) { return true }
                set.insert(num)
            }

            return false
        }
        print("twoSum---:\(twoSum(nums: [2, 4, 5, 6], target: 9))")
    }

    func testTwoSumIndex() {
        func twoSumIndex(nums: [Int], target: Int) -> (Int, Int) {
            var dic = [Int: Int]()

            for (i, num) in nums.enumerated() {
                if let lastIndex = dic[target - num] {
                    return (lastIndex, i)
                } else {
                    dic[num] = i
                }
            }

            fatalError("No valid output!")
        }

        print("twoSumIndex---:\(twoSumIndex(nums: [2, 4, 5, 6], target: 9))")
    }

    func testRemoveDuplicates() throws {
        func removeDuplicates(_ nums: [Int]) -> [Int] {
            return nums.reduce(into: [Int]()) {
                if !$0.contains($1) { $0.append($1) }
            }
        }
        print(removeDuplicates([1, 1, 2]))
    }

}
