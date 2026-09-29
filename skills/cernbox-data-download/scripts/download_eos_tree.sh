#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  download_eos_tree.sh <eos-source-or-cernbox-url> <destination> [mgm]

Examples:
  download_eos_tree.sh /eos/user/x/xia/Run_Data /path/to/source_asu
  download_eos_tree.sh https://cernbox.cern.ch/files/spaces/eos/user/x/xia/Run_Data /path/to/source_asu

The default MGM is root://eosuser.cern.ch.
USAGE
}

if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
  usage >&2
  exit 2
fi

src="$1"
dst="$2"
mgm="${3:-root://eosuser.cern.ch}"

case "$src" in
  https://cernbox.cern.ch/files/spaces/eos/*)
    src="/eos/${src#https://cernbox.cern.ch/files/spaces/eos/}"
    ;;
  http://cernbox.cern.ch/files/spaces/eos/*)
    src="/eos/${src#http://cernbox.cern.ch/files/spaces/eos/}"
    ;;
esac

if ! command -v eos >/dev/null 2>&1; then
  echo "ERROR: eos command is not available in PATH." >&2
  exit 127
fi

if ! klist >/dev/null 2>&1 && [ ! -e "/tmp/x509up_u$(id -u)" ]; then
  echo "ERROR: no Kerberos ticket or X509 proxy found." >&2
  echo "Run: kinit <cern-username>@CERN.CH" >&2
  exit 1
fi

mkdir -p "$dst"

echo "MGM: $mgm"
echo "Source: $src"
echo "Destination: $dst"
echo

remote_list="$(mktemp)"
trap 'rm -f "$remote_list"' EXIT

eos "$mgm" find -f "$src" > "$remote_list"

while IFS= read -r file; do
  case "$file" in
    "$src"/*) ;;
    *) continue ;;
  esac

  rel="${file#"$src"/}"
  out="$dst/$rel"
  mkdir -p "$(dirname "$out")"

  if [ -s "$out" ]; then
    echo "SKIP $rel"
    continue
  fi

  echo "COPY $rel"
  eos "$mgm" cp "$file" "$out"
done < "$remote_list"

remote_count="$(grep -c "^$src/" "$remote_list" || true)"
local_count="$(find "$dst" -type f | wc -l)"
zero_count="$(find "$dst" -type f -size 0 | wc -l)"

echo
echo "Remote files: $remote_count"
echo "Local files:  $local_count"
echo "Local size:   $(du -sh "$dst" | awk '{print $1}')"
echo "Zero-byte local files: $zero_count"

if [ "$remote_count" != "$local_count" ]; then
  echo "WARNING: remote and local file counts differ." >&2
  exit 3
fi

if [ "$zero_count" != "0" ]; then
  echo "WARNING: zero-byte local files found." >&2
  exit 4
fi

echo "Done."
