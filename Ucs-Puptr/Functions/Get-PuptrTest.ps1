#requires -version 4

function Get-PuptrTest {
    <#

        .SYNOPSIS
        Gets list of UcsPuptr tests and their state

        .DESCRIPTION
        This function gets a list of tests depending on the Type parameter.
        It will return the names of the tests and whether or not they are enabled

        .PARAMETER Type
        Type of test to retreive: Simple, Comprehensive, All
        Default = All

        .INPUTS
        None

        .OUTPUTS
        None

        .NOTES
        Version:        1.1
        Author:         Joshua Barton (@foobartn)
        Creation Date:  10.19.2016
        Purpose/Change: Initial script development

        .EXAMPLE
        Gets all tests that don't remediate
        Get-PuptrTest -Type Simple

        .EXAMPLE
        Gets all tests that do remediate
        Get-PuptrTest -Type Comprehensive

        .EXAMPLE
        Gets all tests
        Get-PuptrTest

    #>

    #---------------------------------------------------------[Script Parameters]------------------------------------------------------
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [ValidateSet('Simple','Comprehensive')]
        [string[]]
        $Type = @('Simple','Comprehensive'),

        [Parameter(Mandatory=$false)]
        [ValidateSet('Enabled','Disabled')]
        [string[]]
        $State = @('Enabled','Disabled')
    )

    #-------------------------------------------------------[Parameter Setup]------------------------------------------------------

    # Project Environment Variables 
    $ProjectDir = (Get-Item $PSScriptRoot).parent.FullName
    $SimpleTestDir = $ProjectDir | Join-Path -ChildPath "Diagnostics\2. Simple"
    $CompTestDir = $ProjectDir | Join-Path -ChildPath "Diagnostics\3. Comprehensive"
    [array]$TestDir = $null

    #---------------------------------------------------------[Execute Script]------------------------------------------------------
    switch ($Type) {
        'Simple' {
            $TestDir += $SimpleTestDir
        }
        'Comprehensive' {
            $TestDir += $CompTestDir
        }
    }

    Get-ChildItem -Path $TestDir | ForEach-Object {
        switch -Wildcard ($_.Name) {
            '*Tests*' {$CurrentState = 'Enabled'}
            Default {$CurrentState = 'Disabled'}
        }

        if ($State -contains $CurrentState) {
            $TestObject = [PsCustomObject]@{
                Name = $_.Name.Split('.') | Select -First 1
                State = $CurrentState
                Path = $_.FullName
            }

            $TestObject.PSTypeNames.Insert(0,'PuptrTest.Info')
            $TestObject
        }
    }
}
