//
//  SortTests.swift
//  CoreDataDemo
//
//  Created by Hunter on 2025/6/14.
//

import XCTest

/*
 n: 时间复杂度上，可以看成执行次数。空间复杂度上可以看成开辟内存空间数量。
 时间复杂度：
     O(1)常数时间 (Constant Time)
       ：算法的执行时间不随输入规模 n 的变化而变化
        eg:- 访问数组第一个元素
           - 在字典中通过键查找值
           - 基本的算术运算、比较、赋值 let sum = a + b // O(1)
     O(long n) 对数时间 (Logarithmic Time)
      每次操作能将问题规模大幅削减（如减半）的算法
       eg: - binarySearch
     O(n) 线性时间 (Linear Time)
      一层循环，循环n次
       eg: - 计算数组所有元素之和
           - 查找数组中的最大值
     O(n long n)
      比 O(n) 慢，但比 O(n²) 快得多。许多高效的排序算法属于此类。
       eg: - 快排
           - Swift 标准库的 sort() 方法 (Introsort: 快速排序 + 堆排序 + 插入排序混合)
     O(n²) 平方时间 (Quadratic Time)
      嵌套循环
       eg: -冒泡排序

 空间复杂度
   O(1) - 常数空间 (Constant Space)
     :算法所需的额外空间不随输入规模 n 变化
     // 计算数组元素之和 (上面那个)
     func sumArray(_ array: [Int]) -> Int {
         var total = 0 // 只用了固定数量的变量 (1个)
         for element in array {
             total += element
         }
         return total
     }
   O(n) - 线性空间 (Linear Space)
     : 算法所需的额外空间与输入规模 n 成正比
    var newArray = [Int]() // 创建一个新的空数组
    for element in array {
      newArray.append(element) // 添加 n 个元素
    }
   O(n²) - 平方空间 (Quadratic Space)
    :算法所需的额外空间与 n² 成正比，eg: 二维数组 (分配了一个 n x n 的二维数组)
 */

final class SortTestsTests: XCTestCase {

    func testSort() throws {
        /*
         快速排序: 核心是选择基准值（pivot）+ 分治（Partition）+ 递归，即选择一个基准值（pivot），把比它小的放左边，比它大的放右边。
         （看B站的视频，脑子里有图就好理解了。可以想想成把图书馆一落书按照薄厚排序，抽出一本作为Pivot，分割两落，然后按照pivot这个厚度，不断左右迭代，回落。）
         Complex: O(nlogn)最坏情况是O(n²)比如pivot是最后一个元素且数组本身有序。没有实现分治。或者数组内是大量连续相同或全相同元素。  O(1)
         不稳定(Partition 过程中，相等的元素可能被交换到不同侧)

         稳定的概念：
         示例：[3, 2, 3', 1]（选择 pivot = 2）
         Partition 后可能变成 [1, 2, 3', 3]（3 和 3' 的相对顺序变了！）
         或者 [1, 2, 3, 3']（取决于具体实现）
         */
        func testQuickSort(_ array: [Int]) -> [Int] {
            guard array.count > 1 else { return array} // 4. 左右分区递归到最后一层(只有一个元素或没有)，走到这里就开始回溯了。

            let pivot = array[array.count / 2] // 1. 选择基准值，可以选择第一个，最后一个，中间一个或任意一个，基准值的选择影响递归深度。（pivot选择：固定位置选择（通常做法）；随机选择或三数取中法（处理极端case，如存在大量已经排序好的元素，或相同元素。而去避免时间复杂度为O(n²)））
            // 2. 分区（partition）log n
            let left = array.filter{$0 < pivot}
            let middle = array.filter{$0 == pivot}
            let right = array.filter{$0 > pivot}

            // 3. 递归排序 n
             return testQuickSort(left) + middle + testQuickSort(right)
        }

        /*
         时间复杂度: O(n) * O(n) = O(n²) (内层循环次数随 i 减少，但总和仍是 n(n-1)/2 ≈ O(n²))
         冒泡排序    O(n^2)    O(1)    稳定

         由于冒泡排序只交换不相等的元素，所以它是稳定排序
         示例：[3, 2, 3', 1]（假设 3 和 3' 是相同的值，但带标记以区分）
         第一轮冒泡：[2, 3, 1, 3']（3 和 3' 不交换，因为 3 == 3'）
         第二轮冒泡：[2, 1, 3, 3']（3 和 3' 仍然不交换）
         最终结果：[1, 2, 3, 3']（3 仍然在 3' 前面，相对顺序不变）
         */
        func bubbleSort(array: Array<Int>) -> Array<Int> {
            var sortedArray = array // O(n) 空间
            for i in 0..<sortedArray.count { // 外层循环 n 次
                for j in 0..<sortedArray.count - 1 - i { // 内层循环平均约 n/2 次
                    if sortedArray[j] > sortedArray[j + 1] { _swap(&sortedArray, j, j + 1) } // O(1) 交换
                }
            }
            return sortedArray
        }

        print("testQuickSort---:\(testQuickSort([3, 5, 10, 2, 4]))")
        print("bubbleSort---:\(bubbleSort(array: [ 2, 4, 5, 23, 1, 0, 2, 6]))")
    }

    func testBinarySearch() {
        // 二分查找 (Binary Search) - 要求数组已排序
        // O(log n) - 对数时间 (Logarithmic Time): 每次操作能将问题规模大幅削减（如减半）
        /*
         注意：
         第一，mid 定义在 while 循环外面，如果定义在里面，则每次循环都要重新给 mid 分配内存空间，造成不必要的浪费；定义在循环之外，每次循环只是重新赋值；
         第二，每次重新给 mid 赋值不能写成mid = (left + right) / 2。这种写法表面上看没有问题，但当数组的长度非常大、算法又已经搜索到了最右边部分的时候，那么right + left就会非常之大，造成溢出导致程序崩溃。所以解决问题的办法是写成 mid = left + (right - left) / 2。
         */
        func binarySearch(_ array: [Int], _ target: Int) -> Bool {
            var left = 0, mid = 0, right = array.count - 1 // O(1)
            while left <= right { // 循环次数是 O(log n)
                mid = left + (right - left) / 2 // O(1)
                if array[mid] == target {
                    return true // 找到
                } else if array[mid] < target {
                    left = mid + 1 // 搜索右半部分
                } else { right = mid - 1} // 搜索左半部分
            }
            return false
        }
        print("binarySearch---:\(binarySearch([1, 2, 3, 4, 5, 6], 6))")
    }

    // 二分搜索实战演练题：版本崩溃 https://www.jianshu.com/p/b4036e6d3f13
    func testFindFirstBadVersion() {
        func isBadVersion(_ n: Int) -> Bool {
            n >= 3 ? true : false
        }

        func findFirstBadVersion(from version: Int) -> Int {
            guard version >= 1 else { return -1 }

            var left = 1, right = version, mid = 0

            while left < right { // 当检测到剩下一个版本的时候，我们已经无需在检测直接返回即可，因为它肯定是崩溃的版本。所以while循环不用写成left <= right
                mid = left + (right - left) / 2
                if isBadVersion(mid) {
                    right = mid // 当发现中间版本(mid)是崩溃版本的时候，只能说明第一个崩溃的版本小于等于中间版本。所以只能写成 right = mid
                } else {
                    left = mid + 1
                }
            }

            return left // return right 同样结果
        }

        print("First bad version is: \(findFirstBadVersion(from: 10))")
    }

}


