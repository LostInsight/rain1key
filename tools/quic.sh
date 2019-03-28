#!/bin/bash
backup="/etc/rain/rain_backup.conf"
. $backup
if [[ $v2ray_transport -ge 13 ]]; then
	tmp_transport=$(($v2ray_transport +6))
	sed -i "18s/=$v2ray_transport/=$tmp_transport/" $backup
fi
v2ray update.sh
