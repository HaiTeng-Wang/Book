# 面经

## Fidelity

****常用技术基本都会问，以下这些必看****

### OC

- UIKit
  - UIView异形绘制，点击事件
  - 动画（eg：怎么实现一个连续的动画、等...）
  - 绘制的部分也会问，UIView异形绘制
  - imageWithName 和imageWithFilePath 区别

- layout
  - 如何让UIButton 和 UILabel的最后一行对齐
  - UIView包含大量UIButton是通过约束放在一起的，如何快速获取UIView的最小尺寸

 - category 和 extension

 - 多线程（好好看看这部分）
  - GCD问的比较多
  - 锁也会问

 - Block(Block能否改变int值)

 - Runtime（当时没问我，但是也得看看）

 - Runloop（当时也没问我，可以看看）

 - 性能优化
   - 如何优化UITableView

 - 设计模式
   - 观察者模式
   - 外观模式

- Debug
  - 如何指定循环次数
  - 如何快速定位到哪个方法将UIView置为nil
  - LLDB时时更新页面
  - 断点for循环10次，怎么让断点从第五次之后开始

### 算法
- 什么叫快排
- 什么叫红黑二叉树
- 排序算法

### Swift
- Codable 协议
- ！& ？区别
- 什么是逃逸闭包
- lazy

## 渣打

流程：先英文介绍，然后英文问两个问题，然后问技术，最后coding算法(问过二叉树基础)。 30多分钟，一个面试官。

官方招聘网站
  - UserName: llllhaiteng@gmail.com
  - Password: Hunter504!

### 问题：
- Swift
- SwiftUI
- Combine（项目里全是）
- 后期应该会用RN，会Web是加分项
- 细节也会问，多看细节，比如：UIKit-SwiftUI跳转，跳转参数；SwiftUI布局等，需要好好准备下。
- 结合笔试题
- 项目难点等

### 凯捷(外派渣打)

1.iOS的相关开发经验  swift基础（问的比较详细，例如结构体和类的区别等) 以及新的swift知识.  
2.swift-UI的相关开发经验.  
3.OC的基础知识,OC和Swift两者的区别.  
4.架构能力（框架，设计模式，编码准则）以及数据结构（过往的项目有否接触）.  
5.inout关键字，安全方面（私隐权限关键字）等 （相关安全性问题）.  
6. 考察技术深度. 

特别要留意较为基础的问题（1-3点），问的比较详细需要好好梳理一下过往项目以及技术哈
1.  OC swift区别， 
2. swift enum原始值关联值区别，
3. struct和class区别，
4. swift dic 存储在哪？为什么.
    - Swift 中的 Dictionary 是值类型, 写时复制优化，Copy-on-Write
    - 在 Swift 中，Dictionary（字典）是存储在堆（Heap）上的，而不是栈（Stack）。但它的引用（或指针）可能存储在栈上（如果是局部变量）。
    - Why? 
      - 动态大小：Dictionary 的大小可以动态增长或缩小，而栈内存是固定大小的，不适合存储可变大小的数据结构。
      - 生命周期管理：栈上的数据在函数返回时自动释放，而 Dictionary 可能需要更长的生命周期（比如被多个变量引用）
      - 可以打印内存地址，以0X7开头，高内存地址。`withUnsafePointer(to: &dict) { print("栈上的指针地址: \($0)") }`
    - 字典作为属性呢？
      - 1.Dictionary 作为 struct 的属性
        - struct 本身是值类型，默认存储在栈上（如果是局部变量）或堆上（如果是 class 的属性）。
        - 但 Dictionary 的数据仍然在堆上，struct 只存储它的引用（指针）。
        - 赋值时会发生值复制（Copy-on-Write），但堆数据只有在修改时才真正复制。
        ```swift
          struct MyStruct {
            var dict: [Int: String]  // `dict` 的引用在 `struct` 的内存里，数据在堆上
          }

          var s1 = MyStruct(dict: [1: "A", 2: "B"])
          var s2 = s1  // `s2` 复制 `s1`，但字典数据暂未复制（共享堆数据）

          s2.dict[3] = "C"  // 修改时才真正复制堆数据（Copy-on-Write） struc被copy // s1 仍为 [1: "A", 2: "B"] 
        ```
      - 2.Dictionary 作为 class 的属性
        - class 是引用类型，整个对象存储在堆上。
        - Dictionary 的数据也在堆上，class 存储它的引用（指针）。
        - 赋值时不会复制字典，只是共享引用(因为随着class走，class没被copy)。
        ```swift
          class MyClass {
          var dict: [Int: String]  // `dict` 的引用在 `class` 的堆内存里，数据也在堆上
          }
          let c1 = MyClass()
          c1.dict = [1: "A", 2: "B"]
          let c2 = c1  // `c2` 和 `c1` 指向同一个对象，字典数据不复制

          c2.dict[3] = "C"  // 修改的是同一个字典
          print(c1.dict)    // [1: "A", 2: "B", 3: "C"]（`c1` 和 `c2` 共享字典）
        ```
5. strutc初始化和calss初默认初始化方法，始化为什么struc中let不用写初始值，
    - struct会默认生成逐一成员访问器，在初始化器中会保证未写let的属性有初始值。
6. cocurrence（5.5出现的swift并发, 2021年9月发布, 支持iOS 15+）如何在VC中调用Task，
    - 可以直接调用，因为Task实际上是一个`struct Task<Success, Failure> where Success : Sendable, Failure : Error` 类型，其通过尾随闭包进行初始化，闭包是异步单元，执行异步代码。同时，即使对一个Task保持强引用，在闭包内也不对若引用self, 任务完成self是released。ref: https://developer.apple.com/documentation/swift/task
7. swift 如何在协议中给一个方法设置默认值 func test(aa: String, bb: String = "")
   - 协议本身不能包含带默认值的方法参数，但实现的时候，可以提供默认值参数。
8. coedable model的属性，比json多，或者json的属性比model多，会crash吗？
    - 默认情况下不会 Crash，但具体行为取决于如何处理多余或缺失的字段。
      - 1. Model 属性比 JSON 多（JSON 缺少某些字段）
        - 如果 JSON 缺少某个字段，且该字段是非可选类型（如 Int、String）或没有默认值，解码会失败（throw error），但不会 Crash。 
      - 2. JSON 属性比 Model 多（JSON 有多余字段）
        - 默认情况：Codable 会忽略多余的字段，不会 Crash，也不会报错。
        - 原因：Swift 的 JSONDecoder 默认只解析 Model 中定义的属性，多余的字段会被丢弃。
    - 什么情况下会 Crash？
      - 强制解包（!）
      - 错误的 JSON 格式（如非键值对）, 解析会抛出 DecodingError.dataCorrupted
      - 类型不匹配（如 JSON 是 String，但 Model 是 Int）, 会抛出 DecodingError.typeMismatch

9. 组件化做过吗，podsec中，下载一个zip包，包里有三个framework，如何只下载两个。同时也问到SPM，如何做。
    - 方法 1：使用 vendored_frameworks 选择性导入
      ```
        # 假设 ZIP 包的下载地址
        s.source           = { :http => 'https://example.com/sdk/frameworks.zip' }

        # 只选择需要的 2 个 Framework，忽略第 3 个
        s.vendored_frameworks = [
          'Frameworks/FrameworkA.framework',
          'Frameworks/FrameworkB.framework'
          # 不包含 FrameworkC.framework
        ]
      ```
    - 方法 2：使用 script_phase 删除不需要的 Framework（更动态性，可通过脚本进行些选择性判断，例如配合环境变量去进行判断) 
      ```
          s.source           = { :http => 'https://example.com/sdk/frameworks.zip' }

        # 先包含所有 Framework（确保解压）
        s.vendored_frameworks = 'Frameworks/*.framework'

        # 安装后脚本：删除 FrameworkC.framework
        s.script_phases = [
          {
            :name => 'Remove Unwanted Framework',
            :script => 'rm -rf "${PODS_ROOT}/YourPod/Frameworks/FrameworkC.framework"',
            :execution_position => :after_install
          }
        ]
      ```
10. `s.source`: `s.source` 都能指定哪些？指定 `https//...zip`包和`git`地址的方式什么区别?
    1. s.source 支持的来源类型: 
        - 常见，Git 地址、本地路径、ZIP 包、
    2. ZIP 包 vs. Git 地址的区别
        - zip方式，pod直接下载已编译的二进制文件（如 .framework/.xcframework），并自动解压, Xcode Build 阶段：直接链接已存在的二进制文件，跳过编译步骤。
        - git方式，podinstall时通过podspec中指定的source_file下载源代码
    3. 题外追问:  
      - 如何在 ZIP 包形式下包含源码和frameworks？
        - 步骤 1: 将 源码 和 二进制文件 一起打包到 ZIP 中
        - 步骤 2: Podspec同时声明源码s.source_files和二进制s.vendored_frameworks，将源码和二进制文件 一起打包到 ZIP 中
          ```ruby
          Pod::Spec.new do |s|
            s.name = 'MySDK'
            s.version = '1.0.0'
            s.source = { 
              :http => "https://example.com/MySDK.zip",
              :sha256 => "a1b2c3..."
            }

            # 关键点：同时声明二进制和源码
            s.vendored_frameworks = 'Frameworks/MySDK.framework'  # 二进制
            s.source_files = 'Sources/MySDK/**/*.{h,m,swift}'     # 源码

            # 可选：如果源码需要特殊头文件路径
            s.public_header_files = 'Sources/MySDK/include/*.h'
          end
          ```
    - Pod（拓展）环境变量
      1. shell环境变量, eg: [ "$ENABLE_ADS" == "NO" ]。
          - 特点
              - 作用域：Shell 脚本中的环境变量（在 Podspec 的 script_phases 中使用）。
              - 适用场景：在 CocoaPods 的 安装后脚本（如删除文件、修改配置）中做条件判断。
              - 生命周期：仅在 Pod 的脚本阶段执行时有效。
              - 变量传递方式:	可持久化在 Xcode 项目中(设置Build Settings中User-Defined，其变量会影响Build 阶段和 Shell 脚本), 可以通过终端进行覆盖.eg: ENABLE_ADS=NO pod install
          - 流程说明：在项目的 Build Settings 中可预定义shell环境变量，pod 命令的时候，例如pod install会自动读取 Xcode 传递的变量，我们也可以手动临时覆盖变量值 eg: ENABLE_ADS=NO pod install，所以可用此环境变量值在podfile以及podspec中script_phases做判断，常用于after_install执行。关于验证我们可以在script_phases中echo打印变量值。
          - 例子
            ```ruby
            Pod::Spec.new do |s|
                s.script_phases = [
                  {
                    :name => 'Remove Ads',
                    :script => <<-SCRIPT 
                      if [ "$ENABLE_ADS" == "NO" ]; then
                        rm -rf "${PODS_ROOT}/AdFramework.framework" // shell语法通过$读取环境变量
                      fi
                    SCRIPT,
                    :execution_position => :after_install // :execution_position => :after_install 是一个可选参数，用于控制脚本的执行时机。 脚本会在 pod install 或 pod update 完成时执行（早于 Pods.xcodeproj 生成）。 不写 :execution_position, 脚本默认会在 Pods.xcodeproj 生成之后、Xcode 构建之前 执行（相当于隐式 :before_compile）。
                  }
                ]
              end
            ```
      2. Ruby环境变量，eg: ENV['USE_LOCAL'] (CocoaPods是用Ruby构建的)  
          特点:
            - 作用域：Ruby 进程内部的环境变量（在 Podspec/Podfile 的 Ruby 代码）。
            - 适用场景：在 Podspec 文件（.podspec）中动态配置依赖源或条件逻辑。
            - 生命周期：仅在 pod install 或 pod update 执行期间有效。
            - 变量传递方式:	通过终端临时设置（USE_LOCAL=1) 每次需显式传递.
            - eg: 通过"环境变量"动态指定来源，来达到source_url控制
              ```ruby
              source_url = ENV['USE_LOCAL'] ? { :path => "../local" } : { :git => "https://github.com/lib.git" } // ENV 是 Ruby 的语法
              s.source = source_url
              ```
            - eg: 通过环"境变量"、”source_config“, 动态切换源码/二进制
              ```ruby
              source_config = ENV['USE_SOURCE'] ? { 
              :git => 'https://github.com/your/MySDK.git', 
              :tag => '1.0.0' 
              } : { 
                :http => 'https://example.com/MySDK.zip' 
              }

              Pod::Spec.new do |s|
                s.source = source_config
                if ENV['USE_SOURCE']
                  s.source_files = 'Sources/**/*.swift'  # 源码模式
                else
                  s.vendored_frameworks = 'Frameworks/MySDK.framework'  # 二进制模式
                end
              end
              # 使用方式：
              # 使用二进制集成（默认）pod install
              # 使用源码集成 USE_SOURCE=1 pod install
              ```
    - Pod（拓展）预编译依赖项: binary => true  
      - 将依赖库预编译为 framework，避免开发时重复编译，加快编译速度。
      - 支持缓存，pod install 时会复用。如需切换为源码，设置 binary: false 后重新 pod install 即可。
      - 原理：在 pre install 钩子中生成 framework，保存到 Pod/_Prebuild/ 目录。
        - https://guides.cocoapods.org.cn/plugins/pre-compiling-dependencies.html
    - Pod（拓展）Podfile中，假如有依赖A，依赖B，A B 都依赖C，那最终工程中使用的是C的哪个版本？
      - 最终使用的 C 版本由 依赖解析算法 决定，具体规则：
        - 1、CocoaPods 会选择 同时满足 A 和 B 对 C 的版本要求 的最高兼容版本。
            - eg: A 依赖 C ~> 1.2.0（即 >= 1.2.0 且 < 2.0.0）。B 依赖 C ~> 1.3.0（即 >= 1.3.0 且 < 2.0.0）。最终会选择 C 1.3.0（最高兼容版本）。  
            - 验证方式：pod install --verbose 输出日志中会显示版本解析过程。
        - 2、如果 A 和 B 对 C 的版本要求无法同时满足（如 A 需要 C 2.x，B 需要 C 1.x）pod install 会报错：
          ```ruby
          [!] CocoaPods could not find compatible versions for pod "C":
            In Podfile:
              A (requires C >= 2.0.0)
              B (requires C < 2.0.0)
          ```
        - 3、如果自动解析不符合预期，可以在 Podfile 中显式指定 C 的版本，覆盖 A 和 B 的依赖声明。eg: `pod 'C', '1.5.0' # 强制使用 1.5.0`
      - 最佳实践: 
        - 1、尽量不强制指定版本，除非必要，否则让 CocoaPods 自动解析，避免破坏依赖关系。
        - 2、定期更新依赖：使用 pod outdated 检查可更新的库，然后运行 pod update A B C。
        - 3、处理冲突：如果版本冲突，尝试：联系库维护者调整依赖范围，更新 A/B 到兼容 C 的新版本。

11. WKWeb View中 原生怎么和Js交互，（这块注意，如果现在项目用的多，可能会问）
  - TODO..

## HSBC:
Access Code: H*JzL0h=

官方招聘王炸
  - Username: 15340525 | HaitengWang
  - Password: Hunter504!

### 面试
- Redux

## 乐天：
AI岗位4-5轮面试
1. 首先：笔试题 20 + coding 2
2. 其次：2-3轮算法，页面简单测试下英文难（自我介绍，最近看什么书，介绍项目等）
3. 然后：项目主管，最后HR

