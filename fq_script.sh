#!/bin/sh
# Compile:by-lanse	2017-09-01
route_vlan=`/sbin/ifconfig br0 |grep "inet addr"| cut -f 2 -d ":"|cut -f 1 -d " " `
username=`nvram get http_username`

echo -e -n "\033[41;37m 开始构建翻墙平台......\033[0m\n"
sleep 3
if [ ! -d "/etc/storage/dnsmasq.d/conf" ]; then
	mkdir -p -m 755 /etc/storage/dnsmasq.d/conf
	echo -e "\e[1;36m 创建 'FQ' 文件夹 \e[0m\n"
	cp -f /tmp/fq_script.sh /etc/storage/dnsmasq.d/fq_script.sh
	echo "address=/localhost/127.0.0.1" > /etc/storage/dnsmasq.d/conf/hosts_fq.conf
	chmod 644 /etc/storage/dnsmasq.d/conf/hosts_fq.conf
fi

if [ ! -f "/etc/storage/dnsmasq.d/resolv_bak" ]; then
	echo -e "\e[1;36m 备份 'DNS' 文件 \e[0m\n"
	cp -f /etc/resolv.conf /etc/storage/dnsmasq.d/resolv_bak && chmod 644 /etc/storage/dnsmasq.d/resolv_bak
fi

if [ ! -f "/etc/storage/dnsmasq.d/userlist" ]; then
	echo -e "\e[1;36m 创建自定义翻墙规则 \e[0m\n"
	cat > "/etc/storage/dnsmasq.d/userlist" <<EOF
# 国内dns优化
address=/email.163.com/223.6.6.6
address=/mail.qq.com/119.29.29.29
EOF
fi
chmod 644 /etc/storage/dnsmasq.d/userlist

if [ -d "/etc/storage/dnsmasq.d" ]; then
	echo -e "\e[1;33m 创建更新脚本 \e[0m\n"
	wget --no-check-certificate -t 30 -T 60 https://raw.githubusercontent.com/896660689/OS/master/fq_update.sh -qO /tmp/fq_update.sh
	mv -f /tmp/fq_update.sh /etc/storage/dnsmasq.d/fq_update.sh && sleep 3
	chmod 755 /etc/storage/dnsmasq.d/fq_update.sh
fi

echo -e "\e[1;36m 创建 DNS 配置文件 \e[0m\n"
if [ ! -f "/etc/storage/dnsmasq.d/resolv.conf" ]; then
	cat > /etc/storage/dnsmasq.d/resolv.conf <<EOF
## DNS解析服务器设置
nameserver 127.0.0.1
## 根据网络环境选择DNS.最多6个地址按速排序
nameserver 223.6.6.6
nameserver 176.103.130.131
nameserver 114.114.114.114
nameserver 119.29.29.29
nameserver 8.8.4.4
EOF
fi
chmod 644 /etc/storage/dnsmasq.d/resolv.conf && chmod 644 /etc/resolv.conf
cp -f /etc/storage/dnsmasq.d/resolv.conf /tmp/resolv.conf
sed -i "/#/d" /tmp/resolv.conf;mv -f /tmp/resolv.conf /etc/resolv.conf

if [ -f "/etc/storage/cron/crontabs/$username" ]; then
	echo -e "\e[1;33m 添加定时计划更新任务 \e[0m\n"
	sed -i '/fq_update.sh/d' /etc/storage/cron/crontabs/$username
	sed -i '$a 45 05 * * 2,4,6 sh /etc/storage/dnsmasq.d/fq_update.sh' /etc/storage/cron/crontabs/$username
	sleep 2 && killall crond;/usr/sbin/crond
fi

echo -e "\e[1;36m 添加 FQ 启动路径 \e[0m\n"
[ -f /var/log/dnsmasq.log ] && rm /var/log/dnsmasq.log
[ -f /tmp/tmp_dnsmasq ] && rm /tmp/tmp_dnsmasq
if [ ! -f "/etc/storage/dnsmasq/dnsmasq.conf" ]; then
	wget --no-check-certificate -t 20 -T 50 https://raw.githubusercontent.com/896660689/OS/master/tmp_dnsmasq -qO /tmp/tmp_dnsmasq
	chmod 777 /tmp/tmp_dnsmasq && sh /tmp/tmp_dnsmasq
else
	grep "conf-dir" /etc/storage/dnsmasq/dnsmasq.conf
	if [ $? -eq 0 ]; then
		sed -i '/127.0.0.1/d' /etc/storage/dnsmasq/dnsmasq.conf
		sed -i '/log/d' /etc/storage/dnsmasq/dnsmasq.conf
		sed -i '/1800/d' /etc/storage/dnsmasq/dnsmasq.conf
		sed -i '/conf-dir/d' /etc/storage/dnsmasq/dnsmasq.conf
	else
		echo -e "\033[41;37m 开始写入启动代码 \e[0m\n"
		echo "listen-address=${route_vlan},127.0.0.1
# 添加监听地址
# 开启日志选项
log-queries
log-facility=/var/log/dnsmasq.log
# 异步log,缓解阻塞，提高性能。默认为5，最大为100
log-async=50
# 缓存最长时间
#min-cache-ttl=1800
# 指定服务器'域名''地址'文件夹
conf-dir=/etc/storage/dnsmasq.d/conf
# conf-file=/etc/storage/dnsmasq.d/conf/hosts_fq.conf" >> /tmp/tmp_dnsmasq.conf >/dev/null
		cat /tmp/tmp_dnsmasq.conf | sed -E -e "/#/d" >> /etc/storage/dnsmasq/dnsmasq.conf >/dev/null 2>&1; sleep 3
		rm /tmp/tmp_dnsmasq.conf
	fi
fi

if [ -f "/etc/storage/post_iptables_script.sh" ]; then
	echo -e "\e[1;36m 添加防火墙端口转发规则 \e[0m\n"
	sed -i '/DNAT/d' /etc/storage/post_iptables_script.sh
	sed -i '/iptables-save/d' /etc/storage/post_iptables_script.sh
	sed -i '$a /bin/iptables-save' /etc/storage/post_iptables_script.sh
fi
echo "/bin/iptables -t nat -A PREROUTING -p tcp --dport 53 -j DNAT --to $route_vlan" >> /etc/storage/post_iptables_script.sh
echo "/bin/iptables -t nat -A PREROUTING -p udp --dport 53 -j DNAT --to $route_vlan" >> /etc/storage/post_iptables_script.sh
if [ -f "/etc/storage/post_iptables_script.sh" ]; then
	sed -i '/resolv.conf/d' /etc/storage/post_iptables_script.sh
	sed -i '/restart_dhcpd/d' /etc/storage/post_iptables_script.sh
	sed -i '$a cp -f /etc/storage/dnsmasq.d/resolv.conf /tmp/resolv.conf' /etc/storage/post_iptables_script.sh
	sed -i '$a sed -i "/#/d" /tmp/resolv.conf;mv -f /tmp/resolv.conf /etc/resolv.conf' /etc/storage/post_iptables_script.sh
	sed -i '$a restart_dhcpd >/dev/null 2>&1' /etc/storage/post_iptables_script.sh
fi

if [ -f "/etc/storage/dnsmasq.d/fq_update.sh" ]; then
	echo -e -n "\033[41;37m 开始下载翻墙脚本文件......\033[0m\n"
	sh /etc/storage/dnsmasq.d/fq_update.sh
fi
sleep 3
rm -rf /tmp/fq_script.sh
[ ! -f "/tmp/fqad_install" ] && exit 0
