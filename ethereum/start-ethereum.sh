#!/bin/sh

GETH=/geth
DATA_DIR=/data
GENESIS_PATH="${DATA_DIR}/genesis.conf"
SVC_ENDPOINT="${SVC_URI}/blockchain/info"
EPOCH0_FILE="full-R23-0000000000000000"
EPOCH0_URL="${SVC_CACHE_URI}/dag/${EPOCH0_FILE}"
ETHASH_DIR="/root/.ethash" #TODO switch to proper user

mkdir -vp "${DATA_DIR}"

import_genesis() {
  while true; do
    curl -sL "${SVC_ENDPOINT}" | python -c \
    "import sys, json; print(json.dumps(json.load(sys.stdin)['genesis']))" > \
    "$GENESIS_PATH"
    file_size=$(wc -c < "$GENESIS_PATH")
    if [ $file_size -gt 1 ] && \
        "$GETH" --datadir "${DATA_DIR}" init "${GENESIS_PATH}"; then
      break
    fi
    echo "Waiting 5 secs: ${SVC_ENDPOINT}"
    sleep 5
  done
}

import_ethash() {
  while true; do
    curl -sL "${EPOCH0_URL}" -o "${ETHASH_DIR}/${EPOCH0_FILE}"
    if [ -f "${ETHASH_DIR}/${EPOCH0_FILE}" ]; then
      break
    fi
    echo "Waiting 5 secs: ${EPOCH0_URL}"
    sleep 5
  done
}

import_key() {
  pkey_file=$(mktemp)
  password_file=$(mktemp)
  echo "${PASSWORD}" > "${password_file}"
  echo "${PRIVATE_KEY}" > "${pkey_file}"
  /geth --datadir "${DATA_DIR}" --password "${password_file}" account import "${pkey_file}"
  rm "${pkey_file}"
  rm "${password_file}"
}

if ! [ -d "${DATA_DIR}"/geth/chaindata ]; then
  echo "Importing genesis"
  import_genesis
fi

# wait for bootnode to be populated
enode_file=$(mktemp)
while true; do
  curl -sL "${SVC_ENDPOINT}" | python -c \
  "import sys, json; print(','.join(json.load(sys.stdin)['bootnodes_urls']))" > \
  "$enode_file"
  file_size=$(wc -c < "$enode_file")
  if [ $file_size -gt 1 ]; then
    break
  fi
  echo "Waiting 5 secs: ${SVC_ENDPOINT}"
  sleep 5
done
enodes_list=$(cat "$enode_file")
rm "$enode_file"

networkid_file=$(mktemp)
while true; do
  curl -sL "${SVC_ENDPOINT}" | python -c \
  "import sys, json; print(json.load(sys.stdin)['networkid'])" > \
  "$networkid_file"
  file_size=$(wc -c < "$networkid_file")
  echo "file_size 2 $file_size"
  if [ $file_size -gt 1 ]; then
    break
  fi
  echo "file_size 2 $file_size"
  echo "Waiting 5 secs: ${SVC_ENDPOINT}"
  sleep 5
done
networkid=$(cat "$networkid_file")
rm "$networkid_file"

if [ x"${PASSWORD}" != "x" ] && [ x"${PRIVATE_KEY}" != "x" ]; then
  import_key
fi

if [ x"${ETHERBASE}" != "x" ]; then
  mineopts="--autodag --mine --minerthreads 1 --etherbase ${ETHERBASE}"
  echo "Importing ethash"
  mkdir "${ETHASH_DIR}"
  import_ethash
fi

# start geth
exec /geth \
--datadir "${DATA_DIR}" \
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
--networkid "$networkid" \
--nat none \
$mineopts \
--jitvm false
