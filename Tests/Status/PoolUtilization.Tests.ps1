#requires -Modules Pester, Cisco.UcsManager

[CmdletBinding()]
Param(
    # Optionally fix all config drift that is discovered. Defaults to false (off)
    [switch]$Remediate = $false,

    # Optionally define a different config file to use. Defaults to Vester\Configs\Config.ps1
    [string]$Config = (Split-Path $PSScriptRoot) + '\Configs\Config.ps1'
)

Process {
    # Tests
    Describe -Name 'UCSM Configuration: Pool Usage Threshold' -Tag @('ucsm') -Fixture {
        # Project Environment Variables      
        $ProjectDir = (Get-Item $PSScriptRoot).parent.parent.FullName
        $CredentialDir = "$ProjectDir\Credentials"
        
        # Config Variables
        . $Config
        [string]$PuptrUser = $config.connection.Username
        [string[]]$UcsDomains = $config.connection.Domain
        [string]$PoolThreshold = $config.ucsm.PoolUsageThreshold

        # Importing credentials
        $SecurePassword = Get-Content -Path "..\$PuptrUser.txt" | ConvertTo-SecureString
        $Credential = [pscredential]::new($PuptrUser,$SecurePassword)

        # Connect to UCS 
        Connect-Ucs -Name $UcsDomains -Credential $Credential

        # Run test case
        foreach ($UcsDomain in (Get-UcsStatus)) {
            It -Name "$($UcsDomain.Name) is using less than $PoolThreshold percent of the MAC Pool" -Test {
                #
                # Run commands to gather data
                $MacPools = @(Get-UcsMacPool | Where {$_.Size -ne 0})

                # Assert
                try {
                    foreach ($MacPool in $MacPools) {
                        ($MacPool.Assigned * 100 / $MacPool.Size) | Should Not BeGreaterThan $PoolThreshold
                    }
                } catch {
                    throw $_
                }
            }

            It -Name "$($UcsDomain.Name) is using less than $PoolThreshold percent of the UUID Pool" -Test {
                #
                # Run commands to gather data
                $UuidPools = @(Get-UcsUuidSuffixPool | Where {$_.Size -ne 0})

                # Assert
                try {
                    foreach ($UuidPool in $UuidPools) {
                        ($UuidPool.Assigned * 100 / $UuidPool.Size) | Should Not BeGreaterThan $PoolThreshold
                    }
                } catch {
                    throw $_
                }
            }

            It -Name "$($UcsDomain.Name) is using less than $PoolThreshold percent of the WWNN Pool" -Test {
                #
                # Run commands to gather data
                $WwnnPools = @(Get-UcsWwnPool |  Where {$_.Purpose -eq 'node-wwn-assignment' -AND $_.Size -ne 0})

                # Assert
                try {
                    foreach ($WwnnPool in $WwnnPools) {
                        ($WwnnPool.Assigned * 100 / $WwnnPool.Size) | Should Not BeGreaterThan $PoolThreshold
                    }
                } catch {
                    throw $_
                }
            }

            It -Name "$($UcsDomain.Name) is using less than $PoolThreshold percent of the WWPN Pool" -Test {
                #
                # Run commands to gather data
                $WwpnPools = @(Get-UcsWwnPool | Where {$_.Purpose -eq 'port-wwn-assignment'-AND $_.Size -ne 0})

                # Assert
                try {
                    foreach ($WwpnPool in $WwpnPools) {
                        ($WwpnPool.Assigned * 100 / $WwpnPool.Size) | Should Not BeGreaterThan $PoolThreshold
                    }
                } catch {
                    throw $_
                }
            }
        }

        # Disconnect from UCS
        Disconnect-Ucs
    }
}