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
    Describe -Name 'Comprehensive: Network Control Policy' -Tag @('comprehensive','impact') -Fixture {
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
            $PuptrUserName = $PuptrUser.Split('\') | Select-Object -Last 1
            $PuptrUserPath = $CredentialDir | Join-Path -ChildPath "$PuptrUserName.txt"
            $UcsDomains = $UcsConfiguration.Connection.UcsDomain

            # Importing credentials
            $SecurePassword = Get-Content -Path $PuptrUserPath | ConvertTo-SecureString
            $Credential = [pscredential]::new($PuptrUser,$SecurePassword)

            # Connect to UCS 
            Connect-Ucs -Name $UcsDomains -Credential $Credential

        }

        # Run test case
        foreach ($UcsDomain in (Get-UcsStatus)) {
            foreach ($PolicyName in $UcsConfiguration.Lan.NetworkControlPol.Keys) {
                $Policy = $UcsConfiguration.Lan.NetworkControlPol.$PolicyName
                $ExistingPolicy = Get-UcsNetworkControlPolicy -Ucs $UcsDomain.Name -Org $Policy.Org -Name $PolicyName
                It -Name "Policy $PolicyName on $($UcsDomain.Name) in Org $($Policy.Org) has a CDP State of $($Policy.CDPState)" -Test {
                    # Assert
                    try {
                        $ExistingPolicy.Cdp | Should Be $Policy.CDPState
                    } catch {
                        if ($Remediate) {
                            Write-Warning -Message $_
                            Write-Warning -Message "Changing CDP State on $($ExistingPolicy.Name) to $($Policy.CDPState)" 
                            $ExistingPolicy | Set-UcsNetworkControlPolicy -Cdp $Policy.CDPState -Force
                        } else {
                            throw $_
                        }
                    }
                }
                It -Name "Policy $PolicyName on $($UcsDomain.Name) in Org $($Policy.Org) has a MAC Register Mode of $($Policy.MACRegisterMode)" -Test {
                    # Assert
                    try {
                        $ExistingPolicy.MACRegisterMode | Should Be $Policy.MACRegisterMode
                    } catch {
                        if ($Remediate) {
                            Write-Warning -Message $_
                            Write-Warning -Message "Changing MAC Register Mode on $($ExistingPolicy.Name) to $($Policy.MACRegisterMode)" 
                            $ExistingPolicy | Set-UcsNetworkControlPolicy -MacRegisterMode $Policy.MACRegisterMode -Force
                        } else {
                            throw $_
                        }
                    }
                }
                It -Name "Policy $PolicyName on $($UcsDomain.Name) in Org $($Policy.Org) has an Uplink Failure Action of $($Policy.UplinkFailureAction)" -Test {
                    # Assert
                    try {
                        $ExistingPolicy.UplinkFailAction | Should Be $Policy.UplinkFailureAction
                    } catch {
                        if ($Remediate) {
                            Write-Warning -Message $_
                            Write-Warning -Message "Changing Uplink Failure Action on $($ExistingPolicy.Name) to $($Policy.UplinkFailureAction)" 
                            $ExistingPolicy | Set-UcsNetworkControlPolicy -UplinkFailAction $Policy.UplinkFailureAction -Force
                        } else {
                            throw $_
                        }
                    }
                }
                It -Name "Policy $PolicyName on $($UcsDomain.Name) in Org $($Policy.Org) has a LLDP Transmit setting of $($Policy.LLDPTransmit)" -Test {
                    # Assert
                    try {
                        $ExistingPolicy.LLDPTransmit | Should Be $Policy.LLDPTransmit
                    } catch {
                        if ($Remediate) {
                            Write-Warning -Message $_
                            Write-Warning -Message "Changing LLDP Transmit setting on $($ExistingPolicy.Name) to $($Policy.LLDPTransmit)" 
                            $ExistingPolicy | Set-UcsNetworkControlPolicy -LldpTransmit $Policy.LLDPTransmit -Force
                        } else {
                            throw $_
                        }
                    }
                }
                It -Name "Policy $PolicyName on $($UcsDomain.Name) in Org $($Policy.Org) has a LLDP Receive setting of $($Policy.LLDPReceive)" -Test {
                    # Assert
                    try {
                        $ExistingPolicy.LLDPReceive | Should Be $Policy.LLDPReceive
                    } catch {
                        if ($Remediate) {
                            Write-Warning -Message $_
                            Write-Warning -Message "Changing LLDP Transmit setting on $($ExistingPolicy.Name) to $($Policy.LLDPReceive)" 
                            $ExistingPolicy | Set-UcsNetworkControlPolicy -LldpReceive $Policy.LLDPReceive -Force
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