#!/bin/sh

genesis() {
mkdir -vp "${GG_PATH_PKEYS}"
app || exit 1
}
usage() {
    echo "Usage: docker-compose run utils init"
}

case "$1" in
init)  genesis
    ;;
*) usage
   ;;
esac
