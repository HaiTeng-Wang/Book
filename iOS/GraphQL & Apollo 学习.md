
# GraphQL & Apollo 学习

整个学习时间大概需要2-3天。

学习流程和参考资料如下：

查看[GraphQL官方文档](https://graphql.cn/learn/)去理解API查询语言GraphQL，是什么？为什么？怎么办？（需要3-5个小时读完）

是什么？

> GraphQL 是一个用于 API 的查询语言，是一个使用基于类型系统来执行查询的服务端运行时（类型系统由你的数据定义）。GraphQL 并没有和任何特定数据库或者存储引擎绑定，而是依靠你现有的代码和数据支撑。一个 GraphQL 服务是通过定义类型和类型上的字段来创建的，然后给每个类型上的每个字段提供解析函数。

为什么?

> 接口的返回值，可以通过GraphQL，从静态变为动态，即调用者来声明接口返回什么数据。一旦一个 GraphQL 服务运行起来（通常在 web 服务的一个 URL 上），它就能接收 GraphQL 查询，并验证和执行。接收到的查询首先会被检查确保它只引用了已定义的类型和字段，然后运行指定的解析函数来生成结果。

怎么办？

> 在iOS中通过Apollo使用GraphQL
 - 预先定义一张Schema和声明一些Type来
   - 对于数据模型的抽象是通过Type来描述的
   - 对于接口获取数据的逻辑是通过Schema来描述的

如果仍然晦涩没懂，再看看[30分钟理解GraphQL核心概念](https://segmentfault.com/a/1190000014131950)，（30分钟）

同时配合这篇文章去[入门 GraphQL & Apollo](https://www.bookstack.cn/read/nixzhu-dev-blog/2017-06-01-GraphQL-Apollo.md)。（跟着作者的思路去手动实现，需要2-3个小时。会遇到Swift版本兼容的坑，NodeJS版本兼容的坑）

最后，过一遍[APOLLO的官方文档](https://www.apollographql.com/docs/ios/)。（需要3-5个小时）