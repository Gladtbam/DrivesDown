#!/usr/bin/env bash

sh_ver="2.7.2"
#PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
#export PATH
aria2_conf_dir="/root/.aria2c"
download_path="/root/downloads"
aria2_conf="${aria2_conf_dir}/aria2.conf"
aria2_log="${aria2_conf_dir}/aria2.log"
aria2c="/usr/local/bin/aria2c"
Crontab_file="/usr/bin/crontab"
Green_font_prefix="\033[32m"
Red_font_prefix="\033[31m"
Green_background_prefix="\033[42;37m"
Red_background_prefix="\033[41;37m"
Font_color_suffix="\033[0m"
Info="[${Green_font_prefix}信息${Font_color_suffix}]"
Error="[${Red_font_prefix}错误${Font_color_suffix}]"
Tip="[${Green_font_prefix}注意${Font_color_suffix}]"

check_root() {
    [[ $EUID != 0 ]] && echo -e "${Error} 当前非ROOT账号(或没有ROOT权限)，无法继续操作，请更换ROOT账号或使用 ${Green_background_prefix}sudo su${Font_color_suffix} 命令获取临时ROOT权限（执行后可能会提示输入当前账号的密码）。" && exit 1
}
[[ -e ${aria2c} ]] && echo -e "${Error} Aria2 已安装，请检查 !" && exit 1
check_sys() {
    if [[ -f /etc/redhat-release ]]; then
        release="centos"
    elif cat /etc/issue | grep -q -E -i "debian"; then
        release="debian"
    elif cat /etc/issue | grep -q -E -i "ubuntu"; then
        release="ubuntu"
    elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
        release="centos"
    elif cat /proc/version | grep -q -E -i "debian"; then
        release="debian"
    elif cat /proc/version | grep -q -E -i "ubuntu"; then
        release="ubuntu"
    elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
        release="centos"
    fi
    ARCH=$(uname -m)
    [ $(command -v dpkg) ] && dpkgARCH=$(dpkg --print-architecture | awk -F- '{ print $NF }')
}
Installation_dependency() {
    if [[ ${release} = "centos" ]]; then
        yum update
        yum install -y wget curl nano ca-certificates findutils jq tar gzip dpkg
    else
        apt-get update
        apt-get install -y wget curl nano ca-certificates findutils jq tar gzip dpkg
    fi
    if [[ ! -s /etc/ssl/certs/ca-certificates.crt ]]; then
        wget -qO- git.io/ca-certificates.sh | bash
    fi
}
check_new_ver() {
    aria2_new_ver=$(
        {
            wget -t2 -T3 -qO- "https://api.github.com/repos/P3TERX/aria2-builder/releases/latest" ||
                wget -t2 -T3 -qO- "https://gh-api.p3terx.com/repos/P3TERX/aria2-builder/releases/latest"
        } | grep -o '"tag_name": ".*"' | head -n 1 | cut -d'"' -f4
    )
    if [[ -z ${aria2_new_ver} ]]; then
        echo -e "${Error} Aria2 最新版本获取失败，请手动获取最新版本号[ https://github.com/P3TERX/aria2-builder/releases ]"
        read -e -p "请输入版本号:" aria2_new_ver
        [[ -z "${aria2_new_ver}" ]] && echo "取消..." && exit 1
    fi
}
Download_aria2() {
    update_dl=$1
    if [[ $ARCH == i*86 || $dpkgARCH == i*86 ]]; then
        ARCH="i386"
    elif [[ $ARCH == "x86_64" || $dpkgARCH == "amd64" ]]; then
        ARCH="amd64"
    elif [[ $ARCH == "aarch64" || $dpkgARCH == "arm64" ]]; then
        ARCH="arm64"
    elif [[ $ARCH == "armv7l" || $dpkgARCH == "armhf" ]]; then
        ARCH="armhf"
    else
        echo -e "${Error} 不支持此 CPU 架构。"
        exit 1
    fi
    while [[ $(which aria2c) ]]; do
        echo -e "${Info} 删除旧版 Aria2 二进制文件..."
        rm -vf $(which aria2c)
    done
    DOWNLOAD_URL="https://github.com/P3TERX/aria2-builder/releases/download/${aria2_new_ver}/aria2-${aria2_new_ver%_*}-static-linux-${ARCH}.tar.gz"
    {
        wget -t2 -T3 -O- "${DOWNLOAD_URL}" ||
            wget -t2 -T3 -O- "https://gh-acc.p3terx.com/${DOWNLOAD_URL}"
    } | tar -zx
    [[ ! -s "aria2c" ]] && echo -e "${Error} Aria2 下载失败 !" && exit 1
    [[ ${update_dl} = "update" ]] && rm -f "${aria2c}"
    mv -f aria2c "${aria2c}"
    [[ ! -e ${aria2c} ]] && echo -e "${Error} Aria2 主程序安装失败！" && exit 1
    chmod +x ${aria2c}
    echo -e "${Info} Aria2 主程序安装完成！"
}
Download_aria2_conf() {
    PROFILE_URL1="https://p3terx.github.io/aria2.conf"
    PROFILE_URL2="https://aria2c.now.sh"
    PROFILE_URL3="https://cdn.jsdelivr.net/gh/P3TERX/aria2.conf@master"
    PROFILE_LIST="
aria2.conf
clean.sh
core
script.conf
rclone.env
upload.sh
delete.sh
dht.dat
dht6.dat
move.sh
LICENSE
"
    mkdir -p "${aria2_conf_dir}" && cd "${aria2_conf_dir}"
    for PROFILE in ${PROFILE_LIST}; do
        [[ ! -f ${PROFILE} ]] && rm -rf ${PROFILE}
        wget -N -t2 -T3 ${PROFILE_URL1}/${PROFILE} ||
            wget -N -t2 -T3 ${PROFILE_URL2}/${PROFILE} ||
            wget -N -t2 -T3 ${PROFILE_URL3}/${PROFILE}
        [[ ! -s ${PROFILE} ]] && {
            echo -e "${Error} '${PROFILE}' 下载失败！清理残留文件..."
            rm -vrf "${aria2_conf_dir}"
            exit 1
        }
    done
    sed -i "s@^\(dir=\).*@\1${download_path}@" ${aria2_conf}
    sed -i "s@/root/.aria2/@${aria2_conf_dir}/@" ${aria2_conf_dir}/*.conf
    sed -i "s@^\(rpc-secret=\).*@\1$(date +%s%N | md5sum | head -c 20)@" ${aria2_conf}
    sed -i "s@^#\(retry-on-.*=\).*@\1true@" ${aria2_conf}
    sed -i "s@^\(max-connection-per-server=\).*@\132@" ${aria2_conf}
    touch aria2.session
    chmod +x *.sh
    echo -e "${Info} Aria2 完美配置下载完成！"
}
Service_aria2() {
    if [[ ${release} = "centos" ]]; then
        wget -N -t2 -T3 "https://raw.githubusercontent.com/P3TERX/aria2.sh/master/service/aria2_centos" -O /etc/init.d/aria2 ||
            wget -N -t2 -T3 "https://cdn.jsdelivr.net/gh/P3TERX/aria2.sh@master/service/aria2_centos" -O /etc/init.d/aria2 ||
            wget -N -t2 -T3 "https://gh-raw.p3terx.com/P3TERX/aria2.sh/master/service/aria2_centos" -O /etc/init.d/aria2
        [[ ! -s /etc/init.d/aria2 ]] && {
            echo -e "${Error} Aria2服务 管理脚本下载失败 !"
            exit 1
        }
        chmod +x /etc/init.d/aria2
        chkconfig --add aria2
        chkconfig aria2 on
    else
        wget -N -t2 -T3 "https://raw.githubusercontent.com/P3TERX/aria2.sh/master/service/aria2_debian" -O /etc/init.d/aria2 ||
            wget -N -t2 -T3 "https://cdn.jsdelivr.net/gh/P3TERX/aria2.sh@master/service/aria2_debian" -O /etc/init.d/aria2 ||
            wget -N -t2 -T3 "https://gh-raw.p3terx.com/P3TERX/aria2.sh/master/service/aria2_debian" -O /etc/init.d/aria2
        [[ ! -s /etc/init.d/aria2 ]] && {
            echo -e "${Error} Aria2服务 管理脚本下载失败 !"
            exit 1
        }
        chmod +x /etc/init.d/aria2
        update-rc.d -f aria2 defaults
    fi
    echo -e "${Info} Aria2服务 管理脚本下载完成 !"
}
Read_config() {
    status_type=$1
    if [[ ! -e ${aria2_conf} ]]; then
        if [[ ${status_type} != "un" ]]; then
            echo -e "${Error} Aria2 配置文件不存在 !" && exit 1
        fi
    else
        conf_text=$(cat ${aria2_conf} | grep -v '#')
        aria2_dir=$(echo -e "${conf_text}" | grep "^dir=" | awk -F "=" '{print $NF}')
        aria2_port=$(echo -e "${conf_text}" | grep "^rpc-listen-port=" | awk -F "=" '{print $NF}')
        aria2_passwd=$(echo -e "${conf_text}" | grep "^rpc-secret=" | awk -F "=" '{print $NF}')
        aria2_bt_port=$(echo -e "${conf_text}" | grep "^listen-port=" | awk -F "=" '{print $NF}')
        aria2_dht_port=$(echo -e "${conf_text}" | grep "^dht-listen-port=" | awk -F "=" '{print $NF}')
    fi
}
Set_iptables() {
    if [[ ${release} == "centos" ]]; then
        service iptables save
        chkconfig --level 2345 iptables on
    else
        iptables-save >/etc/iptables.up.rules
        echo -e '#!/bin/bash\n/sbin/iptables-restore < /etc/iptables.up.rules' >/etc/network/if-pre-up.d/iptables
        chmod +x /etc/network/if-pre-up.d/iptables
    fi
}
Add_iptables() {
    iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport ${aria2_RPC_port} -j ACCEPT
    iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport ${aria2_bt_port} -j ACCEPT
    iptables -I INPUT -m state --state NEW -m udp -p udp --dport ${aria2_dht_port} -j ACCEPT
}
Save_iptables() {
    if [[ ${release} == "centos" ]]; then
        service iptables save
    else
        iptables-save >/etc/iptables.up.rules
    fi
}
check_pid() {
    PID=$(ps -ef | grep "aria2c" | grep -v grep | grep -v "aria2.sh" | grep -v "init.d" | grep -v "service" | awk '{print $2}')
}
#Start_aria2() {
#    check_installed_status
#    check_pid
#    [[ ! -z ${PID} ]] && echo -e "${Error} Aria2 正在运行，请检查 !" && exit 1
#    /etc/init.d/aria2 start
#}
crontab_update_status() {
    crontab -l | grep "tracker.sh"
}
Install_aria2() {
check_root
check_sys
echo -e "${Info} 开始安装/配置 依赖..."
Installation_dependency
echo -e "${Info} 开始下载/安装 主程序..."
check_new_ver
Download_aria2
echo -e "${Info} 开始下载/安装 Aria2 完美配置..."
Download_aria2_conf
echo -e "${Info} 开始下载/安装 服务脚本(init)..."
Service_aria2
Read_config
aria2_RPC_port=${aria2_port}
echo -e "${Info} 开始设置 iptables 防火墙..."
Set_iptables
echo -e "${Info} 开始添加 iptables 防火墙规则..."
Add_iptables
echo -e "${Info} 开始保存 iptables 防火墙规则..."
Save_iptables
echo -e "${Info} 开始创建 下载目录..."
mkdir -p ${download_path}
#echo -e "${Info} 所有步骤 安装完毕，开始启动..."
#Start_aria2
}
check_installed_status() {
    [[ ! -e ${aria2c} ]] && echo -e "${Error} Aria2 没有安装，请检查 !" && exit 1
    [[ ! -e ${aria2_conf} ]] && echo -e "${Error} Aria2 配置文件不存在，请检查 !" && [[ $1 != "un" ]] && exit 1
}
check_crontab_installed_status() {
    if [[ ! -e ${Crontab_file} ]]; then
        echo -e "${Error} Crontab 没有安装，开始安装..."
        if [[ ${release} == "centos" ]]; then
            yum install crond -y
        else
            apt-get install cron -y
        fi
        if [[ ! -e ${Crontab_file} ]]; then
            echo -e "${Error} Crontab 安装失败，请检查！" && exit 1
        else
            echo -e "${Info} Crontab 安装成功！"
        fi
    fi
}
Update_bt_tracker() {
    check_installed_status
    check_pid
    [[ -z $PID ]] && {
        bash <(wget -qO- git.io/tracker.sh) ${aria2_conf}
    } || {
        bash <(wget -qO- git.io/tracker.sh) ${aria2_conf} RPC
    }
}
crontab_update_start() {
    crontab -l >"/tmp/crontab.bak"
    sed -i "/aria2.sh update-bt-tracker/d" "/tmp/crontab.bak"
    sed -i "/tracker.sh/d" "/tmp/crontab.bak"
    echo -e "\n0 7 * * * /bin/bash <(wget -qO- git.io/tracker.sh) ${aria2_conf} RPC 2>&1 | tee ${aria2_conf_dir}/tracker.log" >>"/tmp/crontab.bak"
    crontab "/tmp/crontab.bak"
    rm -f "/tmp/crontab.bak"
    if [[ -z $(crontab_update_status) ]]; then
        echo && echo -e "${Error} 自动更新 BT-Tracker 开启失败 !" && exit 1
    else
        Update_bt_tracker
        echo && echo -e "${Info} 自动更新 BT-Tracker 开启成功 !"
    fi
}
Update_bt_tracker_cron() {
    check_installed_status
    check_crontab_installed_status
    crontab_update_start
}
Install_aria2
Update_bt_tracker_cron