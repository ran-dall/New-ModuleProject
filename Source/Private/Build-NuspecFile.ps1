# Creates a NuSpec file for NuGet packaging based on a module manifest
function Build-NuspecFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string]$ModuleManifestPath  # Path to the module manifest (.psd1)
    )

    # Validate manifest path existence
    if (-not (Test-Path $ModuleManifestPath)) {
        Write-Error "Manifest file not found at $ModuleManifestPath"
        return
    }

    # Import manifest data
    $manifest = try { Import-PowerShellDataFile -Path $ModuleManifestPath }
                catch { Write-Error "Failed to import manifest: $_"; return }

    # Extract module ID from RootModule
    $ModuleID = if ($manifest.RootModule -and $manifest.RootModule -match '\.psm1$') {
        [System.IO.Path]::GetFileNameWithoutExtension($manifest.RootModule)
    } else {
        Write-Error "RootModule missing or invalid in manifest"
        return
    }

    # Validate required manifest fields
    if (-not $manifest.ModuleVersion) {
        Write-Error "ModuleVersion missing from manifest"
        return
    }

    # Define nuspec file path
    $nuspecPath = Join-Path (Split-Path -Path $ModuleManifestPath -Parent) "$ModuleID.nuspec"

    # Remove existing nuspec file if present
    if (Test-Path $nuspecPath) {
        Remove-Item -Path $nuspecPath -Force
        Write-Output "Deleted existing nuspec file: $nuspecPath"
    }

    # Generate nuspec content
    $nuspecContent = @"
<?xml version="1.0" encoding="utf-8"?>
<package xmlns="http://schemas.microsoft.com/packaging/2013/05/nuspec.xsd">
  <metadata>
    <id>$ModuleID</id>
    <version>$($manifest.ModuleVersion)</version>
    <authors>$($manifest.Author -join ", ")</authors>
    <owners>$($manifest.Author -join ", ")</owners>
    <description>$($manifest.Description)</description>
    <tags>PowerShell</tags>
  </metadata>
</package>
"@

    # Write nuspec file with UTF-8 BOM encoding
    $nuspecContent | Out-File -FilePath $nuspecPath -Encoding utf8BOM
    Write-Output "Created nuspec file: $nuspecPath"
}
