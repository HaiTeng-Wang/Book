# iOS 静态库 动态库

参考：

> - [Overview of Dynamic Libraries][developer.apple]
> - [Library? Static? Dynamic? Or Framework? Project inside another project
][stackoverflow]
> - [iOS 静态库，动态库与 Framework][iOS 静态库，动态库与 Framework]
> - [iOS里的动态库和静态库][iOS里的动态库和静态库]
> - [WWDC2014之iOS使用动态库][WWDC2014之iOS使用动态库]

库是共享程序代码的方式。

库从本质上来说是一种可执行代码的二进制格式，可以被载入内存中执行。库分静态库和动态库两种。

## 静态库

iOS中的静态库有 .a 和 .framework两种形式；

链接时完整地拷贝至可执行文件中，被多次使用就有多份冗余拷贝。

![staticLibraries.png]

## 动态库

iOS中的动态库有.dylib 和 .framework 形式，后来.dylib动态库又被苹果替换成.tbd的形式。

iOS暂时只允许使用系统动态库。

链接时不复制，程序运行时由系统动态加载到内存，供程序调用，系统只加载一次，多个程序共用，节省内存。

![dynamicLibraries.png]

---

[developer.apple]: https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/DynamicLibraries/100-Articles/OverviewOfDynamicLibraries.html
[stackoverflow]: https://stackoverflow.com/questions/15331056/library-static-dynamic-or-framework-project-inside-another-project
[iOS 静态库，动态库与 Framework]: https://segmentfault.com/a/1190000004920754
[iOS里的动态库和静态库]: https://www.zybuluo.com/qidiandasheng/note/603907
[WWDC2014之iOS使用动态库]: http://foggry.com/blog/2014/06/12/wwdc2014zhi-iosshi-yong-dong-tai-ku/
[dynamicLibraries.png]: https://gitee.com/Ccfax/HunterPrivateImages/raw/master/dynamicLibraries.png
[staticLibraries.png]: https://gitee.com/Ccfax/HunterPrivateImages/raw/master/staticLibraries.png
