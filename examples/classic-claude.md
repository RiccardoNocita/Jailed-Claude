# Classic Claude Scenario

## Description
Connect to Claude using your own configuration, 

- LLM model: **official remote**
- network isolation: ❌
- directory isolation: ✅

Network isolation **must not be enabled**, otherwise the official model will not work.

## Commands
```bash
jailed-claude
``````

```bash
>> Isolate the container (blackhole the upstream host list)? (Enter = yes, 'n' = no): 

# no
``````

```bash
Select a configuration file

# default.cnf
``````

```bash
Select the model to use

# default
``````

Let’s start coding! 💻