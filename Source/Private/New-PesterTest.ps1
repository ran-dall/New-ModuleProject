# Creates a basic Pester test file for a module
function New-PesterTest {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(Mandatory)][string]$ModuleName,  # Name of the module
        [Parameter(Mandatory)][string]$ModulePath  # Path to the module directory
    )

    # Define test file path and content
    $testFilePath = Join-Path -Path "$ModulePath\Tests" -ChildPath "$ModuleName.Tests.ps1"
    $testContent = @"
Describe '$ModuleName Module Tests' {
    It 'Should import module without errors' {
        Import-Module -Name '$ModuleName' -ErrorAction Stop
    }
}
"@

    # Create test file if approved
    if ($PSCmdlet.ShouldProcess($testFilePath, "Create Pester test file")) {
        $testContent | Set-Content -Path $testFilePath
    }
}
