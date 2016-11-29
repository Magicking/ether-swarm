#!/bin/sh

KEY_ENV="/ethvol/nodes.sh"
KEY_FILE="/node.key"

if ! [ -f "${KEY_FILE}" ]; then
  pubkey=`/bootnode --writeaddress --genkey="${KEY_FILE}"`
cat > "${KEY_ENV}" <<HEREDOC
#!/bin/sh

BOOTNODE_PUBKEY="${pubkey}"
HEREDOC
  chmod +x "${KEY_ENV}"
fi

exec /bootnode --addr="0.0.0.0:30303" --nodekey="${KEY_FILE}"
