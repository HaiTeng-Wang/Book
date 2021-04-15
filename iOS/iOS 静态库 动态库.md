# iOS 静态库 动态库

参考：

> - [Overview of Dynamic Libraries][developer.apple]
> - [Library? Static? Dynamic? Or Framework? Project inside another project][stackoverflow]
> - [iOS 静态库，动态库与 Framework][iOS 静态库，动态库与 Framework]
> - [iOS里的动态库和静态库][iOS里的动态库和静态库]

库是共享程序代码的方式。
库从本质上来说是一种可执行代码的二进制格式，可以被载入内存中执行。
库分静态库和动态库两种。

在探索之前，先大致了解程序下编译过程

![编译过程](/assets/编译过程_84o3740we.png)

### 静态库

iOS中的静态库有 .a 和 .framework两种形式；

**链接时**完整地将目标文件.o拷贝至可执行文件中，被多次使用就有多份冗余拷贝。

![staticLibraries.png]

### 动态库

iOS中的动态库有.dylib 和 .framework 形式，后来.dylib动态库又被苹果替换成.tbd的形式。

链接时不复制，目标程序中只会存储指向动态库的引用。程序运行时由系统动态加载到内存，供程序调用，系统只加载一次，多个程序共用，节省内存。

![dynamicLibraries.png]

![动态库&静态库](/assets/动态库&静态库.png)

#### 提示：

- Framework: 实际上是一种打包方式，将库的二进制文件、头文件和有关资源打包到一起，方便管理和分发。

- 出于安全性原因，iOS暂时只允许使用系统动态库（Eg：UIKit）。自己生成的动态库不是真正意义的动态库，最后也还是要拷贝到目标程序中，会被放到ipa下的Framework目录下，基于沙盒运行。苹果把这种Framework称为Embedded Framework。

  例如：不同app都使用了AFNetWorking的动态库，并不只会在系统中存在一份，而是会在多个App中各自打包、签名、加载一份。

---
### 静态库与动态库体积对比

![](https://gitee.com/Ccfax/HunterPrivateImages/raw/master/AFN静态库示例图.png)

![](https://gitee.com/Ccfax/HunterPrivateImages/raw/master/AFN动态库示例图.png)

单纯的体积对比，静态库体积要比动态库大。静态库是`.o`文件的集合，每个文件都包含`Mach header，segment, section`因此会产生冗余。

但是，使用静态库，可以设置连接器的链接参数(`-force_load`) ，只链接主程序使用到的库的相关文件，这样在链接优化后，静态库的体积比动态库小，因而使用静态库可减少ipa体积。

所以，一些公司选择进行进行组件化开发，一方面因为库是已经编译好的二进制了，可以减少编译的时间，主程序只需Link一下。另一方面，如果是纯OC代码的工程，使用静态库，可减少ipa体积。

[developer.apple]: https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/DynamicLibraries/100-Articles/OverviewOfDynamicLibraries.html
[stackoverflow]: https://stackoverflow.com/questions/15331056/library-static-dynamic-or-framework-project-inside-another-project
[iOS 静态库，动态库与 Framework]: https://segmentfault.com/a/1190000004920754
[iOS里的动态库和静态库]: https://www.zybuluo.com/qidiandasheng/note/603907
[dynamicLibraries.png]: https://gitee.com/Ccfax/HunterPrivateImages/raw/master/dynamicLibraries.png
[staticLibraries.png]: https://gitee.com/Ccfax/HunterPrivateImages/raw/master/staticLibraries.png
