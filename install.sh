#!/usr/bin/env bash
set -e

git clone https://github.com/anbe-on/ffff.git ffff-temp
cd ffff-temp
make install
cd -
rm -rf ffff-temp

CONFIG="${HOME}/.bashrc"
if ! grep -Fq 'f() {' "$CONFIG"; then
cat << 'EOF' >> "$CONFIG"

# fff shortcut with cd-on-exit and history append
f() {
    local prev_dir="$PWD"
    local cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/fff"
    fff "$@"
    local new_dir
    new_dir="$(cat "$cache_dir/.fff_d")"
    if [[ "$new_dir" != "$prev_dir" ]]; then
        cd "$new_dir"
        history -a
        history -s "cd $PWD"
        shopt -s histappend
        history -w "$HISTFILE"
    fi
}
EOF
fi
