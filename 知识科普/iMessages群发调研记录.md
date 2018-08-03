# iMessages群发，调研记录

“iMessages群发”行业术语管这个叫“苹果推信”。

说白了就是给一群使用苹果设备的人群发信息。

### iMessage是什么？

苹果官方说明：[关于 iMessage 和短信/彩信][关于 iMessage 和短信/彩信]

> iMessage 是指您通过 Wi-Fi 或蜂窝移动数据网络发送至 iOS 设备和 Mac 的文本、照片或视频。这些信息通过 Apple 而非运营商发送，并且会加密出现在蓝色文本气泡中。要打开或关闭 iMessage，请前往“设置”>“信息”。

iMessage是苹果设备（iPad、iPhone、iPod touch）自带的免费信息发送应用。它的信息通过网络发送，不同于运营商短信。

### 怎样实现iMessage群发?

苹果官方教程：[在 iPhone、iPad 或 iPod touch 上发送群组信息][在 iPhone、iPad 或 iPod touch 上发送群组信息]

当然了，你看完教程肯定会骂我。我猜这并不是你想看到的内容，你想要完成公司运营的推广，给很多很多很多人发送iMessage，群发垃圾信息对吗？

[这里][怎样实现iMessage群发]有篇文章可供参考。

我并未深入进行尝试，也没有实现大批量群发。只是通过AppleScript脚本控制iMessage客户端发送给少量人。
#### 发送iMessage的AppleScript代码
将电话号以`.csv`文件的格式存储，通过脚本进行读取发送。
```javasCript
tell application "Messages"
	set csvData to read "/Users/xxx/Desktop/test.csv"
	set csvEntries to paragraphs of csvData
	repeat with i from 1 to count csvEntries
		set phone to (csvEntries's item i)'s text
		set myid to get id of first service
		set theBuddy to buddy phone of service id myid
		send "今天北京晴，气温13到27度；周二晴，气温11到26度，北风3-4级；周三晴，气温11到24度，微风<3" to theBuddy
	end repeat
end tell
```

AppleScrip:

AppleScript是一种构建与OSX的脚本语言。它的主要工作是自动执行那些重复而耗时的任务

如果从来未接触过AppleScript，可先查看下[百度文库AppleScript入门绍介][百度文库AppleScript入门绍介]。也可直接查看[Apple官方文档][Apple官方文档]。

[CSV文件][百度百科CSV文件]:
> CSV文件由任意数目的记录组成，记录间以某种换行符分隔；


##### 注意：

群发前要检查该号码是否为iMessage账号；

大批量群发小心苹果封杀设备。

---
### 记录两段AppleScript代码

#### 1. 狂发iMessage的AppleScript代码（娱乐可以，自觉不要进行恶意攻击）
```javasCript
tell application "Messages"

set myid to get id of first service
set theBuddy to buddy "电话号码/iM邮箱" of service id myid

repeat 1000 times       #1000是指次数，自定吧
send "iM内容" to theBuddy
end repeat

end tell
```

##### Script Editor示例截图:
![Messages轰炸截图.png]


#### 2. 发送邮件的AppleScript代码
```javasCript
--Variables（变量）
set recipientName to "姓名"
set recipientAddress to "邮件地址"
set theSubject to "主题"
set theContent to "内容"
--Mail的Tell代码块
tell application "Mail"
	--创建邮件
	set theMessage to make new outgoing message with properties {subject:theSubject, content:theContent}
	--设置接受者
	tell theMessage
		make new to recipient with properties {name:recipientName, address:recipientAddress}
		--发送邮件
		send
	end tell
end tell
```



[关于 iMessage 和短信/彩信]: https://support.apple.com/zh-cn/HT207006
[在 iPhone、iPad 或 iPod touch 上发送群组信息]: https://support.apple.com/zh-cn/HT202724
[百度文库AppleScript入门绍介]:https://wenku.baidu.com/view/12c6bc25192e45361066f5ec.html
[Apple官方文档]: https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptX/AppleScriptX.html
[怎样实现iMessage群发]: https://blog.csdn.net/templar1000/article/details/12995213
[Messages轰炸截图.png]:https://gitee.com/Ccfax/HunterPrivateImages/raw/master/Messages轰炸截图.png
[百度百科CSV文件]: https://baike.baidu.com/item/CSV/10739
