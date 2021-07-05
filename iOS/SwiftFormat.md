# SwiftFormat

官方文档和Rules先过一眼

 - https://github.com/nicklockwood/SwiftFormat#config-file
 - https://github.com/nicklockwood/SwiftFormat/blob/master/Rules.md

其它参考的博客：
 - http://ibloodline.com/articles/2017/12/25/swift-format.html 
 - https://juejin.cn/post/6911705237266890759
 - https://zhuanlan.zhihu.com/p/350836005

---

[How do I install it?](https://github.com/nicklockwood/SwiftFormat#how-do-i-install-it)

项目中的使用 ( 第三种方式)

> As a build phase in your Xcode project, so that it runs every time you press Cmd-R or Cmd-B, or

步骤:
 - 1. 安装：项目中使用pod管理依赖，所以使用的是[pod的方式安装](https://github.com/nicklockwood/SwiftFormat#using-cocoapods)

 - 2. 配置：先看文档中[配置相关描述](https://github.com/nicklockwood/SwiftFormat#configuration)，然后根据[Rules文档](https://github.com/nicklockwood/SwiftFormat/blob/master/Rules.md)去编写.swiftformat文件。

 - 3. 如果如上两个步骤已经没问题，此时，可以自己随便写写代码测试下。
   
   例如： 
   build之前是代码是这样的
   ```swift
       func test() {
        if true {
            //
            
    }
    }
   ```

   swiftFormat会在build时去格式化代码，所以build之后可能会变成这样（根据.swiftformat配置文件自定义的规则去格式化代码）
   ```swift
       func test() {
        if true {
            //
        }
    }
   ```
格式化规则需要自己在.swiftformat文件中定义。项目中的.swiftformat文件定义如下:
```
# format options
--swiftversion 5.0
--allman false
--semicolons inline
--commas inline
--binarygrouping ignore
--decimalgrouping ignore
--elseposition same-line
--empty void
--exponentcase lowercase
--exponentgrouping disabled
--fractiongrouping disabled
--header ignore
--hexgrouping ignore
--hexliteralcase uppercase
--importgrouping testable-bottom
--linebreaks lf
--maxwidth none
--octalgrouping ignore
--operatorfunc spaced
--patternlet inline
--ranges spaced
--wraparguments after-first
--wrapcollections preserve
--modifierorder public,override
--wrapparameters after-first
--self init-only
--indent 4
--ifdef indent
--indentcase false
--trimwhitespace always

# file options
--exclude Pods
--exclude SBIUSStock/Service/Apollo/API
--exclude SBIUSStock/Service/Apollo/GraphqlFiles
--exclude SBIUSStock/Service/Apollo/BffFiles

# rules
--disable redundantType
--disable isEmpty
--disable wrapMultilineStatementBraces
--disable redundantPattern
--disable unusedArguments
--disable strongifiedSelf
--disable redundantSelf
--disable enumNamespaces
--disable initCoderUnavailable
--enable blankLinesAroundMark
--enable blankLinesAtEndOfScope
--enable blankLinesAtStartOfScope
--enable blankLinesBetweenScopes
--disable sortedImports
--disable consecutiveSpaces
--disable redundantBackticks
```