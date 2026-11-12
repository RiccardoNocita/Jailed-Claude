#!/usr/bin/env bash
#
# jailed-claude --strict sidecar init.
#
# Runs as PID 1 of the sidecar container (root, --cap-drop=ALL --cap-add=NET_ADMIN)
# and pins the egress of THIS network namespace to an allowlist via nftables:
# only loopback, established/related traffic and new TCP connections to the
# allowed entries are accepted; everything else (other IPs/ports, UDP, ICMP, all
# IPv6) is dropped by chain policy.
#
# STRICT_ALLOW: space-separated entries, "ip:port" (that TCP port only) or "ip"
# (any TCP port of that IPv4 address). The main container later joins this netns WITHOUT NET_ADMIN, so the
# jailed workload cannot modify or flush these rules.
#
# Fail-closed: any validation failure exits non-zero BEFORE the ready marker is
# created, so the wrapper's readiness wait times out and aborts the launch.

set -euo pipefail

READY=/run/jailed-strict-ready
ALLOW="${STRICT_ALLOW:-}"

fail() { echo "!! strict-init: $*" >&2; exit 1; }

[[ -n "$ALLOW" ]] || fail "STRICT_ALLOW not set (wrapper/image version mismatch? rebuild the image)"

rules=""
summary=""
for entry in $ALLOW; do
  ip="${entry%%:*}"
  port=""
  [[ "$entry" == *:* ]] && port="${entry#*:}"
  [[ "$ip" =~ ^([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})$ ]] || fail "invalid IPv4 address: '$entry'"
  for o in "${BASH_REMATCH[@]:1}"; do
    if (( 10#$o > 255 )); then fail "octet out of range in '$entry'"; fi
  done
  if [[ -n "$port" || "$entry" == *: ]]; then
    if ! [[ "$port" =~ ^[0-9]{1,5}$ ]]; then fail "invalid port in '$entry'"; fi
    if (( 10#$port < 1 || 10#$port > 65535 )); then fail "port out of range in '$entry'"; fi
    rules+=$'\t\t'"ip daddr $ip tcp dport $((10#$port)) accept"$'\n'
  else
    rules+=$'\t\t'"ip daddr $ip meta l4proto tcp accept"$'\n'
  fi
  summary+="${summary:+, }$entry"
done

command -v nft >/dev/null 2>&1 || fail "'nft' not found — rebuild the image (docker build -t <image> -f Dockerfile.jailed-claude .)"

cat <<EOF | nft -f - || fail "failed to apply the nftables ruleset (kernel nf_tables support?)"
table inet jailed {
	# Egress is pinned: only loopback, established/related and new TCP to the
	# allowlist are accepted below. Everything else — other IPs, UDP, ICMP
	# and ALL IPv6 traffic — falls through to the drop policy of each chain.
	chain input {
		type filter hook input priority 0; policy drop;
		iifname "lo" accept
		ct state established,related accept
	}
	chain forward {
		type filter hook forward priority 0; policy drop;
	}
	chain output {
		type filter hook output priority 0; policy drop;
		# Docker's embedded DNS (user-defined networks) listens on 127.0.0.11
		# inside this netns and forwards external queries: block it before the
		# loopback accept, or it becomes a DNS exfiltration channel.
		ip daddr 127.0.0.11 drop
		oifname "lo" accept
		ct state established,related accept
$rules	}
}
EOF

touch "$READY"
echo ">> strict-init: egress pinned to {${summary}} (tcp) — ready." >&2

# Sleep forever. Background+wait so a SIGTERM (docker stop) is handled promptly.
while :; do sleep 3600 & wait $!; done
