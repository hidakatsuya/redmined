#!/bin/sh

set -eu

install() {
    local dir=$1
    if [ ! -d $dir ]; then
        return 1
    fi

    wget -q -P $dir https://raw.githubusercontent.com/hidakatsuya/redmined/main/redmined
    chmod +x $dir/redmined

    echo "Installed redmined to $dir"
}

abort() {
    local extra_message=$1
    echo "Failed to install redmined: $extra_message"
    exit 1
}

install ~/.local/bin || install ~/bin || abort "~/.local/bin and ~/bin are not found."
