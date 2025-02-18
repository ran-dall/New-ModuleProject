# Creates and optionally installs a NuGet package for a PowerShell module
function New-ModulePackage {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [string]$ModuleName = (Get-ChildItem -Path (Get-Location) -Filter *.psd1 -Recurse | Select-Object -First 1).BaseName, # Module name (defaults to first .psd1 found)
        [switch]$InstallLocally,  # Install package locally
        [switch]$InstallNuGet     # Install NuGet if not found
    )

    # Helper function to handle existing package
    $handleExistingPackage = {
        param ($nupkgPath)
        Write-Output "Package exists: $nupkgPath"
        $choice = Read-Host "Reuse (R) or Delete and recreate (D)? (R/D)"
        switch ($choice.ToLower()) {
            'r' { Write-Output "Using existing package: $nupkgPath"; return $true }
            'd' {
                Write-Output "Deleting and recreating package..."
                if ($PSCmdlet.ShouldProcess($nupkgPath, "Remove existing package")) {
                    Remove-Item -Path $nupkgPath -Force
                }
                return $false
            }
            default { Write-Error "Invalid choice. Use R or D."; return $null }
        }
    }

    # Helper function to create package
    $createPackage = {
        param ($rootPath, $ModuleName, $psd1Path, $nugetPath)
        $nuspecPath = Join-Path $rootPath "$ModuleName.nuspec"
        $nupkgPath = Join-Path $rootPath "$ModuleName.$($moduleManifest.ModuleVersion).nupkg"

        if (-not (Test-Path $nuspecPath)) {
            Write-Output "Creating nuspec file for $ModuleName..."
            if ($PSCmdlet.ShouldProcess($nuspecPath, "Create nuspec file")) {
                Build-NuspecFile -ModuleManifestPath $psd1Path
            }
            if (-not (Test-Path $nuspecPath)) {
                Write-Error "Failed to create nuspec file"
                return $false
            }
            Write-Output "Generated nuspec file: $nuspecPath"
        }

        if ($PSCmdlet.ShouldProcess($nupkgPath, "Create NuGet package")) {
            & $nugetPath pack $nuspecPath -OutputDirectory $rootPath -NoDefaultExcludes -NoPackageAnalysis -NonInteractive
            if (-not (Test-Path $nupkgPath)) {
                Write-Error "Packaging failed"
                return $false
            }
        }
        $nupkgPath
    }

    # Helper function to install locally
    $installLocally = {
        param ($nupkgPath, $ModuleName)
        $localModulePath = "$env:USERPROFILE\Documents\PowerShell\Modules"
        $extractPath = Join-Path $localModulePath $ModuleName

        if (Test-Path $extractPath) {
            Write-Output "Removing existing module directory: $extractPath"
            if ($PSCmdlet.ShouldProcess($extractPath, "Remove existing module directory")) {
                Remove-Item -Path $extractPath -Recurse -Force
            }
        }

        if ($PSCmdlet.ShouldProcess($extractPath, "Create module directory")) {
            New-Item -ItemType Directory -Path $extractPath -Force | Out-Null
        }

        if ($PSCmdlet.ShouldProcess($extractPath, "Extract package")) {
            Expand-Archive -Path $nupkgPath -DestinationPath $extractPath -Force
            Write-Output "Module installed to $extractPath"
        }

        if (Test-Path $nupkgPath) {
            Write-Output "Deleting temporary package: $nupkgPath"
            if ($PSCmdlet.ShouldProcess($nupkgPath, "Remove package file")) {
                Remove-Item -Path $nupkgPath -Force
                Write-Output "Package file deleted"
            }
        }
    }

    # Main execution: Locate or install NuGet
    $nugetPath = Get-Command nuget -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
    if (-not $nugetPath) {
        if ($InstallNuGet) {
            Write-Output "NuGet not found. Installing via winget..."
            try {
                winget install Microsoft.NuGet -e
                $nugetPath = Get-Command nuget -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
                if (-not $nugetPath) {
                    Write-Error "NuGet installation failed"
                    return
                }
                Write-Output "NuGet installed. Restart PowerShell or update PATH."
            } catch {
                Write-Error "Failed to install NuGet: $_"
                return
            }
        } else {
            Write-Error "NuGet not installed. Use -InstallNuGet to install."
            return
        }
    }

    $rootPath = Get-Location
    $psd1File = Get-ChildItem -Path $rootPath -Filter "$ModuleName.psd1" -Recurse | Select-Object -First 1
    if (-not $psd1File) {
        Write-Error "Manifest file (.psd1) not found"
        return
    }
    $psd1Path = $psd1File.FullName
    Write-Output "Found manifest at: $psd1Path"

    $moduleManifest = try { Import-PowerShellDataFile -Path $psd1Path }
                     catch { Write-Error "Failed to import manifest: $_"; return }

    $nupkgPath = Join-Path $rootPath "$ModuleName.$($moduleManifest.ModuleVersion).nupkg"
    $reuse = if (Test-Path $nupkgPath) { & $handleExistingPackage $nupkgPath } else { $false }

    if ($null -eq $reuse) { return }
    if (-not $reuse) {
        $nupkgPath = & $createPackage $rootPath $ModuleName $psd1Path $nugetPath
        if (-not $nupkgPath) { return }
    }

    if ($InstallLocally) {
        & $installLocally $nupkgPath $ModuleName
    } else {
        Write-Output "Package created at $nupkgPath"
    }
}
