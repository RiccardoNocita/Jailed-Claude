# Hidden Paths Scenario

## Description
Hide sensitive files and folders of your project (e.g. `.env` and `secrets/`) from Claude, using `JAILED_HIDDEN_PATHS`.

- LLM model: **any**
- network isolation: **any**
- directory isolation: ✅ (plus hidden paths 🙈)

Let’s suppose we are working on a project like this one, and we don't want Claude to ever read the API keys in `.env` or the certificates in `secrets/`:

```bash
my-project/
├── .env                 # API keys, DB passwords, ...
├── secrets/
│   ├── prod.key
│   └── cert.pem
├── src/
└── package.json
``````

## Commands

### Option 1: from the environment (per run)

Set the variable when launching, from the project root. Paths are colon separated, relative to the working dir (or absolute inside it).

```bash
cd my-project
JAILED_HIDDEN_PATHS=".env:secrets" jailed-claude
``````

### Option 2: from a conf file (every time the profile is selected)

Add the key to a profile, e.g. "hidden.conf". It is **not** passed to the container: it is only used by the wrapper.

```bash
cat > $HOME/.local/share/jailed-claude/conf/hidden.conf <<'EOF'
JAILED_HIDDEN_PATHS=.env:secrets
EOF
``````

```bash
jailed-claude
``````

```bash
Select a configuration file

# hidden.conf
``````

> If both are set, the two lists are **merged** (duplicates ignored): hiding more is always safer.

### Result

Whichever option you choose, the wrapper confirms what it has hidden:

```bash
>> Hidden paths (2): .env secrets
``````

Let's start coding! 💻

> **What you get:** each listed path is bind-mounted, after the working dir, onto an empty **read-only** decoy living in a throwaway folder under `/tmp` (removed on exit). Inside the container:
> - `.env` exists but is an **empty file**;
> - `secrets/` exists but is an **empty folder**;
> - any write to them fails (read-only filesystem), so nothing can be created or modified there;
> - the real content never reaches the container: on the host, your files are untouched.
>
> **Notes:**
> - missing paths, symlinks, entries containing `..` and paths outside the working dir are skipped with a `!!` warning — check the `Hidden paths` line to be sure everything you expected is listed. For a symlink, list its target instead;
> - if some files inside `secrets/` are tracked by git, `git status` inside the container will show them as deleted: that's expected, they are just hidden;
> - the paths are resolved against the directory you launch `jailed-claude` from, so run it from the project root (or use absolute paths inside it).
