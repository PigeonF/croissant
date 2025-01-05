# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD

<#
    .SYNOPSIS
    Download the project source code and run the Windows-Bootstrap.ps1 script.

    .DESCRIPTION
    The Windows-Install.ps1 script downloads the croissant source code (without git), and subsequently
    runs the Windows-Bootstrap.ps1 script to set up a Windows machine.

    .PARAMETER ArchiveDownloadUrl
    The URL of the GitHub repository to download.

    .PARAMETER Revision
    The revision of the GitHub repository to download.

    .PARAMETER Help
    Print help.

    .INPUTS
    None.

    .OUTPUTS
    None.

    .EXAMPLE
    PS> irm 'https://raw.githubusercontent.com/PigeonF/croissant/refs/heads/main/scripts/Windows-Install.ps1' | iex
    PS> Invoke-Bootstrap -Revision "heads/refs/main"
#>

param (
    [Parameter(HelpMessage = "The URL where the repository archive is fetched from")]
    [string]$ArchiveDownloadUrl = "https://github.com/PigeonF/croissant",
    [Parameter(HelpMessage = "Revision of the repository to download")]
    [string]$Revision = "heads/refs/main",
    [Parameter(HelpMessage = "Print Help")]
    [switch]$Help
)

function Download {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(HelpMessage = "The URL where the repository archive is fetched from")]
        [string]$ArchiveDownloadUrl = "https://github.com/PigeonF/croissant",
        [Parameter(HelpMessage = "Directory to download repository source code to")]
        [string]$DownloadDir = ([System.IO.Path]::GetTempPath()),
        [Parameter(HelpMessage = "Revision of the repository to download")]
        [string]$Revision = "heads/refs/main",
        [Parameter(HelpMessage = "Do not extract the downloaded archive")]
        [switch]$NoExtract,
        [Parameter(HelpMessage = "Download the archive even if it already exists")]
        [switch]$Force
    )

    begin {
        $ArchiveUrl = "$ArchiveDownloadUrl/archive/$Revision.zip"
        $ArchiveFile = Join-Path $DownloadDir "croissant.zip"
        $ArchiveFileExists = Test-Path -Path $ArchiveFile
    }

    process {
        try {
            if ((-not $Force) -and $ArchiveFileExists) {
                Write-Warning "$ArchiveFile already exists"
            }

            if ($Force -or (-not $ArchiveFileExists)) {
                if ($PSCmdlet.ShouldProcess($ArchiveFile, ("Download {0}" -f $ArchiveUrl))) {
                    Write-Output "Downloading $ArchiveUrl to $ArchiveFile"
                    New-Item -Path (Split-Path $ArchiveFile) -ItemType Directory -Force -ErrorAction Stop | Out-Null
                    $wc = New-Object System.Net.WebClient
                    $wc.DownloadFile($ArchiveUrl, $ArchiveFile)
                }
            }

            if (-not $NoExtract) {
                if ($PSCmdlet.ShouldProcess($ArchiveFile, ("Extract To {0}" -f $DownloadDir))) {
                    Write-Output "Extracting $ArchiveFile to $DownloadDir"
                    New-Item -Path $DownloadDir -ItemType Directory -Force -ErrorAction Stop | Out-Null
                    Expand-Archive -Path $ArchiveFile -DestinationPath $DownloadDir
                }
            }
        } catch {
            Throw "$($_.Exception.Message)"
        }
    }
}

function Invoke-Bootstrap {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(HelpMessage = "The URL where the repository archive is fetched from")]
        [string]$ArchiveDownloadUrl = "https://github.com/PigeonF/croissant",
        [Parameter(HelpMessage = "Revision of the repository to download")]
        [string]$Revision = "heads/refs/main"
    )

    begin {
        $DownloadDir = Join-Path ([System.IO.Path]::GetTempPath()) ([System.Guid]::NewGuid())
    }

    process {
        try {
            if ($PSCmdlet.ShouldProcess($ArchiveDownloadUrl, "Download")) {
                Write-Output "Downloading $ArchiveDownloadUrl"
                Download -ArchiveDownloadUrl $ArchiveDownloadUrl -DownloadDir $DownloadDir -Revision $Revision
            }

            $Dirs = Get-ChildItem -Path $DownloadDir -Directory -Force -ErrorAction SilentlyContinue | Select-Object FullName
            if (($Dirs | Measure-Object).Count -ne 1) {
                $RepositoryRoot = $DownloadDir
            } else {
                $RepositoryRoot = $Dirs[0].FullName
            }

            $ScriptsDir = Join-Path $RepositoryRoot "scripts"
            $BootstrapScript = Join-Path $ScriptsDir "Windows-Bootstrap.ps1"
            if ($PSCmdlet.ShouldProcess($BootstrapScript, "Execute")) {
                Write-Output "Executing $BootstrapScript"
                & $BootstrapScript -Verbose:($PSBoundParameters["Verbose"] -eq $true) -Debug:($PSBoundParameters["Debug"] -eq $true)
            }
        } catch {
            Throw "$($_.Exception.Message)"
        }
    }
}

If (-not (($MyInvocation.InvocationName -eq ".") -or ($MyInvocation.InvocationName -eq "")))
{
    try {
        if ($Help) {
            Get-Help $PSCommandPath
        } else {
            Invoke-Bootstrap -ArchiveDownloadUrl $ArchiveDownloadUrl -Revision $Revision
        }
    } catch {
        Write-Error $_
        exit 1
    }
}
