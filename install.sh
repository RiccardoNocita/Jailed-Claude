#!/usr/bin/env bash

#     ▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄  ▄▄▄           ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄           ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄           ▄▄▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄      ▄▄▄  ▄▄▄▄▄▄▄▄▄     ▄▄▄▄▄▄▄▄▄▄▄
#     ███  ▄▄▄▄▄▄▄▄▄▄▄▄▄  ███  ███           ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄███        ▄▄▄▄▄▄▄▄▄▄▄  ███           ▄▄▄▄▄▄▄▄▄▄▄▄▄  ███      ███  ▄▄▄▄▄▄▄▄▄███  ▄▄▄▄▄▄▄▄▄▄▄
#     ███            ███  ███  ███                                 ███                     ███                     ███  ███      ███           ███
#     ███  ███       ███  ███  ███           ███▄▄▄▄▄▄    ███      ███        ███          ███           ███       ███  ███      ███  ███      ███  ███▄▄▄▄▄▄
#     ███  ███▄▄▄▄▄▄▄███  ███  ███           ███▄▄▄▄▄▄    ███      ███        ███          ███           ███▄▄▄▄▄▄▄███  ███      ███  ███      ███  ███▄▄▄▄▄▄
#     ███  ███▄▄▄▄▄▄▄███  ███  ███           ███          ███      ███        ███          ███           ███▄▄▄▄▄▄▄███  ███      ███  ███      ███  ███
# ▄▄▄▄███  ███       ███  ███  ███ ▄▄▄▄▄▄▄▄  ███▄▄▄▄▄▄▄▄  ███▄▄▄▄▄▄███        ███▄▄▄▄▄▄▄▄  ███ ▄▄▄▄▄▄▄▄  ███       ███  ███ ▄▄▄▄▄███  ███▄▄▄▄▄▄███  ███▄▄▄▄▄▄▄▄
# ▄▄▄▄███  ███       ███  ███  ███ ▄▄▄▄▄▄▄▄  ███▄▄▄▄▄▄▄▄  ███▄▄▄▄▄▄███        ███▄▄▄▄▄▄▄▄  ███ ▄▄▄▄▄▄▄▄  ███       ███  ███ ▄▄▄▄▄█▄▄  ███▄▄▄▄▄▄███  ███▄▄▄▄▄▄▄▄
#                   ▄▄▄  ▄▄▄▄▄▄     ▄▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄           ▄▄▄           ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄
#                   ███  ▄▄▄▄▄▄     ▄▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄▄▄  ███           ███           ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄
#                   ███        ███                                       ███  ███           ███                                ███
#                   ███  ███   █ █  ███▄▄▄▄▄▄▄▄▄      ███      ███       ███  ███           ███           ███▄▄▄▄▄▄    ███▄▄▄▄▄███
#                   ███  ███   █ █  ███▄▄▄▄▄▄▄▄▄      ███      ███▄▄▄▄▄▄▄███  ███           ███           ███▄▄▄▄▄▄    ███▄▄▄▄▄
#                   ███  ███   ███           ███      ███      ███▄▄▄▄▄▄▄███  ███           ███           ███          ███ ███▌
#                   ███  ███   ███  ▄▄▄▄▄▄▄▄▄███      ███      ███       ███  ███ ▄▄▄▄▄▄▄▄  ███ ▄▄▄▄▄▄▄▄  ███▄▄▄▄▄▄▄▄  ███ ▐███
#                   ███  ███   ███  ▄▄▄▄▄▄▄▄▄▄▄█      ███      ███       ███  ███ ▄▄▄▄▄▄▄▄  ███ ▄▄▄▄▄▄▄▄  ███▄▄▄▄▄▄▄▄  ███  ███▌
#
# Author: <riccardo.noc@gmail.com>
#
# v: 1.1.0
#
# Github repo: https://github.com/RiccardoNocita/Jailed-Claude
#
set -euo pipefail

# ================= CONFIG (edit these) =================
REPO="RiccardoNocita/Jailed-Claude"
BRANCH="${JAILED_CLAUDE_BRANCH:-master}"                 # branch or tag to install from
INSTALL_DIR="${JAILED_CLAUDE_HOME:-$HOME/.local/share/jailed-claude}"
CMD_NAME="jailed-claude"                               # command name to expose on PATH

# Install fzf (fuzzy pickers) if missing (default: enabled).
# Disable with INSTALL_FZF=0|false|no|off.
INSTALL_FZF="${INSTALL_FZF:-1}"
case "${INSTALL_FZF,,}" in
  0|false|no|off) INSTALL_FZF=0 ;;
  1|true|yes|on)  INSTALL_FZF=1 ;;
  *) echo "!! Unrecognized INSTALL_FZF='${INSTALL_FZF}': defaulting to enabled." >&2; INSTALL_FZF=1 ;;
esac

# Repo paths (relative to repo root) that are required to run:
REQUIRED_FILES=("jailed-claude" "Dockerfile.jailed-claude" "strict-init.sh")  # mandatory
REQUIRED_DIRS=("conf")                                       # merged, user additions kept

TARBALL_URL="https://github.com/${REPO}/archive/refs/heads/${BRANCH}.tar.gz"

# ================= helpers =================
download() { # $1=url  $2=dest
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$1" -o "$2"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "$2" "$1"
  else
    echo "!! Need 'curl' or 'wget' to download." >&2; return 1
  fi
}

install_fzf() { # best effort via the system package manager; never fatal
  local sudo=""
  if [[ "$(id -u)" != "0" ]]; then
    if command -v sudo >/dev/null 2>&1; then sudo="sudo"; fi
  fi
  if   command -v brew    >/dev/null 2>&1; then brew install fzf
  elif command -v apt-get >/dev/null 2>&1; then $sudo apt-get update -qq && $sudo apt-get install -y fzf
  elif command -v dnf     >/dev/null 2>&1; then $sudo dnf install -y fzf
  elif command -v yum     >/dev/null 2>&1; then $sudo yum install -y fzf
  elif command -v pacman  >/dev/null 2>&1; then $sudo pacman -S --noconfirm --needed fzf
  elif command -v zypper  >/dev/null 2>&1; then $sudo zypper --non-interactive install fzf
  elif command -v apk     >/dev/null 2>&1; then $sudo apk add fzf
  else
    echo "!! No supported package manager found." >&2; return 1
  fi
}

echo ">> Installing '$CMD_NAME' from ${REPO} (${BRANCH})"

# ================= download + extract =================
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
download "$TARBALL_URL" "$tmp/repo.tar.gz"
tar -xzf "$tmp/repo.tar.gz" -C "$tmp"

# GitHub tarballs extract into a single top-level dir (e.g. <repo>-<branch>)
SRC_ROOT=""
shopt -s nullglob
for d in "$tmp"/*/; do SRC_ROOT="${d%/}"; break; done
shopt -u nullglob
if [[ -z "$SRC_ROOT" || ! -d "$SRC_ROOT" ]]; then
  echo "!! Could not locate the extracted repository." >&2
  exit 1
fi

# ================= install files =================
mkdir -p "$INSTALL_DIR"

for f in "${REQUIRED_FILES[@]}"; do
  if [[ -f "$SRC_ROOT/$f" ]]; then
    cp -f "$SRC_ROOT/$f" "$INSTALL_DIR/$f"
    echo ">> Installed: $INSTALL_DIR/$f"
  else
    echo "!! Missing required file in repo: $f" >&2
    exit 1
  fi
done

for d in "${REQUIRED_DIRS[@]}"; do
  if [[ -d "$SRC_ROOT/$d" ]]; then
    mkdir -p "$INSTALL_DIR/$d"
    cp -Rf "$SRC_ROOT/$d/." "$INSTALL_DIR/$d/"   # merge: keeps your extra .conf files
    echo ">> Installed dir: $INSTALL_DIR/$d"
  else
    echo ">> (no '$d' dir in repo, skipping)"
  fi
done

chmod +x "$INSTALL_DIR/jailed-claude"

# ================= expose on PATH via symlink =================
choose_bin_dir() {
  local IFS=':' d
  case ":$PATH:" in *":$HOME/.local/bin:"*) echo "$HOME/.local/bin"; return ;; esac
  for d in $PATH; do
    [[ -n "$d" && -d "$d" && -w "$d" ]] && { echo "$d"; return; }
  done
  echo "$HOME/.local/bin"
}

BIN_DIR="$(choose_bin_dir)"
mkdir -p "$BIN_DIR"
ln -sf "$INSTALL_DIR/jailed-claude" "$BIN_DIR/$CMD_NAME"
echo ">> Symlink: $BIN_DIR/$CMD_NAME -> $INSTALL_DIR/jailed-claude"

# ================= ensure PATH in new shells =================
rcfile=""
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
  case "${SHELL##*/}" in
    bash) rcfile="$HOME/.bashrc" ;;
    zsh)  rcfile="$HOME/.zshrc"  ;;
    *)    rcfile="$HOME/.profile" ;;
  esac
  if ! grep -qF "$BIN_DIR" "$rcfile" 2>/dev/null; then
    printf '\n# added by jailed-claude install.sh\nexport PATH="%s:$PATH"\n' "$BIN_DIR" >> "$rcfile"
    echo ">> Added $BIN_DIR to PATH in $rcfile"
  fi
fi

# ================= optional: fzf =================
if command -v fzf >/dev/null 2>&1; then
  echo ">> fzf already installed: $(command -v fzf)"
elif [[ "$INSTALL_FZF" == "1" ]]; then
  echo ">> fzf not found: installing it (skip with INSTALL_FZF=0)..."
  if install_fzf && command -v fzf >/dev/null 2>&1; then
    echo ">> Installed: fzf"
  else
    echo "!! Could not install fzf: '$CMD_NAME' will fall back to numeric menus." >&2
    echo "!! Install it manually: https://github.com/junegunn/fzf#installation" >&2
  fi
else
  echo ">> fzf not found (INSTALL_FZF=0): '$CMD_NAME' will use numeric menus."
fi

# ================= runtime hint =================
if ! command -v docker >/dev/null 2>&1; then
  echo "!! WARNING: 'docker' not found in PATH. Install Docker before running '$CMD_NAME'." >&2
fi

echo ""
echo "Done. Open a new shell (or: source ${rcfile:-~/.bashrc}) and run:"
echo "    $CMD_NAME"
