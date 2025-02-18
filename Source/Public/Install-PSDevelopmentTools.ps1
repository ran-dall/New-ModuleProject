# Installs essential PowerShell development tools
function Install-PSDevelopmentTools {
    [CmdletBinding()]
    param ()

    # List of development modules to install
    $modules = @("PSScriptAnalyzer", "Pester", "InvokeBuild")

    # Install each module if not already available
    $modules | Where-Object { -not (Get-Module -Name $_ -ListAvailable) } | ForEach-Object {
        Write-Output "Installing $_..."
        Install-Module -Name $_ -Scope CurrentUser -Force
    }
}
