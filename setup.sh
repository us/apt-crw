#!/bin/sh
# Add the CRW APT repository and install the crw CLI.
#
#   curl -fsSL https://apt.fastcrw.com/setup.sh | sudo sh
#
# Then crw upgrades come with the rest of the system:
#
#   apt update && apt upgrade
set -eu

REPO_URL="https://apt.fastcrw.com"
KEYRING="/usr/share/keyrings/crw.gpg"
SOURCE_LIST="/etc/apt/sources.list.d/crw.list"

if [ "$(id -u)" -ne 0 ]; then
  echo "error: run as root — curl -fsSL $REPO_URL/setup.sh | sudo sh" >&2
  exit 1
fi

if ! command -v apt-get >/dev/null 2>&1; then
  echo "error: this is a Debian/Ubuntu installer and apt-get is missing." >&2
  echo "       use the portable installer instead:" >&2
  echo "       curl -fsSL https://fastcrw.com/install | sh" >&2
  exit 1
fi

# The repo only publishes amd64 and arm64 .debs; fail loudly rather than
# leaving apt with a source it can never resolve.
ARCH="$(dpkg --print-architecture)"
case "$ARCH" in
  amd64 | arm64) ;;
  *)
    echo "error: no crw packages for '$ARCH' (amd64 and arm64 only)." >&2
    echo "       build from source: https://docs.fastcrw.com/installation/" >&2
    exit 1
    ;;
esac

# Slim base images ship without gpg or the HTTPS transport.
MISSING=""
command -v curl >/dev/null 2>&1 || MISSING="$MISSING curl"
command -v gpg >/dev/null 2>&1 || MISSING="$MISSING gnupg"
[ -e /etc/ssl/certs/ca-certificates.crt ] || MISSING="$MISSING ca-certificates"
if [ -n "$MISSING" ]; then
  echo "==> installing prerequisites:$MISSING"
  apt-get update -qq
  # shellcheck disable=SC2086 # intentional word splitting: one package per arg
  apt-get install -y -qq $MISSING
fi

echo "==> adding the CRW signing key"
curl -fsSL "$REPO_URL/gpg.key" | gpg --dearmor --yes -o "$KEYRING"
chmod 644 "$KEYRING"

echo "==> adding the CRW repository"
echo "deb [arch=$ARCH signed-by=$KEYRING] $REPO_URL stable main" > "$SOURCE_LIST"

echo "==> updating package lists"
apt-get update -qq -o Dir::Etc::sourcelist="$SOURCE_LIST" \
  -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0"

echo "==> installing crw"
apt-get install -y -qq crw

echo
echo "crw $(crw --version 2>/dev/null | awk '{print $NF}') installed. Try:"
echo "  crw scrape https://example.com"
echo
echo "Also available: apt install crw-server (REST API) · crw-mcp (MCP server)"
