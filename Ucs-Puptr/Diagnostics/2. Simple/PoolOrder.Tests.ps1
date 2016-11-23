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
    Describe -Name 'Simple: Pool Assignment Order' -Tag @('simple') -Fixture {
        BeforeAll {
            # Project Environment Variables 
            $ProjectDir = (Get-Item $PSScriptRoot).parent.parent.FullName
            $ConfigName = "$ConfigName.ps1"
            $ConfigDir = $ProjectDir | Join-Path -ChildPath 'Configs'
            $ConfigFile = $ConfigDir | Join-Path -ChildPath $ConfigName
            $CredentialDir = $ProjectDir | Join-Path -ChildPath 'Credentials'
            
            # Ensure $UcsConfiguration is loaded into the session
            . $ConfigFile

            # Set variables from .connection
            $PuptrUser = $UcsConfiguration.Connection.Username
            $PuptrUserPath = $CredentialDir | Join-Path -ChildPath "$PuptrUser.txt"
            $UcsDomains = $UcsConfiguration.Connection.UcsDomain

            # Importing credentials
            $SecurePassword = Get-Content -Path $PuptrUserPath | ConvertTo-SecureString
            $Credential = [pscredential]::new($PuptrUser,$SecurePassword)

            # Connect to UCS 
            Connect-Ucs -Name $UcsDomains -Credential $Credential

            # Test Variables
            $PoolOrder = $UcsConfiguration.Other.PoolAssignmentOrder
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
                foreach ($UIDPool in $UIDPools.$PoolType) {
                    It -Name "Pool $($UIDPool.Name) on $($UcsDomain.Name) is using $PoolOrder pool assignment order" -Test {
                        # Assert
                        try {
                            $UIDPool.AssignmentOrder | Should Be $PoolOrder
                        } catch {
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