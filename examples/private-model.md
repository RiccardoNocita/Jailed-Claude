# Private LLM Scenario

## Description
Connect to a private LLM using a custom configuration

- LLM model: **custom remote**
- network isolation: ✅
- directory isolation: ✅

Let’s suppose we want to connect to a local LLM, Qwen3.8-27B and others, that are running at 10.10.10.10:8888 by using unsloth

## Commands

Create a custom profile named "custom.conf" and select it.

```bash
cat > $HOME/.local/share/jailed-claude/conf/custom.conf <<'EOF'
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
>> Isolate the container (blackhole the upstream host list)? (Enter = yes, 'n' = no): 

# yes or enter
``````

```bash
Select a configuration file

# custom.conf
``````

```bash
Select the model to use

# unsloth/Qwen3.8-27B-GGUF
``````

Let’s start coding! 💻