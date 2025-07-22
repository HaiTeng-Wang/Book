//
//  TreeTests.swift
//  CoreDataDemoTests
//
//  Created by Hunter on 2025/6/16.
//

import XCTest

// Tree
/*
树：一种递归的数据结构，与链表类似，一棵树有且只有一个根节点，每个节点有0到多个子节点，每个子节点还有0到多个子节点，依此类推。每个节点会保存节点的值。
关于树的简介看B站收藏的视频。

邻居节点：相邻的节点；叶子节点：没有子节点的节点；树的高度：树的层数；子树：除了根节点外，子节点和后续节点形成的树。

树是应用广泛，例如html dom，文件索引，等。

分类：二叉树（常见）：每个节点都有两个子节点；三茶树；多叉树。

 根据节点的排列和数量，二叉树分为如下常见类型：
 完全二叉树：每一层的节点都拥有2个子节点，最后一层除外，并且最后一层空缺的节点必须在右边，左边必须填满。
           *
      *         *
   *    *    *

 满二插树：每个节点要么有2个子节点，要么没有子节点，不能只有一个子节点。
           *
      *         *
    *    *

 完美二叉树：所有子节点必须有两个子节点，最后一层都是叶子结点。
          *
    *         *
 *    *     *    *

 平衡二叉树：根据场景定义不严格，1. 左右两遍大体上看起来比较平衡，就是平衡二叉树。2. 或左右子树的高度（当前节点到叶子节点过经过的节点的数量）差不大于一。
           *
      *         *
   *     *          *
*

 二叉搜索树：左子树中节点的值都小于根节点的值，右子树中节点的值都大于根节点的值。Complex: O(log n) n是树中节点的数量， 最坏情况1->3->4->6->7->8排成一条链，像链表一样，它的complex退化为O(n)，为了避免这种最坏情况实际应用中通常会使用平衡二叉搜索树(AVL或红黑树)
             4
       2          6
    1     3    5     7

 平衡二叉搜索树：红黑二叉树（弱平衡）；AVL树（严格平衡）。 【数据结构具体实现以及像insert、remove等常规操作方法不在这里做演示，这里只是概念的普及。可以看B站的收藏。】

 红黑树二叉树：在二叉搜索树的基础上增加了颜色这一属性，并通过一组规则来约束树的结构，从而实现自平衡。Complex: O(log n)
 五条规则：
 1. 每个节点要么是红色，要么是黑色；2.根节点是黑色；3.所有叶子节点（这里指Nil）节点是黑色; 4.如果一个节点是红色，那么他的子节点是黑色；5. 从任意一个节点到其每个叶子的路径，都包含相同数量的黑色节点。
 这五条规则可以保持和近似平衡性（弱平衡），即衍生特性：从根节点到叶子节点的最长路径，不超过最短路径的两倍。

 AVL树：严格平衡（平衡因子：左子树高度 - 右子树高度，在AVL树中每个节点的平衡因子绝对值不能超过1，即范围为[-1, 0 1]。换句话说也就是任何节点的左右子树的高度差不大于1）的二叉搜索树，如果平衡因子[-1, 0 1]不在合理范围内就需要旋转操作来重新平衡了。Complex: O(log n)

 AVL vs 红黑树
 核心目标都是解决二叉搜索树可能退化为链表而导致complex=O(n）的问题，但它们在平衡的程度和使用场景上有所不同。
 AVL是一种严格平衡的二叉搜索树（任何节点的左右子树的高度差不大于1）这种严格的平衡特性在查找操作中非常高效，因为它始终维持较小的树高，然而，代价是在频繁地插入和删除中AVL可能需要更多的旋转来保持平衡，从而曾交了调整的开销。
 红黑树是一种弱平衡的二搜索树，不要求像AVL树那样严格的平衡，而是通过限制红色节点的分布，确保从根节点到任意叶子节点的最长路径不会超过最短路径的两倍，这种较宽松的平衡标准使得红黑树在插入和删除操作中旋转次数更少，性能更稳定。
 总结来说AVL适合查询密集的场景。红黑树更适合频繁插入和删除的场景。
 */

// 二叉树节点
class TreeNode {
    var val: Int
    var left: TreeNode?
    var right: TreeNode?
    init(val: Int) {
        self.val = val
    }
}

// 二叉树
class BinaryTree {
    let root: TreeNode?

    init(root: TreeNode?) {
        self.root = root
    }

    init() {
        self.root = nil
    }
}

// 二叉搜索树
class BinarySearchTree {
    var root: TreeNode?

    func insert(_ val: Int) {
        func insertRecursively(_ node: TreeNode?, _ val: Int) -> TreeNode {
            guard let node = node else { return TreeNode(val: val) } // 插入新节点

            if val < node.val {
                node.left = insertRecursively(node.left, val) // 插入左子树
            } else if val > node.val {
                node.right = insertRecursively(node.right, val) // 插入右子树
            }

            return node
        }

        root = insertRecursively(root, val)
    }

    func search(_ val: Int) -> Bool {
        func searchRecursively(_ node: TreeNode?, _ val: Int) -> Bool {
            guard let node = node else { return false } // 未找到

            guard node.val != val else { return true } // 找到

            if val < node.val {
                return searchRecursively(node.left, val) // 左子树中查找
            } else {
                return searchRecursively(node.right, val) // 右子树中查找
            }
        }

        return searchRecursively(root, val)
    }

    func delete(_ key: Int) {
        func findMin(_ node: TreeNode) -> TreeNode {
            var node = node
            while node.left != nil {
                node = node.left!
            }
            return node
        }

        /*
         情况1：val为叶子节点，直接让父节点不再指向它；
         情况2：val为只有一个子节点的节点，父节点直接指向该节点的子节点；
         情况3：val为有两个子节点的节点（要保持二叉搜索树的规则和结构）
            -  找到中序后继节点，用其值替换当前要删除节点的值，然后删除中序后继节点（它的值比当前要删除节点的值大，同时又比右子树中其它节点的值小。可以通过中序遍历来验证这一点。如果对一个二叉树进行中序遍历会得到从小到大排序的结果。例如：1 3 7 8 11 14 可以看到节点8是节点7的中序后继）。中序后继：右子树中最左边的节点（最小值）。
            - 也可以通过中序前序来替换要删除的节点，例如1 3 7 8 11 14，要删除7，也可以用3节点来替换。
         */
        @discardableResult
        func deleteNode(_ node: TreeNode?, _ key: Int) -> TreeNode? {
            guard let node = node else {  return nil }

            if key < node.val {
                node.left = deleteNode(node.left, key) // 删除左子树的节点
            } else if key > node.val {
                node.right = deleteNode(node.right, key) // 删除右子树的节点
            } else {
                // 找到要删除的节点
                if node.left == nil { // 只有右子树 或 叶子节点
                    return node.right
                } else if node.right == nil { // 只有左子树
                    return node.left
                } else { // case 3：有两个子节点
                    node.val = findMin(node.right!).val // 找到中序后继，替换值
                    node.right = deleteNode(node.right, node.val) // 删除中序后继
                }
            }

            return node
        }
        deleteNode(root, key)
    }

    func maxDepth() -> Int {
        func maxDepth(_ node: TreeNode?) -> Int {
          guard let node = node else { return 0 }

          return max(maxDepth(node.left), maxDepth(node.right)) + 1
        }
        return maxDepth(root)
    }

    func isValidBST() -> Bool {
        func _helper(_ node: TreeNode?, _ min: Int?, _ max: Int?) -> Bool {
          guard let node = node else {
            return true
          }
          // 所有右子节点都必须大于根节点
          if let min = min, node.val <= min {
            return false
          }
          // 所有左子节点都必须小于根节点
          if let max = max, node.val >= max {
            return false
          }

          return _helper(node.left, min, node.val) && _helper(node.right, node.val, max)
        }

        func isValidBST(_ root: TreeNode?) -> Bool {
          return _helper(root, nil, nil)
        }

        return isValidBST(root)
    }
}

final class TreeTests: XCTestCase {

    /*
     深入优先搜索：DFS(Depth-First-Search) 含义：深入到底，回溯再试。以下前、中、后序遍历都是深度优先搜索。
     DFS的实现用递归。（栈思想)
     递归调用：函数递归调用的过程本质上是由系统栈管理的，实际会把每次函数的调用用栈存储回溯。本质上是栈的思想。
     *     *
     *     *
     *     *
     *******
     */
    // 前序遍历（手动用栈实现）
    func getData() -> BinarySearchTree {
        let tree = BinarySearchTree()
        tree.insert(8)
        tree.insert(2)
        tree.insert(3)
        tree.insert(5)
        tree.insert(4)
        tree.insert(6)
        tree.insert(1)
        return tree
    }

    func testForBinarySearchTree() {
        /*
               8
          2       delete（7）
       1    3
              5
            4   6
         */
        let tree = getData()
        tree.insert(7)
        tree.delete(7)

        print("is BinarySearchTree contain 7: \(tree.search(7))")

        print("isValidBST: \(tree.isValidBST())")

        print("maxDepth: \(tree.maxDepth())")
    }

    func testpreOrderTraversal() {
        func preOrderTraversal(_ root: TreeNode?) -> [Int]? {
            guard let root = root else { return nil }
            var res = [Int](),  stack = [root]

            while !stack.isEmpty{
                let node = stack.removeLast()
                res.append(node.val)

                if let right = node.right {
                    stack.append(right)
                }

                if let left = node.left {
                    stack.append(left)
                }
            }
            return res
        }

        let result = preOrderTraversal(getData().root)
        print("preOrderTraversal: \(result!)")
    }

    func testTraversal() {
        /*
         递归实现，脑子例要有树的图和函数调用栈的图（函数压栈，最后一个入栈的先回溯去释放掉)去理解递归即可。【如果没有想象空间，画一下，或者回顾B站的视频】。
         遍历顺序：
           - 前序：根左右； 速记：跟在前
           - 中序：左根右   速记：跟在中
           - 后序：左右根   速记：跟在后

         中序遍历（递归实现）如果当前TreeNode为二叉搜索树，则可以用中序遍历去打印出当前值，为升序。同时删除二叉搜索树节点也需要中序思想
         （需要找到中序后继。详情看以上deleteNode方法注释描述）。
         */
        func preorderTraversal(_ root: TreeNode?) -> [Int] {
            guard let root = root else { return [] }
            return [root.val] + preorderTraversal(root.left) + preorderTraversal(root.right)
        }
        func inorderTraversal(_ root: TreeNode?) -> [Int] {
            guard let root = root else { return [] }
            return inorderTraversal(root.left) + [root.val] + inorderTraversal(root.right)
        }
        func postorderTraversal(_ root: TreeNode?) -> [Int] {
            guard let root = root else { return [] }
            return postorderTraversal(root.left) + postorderTraversal(root.right) + [root.val]
        }

        let preorderTraversal = preorderTraversal(getData().root)
        let inorderTraversal = inorderTraversal(getData().root)
        let postorderTraversal = postorderTraversal(getData().root)

        print("preorderTraversal: \(preorderTraversal)")
        print("inorderTraversal: \(inorderTraversal)")
        print("postorderTraversal: \(postorderTraversal)")
    }

    func testlevelOrder() {
        /*
         广度优先搜索：BFS(Breadth-First-Search) 含义：广度优先，逐层扩展。按层级依次遍历（图或树）数据结构，先访问所有相邻节点，在逐层向外扩展。
         BFS的实现用循环（配合队列）。
         */
        // 层级遍历（BFS的实现用循环（配合队列））
        func levelOrder(_ root: TreeNode?) -> [[Int]] {
            var res = [[Int]](), queue = [TreeNode]()
            if let root = root { queue.append(root) }

            while queue.count > 0 {
                var level = [Int]()
                let size = queue.count

                for _ in 0 ..< size {
                    let node = queue.removeFirst()

                    level.append(node.val)

                    if let left = node.left {
                        queue.append(left)
                    }

                    if let right = node.right {
                        queue.append(right)
                    }
                }
                res.append(level)
            }
            return res
        }

        let levelOrder = levelOrder(getData().root)

        print("levelOrder: \(levelOrder)")
    }

}

