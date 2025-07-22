//
//  DynamicProgrammingTests.swift
//  CoreDataDemoTests
//
//  Created by Hunter on 2025/6/18.
//

import XCTest

/*
 动态规划：DP（Dynamic Programming）：把原问题分解为相对简单的子问题的方式求解复杂问题的方法。
 如果问题有如下特征，可用动态规划思想去解题：很容易得出初始状态（很容易看出边界），有最优子子结构，可得出状态转移方程，有重叠子问题。
  - 初始状态，即此问题的最简单子问题的解。【eg：fbi中最简单的问题是，一开始给定的第一个数和第二个数是几？自然我们可以得出是1。】
  - 状态转移方程，即第n个问题的解与之前的 n - m 个问题解的关系。【eg：fbi中我们可找出规律，得出状态转移方程f(n) = f(n - 1) + f(n - 2)】
  - 最优子结构：一个问题的最优解可以由其子问题的最优解组合而成。【eg：fbi中 f(n-1)和f(n-2) 称为 f(n) 的最优子结构】
  - 重叠子问题：子问题的答案会在其它子问题中重复用到；【eg：fbi中重复计算答案值，计算过f(3) = f(2) + f(1)，还需重复计算f(3)，也就是说f(3)被重复计算多次。】

 核心思想：拆分子问题，找到最简单子问题的解（初始状态），找出规律得到最优子结构，得到状态转移方程，避免重叠子问题。

 动态规划的解法有两种：
 1. 自顶向下：递归的从大问题开始逐一计算子问题，同时注意避免重叠子问题，可经过记忆化搜索也称备忘录
   （把子问题的结果保存起来，后面如果用到相同子问题的结果，则直接从保存的结果中获取）得到最终答案。
 2. 自底向上也称表格法（Tabulation）：从最小的子问题出发，直到计算到大问题本身，得到最终答案（同时注意是否会有重叠子问题。fbi中没有）。

 参考：
  https://www.jianshu.com/p/9ea5a4485f10
  https://www.bilibili.com/video/BV1eM41117FQ/?spm_id_from=333.1387.collection.video_card.click&vd_source=fa4468590f15b96e11adf0cf45781f85
  https://www.bilibili.com/video/BV1VGjMzNEL6/?spm_id_from=333.1387.collection.video_card.click&vd_source=fa4468590f15b96e11adf0cf45781f85
 */

final class DynamicProgrammingTests: XCTestCase {
    /*
     例题：斐波拉契数列
     斐波拉契数列是这样一个数列：1, 1, 2, 3, 5, 8, ... 除了第一个和第二个数字为1以外，其他数字都为之前两个数字之和。现在要求第n（eg: 100）个数字是多少。

     例题：青蛙跳阶问题（和fbi一样，只不过换种问法）
     一只青蛙一次可以跳上1级台阶，也可以跳上2级台阶。求该青蛙跳上一个 10 级的台阶总共有多少种跳法。
     这里不做演示，参考：https://zhuanlan.zhihu.com/p/365698607
     */


    func testfib() {
        /*
         1. 自顶向下（最原始的递归，写法简单，但效率很低）
         Complex:
         时间：O(1) * O(2^n) = O(2^n) 指数级别
          - 解决一个子问题f（n-1）+f（n-2），也就是一个加法的操作，所以复杂度是 O(1)
          - 问题个数 = 递归树节点的总数，递归树的总节点 = 2^n-1，所以是复杂度O(2^n)
         空间：O(1)
         */
        func fib(_ n: Int) -> Int {
            // 定义初始状态
            guard n > 0 else { return 0 }
            if n == 1 || n == 2 { return 1 }
            // 调用状态转移方程
            return fib(n - 1) + fib(n - 2)
        }
        print("自顶向下（最原始的递归，写法简单，但效率很低）: \(fib(10))")
    }

    func testfibWithMemorandum() {
        /*
         Final 1. 自顶向下（带备忘录的递归）
         Complex：
         时间：O(n)
          - 子问题个数 = 树节点数 = n，
          - 解决一个子问题还是O(1)
         空间：O(n) 空间换时间

         当n特别大的时候，有栈溢出风险。
         栈溢出：每一次递归，程序都会将当前的计算压入栈中。随着递归深度的加深，栈的高度也越来越高，直到超过计算机分配给当前进程的内存容量，程序就会崩溃。
         */
        func fibWithMemorandum(_ n: Int) -> Int {
            var nums = Array(repeating: 0, count: n)
            func fib(_ n: Int) -> Int {
                // 定义初始状态
                guard n > 0 else { return 0 }

                if n == 1 || n == 2 { return 1 }

                // 备忘录: 如果已经计算过，直接调用，无需重复计算
                if nums[n - 1] != 0 { return nums[n - 1] }

                // 将计算后的值存入数组
                nums[n - 1] = fib(n - 1) + fib(n - 2)

                return nums[n - 1]
            }
            return fib(n)
        }

        print("自顶向下（带备忘录的递归）: \(fibWithMemorandum(10))")
    }


    func testfibWithTabulation() {
        /*
         2. 自底向上（表格法）通过一个数组从前往后推
         Complex：
         时间：O(n)
         空间：O(n)
         */
        func fib(_ n: Int) -> Int {
            var fib = [0, 1]
            for i in 2 ... n {
                fib.append(fib[i - 1] + fib[i - 2])
            }
            return fib[n]
        }
        print("自底向上（表格法）通过一个数组从前往后推: \(fib(10))")
    }

    func testfibBestWithTabulation()  {
        /*
         Final 2. 自底向上（表格法）空间优化版本，只用两个变量就能快速算出结果
         Complex：（**最优**）
         时间：O(n)
         空间：O(1)
         */
        func fibBest(_ n: Int) -> Int {
            var(pre, cur) = (0, 1)
            for _ in 2 ... n {
                (cur, pre) = (cur + pre, cur)
            }
            return cur
        }
        print("自底向上（表格法）空间优化版本，只用两个变量就能快速算出结果: \(fibBest(10))")
    }
}
