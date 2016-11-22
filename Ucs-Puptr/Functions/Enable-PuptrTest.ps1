#requires -version 4

function Enable-PuptrTest {
    <#

        .SYNOPSIS
        Enable a UcsPuptr test

        .DESCRIPTION
        This function enables a UcsPuptr test in the Diagnostics folder by name

        .PARAMETER Name
        Name of test to enable

        .INPUTS
        None

        .OUTPUTS
        None

        .NOTES
        Author:         Joshua Barton (@foobartn)
        Creation Date:  11.21.2016

        .EXAMPLE
        Enable test
        Enable-PuptrTest -Name ChassisDiscovery

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
        [ValidateNotNullOrEmpty()]$PuptrTest = Get-PuptrTest -State Disabled |
        Where {
            $_.Name -eq $Name
        }

        $NewPath = $PuptrTest.Path.Replace('Disabled','Tests')
        Write-Verbose "Enabling Test: $($PuptrTest.Name)"
        Move-Item -Path $PuptrTest.Path -Destination $NewPath
    } catch {
        if (Get-PuptrTest -State Disabled | Where {$_.Name -eq $Name}) {
            Write-Warning -Message "Cannot enable test: $Name"
            $_.ErrorDetails
        }
        if (Get-PuptrTest -State Enabled | Where {$_.Name -eq $Name}) {
            Write-Warning -Message "$Name test is already enabled"
        } else {
            Write-Warning -Message "Unable to find test: $Name"
        }
    }
}