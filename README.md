<!--
SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>

SPDX-License-Identifier: CC-BY-4.0
-->

# Croissant

## Windows

Use the [installation](./scripts/Windows-Install.ps1), and [bootstrap](./scripts/Windows-Bootstrap.ps1) scripts from an elevated powershell.

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Import-Module DISM
irm 'https://raw.githubusercontent.com/PigeonF/croissant/refs/heads/main/scripts/Windows-Install.ps1' | iex
Invoke-Bootstrap -Revision "refs/heads/main"
jj git clone git@github.com:PigeonF/croissant.git D:\code\croissant
cd D:\code\croissant
just dotfiles
```

## Other Systems

> [!WARNING]
> Non-Windows systems are currently undergoing an overhaul, so documentation might be out of date.
