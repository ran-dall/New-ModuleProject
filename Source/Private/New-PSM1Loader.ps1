# Creates a PSM1 loader file to import public and private functions
function New-PSM1Loader {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(Mandatory)][string]$ModuleName,  # Name of the module
        [Parameter(Mandatory)][string]$ModulePath  # Path to the module directory
    )

    # Define PSM1 content
    $psm1Content = @'
$Public  = @(Get-ChildItem -Path "$PSScriptRoot\Source\Public\*.ps1" -ErrorAction SilentlyContinue)
$Private = @(Get-ChildItem -Path "$PSScriptRoot\Source\Private\*.ps1" -ErrorAction SilentlyContinue)

$Public + $Private | ForEach-Object {
    try { . $_.FullName }
    catch { Write-Error "Failed to import function $($_.FullName)" }
}
Export-ModuleMember -Function $Public.Basename
'@

    # Define PSM1 file path
    $psm1Path = Join-Path -Path $ModulePath -ChildPath "$ModuleName.psm1"

    # Create PSM1 file if approved
    if ($PSCmdlet.ShouldProcess($psm1Path, "Create PSM1 loader file")) {
        $psm1Content | Set-Content -Path $psm1Path
    }
}
