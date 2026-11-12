# Changelog

---
## Unreleased

### Added
- `JAILED_HIDDEN_PATHS`: hide files/folders of the working dir behind empty decoys mounted from `/tmp`; settable from the host env and/or the selected conf file (lists are merged)
- `JAILED_STRICT_ALLOWED_HOSTS`: extra endpoints (`host`, `host:port`, `ip`, `ip:port`; comma/space separated) allowed in `--strict` mode on top of the `ANTHROPIC_BASE_URL` one; settable from the host env and/or the selected conf file (lists are merged). Entries without a port allow every TCP port of that host

### Changed
- `--strict` sidecar protocol: `strict-init.sh` now takes a single `STRICT_ALLOW` list


---

## 1.1.1

### Improved
- Minor fix loading logo
- Docs IDE integration

## 1.1.0

### Improved
- Implemented strict mode
- fzf auto install
- Minor fixes

## 1.0.2

### Improved
- Enhanced read-permission granularity in claude folder.
- Upgraded the base image version.

## 1.0.1

- Project Init