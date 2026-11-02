#!/usr/bin/env bash
set -euo pipefail

CONTAINER="vpn-sidecar"
# WebUI is published on the LAN IP only (compose: ${LAN_IP}:8112), not localhost
DELUGE_HOST="${DELUGE_HOST:-http://192.168.1.2:8112}"
# Password lives in /etc/proton-portforward.env (chmod 600), not in git.
[ -r /etc/proton-portforward.env ] && . /etc/proton-portforward.env
: "${DELUGE_PASSWORD:?set DELUGE_PASSWORD in /etc/proton-portforward.env}"
COOKIE_FILE="/run/proton-portforward.cookie"
REQUESTED_LIFETIME=60
GATEWAY="10.2.0.1"

log() { echo "$(date '+%F %T %Z'): $*"; }

command -v docker >/dev/null || { log "docker not found"; exit 0; }
command -v nsenter >/dev/null || { log "nsenter not found"; exit 0; }
command -v natpmpc >/dev/null || { log "natpmpc not found"; exit 0; }

PID="$(docker inspect --format '{{.State.Pid}}' "$CONTAINER" 2>/dev/null || true)"
if [[ -z "$PID" || "$PID" == "0" ]]; then
  log "container $CONTAINER not running, skip"
  exit 0
fi

TCP_OUT="$(nsenter -n -t "$PID" natpmpc -a 1 0 tcp "$REQUESTED_LIFETIME" -g "$GATEWAY" 2>&1 || true)"
PORT="$(grep -oP 'Mapped public port \K[0-9]+' <<<"$TCP_OUT" | head -n1 || true)"

if [[ -z "$PORT" ]]; then
  log "NAT-PMP TCP request failed: $TCP_OUT"
  exit 0
fi

# Mirror same port for UDP
nsenter -n -t "$PID" natpmpc -a 1 "$PORT" udp "$REQUESTED_LIFETIME" -g "$GATEWAY" >/dev/null 2>&1 || true

rm -f "$COOKIE_FILE"
touch "$COOKIE_FILE"
chmod 600 "$COOKIE_FILE"

AUTH="$(curl -fsS -c "$COOKIE_FILE" -b "$COOKIE_FILE" \
  -X POST "$DELUGE_HOST/json" \
  -H "Content-Type: application/json" \
  -d "{\"method\":\"auth.login\",\"params\":[\"$DELUGE_PASSWORD\"],\"id\":1}" || true)"

if ! grep -q '"result": true' <<<"$AUTH"; then
  log "Deluge auth failed (WebUI unreachable at $DELUGE_HOST?)"
  exit 1
fi

RESULT="$(curl -fsS -b "$COOKIE_FILE" \
  -X POST "$DELUGE_HOST/json" \
  -H "Content-Type: application/json" \
  -d "{\"method\":\"core.set_config\",\"params\":[{\"listen_ports\":[$PORT,$PORT],\"random_port\":false}],\"id\":2}" || true)"

log "renewed port $PORT; Deluge sync result: $RESULT"
