#requires -version 4

function Get-PuptrCredential {
    <#

        .SYNOPSIS
        Gets list of current UcsPuptr credentials

        .DESCRIPTION
        This function gets a list of UcsPuptr credentials and returns their names

        .INPUTS
        None

        .OUTPUTS
        None

        .NOTES
        Author:         Joshua Barton (@foobartn)
        Creation Date:  02.20.2017

        .EXAMPLE
        Get-PuptrCredential

    #>

    #-------------------------------------------------------[Parameter Setup]------------------------------------------------------

    # Project Environment Variables 
    $ProjectDir = (Get-Item $PSScriptRoot).parent.FullName
    $CredentialDir = $ProjectDir | Join-Path -ChildPath 'Credentials'

    #---------------------------------------------------------[Execute Script]------------------------------------------------------
    Get-ChildItem -Path $CredentialDir | ForEach-Object {
        $ConfigObject = [PsCustomObject]@{
            Name = $_.Name.Split('.') | Select-Object -First 1
            Path = $_.FullName
        }

        $ConfigObject.PSTypeNames.Insert(0,'PuptrName.Info')
        $ConfigObject
    }
}