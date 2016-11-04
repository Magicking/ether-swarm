#!/bin/sh

genesis() {
mkdir -vp "${GG_PATH_PKEYS}"
app || exit 1
FIRST_ADDR=`grep -o '"Alloc":{"[^"]\+"' "${GG_PATH_GENESIS}" | cut -d '"' -f4`
cat > "${ENV_FILE}" <<HEREDOC
#!/bin/sh

ETHERBASE="${FIRST_ADDR}"
HEREDOC
chmod +x "${ENV_FILE}"
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
