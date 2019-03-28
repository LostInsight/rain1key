_rm() {
	rm -rf "$@"
}
_cp() {
	cp -f "$@"
}
_sed() {
	sed -i "$@"
}
_mkdir() {
	mkdir -p "$@"
}

_load() {
    local _dir="/etc/rain/repo/src/"
    . "${_dir}$@"
}