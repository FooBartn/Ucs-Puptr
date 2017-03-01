#requires -Modules Pester, Cisco.UcsManager

[CmdletBinding()]
Param(
    # Optionally fix all config drift that is discovered. Defaults to false (off)
    [switch]$Remediate = $false,

    # Optionally define a different config file to use.
    [string]$ConfigName
)

# NOTE: THERE IS AN ISSUE HERE. The Cisco UCS XML presents a port without an SFP present as being 'up'. So this test will not catch that.

Process {
    # Tests
    Describe -Name 'Comprehensive: Ports Both Enabled and Down ' -Tag @('comprehensive','no-impact') -Fixture {
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

            # Test Variables
            $MinimumChassisUplinks = $UcsConfiguration.Equipment.MinimumChassisUplinks
            $LinkAggregation = $UcsConfiguration.Equipment.LinkAggregation
        }

        # Run test case
        foreach ($UcsDomain in (Get-UcsStatus)) {
            $EthPorts = Get-UcsUplinkPort -Ucs $UcsDomain.Name -AdminState 'enabled' |
                Where-Object {$_.OperState -ne 'up'}
            $FcPorts = Get-UcsFcUplinkPort -Ucs $UcsDomain.Name -AdminState 'enabled' |
                Where-Object {$_.OperState -ne 'up'}

            It -Name "$($UcsDomain.Name) has no uplink ports both enabled and down" -Test {
                # Assert
                try {
                    $EthPorts.count | Should Be 0
                } catch {
                    if ($Remediate) {
                        Write-Warning -Message $_
                        foreach ($EthPort in $EthPorts) {
                            Write-Warning -Message "Disabling port $($EthPort.SlotId)/$($EthPort.PortId) on FI $($EthPort.SwitchId) "
                            $EthPort | Set-UcsUplinkPort -AdminState 'disabled' -Force
                        }
                    } else {
                        throw $_
                    }
                }
            }

            It -Name "$($UcsDomain.Name) has no fc ports both enabled and down" -Test {
                # Assert
                try {
                    $FcPorts.count | Should Be 0
                } catch {
                    if ($Remediate) {
                        Write-Warning -Message $_
                        foreach ($FcPort in $FcPorts) {
                            Write-Warning -Message "Disabling port $($FcPort.SlotId)/$($FcPort.PortId) on FI $($FcPort.SwitchId) "
                            $FcPort | Set-UcsUplinkPort -AdminState 'disabled' -Force
                        }
                    } else {
                        throw $_
                    }
                }
            }
        }

        # Disconnect from UCS
        Disconnect-Ucs
    }
}