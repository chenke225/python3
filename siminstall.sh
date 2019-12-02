#!/bin/bash

# This file is accessible as https://install.direct/go.sh
# Original source is located at github.com/v2ray/v2ray-core/release/install-release.sh

# If not specify, default meaning of return value:
# 0: Success
# 1: System error
# 2: Application error
# 3: Network error

CUR_VER=""
NEW_VER=""
ARCH=""
VDIS="64"
CROOT="/mnt/d/sw-learn/linux-root"
ZIPFILE="${CROOT}/tmp/v2ray/v2ray.zip"
V2RAY_RUNNING=0
VSRC_ROOT="${CROOT}/tmp/v2ray"
EXTRACT_ONLY=0
ERROR_IF_UPTODATE=0
DIST_SRC="github"

CMD_INSTALL=""
CMD_UPDATE=""
SOFTWARE_UPDATED=0

SYSTEMCTL_CMD=$(command -v systemctl 2>/dev/null)
SERVICE_CMD=$(command -v service 2>/dev/null)

CHECK=""
FORCE=""
HELP=""
mychange=""

#######color code########
RED="31m"      # Error message
GREEN="32m"    # Success message
YELLOW="33m"   # Warning message
BLUE="36m"     # Info message




###############################
colorEcho(){
    COLOR=$1
    echo -e "\033[${COLOR}${@:2}\033[0m"
}

extract(){
    colorEcho ${BLUE}"Extracting V2Ray package to /tmp/v2ray."
    mkdir -p /tmp/v2ray
    unzip $1 -d ${VSRC_ROOT}
    if [[ $? -ne 0 ]]; then
        colorEcho ${RED} "Failed to extract V2Ray."
        return 2
    fi
    if [[ -d "${CROOT}/tmp/v2ray/v2ray-${NEW_VER}-linux-${VDIS}" ]]; then
      VSRC_ROOT="${CROOT}/tmp/v2ray/v2ray-${NEW_VER}-linux-${VDIS}"
    fi
    return 0
}

copyFile() {
    NAME=$1
    ERROR=`cp "${VSRC_ROOT}/${NAME}" "${CROOT}/usr/bin/v2ray/${NAME}" 2>&1`
    if [[ $? -ne 0 ]]; then
        colorEcho ${YELLOW} "${ERROR}"
        return 1
    fi
    return 0
}

makeExecutable() {
    chmod +x "${CROOT}/usr/bin/v2ray/$1"
}

installV2Ray(){
    # Install V2Ray binary to /usr/bin/v2ray
    mkdir -p ${CROOT}/usr/bin/v2ray
    copyFile v2ray
    if [[ $? -ne 0 ]]; then
        colorEcho ${RED} "Failed to copy V2Ray binary and resources."
        return 1
    fi
    makeExecutable v2ray
    copyFile v2ctl && makeExecutable v2ctl
    copyFile geoip.dat
    copyFile geosite.dat

    # Install V2Ray server config to /etc/v2ray
    if [[ ! -f "${CROOT}/etc/v2ray/config.json" ]]; then
        mkdir -p ${CROOT}/etc/v2ray
        mkdir -p ${CROOT}/var/log/v2ray
        cp "${VSRC_ROOT}/vpoint_vmess_freedom.json" "${CROOT}/etc/v2ray/config.json"
        if [[ $? -ne 0 ]]; then
            colorEcho ${YELLOW} "Failed to create V2Ray configuration file. Please create it manually."
            return 1
        fi
        let PORT=$RANDOM+10000     # 随机数RANDOM范围是0~32767，PC端口范围0~65535
        UUID=$(cat /proc/sys/kernel/random/uuid)  # 产生随机UUID

        # 将10086替换为PORT的内容，替换文件是/etc/v2ray/config.json
        sed -i "s/10086/${PORT}/g" "${CROOT}/etc/v2ray/config.json"
        # 将 23ad6b10-8d1a-40f7-8ad0-e3e35cd38297 替换为 UUID的内容。第一个//表示要替换内容，第二个//是替换内容
        # g指文件中所有的匹配项。最后的项目是被操作文件。前面的s 是替换匹配内容。 -i也是替换。
        sed -i "s/23ad6b10-8d1a-40f7-8ad0-e3e35cd38297/${UUID}/g" "${CROOT}/etc/v2ray/config.json"

        colorEcho ${BLUE} "PORT:${PORT}"
        colorEcho ${BLUE} "UUID:${UUID}"
    fi
    return 0
}


installInitScript(){
    if [[ -n "${SYSTEMCTL_CMD}" ]];then
        if [[ ! -f "${CROOT}/etc/systemd/system/v2ray.service" ]]; then
            if [[ ! -f "${CROOT}/lib/systemd/system/v2ray.service" ]]; then
                cp "${VSRC_ROOT}/systemd/v2ray.service" "${CROOT}/etc/systemd/system/"
                systemctl enable v2ray.service
            fi
        fi
        return
    elif [[ -n "${SERVICE_CMD}" ]] && [[ ! -f "/etc/init.d/v2ray" ]]; then
        installSoftware "daemon" || return $?
        cp "${VSRC_ROOT}/systemv/v2ray" "${CROOT}/etc/init.d/v2ray"
        chmod +x "${CROOT}/etc/init.d/v2ray"
        update-rc.d v2ray defaults
    fi
    return
}



main(){
    #helping information
     
    
    installV2Ray || return $?
    installInitScript || return $?
    if [[ ${V2RAY_RUNNING} -eq 1 ]];then
        colorEcho ${BLUE} "Restarting V2Ray service."
        startV2ray
    fi
    colorEcho ${GREEN} "V2Ray ${NEW_VER} is installed."
    #rm -rf /tmp/v2ray
    return 0
}

main