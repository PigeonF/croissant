# SPDX-FileCopyrightText: 2024 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD

<#
    .SYNOPSIS
    Bootstrap the windows environment.

    .DESCRIPTION
    The Windows-Bootstrap.ps1 script bootstraps the windows environment by

    - Ensuring that `winget` is available.

    .PARAMETER Help
    Print help.

    .INPUTS
    None.

    .OUTPUTS
    None.

    .EXAMPLE
    PS> .\scripts\Windows-Bootstrap.ps1
#>

param (
    [Parameter(HelpMessage = "Print Help")]
    [switch]$Help
)

function Initialize-WinGet {
    [CmdletBinding(SupportsShouldProcess)]
    param ()

    begin {
        $DownloadDir = [System.IO.Path]::GetTempPath()
        $MsixBundle = Join-Path $DownloadDir "winget.msixbundle"
        $WingetReleaseUrl = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
        $MsixBundleExists = Test-Path -Path $MsixBundle
    }

    process {
        try {
            winget --version | Out-Null
            Write-Output "winget is already installed"
        } catch {
            try {
                if (-not (Get-PackageProvider -ListAvailable | Where-Object { $_.Name -eq "NuGet" })) {
                    if ($PSCmdlet.shouldProcess("NuGet Package Provider", "Install")) {
                        Write-Output "Installing NuGet Package Provider"
                        Install-PackageProvider -Name Nuget -Force -Scope AllUsers | Out-Null
                    }
                }

                if (-not (Get-Module -ListAvailable | Where-Object { $_.Name -eq "Microsoft.WinGet.Client" })) {
                    if ($PSCmdlet.shouldProcess("Microsoft.WinGet.Client Module", "Install")) {
                        Write-Output "Installing Microsoft.WinGet.Client Module"
                        Install-Module -Name Microsoft.WinGet.Client -Force -Scope AllUsers -Repository PSGallery | Out-Null
                    }
                }

                if ($PSCmdlet.shouldProcess("WinGet Package Manager", "Repair")) {
                    Write-Output "Repairing WinGet Package Manager"
                    Repair-WinGetPackageManager
                }
            } catch {
                Throw "$($_.Exception.Message)"
            }
        }
    }
}

function Bootstrap {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    process {
        if ($PSCmdlet.ShouldProcess("WinGet", "Initialize")) {
            Write-Output "Initializing WinGet"
            Initialize-WinGet
        }
    }
}

If (-not (($MyInvocation.InvocationName -eq ".") -or ($MyInvocation.InvocationName -eq ""))) {
    try {
        if ($Help) {
            Get-Help $PSCommandPath
        } else {
            Bootstrap
        }
    } catch {
        Write-Error $_
        exit 1
    }
}
