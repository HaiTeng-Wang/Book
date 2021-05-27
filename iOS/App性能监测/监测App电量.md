# App电量监测

参考:
> [iOS-Performance-Optimization](https://github.com/skyming/iOS-Performance-Optimization)

手机->Settings->Battery，**查看过去24小时或7天内手机内App耗电排行榜**，同时也能看每个App这这个时间多使用了多长时间。

##### Xcode->Debug Navgation -> Energy impact，监测App平均能源影响

**Average component utilization**

![](https://gitee.com/Ccfax/HunterPrivateImages/raw/master/Energy%20Impact.png)

Google翻译

---

**Overhead:** 因为你的应用程序需要执行无线电和其他系统资源的工作，所以要有一些能源开销。

---

**High CPU Utilization(高CPU利用率):** CPU使用率大于20%。高CPU利用率会迅速耗尽设备的电池。在不影响用户输入的情况下，总是尽可能快地使用CPU并尽快回到空闲状态。

---

**Network Activity(网络活动):** 发生网络活动以响应您的应用程序。网络带来无线电，需要长时间的电力。

---

**Location Activity(定位):** 您的应用执行的位置活动。更精确和频繁的位置使用更多的能量。请求位置并且只有在真正需要时。

---

**High GPU Utilization(高GPU利用率):** 您的应用程序请求的图形活动。多余的图形和动画会降低响应能力，并将系统资源从低功耗状态中提取出来，或阻止它们一起断电，从而导致大量的能源使用。仅更新可见内容，减少不透明度的使用，并且在执行动画时更喜欢较低的一致帧频。

---

**Backfround state (后台状态):** 你的应用程序处于后台状态，保持系统清醒。 App即使在后台也耗用电量。如果您的应用需要在后台做一些操作，请使用延迟API，以便系统有效地调度工作，并在必要时唤醒以运行您的应用。 否则，放置在后台时立即减少活动，并在活动完成后通知系统。

---

**Foreground state (前台状态):** 应用处于前台状态，使用推荐的API，批量和减少网络操作，并避免对用户界面进行不必要的更新。尽量使您的应用程序在不响应用户输入时绝对闲置。

---

**suspended state (暂停状态):** 系统暂停了您的应用。您的应用程序发起的进程外活动（如位置更新）可能仍会消耗能量。
