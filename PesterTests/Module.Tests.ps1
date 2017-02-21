[CmdLetBinding()]
param(
    
)

# Finds the current script location
$here = Split-Path -Parent $MyInvocation.MyCommand.Path

# Sets current working directory to the current script's location
Set-Location $here

# Finds all sub-folders of current directory and assumes them to be individual module directories.
# Populates list of module names from sub-folders
$allModules = (get-childitem | ? {$_.Attributes -eq "Directory"} | select -ExpandProperty Name)

# Iterates over every item in $allModules
foreach ($mod in $allModules) {

    # Removes any existing instances of module in memory
    Get-Module $mod | Remove-Module

    # Imports module from specific location
    Import-Module "$($here)\$($mod)\$($mod).psm1"

    # Start of Pester tests
    Describe "$($mod) Module Tests" {

        # Collection of tests for checking file structure
        Context 'FileCheck' {
    
            # First test: looking for module .psm1 file in root directory
            It 'has a root module' {

                $file = "$($here)\$($mod)\$($mod).psm1"
                $file | Should Exist

            } # End of test

            # Second test: looking for module .psd1 file in root directory
            It 'has a module manifest' {

                $file = "$($here)\$($mod)\$($mod).psd1"
                $file | Should Exist

            } # End of test

            # Third test: looking for module .ps1xml file in root directory
            It 'has a module format file' {

                $file = "$($here)\$($mod)\$($mod).format.ps1xml"
                $file | Should Exist

            } # End of test
    
        } # End of context

        # Collection of tests for validating module contents
        Context "ValidateModuleContents" {
    
            # Checks that module code throws no errors
            It "$($mod) is valid PowerShell" {

                $modCont = Get-Content -Path "$($here)\$($mod)\$($mod).psm1" -ErrorAction Stop
                $errs = $null
                $null = [System.Management.Automation.PSParser]::Tokenize($modCont, [ref]$errs)
                $errs.Count | Should Be 0

            } # End of test
        
            # Checks that module has required complexity
            It "$($mod) has required complexity" {

                $file = "$($here)\$($mod)\$($mod).psm1"
                $file | Should Contain "CmdletBinding"
                $file | Should Contain "write-verbose"

            } # End of test

            # Checks that module contains help information
            It "$($mod) has help information" {

                $file = "$($here)\$($mod)\$($mod).psm1"
                $file | Should Contain "<#"
                $file | Should Contain "#>"
                $file | Should Contain ".SYNOPSIS"
                $file | Should Contain ".DESCRIPTION"
                $file | Should Contain ".EXAMPLE"

            } # End of test
        
    
        } # End of context


    }
}