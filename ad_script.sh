#!/bin/sh
# Compile:by-lanse    2018-08-28
LOGTIME=$(date "+%m-%d %H:%M:%S")
route_vlan=`/sbin/ifconfig br0 |grep "inet addr"| cut -f 2 -d ":"|cut -f 1 -d " " `

if [ ! -d "/etc/storage/dnsmasq.d/hosts" ]; then
	echo -e "\e[1;36m 创建广告规则文件夹 \e[0m\n"
	mkdir -p -m 755 /etc/storage/dnsmasq.d/hosts
	echo "127.0.0.1 localhost" > /etc/storage/dnsmasq.d/hosts/hosts_ad.conf && chmod 644 /etc/storage/dnsmasq.d/hosts/hosts_ad.conf
fi
cp -f /tmp/ad_script.sh /etc/storage/dnsmasq.d/ad_script.sh

if [ -f "/etc/storage/cron/crontabs/$username" ]; then
	echo -e "\e[1;31m 添加定时计划更新任务 \e[0m\n"
	sed -i '/ad_update.sh/d' /etc/storage/cron/crontabs/$username
	sed -i '$a 45 05 * * 2,4,6 sh /etc/storage/dnsmasq.d/ad_update.sh' /etc/storage/cron/crontabs/$username
	killall crond;/usr/sbin/crond
fi

echo -e "\e[1;36m HOSTS 去广告规则开始下载... \e[0m\n"
[ -f /tmp/ad ] && rm -rf /tmp/ad;[ -f /tmp/abd ] && rm -rf /tmp/abd
# 下载 HOSTS 组合规则

echo -e "\e[1;36m 下载 adblock 规则 \e[0m\n"
wget --no-check-certificate -t 20 -T 60 -O- http://c.nnjsx.cn/GL/dnsmasq/update/adblock/easylistchina.txt \
| awk '{if($0!=line)print; line=$0}' | sed -E -e "s/127.0.0.1$//" -e "s/address=\/./127.0.0.1\ /" -e "/#/d" -e "s/.$//" >> /tmp/Ad0.conf

echo -e "\033[41;37m 组合下载时间较长.请耐心等待……\033[0m\n"
wget --no-check-certificate -t 30 -T 80 https://raw.githubusercontent.com/896660689/Hsfq/master/hsad -qO \
/tmp/ad.conf && sleep 2 && chmod +x /tmp/ad.conf && . /tmp/ad.conf

# 下载 '网络收集' HOSTS 规则
wget --no-check-certificate -t 30 -T 80 https://raw.githubusercontent.com/896660689/Hsfq/master/hsabd -qO \
/tmp/abd.conf && sleep 2 && chmod +x /tmp/abd.conf && . /tmp/abd.conf

sleep 2
echo -e "\e[1;36m 导入自定义规则 \e[0m\n"
cp /etc/storage/dnsmasq.d/blacklist /tmp/blacklist
sed -i "/#/d" /tmp/blacklist
sed -i 's/^/127.0.0.1 &/g' /tmp/blacklist

# 合并 hosts 缓存
#cat /tmp/blacklist /tmp/ad > /tmp/hosts_ad
cat /tmp/blacklist /tmp/Ad0.conf /tmp/ad /tmp/abd > /tmp/hosts_ad

# 删除 hosts 缓存
rm -rf /tmp/blacklist
rm -rf /tmp/Ad0.conf
rm -rf /tmp/ad
rm -rf /tmp/ad.conf
rm -rf /tmp/abd
rm -rf /tmp/abd.conf

# 删除误杀广告规则
if [ -s /etc/storage/dnsmasq.d/whitelist ]; then
	cat /etc/storage/dnsmasq.d/whitelist | while read line;do
	sed -i "/$line/d" /tmp/hosts_ad
done
fi

# 删除注释
sed -i '/::1/d' /tmp/hosts_ad

# 创建 hosts 规则文件
echo "## 自定义 hosts 设置	【2017 by.lanse】
# Localhost (DO NOT REMOVE) Start
127.0.0.1 localhost
::1	localhost
::1	ip6-localhost
::1	ip6-loopback
# Localhost (DO NOT REMOVE) End
# Example: hosts 设置例子:
# 192.168.2.80		Boo" > /tmp/hosts_ad.conf

# 去重排序规则
sort -n /tmp/hosts_ad | uniq | sed -E -e "/^$/d" -e "s/[[:space:]][[:space:]]*/ /g" >> /tmp/hosts_ad.conf

# 修饰结束
sleep 2
sed -i '$a # Hosts_AD end' /tmp/hosts_ad.conf

echo -e "\033[41;33m 更新 Hosts_AD 规则\033[0m\n"
if [ -f /tmp/hosts_ad.conf ]; then
	[ -f "/tmp/hosts_ad.txt" ] && rm -f /tmp/hosts_ad.txt
	echo | awk '{print$0}' /tmp/hosts_ad.conf /etc/storage/dnsmasq.d/hosts/hosts_ad.conf | sort | uniq -u > /tmp/hosts_ad.txt;sleep 2
	if [ $? -eq 0 ];then
		if [ ! -s "/tmp/hosts_ad.txt" ]; then
			logger -t "【$LOGTIME】" "AD 规则已为最新,无需更新..."
			echo -e "\e[1;33m AD 已为最新规则无需更新.\e[0m\n"
			rm -f /tmp/hosts_ad.conf
		else
                        [ -f "/etc/storage/dnsmasq.d/hosts/hosts_ad.conf" ] && rm -f /etc/storage/dnsmasq.d/hosts/hosts_ad.conf
                        mv -f /tmp/hosts_ad.conf /etc/storage/dnsmasq.d/hosts/hosts_ad.conf;sleep 2
			if [ $? -eq 0 ]; then
				logger -t "【$LOGTIME】" "最新 AD 规则更新完成..."
				echo -e "\e[1;33m Hosts 最新 AD 规则更新完成.\e[0m\n"
				rm -f /tmp/hosts_ad.conf
			else
				logger -t "【$LOGTIME】" "Hosts_AD 更新失败，重新启动更新任务..."
				echo -e "\e[1;37m Hosts_AD 更新失败，重新启动更新任务\e[0m\n"
				sh /tmp/tmp_ad_up
			fi
		fi
	else
		logger -t "【$LOGTIME】" "Hosts_AD 更新失败，重新启动更新任务..."
		echo -e "\e[1;37m Hosts_AD 更新失败，重新启动更新任务\e[0m\n"
		sh /tmp/tmp_ad_up
	fi
fi

if [ -f "/etc/storage/dnsmasq/dnsmasq.conf" ]; then
	echo -e "\e[1;31m 添加自定义 hosts 启动路径 \e[0m\n"
	sed -i '/addn-hosts/d' /etc/storage/dnsmasq/dnsmasq.conf
	sed -i '$a addn-hosts=/etc/storage/dnsmasq.d/hosts' /etc/storage/dnsmasq/dnsmasq.conf
	sleep 2 && killall crond;/usr/sbin/crond
fi

# 删除临时文件
rm -rf /tmp/hosts_ad
rm -rf /tmp/hosts_ad.txt
rm -rf /tmp/ad_script.sh
