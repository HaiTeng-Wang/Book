//
//  NodeListTests.swift
//  CoreDataDemoTests
//
//  Created by Hunter on 2025/6/14.
//

import XCTest

// 结合B站收藏的视频去看链表，以及leetcode上收藏的题。 ***做链表题的时候，脑子里要有图，实际上就是指针移动。***
class ListNode { // 单向链表节点（如果定义双向链表的话需要再有添加一个var pre: ListNode? 去保持前置节点的引用）
  var val: Int // val value的简写
  var next: ListNode?

  init(_ val: Int) {
    self.val = val
    self.next = nil
  }
}

// 单项链表
class List {
    var head: ListNode?
    var tail: ListNode?

    func insert(val: Int, befor target: Int) {
        guard let head = head else { return }

        let newNode = ListNode(val)
        var pre = head, cur = head

        guard head.val != target else { // 要处理val是头节点的情况。
            newNode.next = cur
            self.head = newNode
            return
        }

        while cur.val != target {
            guard cur.next != nil else { fatalError("No valid target!") }
            pre = cur
            cur = cur.next!
        }

        newNode.next = cur
        pre.next = newNode
    }

    func insert(val: Int, after target: Int) {
        guard let head = head else { return }

        var cur = head
        while cur.val != target {
            guard cur.next != nil else { fatalError("No valid target!") }
            cur = cur.next!
        }

        let newNode = ListNode(val)

        guard cur.next != nil else { // Need to handle the case of where val is tail node.
            cur.next = newNode
            self.tail = newNode
            return
        }

        newNode.next = cur.next
        cur.next = newNode
    }

    func remove(_ val: Int) {
        guard let head = head else { return }

        guard val != head.val else { // Hadelling for val is head
            self.head = self.head?.next
            return
        }

        var cur = head, pre = cur

        // find target node
        while cur.val != val {
            guard cur.next != nil else { fatalError("No valid val!")}
            pre = cur
            cur = cur.next!
        }

        guard cur.next != nil else { // Hadelling for val is tail
            pre.next = nil
            self.tail = pre
            return
        }

        pre.next = cur.next
    }


  // 尾插法
  func appendToTail(_ val: Int) {
    if tail == nil {
      tail = ListNode(val)
      head = tail
    } else {
      tail!.next = ListNode(val)
      tail = tail!.next
      // 如果是循环链表（eg: 1->2->3->4->5->1）的话，添加如下代码
//      tail?.next = head
    }
  }

  // 头插法
  func appendToHead(_ val: Int) {
    if head == nil {
      head = ListNode(val)
      tail = head
    } else {
      let temp = ListNode(val)
      temp.next = head
      head = temp
        // 如果是双向循环链表(eg: 5<-1->2->3->4->5->1)的话 需要ListNode有pre属性，同时添加head.pre = tail代码，同时打开line 105行.
    }
  }
}

final class ListNodeTests: XCTestCase {

    func list() -> List {
        let list: List = List()
        list.appendToTail(1)
        list.appendToTail(5)
        list.appendToTail(3)
        list.appendToTail(2)
        list.appendToTail(4)
        list.appendToTail(2)
        return list
    }

    func testList() {
        let list = list()
        list.insert(val: 0, befor: 1)
        list.insert(val: 4, befor: 5)
        list.insert(val: 6, after: 5)
        list.remove(0)
        list.remove(4)
        list.remove(6)
        print(list)
    }

    /*
     给一个链表和一个值x，要求只保留链表中所有小于x的值，原链表的节点顺序不能变。
     例：1->5->3->2->4->2，给定x = 3。则我们要返回 1->2->2
     */
    func testGetLeftList() {
        func getLeftList(_ head: ListNode?, _ x: Int) -> ListNode? { // 原理： 因为不确定头节点，所以需要定义一个dummy节点。移动cur指针直到最后一个node，移动过程中判断cur.val < x 就尾插法拼接（pre.next = cur, pre = cur）
          let dummy = ListNode(0) // 虚拟的头前结点（因为不确定哪个是满足条件的头节点）
          var pre = dummy // 前置节点
          var cur = head // 当前节点


          while cur != nil {
            if cur!.val < x { // 把[满足条件的node]进行拼接（尾插法）(pre = dummy, dummy.next = pre, dummy.next.next = pre, dummy.next.next.next = pre)
              pre.next = cur // 第一轮，[第1次满足条件的node]设置为pre的next；第二轮，因为dummy的next就是pre，所以，第二轮就是0->[第1次满足条件的node(pre)]->[第2次满足条件的node] -> 第三轮依次类推
              pre = cur! // 第一轮，pre设置为[第1次满足条件的node]（要知道，因为pre和dummy的内存地址一样，所以dummy的next是[第1次满足条件的node]也就是pre）；第二轮，dummy的next（即[第1次满足条件的node]）的next设置为pre -> 第三轮以此类推
            }
              cur = cur!.next // 遍历链表（依次指向下一个节点，直到最后一个节点，node == nil）
          }

          return dummy.next
        }

        let list = getLeftList(list().head!, 3)
        print(list as Any)
    }

    /*
     给一个链表和一个值x，要求将链表中所有小于x的值放到左边，所有大于等于x的值放到右边。原链表的节点顺序不能变。
     例：1->5->3->2->4->2，给定x = 3。则我们要返回 1->2->2->5->3->4
     */
    func testPartition() {
        func partition(_ head: ListNode?, x: Int) -> ListNode? {
            guard let head = head else { return head }

            // 引入Dummy节点
            let preDummy = ListNode(0), postDummy = ListNode(0)
            var pre = preDummy, post = postDummy, cur: ListNode? = head

            // 用尾插法处理左边和右边
            while cur != nil {
                if cur!.val < x {
                    pre.next = cur
                    pre = cur!
                } else {
                    post.next = cur
                    post = cur!
                }
                cur = cur!.next
            }

            // 左右拼接
            post.next = nil // 防止闭环
            pre.next = postDummy.next

            return preDummy.next
        }

        let list = partition(list().head!, x: 3)
        print(list as Any)
    }

    // 反转链表（原理：三指针 pre（初始为空指针） cur（当前node），以及循环体中的防止断链的next，next = cur.next。移动cur，cur.next指向pre，pre指向cur，cur指向next）
    func testReversed() {
        func reversed(_ head: ListNode?) -> ListNode? {
            guard let head = head else { return head }

            var cur: ListNode? = head, pre: ListNode?

            while cur != nil {
                let next = cur!.next
                cur!.next = pre
                pre = cur!
                cur = next
            }

            return pre
        }
        let list = reversed(list().head!)
        print(list as Any)
    }

    // 检测一个链表中是否有环
    func testHasCycle() {
        func hasCycle(_ head: ListNode?) -> Bool {
            var fast = head, slow = head

            while fast != nil && fast!.next != nil {
                fast = fast!.next!.next
                slow = slow!.next
                if fast === slow { return true }
            }

            return false
        }

        let isHasCycle = hasCycle(list().head!)
        print(isHasCycle)
    }

    // 删除链表的第N个节点 5 3 1 6 2（找到n，然后pre.next = n.next）
    func testRemoved() {
        func removed(_ target: Int, for head: ListNode ) -> ListNode {
            var cur = head, pre = cur

            while cur.val != target {
                guard cur.next != nil else {
                    fatalError("No valid input, the head is not contain target value!")
                }
                pre = cur
                cur = cur.next!
            }
            pre.next = cur.next
            return head
        }
        let list = removed(3, for: list().head!)
        print(list)
    }

    // 删除链表的倒数第N个节点。(快慢指针，fast先走n步，然后再一起走，fast走到最后一个node(此时low就是target的pre)，最后low.next = low.next.next)
    func testRemoveNthFromEnd() {
        func removeNthFromEnd(_ head: ListNode?, _ n: Int) -> ListNode? {
            guard head != nil else { return nil }
            guard n > 0 else { return head }

            let dummy = ListNode(0) // 如果删除的是头节点，这里需要用到dummy占位。
            dummy.next = head
            var fast: ListNode? = dummy, slow: ListNode? = dummy

            for _ in 1...n {
                if fast == nil { break }
                fast = fast!.next
            }

            while fast != nil && fast!.next != nil {
                fast = fast!.next
                slow = slow!.next
            }

            slow!.next = slow!.next!.next

            return dummy.next
        }

        let list = removeNthFromEnd(list().head!, 14)
        print(list as Any)
    }
}
