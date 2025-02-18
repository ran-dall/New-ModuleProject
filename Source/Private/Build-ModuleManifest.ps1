# Builds a PowerShell module manifest with provided parameters
function Build-ModuleManifest {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string]$ModuleName,          # Name of the module
        [Parameter(Mandatory)][string]$ModulePath,         # Path where module files will be created
        [string]$ModuleVersion = "1.0.0",                  # Version of the module
        [string]$Author = "Your Name",                     # Author of the module
        [string]$CompanyName,                              # Company or vendor name
        [string]$Description = "A description of $ModuleName", # Module description
        [string]$PowerShellVersion = "5.1",                # Minimum PowerShell version required
        [string[]]$FunctionsToExport = @("Get-Greeting"),  # Functions to export from the module
        [string]$HelpInfoURI,                              # URI for help documentation
        [string]$Copyright = "(c) $Author. All rights reserved.", # Copyright notice
        [string[]]$CompatiblePSEditions = @(),             # Compatible PowerShell editions
        [string[]]$RequiredModules = @(),                  # Required modules
        [string[]]$CmdletsToExport = @(),                  # Cmdlets to export
        [string[]]$VariablesToExport = @(),                # Variables to export
        [string[]]$AliasesToExport = @(),                  # Aliases to export
        [string]$DefaultCommandPrefix                      # Default command prefix
    )

    # Define base manifest parameters and include all optional parameters directly
    $manifestParams = @{
        Path                 = Join-Path -Path $ModulePath -ChildPath "$ModuleName.psd1"
        RootModule           = "$ModuleName.psm1"
        ModuleVersion        = $ModuleVersion
        Author               = $Author
        Description          = $Description
        PowerShellVersion    = $PowerShellVersion
        FunctionsToExport    = $FunctionsToExport
        CmdletsToExport      = $CmdletsToExport
        VariablesToExport    = $VariablesToExport
        AliasesToExport      = $AliasesToExport
        CompanyName          = $CompanyName
        Copyright            = $Copyright
        CompatiblePSEditions = $CompatiblePSEditions
        RequiredModules      = $RequiredModules
        HelpInfoURI          = $HelpInfoURI
        DefaultCommandPrefix = $DefaultCommandPrefix
    }

    # Create the module manifest
    New-ModuleManifest @manifestParams
}
