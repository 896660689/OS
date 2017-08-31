#!/bin/sh
# Compile:by-lanse  2017-08-31
LOGTIME=$(date "+%m-%d %H:%M:%S")

echo " 检测AD安装脚本版本 "
if [ ! -f /tmp/ad_script_up.sh ]; then
	logger -t "【$LOGTIME】" " 开始运行去广告更新任务..."
	wget --no-check-certificate https://raw.githubusercontent.com/896660689/OS/master/ad_script.sh -O /tmp/ad_script_up.sh;chmod 775 /tmp/ad_script_up.sh
	cat /tmp/ad_script_up.sh /etc/storage/dnsmasq.d/ad_script.sh | awk '{ print$0}' | sort | uniq -u > /tmp/ad_script_up.txt && sleep 2
	if [ ! -s "/tmp/ad_script_up.txt" ]; then
		echo -e "\e[1;33m AD 安装脚本已为最新,无需更新.\e[0m\n" && rm -f /tmp/ad_script_up.sh && rm -f /tmp/ad_script_up.txt
	else
		rm -f /etc/storage/dnsmasq.d/ad_script.sh
		cp -f /tmp/ad_script_up.sh /etc/storage/dnsmasq.d/ad_script.sh
		mv -f /tmp/ad_script_up.sh /tmp/ad_script.sh && rm -f ad_script_up.txt
		echo -e "\033[41;37m安装脚本更新完成.开始运行\033[0m\n" && sleep 3
		sh /tmp/ad_script.sh
	fi
fi
if [ -x "/etc/storage/dnsmasq.d/ad_update.sh" ]; then
	[ -f /tmp/tmp_ad_up ] && rm -f /tmp/tmp_ad_up
	# 准备翻墙 AD 文件
	wget --no-check-certificate -t 10 -T 30 https://raw.githubusercontent.com/896660689/OS/master/tmp_ad_up -qO \
	/tmp/tmp_ad_up && chmod 755 /tmp/tmp_ad_up && . /tmp/tmp_ad_up
fi
sleep 3 && exit 0
