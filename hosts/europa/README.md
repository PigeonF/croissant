# Europa

Scripts used to bootstrap the installation for a Windows 11 Desktop.
The Desktop is used to SSH into the other machines described in this repository.

## Hardware

![System hardware determined by the `hwloc` package](images/topology.svg "Generated using `just hosts::europa::topology`")

## Bootstrap

Since nix does not run on Windows, this host does not support automatic provisioning.
The repository does provide two scripts that help with bootstrapping the system.
[Windows-Install.ps1] downloads and runs [Windows-Bootstrap.ps1], which installs packages using [winget] and [chocolatey].

[chocolatey]: https://chocolatey.org/
[Windows-Bootstrap.ps1]: ./Windows-Bootstrap.ps1
[Windows-Install.ps1]: ../../scripts/Windows-Install.ps1
[winget]: https://learn.microsoft.com/en-us/windows/package-manager/winget/

The [Windows-Bootstrap.ps1] script can also be called using `just`.

```console
just hosts::europa::bootstrap
```

On a fresh install, call the [Windows-Install.ps1] script from powershell.

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Import-Module DISM
irm 'https://raw.githubusercontent.com/PigeonF/croissant/refs/heads/main/scripts/Windows-Install.ps1' | iex
Invoke-Bootstrap -Revision "refs/heads/main"
jj git clone git@github.com:PigeonF/croissant.git D:\code\croissant
cd D:\code\croissant
just hosts::europa::update
```
