#requires -version 4

function Export-PuptrConfig {
    <#
    
        .SYNOPSIS
        Makes a backup copy of a UcsPuptr configuration file

        .DESCRIPTION
        This function will make a copy of the named configuration file and save
        it in the specified path

        .PARAMETER Name
        Name of the configuration
        Can get a list of configuration names using Get-PuptrConfig

        .PARAMETER Path
        Path to save specified configuration file

        .INPUTS
        None

        .OUTPUTS
        None

        .NOTES
        Author:         Joshua Barton (@foobartn)
        Creation Date:  11.21.2016

        .EXAMPLE
        Export Prod configuration
        Export-PuptrConfig -Name Prod -Path C:\

    #>

    #---------------------------------------------------------[Script Parameters]------------------------------------------------------
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $Name,

        [Parameter(Mandatory=$true)]
        [string]
        $Path
    )

    #---------------------------------------------------------[Execute Script]------------------------------------------------------
    try {
        [ValidateNotNullOrEmpty()]$PuptrConfig = Get-PuptrConfig |
        Where-Object {
            $_.Name -eq $Name
        }

        Write-Verbose "Backing up configuration $($PuptrConfig.Name)"
        Copy-Item -Path $PuptrConfig.Path -Destination $Path
    } catch {
        if (Get-PuptrConfig | Where {$_.Name -eq $Name}) {
            Write-Warning -Message "Unable to move configuration file: $Name"
            $_.ErrorDetails
        } else {
            Write-Warning -Message "Unable to find configuration file: $Name"
        }
    }
}