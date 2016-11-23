#requires -Modules Pester, Cisco.UcsManager

[CmdletBinding()]
Param(
    # Optionally fix all config drift that is discovered. Defaults to false (off)
    [switch]$Remediate = $false,

    # Optionally define a different config file to use.
    [string]$ConfigName
)

Process {
    # Tests
    Describe -Name 'Comprehensive: Maintenance Policy' -Tag @('comprehensive','no-impact') -Fixture {
        BeforeAll {
            # Project Environment Variables 
            $ProjectDir = (Get-Item $PSScriptRoot).parent.parent.FullName
            $ConfigDir = $ProjectDir | Join-Path -ChildPath 'Configs'
            $ConfigFile = $ConfigDir | Join-Path -ChildPath "$ConfigName.ps1"
            $CredentialDir = $ProjectDir | Join-Path -ChildPath 'Credentials'
            
            # Ensure $UcsConfiguration is loaded into the session
            . $ConfigFile

            # Set variables from .connection
            $PuptrUser = $UcsConfiguration.Connection.Username
            $PuptrUserName = $PuptrUser.Split('\') | Select -Last 1
            $PuptrUserPath = $CredentialDir | Join-Path -ChildPath "$PuptrUserName.txt"
            $UcsDomains = $UcsConfiguration.Connection.UcsDomain

            # Importing credentials
            $SecurePassword = Get-Content -Path $PuptrUserPath | ConvertTo-SecureString
            $Credential = [pscredential]::new($PuptrUser,$SecurePassword)

            # Connect to UCS 
            Connect-Ucs -Name $UcsDomains -Credential $Credential

            # Test Variables
            $MaintenancePolicies = $UcsConfiguration.Server.MaintenancePolicy
        }

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