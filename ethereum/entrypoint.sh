#!/bin/sh

PWD_FILE=`mktemp`
echo "${ACCOUNT_PASSWORD}" > "$PWD_FILE"

if ! [ "$#" -gt 0 ]; then
  exec "$@"
fi

if ! [ -f "${ENV_FILE}" ]; then
  echo "${ENV_FILE} not present please run"
  echo "docker-compose run utils"
  exit 1
fi

 . "${ENV_FILE}"

if [ x"${ETHERBASE}" == "x" ]; then
  echo "ETHERBASE not set please run"
  echo "docker-compose run utils"
  exit 1
fi

import_genesis() {
  if ! [ -d "${DATA_DIR}" ] && ! [ -f "${GG_PATH_GENESIS}" ]; then
    echo Base dir not existing and genesis configuration not present
    exit 1
  fi
  if [ -f "${GG_PATH_GENESIS}" ]; then
    /geth --datadir "${DATA_DIR}" init "${GG_PATH_GENESIS}"
    rm -v "${GG_PATH_GENESIS}".bak
    mv -v "${GG_PATH_GENESIS}" "${GG_PATH_GENESIS}".bak
  fi
}

import_keys() {
  if [ x"${GG_PATH_PKEYS}" == "x" ]; then
    echo "GG_PATH_PKEYS not set please check"
    echo "docker-compose configuration file"
    exit 1
  fi
  find "${GG_PATH_PKEYS}"/ -type f | while read key; do
    /geth --datadir "${DATA_DIR}" --password "${PWD_FILE}" account import "${key}"
    rm -v "${key}"
  done
}

import_genesis
import_keys

exec /geth \
--datadir "${DATA_DIR}" \
--password "${PWD_FILE}" \
--unlock "${ETHERBASE}" \
--nodiscover \
--maxpeers 0 \
--rpc \
--rpccorsdomain "*" \
--identity "Primary node" \
--ipcapi "admin,db,eth,debug,miner,net,shh,txpool,personal,web3" \
--rpcapi "db,eth,net,web3" \
--rpcaddr "0.0.0.0" \
--ws \
--wsaddr "0.0.0.0" \
--wsapi "db,eth,net,web3" \
--wsorigins "*" \
--autodag \
--networkid 1900 \
--nat none \
--mine \
--minerthreads 1 \
--etherbase "${ETHERBASE}" \
--jitvm false
