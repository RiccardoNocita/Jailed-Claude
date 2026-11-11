# Exposed Paths Scenario

## Description
Make selected folders/files **outside** your project visible to Claude (e.g. the Maven cache in `~/.m2`), using `JAILED_EXPOSE_PATHS`.

- LLM model: **any**
- network isolation: **any**
- directory isolation: ✅ (plus exposed paths 🔓)

By default the jail only mounts the working dir and `~/.claude{,.json}`: everything else in `$HOME` is invisible. Let’s suppose we are working on a Maven project and we don't want every `mvn` run inside the container to download the whole internet again: we want to reuse the local repository in `~/.m2`. We'd also like git inside the container to know who we are, without letting it change our `~/.gitconfig`.

```bash
$HOME/
├── .m2/                 # Maven local repository (+ settings.xml)
├── .gitconfig
└── my-project/          # working dir
    ├── src/
    └── pom.xml
``````

## Commands

### Option 1: from the environment (per run)

Set the variable when launching. Paths are colon separated and must be absolute or start with `~/`. Each path is mounted **read-write** by default; put an `ro` token right after it to mount it read-only (same syntax as `docker -v`).

```bash
cd my-project
JAILED_EXPOSE_PATHS="~/.m2:~/.gitconfig:ro" jailed-claude
``````

> A leading `~` is expanded by the wrapper too, so it works even inside quotes or in a conf file (where no shell expansion happens).

### Option 2: from a conf file (every time the profile is selected)

Add the key to a profile, e.g. "maven.conf". It is **not** passed to the container: it is only used by the wrapper.

```bash
cat > $HOME/.local/share/jailed-claude/conf/maven.conf <<'EOF'
JAILED_EXPOSE_PATHS=~/.m2:~/.gitconfig:ro
EOF
``````

```bash
jailed-claude
``````

```bash
Select a configuration file

# maven.conf
``````

> If both are set, the two lists are **merged** (duplicates ignored).

### Result

Whichever option you choose, the wrapper confirms what it has exposed:

```bash
>> Exposed paths (2): ~/.m2(rw) ~/.gitconfig(ro)
``````

Let's start coding! 💻

> **What you get:** each listed path is bind-mounted at the **same path** inside the container. Since `HOME` inside the container is your host home, `mvn` finds `~/.m2` where it expects it: already downloaded artifacts are reused and new ones are written back to your host cache.
>
> **Guard rails** — an entry is refused (with a `!!` warning) when it would defeat the jail:
> - `/`, your home itself or any of its parents (e.g. `/home`);
> - system paths (`/etc`, `/usr`, `/var`, `/run`, `/proc`, `/sys`, `/dev`, ...);
> - container runtime sockets (`docker.sock`, `podman.sock`, `containerd.sock`): they would let Claude escape the jail;
> - anything overlapping the working dir (it is already mounted, and re-mounting it would bypass `JAILED_HIDDEN_PATHS`) or `~/.claude{,.json}` (managed by the jail).
>
> Missing paths, relative paths and entries containing `..` are skipped. Symlinks are resolved: the real target is checked and mounted at the path you listed.
>
> **Notes:**
> - an exposed path is **really** shared with the host: with `rw`, whatever happens inside the container (including an unfortunate `rm -rf`) happens to your files. Prefer `ro` whenever writing is not needed;
> - `~/.m2/settings.xml` may hold repository credentials: exposing `~/.m2` makes them readable by Claude. If that's a concern, keep the credentials elsewhere or expose only `~/.m2/repository`;
> - check the `Exposed paths` line to be sure everything you expected is listed.
