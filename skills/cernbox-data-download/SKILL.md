---
name: cernbox-data-download
description: Download datasets from CERNBox-backed EOS user/project paths to local storage. Use when the user gives a CERNBox web URL such as cernbox.cern.ch/files/spaces/eos/... or an EOS path such as /eos/user/... and asks to download, sync, mirror, resume, or verify data on this machine.
---

# CERNBox Data Download

## Workflow

1. Translate CERNBox web URLs to EOS paths:
   - `https://cernbox.cern.ch/files/spaces/eos/user/x/xia/Run_Data`
   - becomes `/eos/user/x/xia/Run_Data`
2. Check local tools and credentials:
   - Prefer `eos root://eosuser.cern.ch ...` for `/eos/user/...`.
   - Use `klist` to check Kerberos tickets.
   - If unauthenticated, ask the user to run `kinit <cern-username>@CERN.CH` in their terminal. Do not ask for or accept CERN passwords in chat.
   - A repeated warning like `TLS: Unable to use cert+key file /tmp/x509up_u...` is acceptable if Kerberos access works.
3. Confirm the destination path:
   - Use `readlink -f <destination>` because user paths under `/home/.../data` may resolve through symlinks to `/data_ilc/...` or `/grid_mnt/data__DATA/...`.
   - If the resolved destination is outside the normal sandbox, request escalation before writing.
4. List the remote directory before copying:
   - `eos root://eosuser.cern.ch ls -l <eos-path>`
   - `eos root://eosuser.cern.ch find -f <eos-path>`
5. For directories, use the bundled script rather than relying on remote globs. `eos cp -r <path>/* <dst>` may fail because the glob can be expanded against localhost.
6. After download, verify:
   - remote file count equals local file count
   - local top-level directory count is plausible
   - `du -sh <destination>` is nonzero and expected
   - no zero-byte files exist unless the remote also has zero-byte files

## Bundled Script

Use `scripts/download_eos_tree.sh` for resumable directory downloads.

```bash
bash /path/to/skill/scripts/download_eos_tree.sh \
  /eos/user/x/xia/Run_Data \
  /home/llr/ilc/shi/data/SiWECAL-Prototype/TB2026-06/Comission/source_asu
```

The script:

- creates local subdirectories
- copies files one by one with `eos root://eosuser.cern.ch cp`
- skips existing non-empty files
- prints a final local count, remote count, local size, and zero-byte-file check

## Safety

- Never collect CERN passwords in chat.
- Prefer resumable copy behavior over deleting and restarting.
- Do not remove existing local files unless the user explicitly asks.
- If a download fails midway, rerun the same script; it skips completed non-empty files.
