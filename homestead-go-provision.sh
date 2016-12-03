#!/bin/bash

INLINE_BOLD=$(tput bold)
BOLD () {
    tput bold
}
INLINE_NORMAL=$(tput sgr0)
NORMAL () {
    tput sgr0
}

GO_FOLDER="$HOME/go"
GO_BIN_FOLDER="/usr/local/"
CHECKSUM_SHA256=${1-""}
GO_VERSION=${2:-'1.7.4'}
GO_ARCH=${3:-'amd64'}
GO_OS=${4:-'linux'}
GO_FILE="go${GO_VERSION}.${GO_OS}-${GO_ARCH}.tar.gz"
GO_FILE_URL="https://storage.googleapis.com/golang/${GO_FILE}"
FILE_SHA256=""

cat <<- _INTRO_
 |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 ${INLINE_BOLD}This script installs Go and adds Go folders to the environment${INLINE_NORMAL}
 ---Downloading ${GO_FILE_URL}---
 |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|
_INTRO_

cd /tmp || { printf "Can't enter /tmp directory.\n" && exit 126; }
curl -O "$GO_FILE_URL"

if [[ -n "$CHECKSUM_SHA256" ]]; then
    FILE_SHA256=$(sha256sum "$GO_FILE")

    if [[ "$FILE_SHA256" != "$CHECKSUM_SHA256" ]]; then
        printf "SHA256 Checksum did not match."
        exit 1
    fi
fi

if (( $? != 0 )) || [[ ! -f $GO_FILE ]]; then
    BOLD
    printf "Failed curling Go binary.\n"
    NORMAL
    exit 1;
fi

printf "Unzipping Go to %s\n" ${GO_BIN_FOLDER}
sudo tar -C /usr/local -xzf "$GO_FILE"

PATH=$PATH:$(pwd)/${GO_BIN_FOLDER}
export PATH

[[ ! -d "$HOME/go" ]] && mkdir -p "$HOME/go/bin"

echo "export PATH=\$PATH:${GO_BIN_FOLDER}go/bin" >> ~/.profile
echo "export GOPATH=${GO_FOLDER}" >> ~/.profile

printf "Go successfully provisioned on Homestead"
