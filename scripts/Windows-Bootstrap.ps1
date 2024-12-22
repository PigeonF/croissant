# SPDX-FileCopyrightText: 2024 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD

<#
    .SYNOPSIS
    Bootstrap the windows environment.

    .DESCRIPTION
    The Windows-Bootstrap.ps1 script bootstraps the windows environment.

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

function Bootstrap {
    [CmdletBinding()]
    param()

    process {
        Write-Host "Bootstrapping..."
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
