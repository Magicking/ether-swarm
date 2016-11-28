#!/bin/sh

PWD_FILE=`mktemp`
ENV_FILE="/env.sh"
echo "${ACCOUNT_PASSWORD}" > "$PWD_FILE"

if ! [ "$#" -gt 0 ]; then
  exec "$@"
fi

if [ -f "${ENV_FILE}" ]; then
 . "${ENV_FILE}"
fi

import_genesis() {
  if [ -f "${GG_PATH_GENESIS}" ]; then
    /geth --datadir "${DATA_DIR}" init "${GG_PATH_GENESIS}" || exit 1
  else
    echo "Base genesis configuration not found please run utils init first"
    exit 1
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
    echo "Consuming ${key}"
    rm -v "${key}"
    etherbase=`echo -n ${key} | grep -o '0x.*'`
cat > "${ENV_FILE}" <<HEREDOC
#!/bin/sh

ETHERBASE="${etherbase}"
HEREDOC
  chmod +x "${ENV_FILE}"
    break
  done
}

if ! [ -d "${DATA_DIR}"/chainstate ]; then
  import_genesis
fi
if [ x"${ETHERBASE}" == "x" ]; then
  import_keys
  . "${ENV_FILE}"
fi

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
