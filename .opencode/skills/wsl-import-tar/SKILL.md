---
name: wsl-import-tar
description: |
  Idempotent procedure for importing a Linux distribution tar file into WSL2.

  USE WHEN: the user has a .tar file (from `wsl --export`, a Docker container
  export, or community sources such as mvaisakh/wsl-distro-tars) and wants to
  register it as a WSL2 distribution with a chosen default user, install
  location, and WSL version.

  DO NOT USE for: WSL feature enablement, general WSL config, Hyper-V
  configuration, dual-boot setup, or moving an already-imported distro. Those
  are covered by the `wsl-setup` skill.

  IDEMPOTENT CONTRACT: re-running this skill on an already-imported distro is a
  no-op. It detects existing installs, existing VHDx files, and existing
  `/etc/wsl.conf` content, and merges new settings rather than overwriting.
  No data is destroyed on re-run. The only destructive step is the explicit
  `wsl --unregister` call, which requires user confirmation and a flag.
---

# wsl-import-tar

Import a Linux distribution tar file into WSL2 safely and repeatably.

**Base directory for this skill**: `W:\Learning\.opencode\skills\wsl-import-tar/`

## Variables to collect from the user

Collect these up front. Do not invent defaults; ask if any are missing.

| Variable | Example | Notes |
|---|---|---|
| `<DISTRO_NAME>` | `Kali` | Must be a valid registry name: letters, digits, `-`, `_`. No spaces. |
| `<INSTALL_DIR>` | `P:\WSL\Kali` | Windows path. Will hold the resulting `ext4.vhdx`. Must NOT exist as a non-empty directory unless you are re-running. |
| `<TAR_PATH>` | `F:\iSO\WSL-Distros\kali-linux.tar` | Windows path to a `.tar` file (NOT a `.vhdx`). Must exist and be > 1 MB. |
| `<WSL_VERSION>` | `2` | Use `2` unless the user has a specific WSL 1 reason. |
| `<DEFAULT_USER>` | `mbs` | Optional. Linux username to set as default. Must already exist in the distro's `/etc/passwd`. |
| `<DISK_TARGET>` | drive letter or label | Optional sanity check. Refuse the install if the target drive has less than 2 GB free. |

## Pre-flight (always run first)

1. **WSL is installed and current.**
   ```powershell
   wsl --version
   wsl --update           # safe; no-op if already current
   wsl --status
   ```
   Expect: exit code 0, version `>= 2.0.0`. If `wsl` is not found, stop and
   tell the user to install WSL first (the `wsl-setup` skill covers this).

2. **WSL features are enabled.**
   ```powershell
   Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
   Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
   ```
   Both must report `State = Enabled`.

3. **Tar file exists and is non-trivial.**
   ```powershell
   Get-Item -LiteralPath "<TAR_PATH>" | Select-Object FullName, Length
   ```
   Expect: file present, `Length > 1MB`. Refuse to proceed otherwise.

4. **Target drive has headroom.**
   ```powershell
   Get-Volume | Where-Object { $_.DriveLetter -eq (Split-Path -Qualifier "<INSTALL_DIR>").TrimEnd(':') }
   ```
   Expect: `SizeRemaining > 2GB`. Refuse the install otherwise and ask the
   user to free space or pick another drive.

## Idempotency guards (run before every mutation)

| State to detect | Command | If true, action |
|---|---|---|
| Distro already registered | `wsl --list --quiet \| Where-Object { $_ -eq '<DISTRO_NAME>' }` | Skip import. Jump to step 5 (config). Report "already imported". |
| `<INSTALL_DIR>` already has `ext4.vhdx` | `Test-Path -LiteralPath "<INSTALL_DIR>\ext4.vhdx"` | If distro is also registered: skip import. If not: refuse — would orphan the VHDx. Ask user to either pick a fresh `<INSTALL_DIR>` or `wsl --import-in-place`. |
| Distro is currently running | `wsl --list --running --quiet \| Where-Object { $_ -eq '<DISTRO_NAME>' }` | `wsl --terminate <DISTRO_NAME>` before mutating `/etc/wsl.conf`. |

These three checks together make the skill re-runnable. Always re-run them at
the top of every invocation.

## Procedure

### Step 1 — Create the install directory

```powershell
New-Item -ItemType Directory -Path "<INSTALL_DIR>" -Force | Out-Null
```

### Step 2 — Import the tar

```powershell
wsl --import <DISTRO_NAME> "<INSTALL_DIR>" "<TAR_PATH>" --version <WSL_VERSION>
```

Expect: exit code 0, no "Unspecified error", `ext4.vhdx` appears under
`<INSTALL_DIR>`. The VHDx is auto-expanding and is owned by the SYSTEM account;
do not attempt to edit it from outside WSL.

**Failure modes:**
- "Unspecified error" -> drive is full, antivirus is blocking, or tar > 256 GB.
  Run `wsl --update` (done in pre-flight) and retry. If still failing, ask
  the user to free disk space on the target drive.
- "Access is denied" -> another WSL process holds the VHDx. Run
  `wsl --shutdown` and retry.

### Step 3 — Verify the distro boots

```powershell
wsl -d <DISTRO_NAME> -u root -- uname -a
wsl -d <DISTRO_NAME> -u root -- cat /etc/os-release
```

Expect: a `Linux` line and a recognizable `PRETTY_NAME`. If the tar was built
without systemd or with a non-standard init, `/etc/os-release` is still a
reliable identity check.

### Step 4 — Terminate the distro

Required before editing `/etc/wsl.conf`, so the change applies on the next
launch.

```powershell
wsl --terminate <DISTRO_NAME>
```

### Step 5 — Configure the default user (idempotent merge)

If `<DEFAULT_USER>` is not provided, stop here. The distro will boot as
`root` until configured (this is the default for all imported distros).

Otherwise, **merge** into the existing `/etc/wsl.conf`. Do NOT overwrite the
file unconditionally — the user (or a previous run) may have set other
sections (`[boot]`, `[network]`, `[interop]`, etc.).

```powershell
wsl -d <DISTRO_NAME> -u root -- bash -lc '
  set -e
  CONF=/etc/wsl.conf
  cp -a "$CONF" "${CONF}.bak.$(date +%Y%m%d-%H%M%S)"
  if grep -q "^\[user\]" "$CONF"; then
    if grep -q "^default=" "$CONF"; then
      sed -i "s/^default=.*/default=<DEFAULT_USER>/" "$CONF"
    else
      sed -i "/^\[user\]/a default=<DEFAULT_USER>" "$CONF"
    fi
  else
    printf "\n[user]\ndefault=<DEFAULT_USER>\n" >> "$CONF"
  fi
  cat "$CONF"
'
wsl --terminate <DISTRO_NAME>
```

The backup line means a re-run after a typo can be recovered. The merge logic
covers three cases:
- `[user]` section exists with a `default=` line -> update in place
- `[user]` section exists without `default=` -> add the line
- No `[user]` section -> append a new section

### Step 6 — Verify the default user

```powershell
wsl -d <DISTRO_NAME> -- whoami
wsl -d <DISTRO_NAME> -- id
```

Expect: `<DEFAULT_USER>`. The systemd user-session warning is cosmetic; ignore
it. If `whoami` still reports `root`, terminate the distro again and retry.

### Step 7 — Report

Print a short summary:
- Distro name + WSL version
- `<INSTALL_DIR>` and resulting VHDx size
- Default user
- `wsl -l -v` output for visual confirmation

## Re-running this skill

Three legitimate re-run cases:

1. **Re-run with no changes** -> all guards fire, every step is a no-op. Safe.
2. **Re-run with a new default user** -> guards pass, the merge in Step 5
   updates the line. Safe.
3. **Re-run with a new `<INSTALL_DIR>`** -> the existing install guard fires.
   Do NOT silently delete the old VHDx. Ask the user: keep both (use a
   different `<DISTRO_NAME>`), or unregister + remove the old one first
   (destructive; require explicit confirmation).

Re-running is **never** destructive by default. The only destructive actions
in this skill are:

| Action | How to gate it |
|---|---|
| `wsl --unregister <DISTRO_NAME>` | Require user to type the distro name verbatim to confirm. Document the loss of all data in the VHDx. |
| `Remove-Item -LiteralPath "<INSTALL_DIR>\ext4.vhdx"` | Same gating. WSL still holds a registry entry without the file otherwise. |

If the user says "start over" or "wipe", confirm in writing which distro and
which VHDx, and only then proceed with the gated destructive action.

## Reuse patterns

- **Other distros in the same tar folder**: invoke this skill once per
  `(DISTRO_NAME, INSTALL_DIR, TAR_PATH)` triple. The guards mean parallel
  invocations on different triples are safe.
- **Fresh host / rebuild**: pre-flight checks handle missing WSL features.
  The user must install the MSI and enable the features first; refer them
  to `wsl-setup`.
- **Move an imported distro to a different drive**: NOT this skill. Use
  `wsl --export` to a tar (or `--format vhd` for speed), then this skill to
  re-import to the new location.
- **CI / scripted provisioning**: parameterize all five variables and feed
  them from a script. Add `--non-interactive` discipline by skipping Step 6
  verify-print and only failing on non-zero exit codes.

## References

- [Microsoft Learn — Import any Linux distribution to use with WSL](https://learn.microsoft.com/en-us/windows/wsl/use-custom-distro)
- [Microsoft Learn — Basic commands for WSL](https://learn.microsoft.com/en-us/windows/wsl/basic-commands)
- [Microsoft Learn — Advanced configuration: `.wslconfig` and `wsl.conf`](https://learn.microsoft.com/en-us/windows/wsl/wsl-config)
- [Microsoft WSL GitHub — `wsl --import` returns Unspecified error (Issue #4735)](https://github.com/microsoft/WSL/issues/4735)
- [mvaisakh/wsl-distro-tars](https://github.com/mvaisakh/wsl-distro-tars) — reference
  for the tarball format and import procedure
- Companion skill: `wsl-setup` — WSL feature enablement, host config,
  Hyper-V / dual-boot. Use that first if WSL is not yet installed.
