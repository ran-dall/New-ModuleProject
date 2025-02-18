# Get public and private function definition files
$Public  = @(Get-ChildItem -Path "$PSScriptRoot\Source\Public\*.ps1" -ErrorAction SilentlyContinue)
$Private = @(Get-ChildItem -Path "$PSScriptRoot\Source\Private\*.ps1" -ErrorAction SilentlyContinue)

# Dot source the files
Foreach ($import in @($Public + $Private)) {
    Try { . $import.FullName } Catch { Write-Error "Failed to import function $import.FullName" }
}

# Export only public functions
Export-ModuleMember -Function $Public.Basename
