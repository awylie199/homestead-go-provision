#!/bin/bash

INLINE_BOLD=$(tput bold)
BOLD () {
    tput bold
}
INLINE_NORMAL=$(tput sgr0)
NORMAL () {
    tput sgr0
}

GO_BIN_FOLDER="/usr/local/"
PROVISIONER=${1:-"vagrant"}
GO_FOLDER="/home/${PROVISIONER}/go"
CHECKSUM_SHA256=${2:-""}
GO_VERSION=${3:-'1.8'}
GO_ARCH=${4:-'amd64'}
GO_OS=${5:-'linux'}
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
tar -C /usr/local -xzf "$GO_FILE"

[[ ! -d "/home/vagrant/go" ]] && mkdir -p "/home/$PROVISIONER/go/bin"

echo "PATH=\$PATH:${GO_BIN_FOLDER}go/bin" >> "/home/$PROVISIONER/.profile"
echo "GOPATH=${GO_FOLDER}" >> "/home/$PROVISIONER/.profile"
echo "PATH=\$PATH:/home/$PROVISIONER/go/bin" >> "/home/${PROVISIONER}/.profile"
echo "export GOPATH" >> "/home/$PROVISIONER/.profile"
source "/home/$PROVISIONER/.profile"
chown -R $PROVISIONER:$PROVISIONER $GO_FOLDER
printf "Go successfully provisioned on Homestead"
