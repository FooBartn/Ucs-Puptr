#requires -version 4

function Disable-PuptrTest {
    <#

        .SYNOPSIS
        Disables a UcsPuptr test

        .DESCRIPTION
        This function disables a UcsPuptr test in the Diagnostics folder by name

        .PARAMETER Name
        Name of test to disable

        .INPUTS
        None

        .OUTPUTS
        None

        .NOTES
        Author:         Joshua Barton (@foobartn)
        Creation Date:  11.21.2016

        .EXAMPLE
        Disable test
        Disable-PuptrTest -Name ChassisDiscovery

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
        [ValidateNotNullOrEmpty()]$PuptrTest = Get-PuptrTest -State Enabled |
        Where {
            $_.Name -eq $Name
        }

        $NewPath = $PuptrTest.Path.Replace('Tests','Disabled')
        Write-Verbose "Disabling test: $($PuptrTest.Name)"
        Move-Item -Path $PuptrTest.Path -Destination $NewPath
    } catch {
        if (Get-PuptrTest -State Enabled | Where {$_.Name -eq $Name}) {
            Write-Warning -Message "Cannot disable test: $Name"
            $_.ErrorDetails
        }
        if (Get-PuptrTest -State Disabled | Where {$_.Name -eq $Name}) {
            Write-Warning -Message "$Name test is already disabled"
        } else {
            Write-Warning -Message "Unable to find test: $Name"
        }
    }
}