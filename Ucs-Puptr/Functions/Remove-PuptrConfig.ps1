#requires -version 4

function Remove-PuptrConfig {
    <#

        .SYNOPSIS
        Remove a configuration file

        .DESCRIPTION
        This function removes an existing UcsPuptr configuration file

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
        Remove a configuration named Prod
        Remove-PuptrConfig -Name Prod

    #>

    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="High"
    )]
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $Name
    )

    #---------------------------------------------------------[Execute Script]------------------------------------------------------
    try {
        [ValidateNotNullOrEmpty()]$PuptrConfig = Get-PuptrConfig |
        Where-Object {
            $_.Name -eq $Name
        }
        if($pscmdlet.ShouldProcess($PuptrConfig.Path)) {
            Write-Verbose "Removing Configuration: $($PuptrConfig.Name)"
            Remove-Item -Path $PuptrConfig.Path -Force
        }
    } catch {
        if (Get-PuptrConfig | Where {$_.Name -eq $Name}) {
            Write-Warning -Message "Unable to remove configuration file: $Name"
        } else {
            Write-Warning -Message "Unable to find configuration file: $Name"
        }
    }
}