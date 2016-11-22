#requires -version 4

function New-PuptrConfig {
    <#

        .SYNOPSIS
        Create a new configuration file

        .DESCRIPTION
        This function creates a new configuration file from template and opens it in the default .ps1 editor

        .PARAMETER Name
        Name of configuration file (Test, Prod, Peanuts, etc)

        .INPUTS
        None

        .OUTPUTS
        None

        .NOTES
        Author:         Joshua Barton (@foobartn)
        Creation Date:  11.21.2016

        .EXAMPLE
        Create a new configuration named Prod
        New-PuptrConfig -Name Prod

    #>



    #---------------------------------------------------------[Script Parameters]------------------------------------------------------
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $Name,

        [Parameter(Mandatory=$false)]
        [bool]
        $Edit = $true
    )

    #-------------------------------------------------------[Parameter Setup]------------------------------------------------------

    # Project Environment Variables 
    $ProjectDir = (Get-Item $PSScriptRoot).parent.FullName
    $ConfigDir = $ProjectDir | Join-Path -ChildPath 'Configs'
    $NewConfigFile = $ConfigDir | Join-Path -ChildPath "$Name.ps1"
    $ConfigTemplate = $ProjectDir | Join-Path -ChildPath 'Templates\Configuration-Template.ps1'

    #---------------------------------------------------------[Execute Script]------------------------------------------------------
    try {
        Write-Verbose "Creating $ConfigDir if necessary"
        if (-not(Test-Path -Path $ConfigDir)) {
            $null = New-Item -Path $ConfigDir -ItemType Directory -Force -ErrorAction Stop
        }

        Write-Verbose "Copying template to $NewConfigFile"
        Copy-Item -Path $ConfigTemplate -Destination $NewConfigFile -ErrorAction Stop

        $NewConfigName = (Get-Item -Path $NewConfigFile).Name
        Write-Verbose "$NewConfigName configuration created"
        
        if ($Edit) {
            Write-Verbose "Opening configuration: $NewConfigName"
            Invoke-Item -Path $NewConfigFile -ErrorAction Stop
        }
    } catch {
        $_
    }
}