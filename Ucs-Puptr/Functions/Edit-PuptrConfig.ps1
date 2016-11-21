#requires -version 4

function Edit-PuptrConfig {
    <#

        .SYNOPSIS
        Edit a UcsPuptr configuration file

        .DESCRIPTION
        This function will use Invoke-Item to open a configuration file
        in the default .ps1 editor

        .PARAMETER Name
        Name of the configuration
        Can get a list of configuration names using Get-PuptrConfig

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
        Edit Prod configuration
        Edit-PuptrConfig -Name Prod

    #>

    #---------------------------------------------------------[Script Parameters]------------------------------------------------------
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $Name
    )

    #---------------------------------------------------------[Execute Script]------------------------------------------------------
    try {
        [ValidateNotNullOrEmpty()]$PuptrConfig = Get-PuptrConfig |
        Where {
            $_.Name -eq $Name
        }
        Write-Verbose "Opening configuration: $($PuptrConfig.Name)"
        Invoke-Item -Path $PuptrConfig.Path
    } catch {
        if (Get-PuptrConfig | Where {$_.Name -eq $Name}) {
            Write-Warning -Message "Unable to edit configuration file: $Name"
            $_.ErrorDetails
        } else {
            Write-Warning -Message "Unable to find configuration file: $Name"
        }
    }
}