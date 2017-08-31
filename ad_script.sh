#!/bin/sh
# Compile:by-lanse    2018-08-31
route_vlan=`/sbin/ifconfig br0 |grep "inet addr"| cut -f 2 -d ":"|cut -f 1 -d " " `
username=`nvram get http_username`

echo -e -n "\033[41;37m 开始构建去广告平台......\033[0m\n"
sleep 3
if [ ! -d "/etc/storage/dnsmasq.d/hosts" ]; then
	echo -e "\e[1;36m 创建广告规则文件夹 \e[0m\n"
	mkdir -p -m 755 /etc/storage/dnsmasq.d/hosts
	echo "127.0.0.1 localhost" > /etc/storage/dnsmasq.d/hosts/hosts_ad.conf && chmod 644 /etc/storage/dnsmasq.d/hosts/hosts_ad.conf
fi
cp -f /tmp/ad_script.sh /etc/storage/dnsmasq.d/ad_script.sh

if [ -d "/etc/storage/dnsmasq.d" ]; then
	echo -e "\e[1;33m 创建更新脚本 \e[0m\n"
	wget --no-check-certificate -t 30 -T 60 https://raw.githubusercontent.com/896660689/OS/master/ad_update.sh -qO /tmp/ad_update.sh
	mv -f /tmp/ad_update.sh /etc/storage/dnsmasq.d/ad_update.sh && sleep 3
	chmod 755 /etc/storage/dnsmasq.d/ad_update.sh
fi

if [ ! -d "/etc/storage/dnsmasq.d/hosts" ]; then
	echo -e "\e[1;36m 创建 'HOSTS' 文件 \e[0m\n"
	mkdir -p /etc/storage/dnsmasq.d/hosts
	echo "127.0.0.1 localhost" > /etc/storage/dnsmasq.d/hosts/hosts_ad.conf && chmod 644 /etc/storage/dnsmasq.d/hosts/hosts_ad.conf
fi

echo -e "\e[1;36m 创建自定义广告黑名单 \e[0m\n"
if [ ! -f "/etc/storage/dnsmasq.d/blacklist" ]; then
	cat > "/etc/storage/dnsmasq.d/blacklist" <<EOF
# 请在下面添加广告黑名单
# 每行输入要屏蔽广告网址不含http://符号
active.admore.com.cn
g.163.com
mtty-cdn.mtty.com
static-alias-1.360buyimg.com
image.yzmg.com
files.jb51.net/image
common.jb51.net/images
du.ebioweb.com/ebiotrade/web_images
www.37cs.com
fuimg.com
sinaimg.cn
ciimg.com
pic.iidvd.com
cnzz.com
statis.api.3g.youku.com
ad.m.qunar.com
lives.l.aiseet.atianqi.com
# 运营商ip劫持
120.197.89.239
211.139.178.49
221.179.46.190
221.179.46.193
221.179.46.194
60.19.29.21
60.19.29.24
61.174.50.168
# 广告IP劫持
47.89.59.182
106.75.65.90
114.55.123.44
122.225.103.120
123.59.78.229
139.224.26.92
222.186.61.97
222.187.226.96
23.235.156.167
101.201.29.182
EOF
fi
chmod 644 /etc/storage/dnsmasq.d/blacklist

echo -e "\e[1;36m 创建自定义广告白名单 \e[0m\n"
if [ ! -f "/etc/storage/dnsmasq.d/whitelist" ]; then
	cat > "/etc/storage/dnsmasq.d/whitelist" <<EOF
# 请将误杀的网址添加到在下面白名单
# 每行输入相应准确的网址或关键词即可:
m.baidu.com
github.com
raw.githubusercontent.com
my.k2
tv.sohu.com
toutiao.com
jd.com
tejia.taobao.com
temai.taobao.com
ai.m.taobao.com
ai.taobao.com
re.taobao.com
shi.taobao.com
s.click.taobao.com
s.click.tmall.com
ju.taobao.com
dl.360safe.com
down.360safe.com
fd.shouji.360.cn
zhushou.360.cn
shouji.360.cn
hot.m.shouji.360tpcdn.com
EOF
fi
chmod 644 /etc/storage/dnsmasq.d/whitelist

if [ -f "/etc/storage/cron/crontabs/$username" ]; then
	echo -e "\e[1;31m 添加定时计划更新任务 \e[0m\n"
	sed -i '/ad_update.sh/d' /etc/storage/cron/crontabs/$username
	sed -i '$a 35 05 * * 2,4,6 sh /etc/storage/dnsmasq.d/ad_update.sh' /etc/storage/cron/crontabs/$username
	killall crond;/usr/sbin/crond
fi

if [ -f "/etc/storage/dnsmasq/dnsmasq.conf" ]; then
	echo -e "\e[1;36m 添加 HOSTS 启动路径 \e[0m\n"
	grep "addn-hosts" /etc/storage/dnsmasq/dnsmasq.conf
	if [ $? -eq 0 ]; then
		sed -i '/addn-hosts/d' /etc/storage/dnsmasq/dnsmasq.conf
	else
		echo -e "\033[41;37m 开始写入启动代码 \e[0m\n"
	fi
	echo "addn-hosts=/etc/storage/dnsmasq.d/hosts" >> /tmp/tmp_dnsmasq.conf
	cat /tmp/tmp_dnsmasq.conf >> /etc/storage/dnsmasq/dnsmasq.conf;sleep 3
	rm -f /tmp/tmp_dnsmasq.conf
fi

if [ -f "/etc/storage/dnsmasq.d/ad_update.sh" ]; then
	echo -e -n "\033[41;37m 开始下载去广告脚本文件......\033[0m\n"
	sh /etc/storage/dnsmasq.d/ad_update.sh
fi

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+                 installation is complete                 +"
echo "+                                                          +"
echo "+                     Time:`date +'%Y-%m-%d'`                      +"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
sleep 3
rm -rf /tmp/ad_script.sh
[ ! -f "/tmp/fqad_install" ] && exit 0
