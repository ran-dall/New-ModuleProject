# PSModuleDeveloperTools

## Overview
PSModuleDeveloperTools is a PowerShell module designed to streamline the creation, packaging, and testing of PowerShell modules. It automates the setup of a structured module project, enables packaging for distribution, and includes Pester tests for validation.

## Installation
To install the module, use:
```powershell
Install-Module -Name PSModuleDeveloperTools -Scope CurrentUser -Force
```

## Creating a New Module Project
To create a new module project within a specified directory:
```powershell
New-ModuleProject -ModuleName "MyModule" -ModulePath "C:\Projects" -Description "My custom PowerShell module" -Author "YourName" -CompanyName "YourCompany" -ModuleVersion "1.0.0" -License "MIT"
```
This will generate a new PowerShell module structure under `C:\Projects\MyModule`.

### Folder Structure
```
MyModule/
├── Source/
│   ├── Public/
│   ├── Private/
├── Tests/
│   ├── MyModule.Tests.ps1
├── MyModule.psm1
├── MyModule.psd1
├── README.md
├── .gitignore (if -InitializeGit is used)
```

## Running Tests
This module includes Pester tests to validate functionality.
To run tests, execute:
```powershell
Invoke-Pester -Path .\Tests\MyModule.Tests.ps1 -Output Detailed
```
Ensure Pester is installed with:
```powershell
Install-Module -Name Pester -Force -SkipPublisherCheck
```

## Packaging the Module
After developing the module, you can package it using:
```powershell
New-ModulePackage -ModuleName "MyModule" -InstallLocally
```
This will generate a `.nuspec` file and prepare the module for local or public distribution.

## Ensuring Module Accessibility
If the module is not found, ensure it's in `$env:PSModulePath`. You can add it dynamically:
```powershell
$modulePath = "C:\Projects\MyModule"
$env:PSModulePath = "$modulePath;$env:PSModulePath"
```
Then import it manually:
```powershell
Import-Module -Name "$modulePath\MyModule.psm1" -ErrorAction Stop
```

## License
This module is licensed under the OSL-3.0 License.
