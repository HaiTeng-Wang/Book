//
//  StackAndQueueTests.swift
//  CoreDataDemoTests
//
//  Created by Hunter on 2025/6/14.
//

import XCTest

protocol StackContainer {
    associatedtype Item
    mutating func push(_ item: Item)
    mutating func pop() -> Item?
    var size: Int { get }
    var peek: Item? { get }
    var isEmpty: Bool { get }
    subscript(i: Int) -> Item { get }
}

struct Stack<Item>: StackContainer {
    var items = [Item]()

    var size: Int { items.count }

    var peek: Item? { items.last }

    var isEmpty: Bool { return items.isEmpty }

    mutating func push(_ item: Item) { items.append(item) }

    mutating func pop() -> Item? { return items.removeLast() }

    subscript(i: Int) -> Item { items[i] }
}

protocol QueueContainer {
  associatedtype Element
  var isEmpty: Bool { get }
  var size: Int { get }
  var peek: Element? { get }
  mutating func enqueue(_ newElement: Element)
  mutating func dequeue() -> Element?
}


struct Queue<Element>: QueueContainer {

  var isEmpty: Bool { return left.isEmpty && right.isEmpty }
  var size: Int { return left.count + right.count }
  var peek: Element? { return left.isEmpty ? right.first : left.last }

  private var left = [Element]()
  private var right = [Element]()

  mutating func enqueue(_ newElement: Element) {
    right.append(newElement)
  }

  mutating func dequeue() -> Element? {
    if left.isEmpty {
      left = right.reversed()
      right.removeAll()
    }
    return left.popLast()
  }
}

// 用栈来实现队列
struct QueueWithStack<Element> {
    var stackA: Stack<Element>
    var stackB: Stack<Element>

  var isEmpty: Bool {
    return stackA.isEmpty && stackB.isEmpty;
  }

  var peek: Element? {
      mutating get {
      shift();
      return stackB.peek;
    }
  }

  var size: Int {
    get {
      return stackA.size + stackB.size
    }
  }

  init() {
      stackA = Stack<Element>()
      stackB = Stack<Element>()
  }

  mutating func enqueue(object: Element) {
    stackA.push(object);
  }

  mutating func dequeue() -> Element? {
    shift()
      return stackB.pop()
  }

    private mutating func shift() {
        if stackB.isEmpty {
            while !stackA.isEmpty {
                stackB.push(stackA.pop()!);
            }
    }
  }
}

// 用队列实现栈
struct StackWithQueue<Element> {
    var queueA: Queue<Element>
  var queueB: Queue<Element>

  init() {
    queueA = Queue()
    queueB = Queue()
  }

  var isEmpty: Bool {
    return queueA.isEmpty && queueB.isEmpty
  }

  var peek: Element? {
      mutating get {
      shift()
      let peekObj = queueA.peek
      queueB.enqueue(queueA.dequeue()!)
      swap()
      return peekObj
    }
  }

  var size: Int {
    return queueA.size
  }

    mutating func push(object: Element) {
    queueA.enqueue(object)
  }

    mutating func pop() -> Element? {
    shift()
    let popObject = queueA.dequeue()
    swap()
    return popObject
  }

    private mutating func shift() {
    while queueA.size != 1 {
      queueB.enqueue(queueA.dequeue()!)
    }
  }

    private mutating func swap() {
    (queueA, queueB) = (queueB, queueA)
  }
}

// 参考 https://www.jianshu.com/p/a2a2fbe4ca29
final class StackAndQueueTests: XCTestCase {

    func testQueueWithStack() {
        var queue = QueueWithStack<Int>()
        queue.enqueue(object: 1)
        queue.enqueue(object: 2)
        queue.enqueue(object: 3)
        queue.enqueue(object: 4)
        print(queue)
    }

    func testStackWithQueue() {
        var stack = StackWithQueue<Int>()
        stack.push(object: 1)
        stack.push(object: 2)
        stack.push(object: 3)
        stack.push(object: 4)
        print(stack)
    }

}
