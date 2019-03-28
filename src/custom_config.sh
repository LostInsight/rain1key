# custom inbounds config
if [[ -f /etc/rain/custom/in.json ]]; then
	custom_config_file="/etc/rain/custom/in.json"
	sed -i "/\/\/include_in_config/r $custom_config_file" $v2ray_server_config
	sed -i "s#//include_in_config#,#" $v2ray_server_config
fi
# custom outbounds config
if [[ -f /etc/rain/custom/out.json ]]; then
	custom_config_file="/etc/rain/custom/out.json"
	sed -i "/\/\/include_out_config/r $custom_config_file" $v2ray_server_config
	sed -i "s#//include_out_config#,#" $v2ray_server_config
fi
# custom rules
if [[ -f /etc/rain/custom/rules.json ]]; then
	custom_rules_file="/etc/rain/custom/rules.json"
	sed -i "/\/\/include_rules/r $custom_rules_file" $v2ray_server_config
	sed -i "s#//include_rules#,#" $v2ray_server_config
fi