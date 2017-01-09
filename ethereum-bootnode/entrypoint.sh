#!/bin/sh

KEY_FILE="/node.key"
SVC_ENDPOINT="${SVC_URI}/blockchain/bootnode" #TODO

if ! [ -f "${KEY_FILE}" ]; then
  pubkey=$(/bootnode --writeaddress --genkey="${KEY_FILE}")
  ip=$(ip -4 -o a show | grep 172 | sed -e 's:\/.*::g' -e 's:.*inet ::')
  while true; do
    code=$(curl -sL -X POST "${SVC_ENDPOINT}?enode_url=enode:%2F%2F${pubkey}%40${ip}:${BOOTNODE_PORT}")
    if [ x"$code" == "xtrue" ]; then
        break
    fi
    echo "Waiting 5 secs: ${SVC_ENDPOINT}"
    sleep 5
  done
fi

exec /bootnode --addr="0.0.0.0:${BOOTNODE_PORT}" --nodekey="${KEY_FILE}"
