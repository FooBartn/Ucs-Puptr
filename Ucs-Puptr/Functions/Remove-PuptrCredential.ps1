#requires -version 4

function Remove-PuptrCredential {
    <#

        .SYNOPSIS
        Remove a credential file

        .DESCRIPTION
        This function removes an existing UcsPuptr credential file

        .PARAMETER Name
        User name / name of the credential file

        .INPUTS
        None

        .OUTPUTS
        None

        .NOTES
        Author:         Joshua Barton (@foobartn)
        Creation Date:  02.20.2017

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
        [ValidateNotNullOrEmpty()]$PuptrCredential = Get-PuptrCredential |
        Where-Object {
            $_.Name -eq $Name
        }
        if($pscmdlet.ShouldProcess($PuptrCredential.Path)) {
            Write-Verbose "Removing Credential: $($PuptrCredential.Name)"
            Remove-Item -Path $PuptrCredential.Path -Force
        }
    } catch {
        if (Get-PuptrConfig | Where-Object {$_.Name -eq $Name}) {
            Write-Warning -Message "Unable to remove credential file: $Name"
        } else {
            Write-Warning -Message "Unable to find credential file: $Name"
        }
    }
}