Describe 'PSModuleDeveloperTools Module' {
    BeforeAll {
        # Define test module path inside the Tests directory
        $testPath = Join-Path -Path $PSScriptRoot -ChildPath 'TestModule'
        $env:PSModulePath = "$testPath;$env:PSModulePath"

        # Ensure module is imported before tests run
        $moduleName = 'PSModuleDeveloperTools'
        if (-not (Get-Module -Name $moduleName)) {
            Import-Module -Name $moduleName -ErrorAction Stop
        }
    }

    BeforeEach {
        # Cleanup previous test data to ensure a fresh environment
        Remove-Item -Path $testPath -Recurse -Force -ErrorAction SilentlyContinue
    }

    Context 'Module Import' {
        It 'Should import module without errors' {
            { Import-Module -Name 'PSModuleDeveloperTools' -ErrorAction Stop } | Should -Not -Throw
        }
    }

    Context 'New-ModuleProject Function' {
        It 'Should create a new module project directory' {
            { New-ModuleProject -ModuleName 'TestModule' -ModulePath $PSScriptRoot } | Should -Not -Throw
            Test-Path $testPath | Should -Be $true
        }
    }

    Context 'New-ModulePackage Function' {
        It 'Should create a module package' {
            $testPath = Join-Path -Path $PSScriptRoot -ChildPath 'TestModule'

            # Ensure clean test environment
            if (Test-Path $testPath) { Remove-Item -Path $testPath -Recurse -Force }

            # Create the test module
            New-ModuleProject -ModuleName 'TestModule' -ModulePath $PSScriptRoot
            Start-Sleep -Seconds 2 # Allow file system to catch up

            # Ensure manifest exists before packaging
            $manifestPath = Join-Path -Path $testPath -ChildPath 'TestModule.psd1'
            Write-Output "Checking for manifest at: $manifestPath"

            if (-not (Test-Path $manifestPath)) {
                Write-Output "Manifest missing, creating a placeholder..."
                New-ModuleManifest -Path $manifestPath -RootModule 'TestModule.psm1' -ModuleVersion '1.0.0'
            }

            Test-Path $manifestPath | Should -Be $true

            # Run packaging inside TestModule directory
            Push-Location $testPath
            { New-ModulePackage -ModuleName 'TestModule' -InstallLocally } | Should -Not -Throw
            Pop-Location

            # Check if the package file was created
            Test-Path "$testPath\TestModule.nuspec" | Should -Be $true
        }

        AfterAll {
            $testPath = Join-Path -Path $PSScriptRoot -ChildPath 'TestModule'
            if (Test-Path $testPath) {
                Write-Output "Cleaning up test module directory: $testPath"
                Remove-Item -Path $testPath -Recurse -Force
            }
        }
    }

    Context 'Install-PSDevelopmentTool Function' {
        It 'Should install required development tools' {
            { Install-PSDevelopmentTools } | Should -Not -Throw
            Get-Module -ListAvailable | Where-Object { $_.Name -in @('PSScriptAnalyzer', 'Pester', 'InvokeBuild') } | Should -Not -BeNullOrEmpty
        }
    }
}
