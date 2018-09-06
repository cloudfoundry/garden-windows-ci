#!/usr/bin/env bash

set -e

GOLANG_VERSION=1.11
GOLANG_DOWNLOAD_URL=https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz
GOLANG_DOWNLOAD_SHA256=b3fcf280ff86558e0559e185b601c9eade0fd24c900b4c63cd14d1d38613e499

GODIR="/usr/local/src/go"
rm -rf $GODIR

curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
    && echo "$GOLANG_DOWNLOAD_SHA256  golang.tar.gz" | sha256sum -c - \
    && tar -C "$(dirname $GODIR)" -xzf golang.tar.gz \
    && rm golang.tar.gz
