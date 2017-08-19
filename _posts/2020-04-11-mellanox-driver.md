---
title: Mellanox ConnectX-2 VPI Linux 内核驱动
date: 2020-04-11
layout: post
cover_url: /assets/images/MHQH29B-XSR.jpg
---

在淘宝上买了两个 Mellanox 的双口 40Gbps 网卡。型号是 MHQH29B-XSR。拿到手以后换上长挡板，装到电脑上，才发现是 PCIe GEN2.0 的。不过反正我的 R510 也只有 2.0 支持，所以反而不用担心是 3.0 的卡然后不兼容 2.0 连接（？）。

这个型号的卡在 Mellanox 那里被叫做“VPI”卡。Mellanox 生产三种不同的网卡：以太网卡，InfiniBand 网卡，还有 VPI 卡。VPI 卡，就是可以切换 Infiniband 模式和 Ethernet 模式的网卡。ConnectX-2 这个系列，据我所知，是早在 2009 年开始出售的老古董。所以 Mellanox 官网上的驱动支持在几年前（？）已经停止了。最后发布的工具软件只支持到 Ubuntu 16.10 版本。据 reddit 上的帖子[^1]，你可以忽略警告强行安装官网上的驱动包，然后重启以后就不能用了，必须要重新安装一遍[^2]。至于为什么要装这个驱动，就是因为 VPI 卡可以切换 Ethernet 和 Infiniband 模式，选择哪种是软件管理的。然后默认状态下是 InfiniBand，就必须要用官网驱动包里的工具来修改卡具体的功能。

有人可能会说[^3]，用 InfiniBand 然后用 IPoIB，也可以达到和以太网差不多的效果啊？但是我希望把这个用作主要的网络连接，我的电脑上有很多虚拟机（实际上我基本上都在虚拟机里），我希望把虚拟机通过虚拟交换机连接到我家的路由器上，和宿主机共用同一套 DHCP，DNS 服务，还有 Bonjour 和 NetBIOS 啥的。如果只有一个不透明的 IP，这些应用是跑不起来的。我们需要真正的以太网连接才行。

我在网上搜索了一圈，发现有一种叫 EoIB 的说法，Ethernet on InfiniBand，也就是说在 InfiniBand 的基础上建立一个虚拟的 Ethernet 连接。但是找来找去只有两个 slider，一个 YouTube 视频，就没有其它的说法了。我猜提出这种设想的人可能是被 Mellanox[^4] 给招安了，毕竟如果可以用软件来模拟以太网的话，那 VPI 卡就卖不出去了。

其实可以注意到，Linux 有一套专门用来驱动 Mellanox 网卡的模块，我插上网卡重启了以后它就加载了 `mlx4_core` `mlx4_ib` `mlx4_en` 几个模块。也就是说，这些本来就在内核源码里的驱动并不需要从 Mellanox 那里下载也可以用。经过一番 GitHub 搜索，我发现 `mlx4_core` 底下有个叫 `port_type_array` 的参数，就是我需要的。通过
``` sh
echo 2,2 | sudo tee /sys/module/mlx4_core/parameters/port_type_array
```
可以把两个网口[^5]都给改成以太网模式。通过
``` sh
cat /sys/module/mlx4_core/parameters/port_type_array
```
也可以看当前配置是怎么样的。

要让系统一开机就把两个网口都设置成以太网模式，可以在 `/etc/modprobe.d` 里面加个参数来做到。创建个新文件，例如 `/etc/modprobe.d/mlx4.conf` ，把参数写进去：
``` conf
options mlx4_core port_type_array=2,2
```
然后，更新 initramfs：
``` sh
update-initramfs -u
```
重启。Et voilà!

如果用的是 nixos，往 `/etc/nixos/configuration.nix` 里加入一个
``` nix
boot.extraModprobeConfig = ''
  options mlx4_core port_type_array=2,2
''
```
即可。别忘了也改改 `boot.kernelModules` 把几个 `mlx_*` 加载上。

改完以后，我发现这玩意在以太网模式下速度并没有 40Gbps，而是只有 10Gbps。不过其实已经性价比挺高的了。参考报价：网卡两张，200元，光纤[^6]10米，350元。

[^1]: <https://www.reddit.com/r/homelab/comments/8hfbpw/mellanox_connectx2_with_ubuntu_1804/>

[^2]: 真是函数式（？）

[^3]: 就是我一开始也这么想……然后发现不行orz

[^4]: 或者别的做 InfiniBand 设备的公司。我猜。

[^5]: 我这是两个。如果你有四个网口的话就是 `2,2,2,2`，如果是只有一个的话是 `2`，我猜。

[^6]: 光纤是一根塑料管里面有四根多模光纤，模块和光纤装在一起不可拆分。我也还买了个铜线版（也就是被动版）的，两头也是一样的模块。粗很多，而且只有3米。留作以后扩展吧。
