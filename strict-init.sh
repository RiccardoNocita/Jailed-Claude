#!/usr/bin/env bash
#
# jailed-claude --strict sidecar init.
#
# Runs as PID 1 of the sidecar container (root, --cap-drop=ALL --cap-add=NET_ADMIN)
# and pins the egress of THIS network namespace to a single {ips}:port via nftables:
# only loopback, established/related traffic and new TCP connections to the target
# set are accepted; everything else (other IPs, UDP, ICMP, all IPv6) is dropped by
# chain policy. The main container later joins this netns WITHOUT NET_ADMIN, so the
# jailed workload cannot modify or flush these rules.
#
# Fail-closed: any validation failure exits non-zero BEFORE the ready marker is
# created, so the wrapper's readiness wait times out and aborts the launch.

set -euo pipefail

READY=/run/jailed-strict-ready
IPS="${STRICT_TARGET_IPS:-}"
PORT="${STRICT_TARGET_PORT:-}"

fail() { echo "!! strict-init: $*" >&2; exit 1; }

[[ -n "$IPS" ]] || fail "STRICT_TARGET_IPS not set"
if ! [[ "$PORT" =~ ^[0-9]{1,5}$ ]]; then fail "invalid STRICT_TARGET_PORT: '$PORT'"; fi
if (( PORT < 1 || PORT > 65535 )); then fail "STRICT_TARGET_PORT out of range: $PORT"; fi

ipset=""
for ip in $IPS; do
  [[ "$ip" =~ ^([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})$ ]] || fail "invalid IPv4 address: '$ip'"
  for o in "${BASH_REMATCH[@]:1}"; do
    if (( 10#$o > 255 )); then fail "octet out of range in '$ip'"; fi
  done
  ipset+="${ipset:+, }$ip"
done

command -v nft >/dev/null 2>&1 || fail "'nft' not found — rebuild the image (docker build -t <image> -f Dockerfile.jailed-claude .)"

cat <<EOF | nft -f - || fail "failed to apply the nftables ruleset (kernel nf_tables support?)"
table inet jailed {
	# Egress is pinned: only loopback, established/related and new TCP to the
	# target set are accepted below. Everything else — other IPs, UDP, ICMP
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
		ip daddr { $ipset } tcp dport $PORT accept
	}
}
EOF

touch "$READY"
echo ">> strict-init: egress pinned to {${ipset}}:$PORT — ready." >&2

# Sleep forever. Background+wait so a SIGTERM (docker stop) is handled promptly.
while :; do sleep 3600 & wait $!; done
