#!/bin/sh

PWD_FILE=`mktemp`
ENV_FILE="/env.sh"
KEY_ENV="/ethvol/nodes.sh"
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
    if mv "${key}" /node_key; then
      /geth --datadir "${DATA_DIR}" --password "${PWD_FILE}" account import /node_key
      echo "Consuming ${key}"
      etherbase=`echo -n "${key}" | grep -o '0x.*'`
cat > "${ENV_FILE}" <<HEREDOC
#!/bin/sh

ETHERBASE="${etherbase}"
export ETHERBASE
HEREDOC
      chmod +x "${ENV_FILE}"
    fi
    break
  done
}

if ! [ -d "${DATA_DIR}"/geth/chaindata ]; then
  echo "import genesis"
  import_genesis
fi
if [ x"${ETHERBASE}" == "x" ]; then
  import_keys
  if ! [ -f "${ENV_FILE}" ]; then
    echo "No keys founds please run utils init" #TODO Allow to run with no key
    exit 1
  fi
  . "${ENV_FILE}"
fi
if [ x"${ENODE_HOST}" == "x" ]; then
  echo "Bootnode ENODE_HOST variable not set"
  exit 1
fi
if ! [ -f "${KEY_ENV}" ]; then
  echo "Wait few seconds for bootnode to write information"
  sleep 5
  if ! [ -f "${KEY_ENV}" ]; then
    echo "Bootnode information could not be found"
    exit 1
  fi
fi

if [ x"${MINE}" = "x0" ]; then
  mineopts=""
else
  mineopts="--mine --minerthreads 1"
fi

. "${KEY_ENV}"
host_ip=`ping -c 1 -q "${ENODE_HOST}" | grep PING | cut -d '(' -f 2 | cut -d ')' -f 1`
enodes_list="enode://${BOOTNODE_PUBKEY}@${host_ip}:30303"
echo "# $enodes_list #"
exec /geth \
--datadir "${DATA_DIR}" \
--password "${PWD_FILE}" \
--unlock "${ETHERBASE}" \
--maxpeers 100 \
--rpc \
--rpccorsdomain "*" \
--bootnodes "$enodes_list" \
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
$mineopts \
--etherbase "${ETHERBASE}" \
--jitvm false
