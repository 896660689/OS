 v2ray/xray 是手动安装在 storage 下，现在改为将 v2ray/xray 内置到 padavan 固件中。使用 actions 来构建，笔者使用的是 k2p，如果是 padavan 支持的其它型号的路由，可以参考修改打造你自己的固件。

编译好的纯净版固件可以在 release 下载，有条件的可以挑战一下科学500兆：

榨干 MT7621 极限性能，科学跑满500兆有木有可能
证书
v2ray/xray 使用 tls 相关协议时会需要验证证书的有效性，而 padavan 默认是没有包含 ssl 根证书的。简单的方式可以配置 v2ray/xray 不验证，但是出于安全性的考虑，还是要验证的比较好。
/usr/lib/cacert.pem
证书文件来自于 https://curl.haxx.se/docs/caextract.html

配置 xray **推荐** （二选一）
将 xray 文件夹里的所有文件上传至路由器 /etc/storage/xray 目录，并添加脚本执行权限

chmod +x /etc/storage/xray/*.sh
配置 x2ray （二选一）
将 v2ray 文件夹里的所有文件上传至路由器 /etc/storage/v2ray 目录，并添加脚本执行权限

chmod +x /etc/storage/v2ray/*.sh
