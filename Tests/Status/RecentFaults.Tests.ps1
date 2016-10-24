#requires -Modules Pester, Cisco.UcsManager

[CmdletBinding()]
Param(
    # Optionally fix all config drift that is discovered. Defaults to false (off)
    [switch]$Remediate = $false,

    # Optionally define a different config file to use.
    [string]$Config
)

Process {
    # Tests
    Describe -Name 'UCSM Configuration: Fault(s)' -Tag @('ucsm') -Fixture {
        # Project Environment Variables      
        $ProjectDir = (Get-Item $PSScriptRoot).parent.parent.FullName
        $CredentialDir = "$ProjectDir\Credentials"
        
        # Config Variables
        . $Config
        [string]$PuptrUser = $config.connection.Username
        [string[]]$UcsDomains = $config.connection.Domain
        [array]$SeverityFilter = $config.ucsm.FaultSeverity

        # Importing credentials
        $SecurePassword = Get-Content -Path "$CredentialDir\$PuptrUser.txt" | ConvertTo-SecureString
        $Credential = [pscredential]::new($PuptrUser,$SecurePassword)

        # Connect to UCS 
        Connect-Ucs -Name $UcsDomains -Credential $Credential

        # Run test case
        foreach ($UcsDomain in (Get-UcsStatus)) {
            It -Name "$($UcsDomain.Name) has no faults of severity: $SeverityFilter" -Test {
                # Gather faults according to severity filter
                $UcsFaults = Get-UcsFault -Ucs $UcsDomain.Name |
                Where-Object -FilterScript {
                    $SeverityFilter -contains $_.Severity
                }

                # Assert
                try {
                    $UcsFaults.count | Should Be 0
                } catch {
                    throw $_
                }
            }
        }

        # Disconnect from UCS
        Disconnect-Ucs
    }
}