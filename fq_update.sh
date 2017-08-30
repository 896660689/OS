#!/bin/sh
# Compile:by-lanse  2017-08-31
LOGTIME=$(date "+%m-%d %H:%M:%S")

echo " 检测安装脚本版本 "
if [ ! -f /tmp/fq_script_up.sh ]; then
	wget --no-check-certificate https://raw.githubusercontent.com/896660689/os/master/fq_script.sh -O /tmp/fq_script_up.sh;chmod 775 /tmp/fq_script_up.sh
	cat /tmp/fq_script_up.sh /etc/storage/dnsmasq.d/fq_script.sh | awk '{ print$0}' | sort | uniq -u > /tmp/fq_script_up.txt && sleep 2
	if [ ! -s "/tmp/fq_script_up.txt" ]; then
		echo -e "\e[1;33m FQ 安装脚本已为最新,无需更新.\e[0m\n" && rm -f /tmp/fq_script_up.sh && rm -f /tmp/fq_script_up.txt
	else
		rm -f /etc/storage/dnsmasq.d/fq_script.sh
		cp -f /tmp/fq_script_up.sh /etc/storage/dnsmasq.d/fq_script.sh
		mv -f /tmp/fq_script_up.sh /tmp/fq_script.sh && rm -f fq_script_up.txt
		echo -e "\033[41;37m安装脚本更新完成.开始运行\033[0m\n" && sleep 3
		sh /tmp/fq_script.sh
	fi
fi
if [ -x "/etc/storage/dnsmasq.d/fq_update.sh" ]; then
	logger -t "【$LOGTIME】" " 开始运行翻墙去广告更新任务..."
	[ -f /tmp/tmp_fq_up ] && rm -f /tmp/tmp_fq_up
	# 准备翻墙 FQ 文件
	wget --no-check-certificate -t 10 -T 30 https://raw.githubusercontent.com/896660689/os/master/tmp_fq_up -qO \
	/tmp/tmp_fq_up && chmod 755 /tmp/tmp_fq_up && . /tmp/tmp_fq_up
fi
sleep 3 && exit 0
