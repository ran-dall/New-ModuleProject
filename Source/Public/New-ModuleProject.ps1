# Creates a new PowerShell module project with a standard structure
function New-ModuleProject {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(Mandatory)][string]$ModuleName,          # Name of the module
        [string]$ModulePath = (Get-Location).Path,         # Base path for module creation
        [switch]$InitializeGit,                            # Initialize Git repository
        [switch]$InstallDevelopmentTools,                  # Install development tools
        [switch]$IncludePesterTests,                       # Include Pester test file
        [string]$ModuleVersion = "1.0.0",                  # Module version
        [string]$Author = "Your Name",                     # Author name
        [string]$CompanyName,                              # Company name
        [string]$Description = "A description of $ModuleName", # Module description
        [string]$PowerShellVersion = "5.1",                # Minimum PowerShell version
        [string[]]$FunctionsToExport = @("Get-Greeting"),  # Functions to export
        [string]$HelpInfoURI,                              # Help documentation URI
        [string]$Copyright = "(c) $Author. All rights reserved.", # Copyright notice
        [string[]]$CompatiblePSEditions = @(),             # Compatible PS editions
        [string[]]$RequiredModules = @(),                  # Required modules
        [string[]]$CmdletsToExport = @(),                  # Cmdlets to export
        [string[]]$VariablesToExport = @(),                # Variables to export
        [string[]]$AliasesToExport = @(),                  # Aliases to export
        [string]$DefaultCommandPrefix                      # Default command prefix
    )

    # Helper function to create directory structure
    $createDirectoryStructure = {
        param ($FullModulePath)
        $paths = @(
            "$FullModulePath\Source\Public",
            "$FullModulePath\Source\Private",
            "$FullModulePath\Tests",
            "$FullModulePath\README.md"
        )

        $paths | ForEach-Object {
            if (-not (Test-Path $_)) {
                $itemType = if ($_.EndsWith(".md")) { "File" } else { "Directory" }
                if ($PSCmdlet.ShouldProcess($_, "Create $itemType")) {
                    New-Item -Path $_ -ItemType $itemType -Force | Out-Null
                }
            }
        }
    }

    # Helper function to initialize Git
    $initializeGitRepo = {
        param ($FullModulePath)
        if (Get-Command git -ErrorAction SilentlyContinue) {
            Push-Location $FullModulePath
            git init | Out-Null
            Pop-Location
            Write-Output "Initialized Git repository in $FullModulePath"
        } else {
            Write-Warning "Git not installed or not in PATH"
        }
    }

    # Define full module path
    $FullModulePath = Join-Path -Path $ModulePath -ChildPath $ModuleName

    # Check for existing module
    if (Test-Path $FullModulePath) {
        Write-Warning "Module '$ModuleName' already exists at $FullModulePath"
        return
    }

    Write-Output "Creating module structure for '$ModuleName'..."

    # Create directory structure
    & $createDirectoryStructure $FullModulePath

    # Create core module files
    if ($PSCmdlet.ShouldProcess($FullModulePath, "Create PSM1 loader")) {
        New-PSM1Loader -ModuleName $ModuleName -ModulePath $FullModulePath
    }
    if ($PSCmdlet.ShouldProcess($FullModulePath, "Create module manifest")) {
        Build-ModuleManifest -ModuleName $ModuleName `
                            -ModulePath $FullModulePath `
                            -ModuleVersion $ModuleVersion `
                            -Author $Author `
                            -CompanyName $CompanyName `
                            -Description $Description `
                            -PowerShellVersion $PowerShellVersion `
                            -FunctionsToExport $FunctionsToExport `
                            -HelpInfoURI $HelpInfoURI `
                            -Copyright $Copyright `
                            -CompatiblePSEditions $CompatiblePSEditions `
                            -RequiredModules $RequiredModules `
                            -CmdletsToExport $CmdletsToExport `
                            -VariablesToExport $VariablesToExport `
                            -AliasesToExport $AliasesToExport `
                            -DefaultCommandPrefix $DefaultCommandPrefix
    }

    # Add optional features
    if ($IncludePesterTests -and $PSCmdlet.ShouldProcess($FullModulePath, "Create Pester tests")) {
        New-PesterTest -ModuleName $ModuleName -ModulePath $FullModulePath
    }

    if ($InstallDevelopmentTools -and $PSCmdlet.ShouldProcess("Development tools", "Install")) {
        Install-PSDevelopmentTools
    }

    if ($InitializeGit -and $PSCmdlet.ShouldProcess($FullModulePath, "Initialize Git repository")) {
        & $initializeGitRepo $FullModulePath
    }

    Write-Output "Module '$ModuleName' created successfully at $FullModulePath"
}
