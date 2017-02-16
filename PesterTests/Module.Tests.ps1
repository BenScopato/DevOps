[CmdLetBinding()]
param(
    [Parameter(Mandatory=$True)]
    [string]$ModuleName
)

# Finds the current script location
$here = Split-Path -Parent $MyInvocation.MyCommand.Path

# Finds the next directory up
$root = (Get-Item $here\..).FullName

# Sets module name to user entered param
$mod = $ModuleName

# Start of Pester tests
Describe "$($mod) Module Tests" {

    # Collection of tests for checking file structure
    Context 'FileCheck' {
    
        # First test: looking for module .psm1 file in root directory
        It 'has a root module' {

            $file = "$($root)\$($mod).psm1"
            $file | Should Exist

        } # End of test

        # Second test: looking for module .psd1 file in root directory
        It 'has a module manifest' {

            $file = "$($root)\$($mod).psd1"
            $file | Should Exist

        } # End of test

        # Third test: looking for module .ps1xml file in root directory
        It 'has a module format file' {

            $file = "$($root)\$($mod).format.ps1xml"
            $file | Should Exist

        } # End of test
    
    } # End of context

    # Collection of tests for validating module contents
    Context "ValidateModuleContents" {
    
        # Checks that module code throws no errors
        It "$($mod) is valid PowerShell" {

            $modCont = Get-Content -Path "$($root)\$($mod).psm1" -ErrorAction Stop
            $errs = $null
            $null = [System.Management.Automation.PSParser]::Tokenize($modCont, [ref]$errs)
            $errs.Count | Should Be 0

        } # End of test
    
    } # End of context


}