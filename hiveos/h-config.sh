#!/usr/bin/env bash
# FreeForGem-VELA — see LICENSE
# Called by HiveOS with the flight sheet variables; writes the miner arguments to $CUSTOM_CONFIG_FILENAME.
#   Pool URL      (CUSTOM_URL)         one or more, space separated (the first = primary, the others = failover):
#                                      http://159.69.194.46:3349 (AriaPool), stratum+tcp://vela.suprnova.cc:7601 (suprnova),
#                                      stratum+ssl://vela.suprnova.cc:7604 (suprnova over TLS),
#                                      http://rpcuser:rpcpass@NODE:PORT (solo, own node)
#   Wallet/worker (CUSTOM_TEMPLATE)    %WAL%.%WORKER_NAME%  (or just %WAL%)
#   Pass          (CUSTOM_PASS)        normally empty (x)
#   Extra config  (CUSTOM_USER_CONFIG) extra arguments, e.g. --mode balance   --auto-uv   --lock-cclock 1500   --devices 0,1   --pl 135
#                                      add  --cmp-unlock-driver  to install the CMP-unlock NVIDIA driver on CMP rigs (see h-run.sh)
cd "$(dirname "$0")"
. ./h-manifest.conf

pools=""
for u in ${CUSTOM_URL:-}; do pools+=" --pool $u"; done
tpl=${CUSTOM_TEMPLATE:-}
[[ -z $tpl ]] && tpl=${WORKER_NAME:+%WAL%.$WORKER_NAME}
[[ -z ${CUSTOM_URL:-} ]] && echo "ffgv: Pool URL is empty in the flight sheet" >&2
[[ -z $tpl ]] && echo "ffgv: Wallet template is empty in the flight sheet" >&2

echo "$pools --user $tpl --pass ${CUSTOM_PASS:-x} ${CUSTOM_USER_CONFIG:-}" > "$CUSTOM_CONFIG_FILENAME"
