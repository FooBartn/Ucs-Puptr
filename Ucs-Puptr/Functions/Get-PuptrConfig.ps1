#requires -version 4

function Get-PuptrConfig {
    <#

        .SYNOPSIS
        Gets list of UcsPuptr configurations

        .DESCRIPTION
        This function gets a list of UcsPuptr configurations and returns their names

        .INPUTS
        None

        .OUTPUTS
        None

        .NOTES
        Author:         Joshua Barton (@foobartn)
        Creation Date:  11.21.2016

        .EXAMPLE
        Get-PuptrConfig

    #>

    #-------------------------------------------------------[Parameter Setup]------------------------------------------------------

    # Project Environment Variables 
    $ProjectDir = (Get-Item $PSScriptRoot).parent.FullName
    $ConfigDir = $ProjectDir | Join-Path -ChildPath 'Configs'

    #---------------------------------------------------------[Execute Script]------------------------------------------------------
    Get-ChildItem -Path $ConfigDir | ForEach-Object {
        $ConfigObject = [PsCustomObject]@{
            Name = $_.Name.Split('.') | Select -First 1
            Path = $_.FullName
        }

        $ConfigObject.PSTypeNames.Insert(0,'PuptrConfig.Info')
        $ConfigObject
    }
}