[SDWebImage](https://github.com/rs/SDWebImage)
![](https://raw.githubusercontent.com/rs/SDWebImage/master/Docs/SDWebImageSequenceDiagram.png)

[快速回顾Runtime](https://gitee.com/Ccfax/HunterPrivateImages/blob/master/Runtime.md)

[动画](http://blog.csdn.net/yixiangboy/article/details/47016829)

[绘制基本图形]()

[加密]()


---

代码重构，组件化开发。
为什么重构？
遵循什么原则进行？制定哪些规范？怎么进行的？
重构结果？

过程：
删-整理-内聚-抽离（组件化）

分层：
入口-
全局共享块（PCH，header.h，宏文件，分类categry如色值、字号、tableViewIdenty、Keys、等，Model层，公共控件如弹窗、空缺页面、成功提示页面）-
业务代码-
数据模块（规范Model）-
编写页面导航Router-
管理类
（为什么要组件化（意义）？什么是组件化？怎么组件化（方案）？结果）


Swift相关（优缺点）
Swift与OC混编
遇到什么坑
注意事项
升级X8后，遇到的坑
Swift3.0、4.0带来哪些改变

留声机HT相关

内存相关
多线程
runtime
runloop
webView WKWebView JS交互
sdwebimage解读
性能优化，tableView卡顿
AVFoundation框架
数据持久化
动画相关
UI绘制
coacoapod相关
加密
