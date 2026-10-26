# Strict Mode Scenario (egress pinning)

## Description
Pin **all** network egress to a single endpoint — the one in `ANTHROPIC_BASE_URL`.

- LLM model: **custom remote**
- network isolation: ✅🔒 hard (L3 firewall, not just DNS)
- directory isolation: ✅

Let’s suppose we want to connect to a local LLM, Qwen3.8-27B and others, that are running at 10.10.10.10:8888 by using unsloth
and you want the guarantee that **nothing else on the network is reachable** — not Anthropic, not telemetry, not any exfiltration endpoint. Not even by raw IP.

## Commands

Create a custom profile named "strict.conf" and select it.

```bash
cat > $HOME/.local/share/jailed-claude/conf/strict.conf <<'EOF'
API_FORCE_IDLE_TIMEOUT=0
API_TIMEOUT_MS="3600000"
ANTHROPIC_BASE_URL="http://10.10.10.10:8888"
ANTHROPIC_AUTH_TOKEN="sk-unsloth-****"
ANTHROPIC_API_KEY=""
JAILED_MODELS=unsloth/Qwen3.8-27B-GGUF,unsloth/Qwen3.6-35B-A3B-GGUF
EOF
``````

```bash
jailed-claude
``````

```bash
>> Select the network isolation mode

# strict
``````

```bash
Select a configuration file

# strict.conf
``````

```bash
Select the model to use

# unsloth/Qwen3.8-27B-GGUF
``````

```bash
>> --strict target: 10.10.10.10 port 8888 -> 10.10.10.10
>> host.docker.internal: NOT mapped (forced off in --strict mode).
>> --strict active: egress pinned to 10.10.10.10 (tcp/8888) — everything else is dropped at L3.
``````

Let's start coding! 💻

> **What you get:** a sidecar applies an nftables ruleset in the shared network namespace that accepts *only* TCP to `10.10.10.10:8888` (plus loopback and established traffic). Every other packet — other IPs, UDP, ICMP, all IPv6 — is dropped at L3. The container itself keeps `--cap-drop=ALL`, so even adversarial code inside the jail cannot flush the ruleset.
>
> **Note:** the pin is per IP:port, not per hostname — with a target behind a CDN/shared IP, other domains on that IP stay reachable. A dedicated private endpoint like `10.10.10.10:8888` avoids this (see *Strict mode → What "one endpoint" really means* in the README).
