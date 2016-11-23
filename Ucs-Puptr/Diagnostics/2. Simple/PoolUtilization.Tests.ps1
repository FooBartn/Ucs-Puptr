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
    Describe -Name 'Simple: Pool Usage Threshold' -Tag @('simple') -Fixture {
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
            $PoolThreshold = $UcsConfiguration.Other.PoolUsageThreshold
        }

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

            foreach ($PoolType in $UIDPools.Keys) {
                It -Name "$($UcsDomain.Name) is using less than $PoolThreshold percent of the $PoolType" -Test {
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