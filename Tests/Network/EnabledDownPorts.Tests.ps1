#requires -Modules Pester, Cisco.UcsManager

[CmdletBinding()]
Param(
    # Optionally fix all config drift that is discovered. Defaults to false (off)
    [switch]$Remediate = $false,

    # Optionally define a different config file to use.
    [string]$Config
)

# NOTE: THERE IS AN ISSUE HERE. The Cisco UCS XML presents a port without an SFP present as being 'up'. So this test will not catch that.

Process {
    # Tests
    Describe -Name 'Network Configuration: Ports Both Enabled and Down ' -Tag @('network','no-impact') -Fixture {
        # Project Environment Variables      
        $ProjectDir = (Get-Item $PSScriptRoot).parent.parent.FullName
        $CredentialDir = "$ProjectDir\Credentials"
        
        # Config Variables
        . $Config
        [string]$PuptrUser = $config.connection.Username
        [string[]]$UcsDomains = $config.connection.Domain
        #[vartype]$var = 

        # Importing credentials
        $SecurePassword = Get-Content -Path "$CredentialDir\$PuptrUser.txt" | ConvertTo-SecureString
        $Credential = [pscredential]::new($PuptrUser,$SecurePassword)

        # Connect to UCS 
        Connect-Ucs -Name $UcsDomains -Credential $Credential

        # Run test case
        foreach ($UcsDomain in (Get-UcsStatus)) {
            $EthPorts = Get-UcsUplinkPort -Ucs $UcsDomain.Name -AdminState 'enabled' |
                Where {$_.OperState -ne 'up'}
            $FcPorts = Get-UcsFcUplinkPort -Ucs $UcsDomain.Name -AdminState 'enabled' |
                Where {$_.OperState -ne 'up'}

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