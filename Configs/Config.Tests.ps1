#requires -Version 3 -Modules Pester

[CmdletBinding()]
Param(
    # Optionally define a different config file to use. Defaults to Vester\Configs\Config.ps1
    [string]$Config = "$PSScriptRoot\Config.ps1"
)

Process {
    Describe 'Config file validation' {
        It 'Is reading a valid config file' {
            $Config | Should Exist
        }
        
        # Ensure $config is loaded into the session
        . $Config

        It 'Properly supplies variable $config' {
            $config | Should Not BeNullOrEmpty
        }

        It 'Contains proper settings for .connection' {
            $PuptrUser = $config.connection.Username
            $PuptrUser | Should Not BeNullOrEmpty
            $config.connection.Domain.Count | Should BeGreaterThan 0
            
            # Test if secure file exists. If not, create it.
            try {
                Test-Path -Path "..\$PuptrUser.txt" -ErrorAction Stop | Should Be $true
            } catch {
                Write-Warning -Message $_
                Write-Warning -Message "Creating secure password file for $PuptrUser"
                $Credential = Get-Credential -UserName $PuptrUser -Message 'Credentials for connecting to UCS Domains with Ucs-Puptr'
                $Credential.Password | ConvertFrom-SecureString | Out-File -FilePath "..\$($Credential.UserName).txt"
            }

            # Importing credentials
            $SecurePassword = Get-Content -Path "..\$PuptrUser.txt" | ConvertTo-SecureString
            $Credential = [pscredential]::new($PuptrUser,$SecurePassword)
            
            # Support multiple default ucs connections if necessary
            try {
                if ($config.connection.Domain.Count -gt 1) {
                    (Get-UcsPowerToolConfiguration).SupportMultipleDefaultUcs | Should Be $true
                }
            } catch {
                Write-Warning -Message $_
                Write-Warning -Message "Enabling support for multiple default Ucs connections"
                Set-UcsPowerToolConfiguration -SupportMultipleDefaultUcs $true -Force
            }

            # Test connectivity
            foreach ($Domain in $config.connection.Domain) {
                try {
                    Connect-Ucs -Name $Domain -Credential $Credential -ErrorAction Stop | Should Not BeNullOrEmpty
                } catch {
                    throw $_
                } finally {
                    Disconnect-Ucs
                }
            }
        }

        It 'Contains proper settings for .ucsm' {
            $UcsmKeys = 'PoolUsageThreshold|FaultSeverity|FaultRetentionFrequency|FaultRetentionValue|'
            $UcsmKeys += 'MaintenancePolicy|PoolAssignmentOrder|InfoPolicyState|FirmwareVersion'
            $config.ucsm.Keys | Should Match $UcsmKeys
            $config.ucsm.Keys.Count | Should Be 8
            $config.ucsm.Values | ForEach-Object {$_ | Should Not BeNullOrEmpty}
            $config.ucsm.PoolUsageThreshold | Should Not BeGreaterThan 100
            $config.ucsm.PoolUsageThreshold | Should Not BeLessThan 1
            $config.ucsm.PoolUsageThreshold | Should BeOfType Int
            $config.ucsm.FaultSeverity | Should Match 'critical|major|warning|info'
            $config.ucsm.FaultSeverity | Should BeOfType String
            $config.ucsm.FaultRetentionFrequency | Should Match 'forever|days|hours|minutes|seconds'
            $config.ucsm.FaultRetentionFrequency | Should BeOfType String
            $config.ucsm.FaultRetentionValue | Should BeOfType Int
            $config.ucsm.MaintenancePolicy | Should Match 'user-ack|immediate|timer-automatic'
            $config.ucsm.MaintenancePolicy | Should BeOfType String
            $config.ucsm.PoolAssignmentOrder | Should Match 'default|sequential'
            $config.ucsm.PoolAssignmentOrder | Should BeOfType String
            $config.ucsm.InfoPolicyState | Should Match 'enabled|disabled'
            $config.ucsm.InfoPolicyState | Should BeOfType String
            $config.ucsm.FirmwareVersion | Should Match '^[1-3].[1-3]'
            $config.ucsm.FirmwareVersion | Should BeOfType String
        }

        It 'Contains proper settings for .fabric' {
            $SwitchModes = 'end-host|switch'
            $config.fabric.Keys | Should Match 'EthernetSwitchMode|FcSwitchMode'
            $config.fabric.Keys.Count | Should Be 2
            $config.fabric.EthernetSwitchMode | Should Match $SwitchModes
            $config.fabric.EthernetSwitchMode | Should BeOfType String
            $config.fabric.FcSwitchMode | Should Match $SwitchModes
            $config.fabric.FcSwitchMode | Should BeOfType String
        }

        It 'Contains proper settings for .server' {
            $ServerKeys = 'MinimumChassisUplinks|LinkAggregation|PowerRedundancy|'
            $ServerKeys += 'SELProtocol|SELRemoteStore|SELRemotePath|SELClearOnBackup|'
            $ServerKeys += 'SELAction|SELInterval'
            $config.server.Keys | Should Match $ServerKeys
            $config.server.Keys.Count | Should Be 9
            $config.server.MinimumChassisUplinks | Should Match '1|2|4|8|platform-max'
            $config.server.MinimumChassisUplinks | Should BeOfType String
            $config.server.LinkAggregation | Should Match 'none|port-channel'
            $config.server.LinkAggregation | Should BeOfType String
            $config.server.PowerRedundancy | Should Match 'non-redundant|n\+1|grid'
            $config.server.PowerRedundancy | Should BeOfType String
            $config.server.SELProtocol | Should BeOfType String
            $config.server.SELRemotePath | Should BeOfType String
            $config.server.SELClearOnBackup | Should Match 'yes|no'
            $config.server.SELClearOnBackup | Should BeOfType String
            $config.server.SELAction | Should Match 'log-full|on-assoc-change|on-clear|timer'
            $config.server.SELAction | Should BeOfType String
            $config.server.SELInterval | Should Match '1 hour|2 hours|4 hours|8 hours|24 hours|1 week|1 month'
            $config.server.SELInterval | Should BeOfType String
        }
        It 'Contains proper settings for .network' {
            $NetworkKeys = 'CDPState|MACRegisterMode|UplinkFailureAction|PriorityFlowControl|'
            $NetworkKeys += 'SendFlowControl|ReceiveFlowControl|LACPSuspend|LACPRate|UDLDState|'
            $NetworkKeys += 'UDLDMode|UDLDRecoveryAction|UDLDRecoveryInterval|'
            $NetworkKeys += 'DefaultVnicBehavior|DefaultVhbaBehavior|MacForging'
            $config.network.Keys | Should Match $NetworkKeys
            $config.network.Keys.Count | Should Be 15
            $config.network.CDPState | Should Match 'enabled|disabled'
            $config.network.CDPState | Should BeOfType String
            $config.network.MACRegisterMode | Should Match 'only-native-vlan|all-host-vlans'
            $config.network.MACRegisterMode | Should BeOfType String
            $config.network.UplinkFailureAction | Should Match 'link-down|warning'
            $config.network.UplinkFailureAction | Should BeOfType String
            $config.network.PriorityFlowControl | Should Match 'auto|on'
            $config.network.PriorityFlowControl | Should BeOfType String
            $config.network.SendFlowControl | Should Match 'on|off'
            $config.network.SendFlowControl | Should BeOfType String
            $config.network.ReceiveFlowControl | Should Match 'on|off'
            $config.network.ReceiveFlowControl | Should BeOfType String
            $config.network.LACPSuspend | Should Match 'true|false'
            $config.network.LACPSuspend | Should BeOfType String
            $config.network.LACPRate | Should Match 'normal|fast'
            
        }
    } #Describe
} #Process