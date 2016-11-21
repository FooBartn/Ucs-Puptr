#requires -version 4

function Import-PuptrConfig {
    <#
    
        .SYNOPSIS
        Import a UcsPuptr configuration file

        .DESCRIPTION
        This function will import a configuration file into UcsPuptr

        .PARAMETER Path
        Path to configuration file

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
        Import configuration file C:\Prod.ps1
        Import-PuptrConfig -Path C:\Prod.ps1

    #>

    #---------------------------------------------------------[Script Parameters]------------------------------------------------------
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $Path
    )

    #-------------------------------------------------------[Parameter Setup]------------------------------------------------------

    # Project Environment Variables 
    $ProjectDir = (Get-Item $PSScriptRoot).parent.FullName
    $ConfigDir = $ProjectDir | Join-Path -ChildPath 'Configs'

    #---------------------------------------------------------[Execute Script]------------------------------------------------------
    try {
        $PuptrConfig = Get-Item -Path $Path -ErrorAction Stop

        Write-Verbose "Importing configuration file $Path"
        Copy-Item -Path $Path -Destination $ConfigDir
    } catch {
        $_.ErrorDetails
    }
}