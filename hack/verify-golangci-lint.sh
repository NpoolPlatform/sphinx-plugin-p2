#!/usr/bin/env bash
MY_PATH=`cd $(dirname $0);pwd`
ROOT_PATH=$MY_PATH/../
LINT_BIN=${ROOT_PATH}/bin
source $MY_PATH/golang-env.sh

go clean --modcache
go mod tidy

set -o errexit
set -o nounset
set -o pipefail

VERSION_NUM=1.61.0
VERSION=v${VERSION_NUM}
URL_BASE=https://raw.githubusercontent.com/golangci/golangci-lint
URL=$URL_BASE/$VERSION/install.sh

if [[ ! -f .golangci.yml ]]; then
    echo 'ERROR: missing .golangci.yml in repo root' >&2
    exit 1
fi

if ! command -v gofumpt; then
    go install mvdan.cc/gofumpt@v0.3.1
fi

PATH=$LINT_BIN:$PATH
set +e
rc=`golangci-lint version | grep $VERSION_NUM`
if [ ! $? -eq 0 ]; then
  set -e
  curl -sfL $URL | sh -s $VERSION -b $LINT_BIN
fi
set -e

go env

golangci-lint version
golangci-lint linters
golangci-lint --verbose run "$@"
