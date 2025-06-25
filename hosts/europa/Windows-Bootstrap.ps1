<#
    .SYNOPSIS
    Bootstrap the windows environment.

    .DESCRIPTION
    The Windows-Bootstrap.ps1 script bootstraps the windows environment by

    - Ensuring that `winget` is available.
    - Installing winget packages.
    - Ensuring that `choco` is available.
    - Installing chocolatey packages.

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

function Initialize-Chocolatey {
    [CmdletBinding(SupportsShouldProcess)]
    param ()

    process {
        try {
            choco --version | Out-Null
            Write-Output "chocolatey is already installed"
        } catch {
            try {
                $wc = New-Object System.Net.WebClient
                iex ($wc.DownloadString('https://community.chocolatey.org/install.ps1'))
            } catch {
                Throw "$($_.Exception.Message)"
            }
        }
    }
}

function Initialize-WinGet {
    [CmdletBinding(SupportsShouldProcess)]
    param ()

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

function Invoke-ChocolateyInstalls {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(HelpMessage = "Path to .configurations directory", Mandatory=$true)]
        [string]$Directory,
        [Parameter(HelpMessage = "Package files to call `choco install` on")]
        [string[]]$Packages = @(
            "packages-personal.config",
            "packages-development.config"
        )
    )

    process {
        foreach ($Package in $Packages) {
            $PackagesConfig = Join-Path $Directory $Package
            if ($PSCmdlet.ShouldProcess($PackagesConfig, "choco install")) {
                Write-Output "Install Chocolatey Packages Configuration $PackagesConfig"
                choco install --yes $PackagesConfig
            }
        }
    }
}

function Invoke-WinGetConfigurations {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(HelpMessage = "Path to .configurations directory", Mandatory=$true)]
        [string]$Directory,
        [Parameter(HelpMessage = "Configuration files to call `winget configure` on")]
        [string[]]$Configurations = @(
            "settings.dsc.yaml",
            "packages-base.dsc.yaml",
            "packages-personal.dsc.yaml",
            "packages-development.dsc.yaml"
        )
    )

    process {
        foreach ($Configuration in $Configurations) {
            $WinGetConfiguration = Join-Path $Directory $Configuration
            if ($PSCmdlet.ShouldProcess($WinGetConfiguration, "winget configure")) {
                Write-Output "Applying WinGet Configuration $WinGetConfiguration"
                winget configure --accept-configuration-agreements -f $WinGetConfiguration
            }
        }
    }
}

function Bootstrap {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(HelpMessage = "Path to the repository root", Mandatory=$true)]
        [string]$RepositoryRoot
    )

    begin {
        $ConfigurationsDir = Join-Path $RepositoryRoot ".configurations"
    }

    process {
        if ($PSCmdlet.ShouldProcess("WinGet Configurations", "Apply")) {
            Write-Output "Applying WinGet Configurations"
            Initialize-WinGet
            Invoke-WinGetConfigurations -Directory $ConfigurationsDir
        }

        if ($PSCmdlet.ShouldProcess("Chocolatey Packages", "Install")) {
            Write-Output "Installing Chocolatey Packages"
            Initialize-Chocolatey
            Invoke-ChocolateyInstalls -Directory $ConfigurationsDir
        }
    }
}

If (-not (($MyInvocation.InvocationName -eq ".") -or ($MyInvocation.InvocationName -eq ""))) {
    try {
        if ($Help) {
            Get-Help $PSCommandPath
        } else {
            $RepositoryRoot = $PSScriptRoot | Split-Path -Parent | Split-Path -Parent
            Bootstrap -RepositoryRoot $RepositoryRoot
        }
    } catch {
        Write-Error $_
        exit 1
    }
}
