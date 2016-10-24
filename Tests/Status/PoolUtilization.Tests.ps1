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
        $SecurePassword = Get-Content -Path "$CredentialDir\$PuptrUser.txt" | ConvertTo-SecureString
        $Credential = [pscredential]::new($PuptrUser,$SecurePassword)

        # Connect to UCS 
        Connect-Ucs -Name $UcsDomains -Credential $Credential

        # Run test case
        foreach ($UcsDomain in (Get-UcsStatus)) {

            $UIDPools = @{
                MacPool = Get-UcsMacPool -Ucs $UcsDomain.Name |
                    Where {$_.Size -ne 0}
                UuidPool = Get-UcsUuidSuffixPool -Ucs $UcsDomain.Name |
                    Where {$_.Size -ne 0}
                WwnnPool = Get-UcsWwnPool -Ucs $UcsDomain.Name |
                    Where {$_.Purpose -eq 'node-wwn-assignment' -AND $_.Size -ne 0}
                WwpnPool = Get-UcsWwnPool -Ucs $UcsDomain.Name | 
                    Where {$_.Purpose -eq 'port-wwn-assignment'-AND $_.Size -ne 0}
            }

            foreach ($PoolType in $UIDPools) {
                It -Name "$($UcsDomain.Name) is using less than $PoolThreshold percent of the MAC Pool" -Test {
                    #
                    # Run commands to gather data
                    $MacPools = @(Get-UcsMacPool | Where {$_.Size -ne 0})

                    # Assert
                    try {
                        foreach ($UIDPool in $UIDPools.$PoolType) {
                            ($UIDPool.Assigned * 100 / $UIDPool.Size) | Should Not BeGreaterThan $PoolThreshold
                        }
                    } catch {
                        throw $_
                    }
                }
            }
        }

        # Disconnect from UCS
        Disconnect-Ucs
    }
}