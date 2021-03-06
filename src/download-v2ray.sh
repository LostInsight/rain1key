_get_latest_version() {
	v2ray_latest_ver="$(curl -H 'Cache-Control: no-cache' -s https://api.github.com/repos/v2ray/v2ray-core/releases/latest | jq -r .tag_name)"

	if [[ ! $v2ray_latest_ver ]]; then
		echo
		echo -e " $red获取 V2Ray 最新版本失败!!!$none"
		echo
		echo -e " 请尝试执行如下命令: $green echo 'nameserver 8.8.8.8' >/etc/resolv.conf $none"
		echo
		echo " 然后再重新运行脚本...."
		echo
		exit 1
	fi
}

_download_v2ray_file() {
	_get_latest_version
	[[ -d /tmp/rain ]] && rm -rf /tmp/rain
	mkdir -p /tmp/rain
	v2ray_tmp_file="/tmp/rain/rain.zip"
	v2ray_download_link="https://github.com/v2ray/v2ray-core/releases/download/$v2ray_latest_ver/v2ray-linux-${v2ray_bit}.zip"

	if ! wget --no-check-certificate -O "$v2ray_tmp_file" $v2ray_download_link; then
		echo -e "
        $red 下载 V2Ray 失败啦..可能是你的 VPS 网络太辣鸡了...请重试...$none
        " && exit 1
	fi

	unzip $v2ray_tmp_file -d "/tmp/rain/"
	mkdir -p /usr/bin/rain
	cp -f "/tmp/rain/v2ray" "/usr/bin/rain/rain"
	chmod +x "/usr/bin/rain/rain"
	cp -f "/tmp/rain/v2ctl" "/usr/bin/rain/v2ctl"
	chmod +x "/usr/bin/rain/v2ctl"
}

_install_v2ray_service() {
	if [[ $systemd ]]; then
		#cp -f "/tmp/rain/systemd/system/v2ray.service" "/lib/systemd/system/rain.service"
		#sed -i "s/on-failure/always/" /lib/systemd/system/rain.service
		#sed -i "s/v2ray/rain/g" /lib/systemd/system/rain.service

		cat >/lib/systemd/system/rain.service<<EOF
[Unit]
Description=V2Ray Service
Documentation=https://www.rain.com/ https://www.v2fly.org/
After=network.target nss-lookup.target

[Service]
# If the version of systemd is 240 or above, then uncommenting Type=exec and commenting out Type=simple
#Type=exec
Type=simple
# This service runs as root. You may consider to run it as another user for security concerns.
# By uncommenting User=nobody and commenting out User=root, the service will run as user nobody.
# More discussion at https://github.com/rain/rain-core/issues/1011
User=root
#User=nobody
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/bin/rain/rain -config /etc/rain/config.json
Restart=always

[Install]
WantedBy=multi-user.target
EOF
		systemctl enable rain
	else
		apt-get install -y daemon
		cp "/tmp/rain/systemv/v2ray" "/etc/init.d/rain"
		chmod +x "/etc/init.d/rain"
		update-rc.d -f rain defaultsv2ray
	fi
}

_update_v2ray_version() {
	_get_latest_version
	if [[ $v2ray_ver != $v2ray_latest_ver ]]; then
		echo
		echo -e " $green 咦...发现新版本耶....正在拼命更新.......$none"
		echo
		_download_v2ray_file
		do_service restart v2ray
		echo
		echo -e " $green 更新成功啦...当前 V2Ray 版本: ${cyan}$v2ray_latest_ver$none"
		echo
		echo -e " $yellow 温馨提示: 为了避免出现莫名其妙的问题...V2Ray 客户端的版本最好和服务器的版本保持一致$none"
		echo
	else
		echo
		echo -e " $green 木有发现新版本....$none"
		echo
	fi
}

_mkdir_dir() {
	mkdir -p /var/log/rain
	mkdir -p /etc/rain
}
