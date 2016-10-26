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
    Describe -Name 'UCSM Configuration: Maintenance Policy' -Tag @('ucsm','no-impact') -Fixture {
        # Project Environment Variables      
        $ProjectDir = (Get-Item $PSScriptRoot).parent.parent.FullName
        $CredentialDir = "$ProjectDir\Credentials"
        
        # Config Variables
        . $Config
        [string]$PuptrUser = $config.connection.Username
        [string[]]$UcsDomains = $config.connection.Domain
        [string]$MaintenancePolicies = $config.ucsm.MaintenancePolicy

        # Importing credentials
        $SecurePassword = Get-Content -Path "$CredentialDir\$PuptrUser.txt" | ConvertTo-SecureString
        $Credential = [pscredential]::new($PuptrUser,$SecurePassword)

        # Connect to UCS 
        Connect-Ucs -Name $UcsDomains -Credential $Credential

        # Run test case
        foreach ($UcsDomain in (Get-UcsStatus)) {
            foreach ($PolicyName in $MaintenancePolicies.Keys) {
                $ExpectedValue = $MaintenancePolicies.$PolicyName
                It -Name "$($UcsDomain.Name) has a policy named $PolicyName set to $ExpectedValue" -Test {
                    # Run commands to gather data
                        $MaintenancePolicy = Get-UcsMaintenancePolicy -Ucs $UcsDomain.Name -Name $PolicyName
                    # Assert
                    try {
                        $MaintenancePolicy.UptimeDisr | Should Be $ExpectedValue
                    } catch {
                        if ($Remediate) {
                            Write-Warning -Message $_
                            Write-Warning -Message "Setting maintenance policy `'$PolicyName`' to $ExpectedValue"
                            $MaintenancePolicy | Set-UcsMaintenancePolicy -UptimeDisr $ExpectedValue -Force
                        } else {
                            throw $_
                        }
                    }
                }
            }
        }

        # Disconnect from UCS
        Disconnect-Ucs
    }
}