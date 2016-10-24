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
    Describe -Name 'Network Configuration: Enabled LAN Ports ' -Tag @('network') -Fixture {
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
            $EthPorts = Get-UcsUplinkPort -Ucs $UcsDomain.Name -AdminState 'enabled'
            foreach ($EthPort in $EthPorts) {
                It -Name "$($UcsDomain.Name) port $($EthPort.SlotId)/$($EthPort.PortId) is up" -Test {
                    # Assert
                    try {
                        $EthPort.OperState | Should Be 'up'
                    } catch {
                        if ($Remediate) {
                            Write-Warning -Message $_
                            Write-Warning -Message "Disabling port $($EthPort.SlotId)/$($EthPort.PortId) on FI $($EthPort.SwitchId) " 
                            $EthPort | Set-UcsUplinkPort -AdminState 'disabled' -Force
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