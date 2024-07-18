#!/bin/sh

set -eu

readonly REDMINED_FILE_URL=https://raw.githubusercontent.com/hidakatsuya/redmined/main/redmined

install() {
    local dir=$1

    if [ ! -d $dir ]; then
        return 1
    fi

    if command -v wget > /dev/null; then
        wget -q -P $dir $REDMINED_FILE_URL
    elif command -v curl > /dev/null; then
        curl -sL -o $dir/redmined $REDMINED_FILE_URL
    else
        abort "wget or curl is required."
    fi

    chmod +x $dir/redmined

    echo "Installed redmined to $dir"
}

abort() {
    local message=$1
    echo "Failed to install redmined: $message"
    exit 1
}

install ~/.local/bin || install ~/bin || abort "~/.local/bin and ~/bin are not found."
