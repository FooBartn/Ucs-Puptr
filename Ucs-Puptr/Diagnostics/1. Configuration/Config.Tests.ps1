#requires -Version 3 -Modules Pester, Cisco.UcsManager

[CmdletBinding()]
Param(
    # Optionally fix all config drift that is discovered. Defaults to false (off)
    [switch]$Remediate = $false,

    # Optionally define a different config file to use. Defaults to Vester\Configs\Config.ps1
    [string]$ConfigName
)

Process {
    Describe -Name 'Configuration File Validation' -Tag @('config') -Fixture {
        BeforeAll {
            # Project Environment Variables
            $ProjectDir = (Get-Item $PSScriptRoot).parent.parent.FullName
            $ConfigDir = $ProjectDir | Join-Path -ChildPath 'Configs'
            $ConfigFile = $ConfigDir | Join-Path -ChildPath "$ConfigName.ps1"

            # Describe Scoped Matching Variable
            $EnablePattern = '^enabled$|^disabled$'
            $YesNoPattern = '^yes$|^no$'
            $TruePattern = '^true$|^false$'
            $NicBehaviorPattern = '^none$|^hw-inherit$'
            $LACPRateVals = '^normal$|^fast$'
        }

        It 'Configuration directory should exist' {
            $ConfigDir | Should Exist
        }

        It 'Is reading a valid config file' {
            $ConfigFile | Should Exist
        }

        # Ensure $UcsConfiguration is loaded into the session
        . $ConfigFile

        It 'Properly supplies variable $UcsConfiguration' {
            $UcsConfiguration | Should Not BeNullOrEmpty
        }

        It 'Contains proper settings for .Connection' {
            $UcsConfiguration.Connection.Keys | Should Match 'Username|Domain'
            $UcsConfiguration.Connection.Keys.Count | Should Be 2
            $UcsConfiguration.Connection.Username | Should Not BeNullOrEmpty
            $UcsConfiguration.Connection.Username | Should BeOfType String
            $UcsConfiguration.Connection.UcsDomain.Count | Should BeGreaterThan 0
            $UcsConfiguration.Connection.UcsDomain | Should BeOfType String
        }

        It 'Contains proper settings for .Equipment' {
            # It Scoped Matching Variable
            $EquipmentKeys = 'InfoPolicyState|EthernetSwitchMode|FcSwitchMode|FirmwareVersion|'
            $EquipmentKeys += 'MinimumChassisUplinks|LinkAggregation|PowerRedundancy|SELPolicy'
            $SELKeys = 'Protocol|RemoteStore|RemotePath|ClearOnBackup|Action|Interval'
            $SwitchModes = '^end-host$|^switch$'
            $FirmwarePattern = '^[1-3].[1-3]\([0-9][a-z]\)$'
            $ChassisUplinkVals = '^1-link$|^2-link$|^4-link$|^8-link$|^platform-max$'
            $SELProtoVals = '^ftp$|^tftp$|^scp$|^sftp$'
            $SELActionVals = '^log-full$|^on-assoc-change$|^on-clear$|^timer$'
            $SELIntervalVals = '^1 hour$|^2 hours$|^4 hours$|^8 hours$|^24 hours$|^1 week$|^1 month$'
            $PowerRedunVals = '^non-redundant$|^n\+1$|^grid$'
            $LinkAggregVals = '^none$|^port-channel$'

            # Assertions
            $UcsConfiguration.Equipment.Keys | Should Match $EquipmentKeys
            $UcsConfiguration.Equipment.Keys.Count | Should Be 8
            $UcsConfiguration.Equipment.Values | ForEach-Object {$_ | Should Not BeNullOrEmpty}
            $UcsConfiguration.Equipment.InfoPolicyState | Should Match $EnablePattern
            $UcsConfiguration.Equipment.InfoPolicyState | Should BeOfType String
            $UcsConfiguration.Equipment.EthernetSwitchMode | Should BeOfType String
            $UcsConfiguration.Equipment.EthernetSwitchMode | Should Match $SwitchModes
            $UcsConfiguration.Equipment.FcSwitchMode | Should Match $SwitchModes
            $UcsConfiguration.Equipment.FcSwitchMode | Should BeOfType String
            $UcsConfiguration.Equipment.FirmwareVersion | Should Match $FirmwarePattern
            $UcsConfiguration.Equipment.FirmwareVersion | Should BeOfType String
            $UcsConfiguration.Equipment.MinimumChassisUplinks | Should Match $ChassisUplinkVals
            $UcsConfiguration.Equipment.MinimumChassisUplinks | Should BeOfType String
            $UcsConfiguration.Equipment.LinkAggregation | Should Match $LinkAggregVals
            $UcsConfiguration.Equipment.LinkAggregation | Should BeOfType String
            $UcsConfiguration.Equipment.PowerRedundancy | Should Match $PowerRedunVals
            $UcsConfiguration.Equipment.PowerRedundancy | Should BeOfType String
            $UcsConfiguration.Equipment.SELPolicy.Keys | Should Match $SELKeys
            $UcsConfiguration.Equipment.SELPolicy.Keys.Count | Should Be 6
            $UcsConfiguration.Equipment.SELPolicy.Protocol | Should Match $SELProtoVals
            $UcsConfiguration.Equipment.SELPolicy.Protocol | Should BeOfType String
            $UcsConfiguration.Equipment.SELPolicy.RemoteStore | Should BeOfType String
            $UcsConfiguration.Equipment.SELPolicy.RemotePath | Should BeOfType String
            $UcsConfiguration.Equipment.SELPolicy.ClearOnBackup | Should Match $YesNoPattern
            $UcsConfiguration.Equipment.SELPolicy.ClearOnBackup | Should BeOfType String
            $UcsConfiguration.Equipment.SELPolicy.Action | Should Match $SELActionVals
            $UcsConfiguration.Equipment.SELPolicy.Action | Should BeOfType String
            $UcsConfiguration.Equipment.SELPolicy.Interval | Should Match $SELIntervalVals
            $UcsConfiguration.Equipment.SELPolicy.Interval | Should BeOfType String
        }

        It 'Contains proper settings for .Admin' {
            # It Scoped Matching Variable
            $AdminKeys = 'Fault|Authentication|CallHome|CommServices|DnsServers'
            $NativeAuthKeys = 'Realm|ProviderGroup|WebSessionRefresh|WebSessionTimeout'
            $CommServiceKeys = 'WebSession|ShellSession|CimcWebService|HttpService|HttpsService|'
            $CommServiceKeys += 'Telnet|CimXml|Snmp'
            $SessionKeys = 'MaxSessionsPerUser|MaxSessions'
            $HttpServiceKeys = 'State|Port|RedirectToHttps'
            $HttpsServiceKeys = 'State|Port|KeyRing|CipherMode'
            $RealmVals = '^ldap$|^local$|^tacacs$|^radius$|^none$'
            $RetIntPattern = '^[0-9][0-9]:[0-9][0-9]:[0-9][0-9]:[0-9][0-9]$'
            $CipherVals = '^High-Strength$|^Medium-Strength$|^Low-Strength$|^Custom$'

            # Assertions
            $UcsConfiguration.Admin.Keys | Should Match $AdminKeys
            $UcsConfiguration.Admin.Keys.Count | Should Be 5
            $UcsConfiguration.Admin.Fault.Keys | Should Match 'Severity|RetentionInterval'
            $UcsConfiguration.Admin.Fault.Keys.Count | Should Be 2
            $UcsConfiguration.Admin.Fault.Severity | Should Match 'critical|major|warning|info'
            $UcsConfiguration.Admin.Fault.Severity | Should BeOfType String
            $UcsConfiguration.Admin.Fault.RetentionInterval | Should Match "forever|$RetIntPattern"
            $UcsConfiguration.Admin.Fault.RetentionInterval | Should BeOfType String
            $UcsConfiguration.Admin.Authentication.Keys | Should Match 'NativeAuth|ConsoleAuth'
            $UcsConfiguration.Admin.Authentication.Keys.Count | Should Be 2
            $UcsConfiguration.Admin.Authentication.NativeAuth.Keys | Should Match $NativeAuthKeys
            $UcsConfiguration.Admin.Authentication.NativeAuth.Keys.Count | Should Be 4
            $UcsConfiguration.Admin.Authentication.NativeAuth.Realm | Should Match $RealmVals
            $UcsConfiguration.Admin.Authentication.NativeAuth.Realm | Should BeOfType String
            $UcsConfiguration.Admin.Authentication.NativeAuth.ProviderGroup | Should BeOfType String
            $UcsConfiguration.Admin.Authentication.NativeAuth.WebSessionRefresh | Should BeOfType Int
            $UcsConfiguration.Admin.Authentication.NativeAuth.WebSessionTimeout | Should BeOfType Int
            $UcsConfiguration.Admin.Authentication.ConsoleAuth.Keys | Should Match 'Realm'
            $UcsConfiguration.Admin.Authentication.ConsoleAuth.Realm | Should Match $RealmVals
            $UcsConfiguration.Admin.Authentication.ConsoleAuth.Realm | Should BeOfType String
            $UcsConfiguration.Admin.CommServices.Keys | Should Match $CommServiceKeys
            $UcsConfiguration.Admin.CommServices.Keys.Count | Should Be 8
            $UcsConfiguration.Admin.CommServices.WebSession.Keys | Should Match $SessionKeys
            $UcsConfiguration.Admin.CommServices.WebSession.Keys.Count | Should Be 2
            $UcsConfiguration.Admin.CommServices.WebSession.MaxSessionsPerUser | Should BeOfType Int
            $UcsConfiguration.Admin.CommServices.WebSession.MaxSessions | Should BeOfType Int
            $UcsConfiguration.Admin.CommServices.ShellSession.Keys | Should Match $SessionKeys
            $UcsConfiguration.Admin.CommServices.ShellSession.Keys.Count | Should Be 2
            $UcsConfiguration.Admin.CommServices.ShellSession.MaxSessionsPerUser | Should BeOfType Int
            $UcsConfiguration.Admin.CommServices.ShellSession.MaxSessions | Should BeOfType Int
            $UcsConfiguration.Admin.CommServices.CimcWebService | Should Match $EnablePattern
            $UcsConfiguration.Admin.CommServices.CimcWebService | Should BeOfType String
            $UcsConfiguration.Admin.CommServices.HttpService.Keys | Should Match $HttpServiceKeys
            $UcsConfiguration.Admin.CommServices.HttpService.Keys.Count | Should Be 3
            $UcsConfiguration.Admin.CommServices.HttpService.State | Should Match $EnablePattern
            $UcsConfiguration.Admin.CommServices.HttpService.State | Should BeOfType String
            $UcsConfiguration.Admin.CommServices.HttpService.Port | Should BeOfType Int
            $UcsConfiguration.Admin.CommServices.HttpService.Port | Should Not BeNullOrEmpty
            $UcsConfiguration.Admin.CommServices.HttpService.RedirectToHttps | Should Match $EnablePattern
            $UcsConfiguration.Admin.CommServices.HttpService.RedirectToHttps | Should BeOfType String
            $UcsConfiguration.Admin.CommServices.HttpsService.Keys | Should Match $HttpsServiceKeys
            $UcsConfiguration.Admin.CommServices.HttpsService.Keys.Count | Should Be 4
            $UcsConfiguration.Admin.CommServices.HttpsService.State | Should Match $EnablePattern
            $UcsConfiguration.Admin.CommServices.HttpsService.State | Should BeOfType String
            $UcsConfiguration.Admin.CommServices.HttpsService.Port | Should BeOfType Int
            $UcsConfiguration.Admin.CommServices.HttpsService.Port | Should Not BeNullOrEmpty
            $UcsConfiguration.Admin.CommServices.HttpsService.KeyRing | Should BeOfType String
            $UcsConfiguration.Admin.CommServices.HttpsService.KeyRing | Should Not BeNullOrEmpty
            $UcsConfiguration.Admin.CommServices.HttpsService.CipherMode | Should Match $CipherVals
            $UcsConfiguration.Admin.CommServices.HttpsService.CipherMode | Should BeOfType String
            $UcsConfiguration.Admin.CommServices.Telnet | Should Match $EnablePattern
            $UcsConfiguration.Admin.CommServices.Telnet | Should BeOfType String
            $UcsConfiguration.Admin.CommServices.CimXml | Should Match $EnablePattern
            $UcsConfiguration.Admin.CommServices.CimXml | Should BeOfType String
            $UcsConfiguration.Admin.CommServices.Snmp | Should Match $EnablePattern
            $UcsConfiguration.Admin.CommServices.Snmp | Should BeOfType String
            $UcsConfiguration.Admin.DnsServers.Count | Should BeGreaterThan 0
            $UcsConfiguration.Admin.DnsServers | Should BeOfType String
        }

        It 'Contains proper settings for .Server' {
            # It Scoped Matching Variable
            $ServerKeys = 'MaintenancePolicy|PowerControlPol|ScrubPolicy|MemoryPolicy'
            $PowerControlKeys = 'FanSpeed|PowerCap|Priority'
            $ScrubPolicyKeys = 'DiskScrub|BiosScrub|FlashScrub'
            $MaintPolicyVals = '^user-ack$|^immediate$|^timer-automatic$'
            $FanSpeedVals = '^low-power$|^balanced$|^performance$|^high-power$|^max-power$|^any$'
            $PowerCapVals = '^cap$|^no-cap$'
            $PowerPrioVals = '^[1-9]$|^10$'

            # Assertions
            $UcsConfiguration.Server.Keys | Should Match $ServerKeys
            $UcsConfiguration.Server.Keys.Count | Should Be 4
            $UcsConfiguration.Server.MaintenancePolicy.Keys.Count | Should Not Be 0
            $UcsConfiguration.Server.MaintenancePolicy.Values | Should Match $MaintPolicyVals
            $UcsConfiguration.Server.MaintenancePolicy.Values | Should BeOfType String
            $UcsConfiguration.Server.PowerControlPol.Keys.Count | Should Not Be 0
            foreach ($Policy in $UcsConfiguration.Server.PowerControlPol.Keys) {
                $UcsConfiguration.Server.PowerControlPol.$Policy.Keys | Should Match $PowerControlKeys
                $UcsConfiguration.Server.PowerControlPol.$Policy.Keys.Count | Should Be 3
                $UcsConfiguration.Server.PowerControlPol.$Policy.FanSpeed | Should Match $FanSpeedVals
                $UcsConfiguration.Server.PowerControlPol.$Policy.FanSpeed | Should BeOfType String
                $UcsConfiguration.Server.PowerControlPol.$Policy.PowerCap | Should Match $PowerCapVals
                $UcsConfiguration.Server.PowerControlPol.$Policy.PowerCap | Should BeOfType String
                $UcsConfiguration.Server.PowerControlPol.$Policy.Priority | Should Match $PowerPrioVals
            }
            $UcsConfiguration.Server.ScrubPolicy.Keys.Count | Should Not Be 0
            foreach ($Policy in $UcsConfiguration.Server.ScrubPolicy.Keys) {
                $UcsConfiguration.Server.ScrubPolicy.$Policy.Keys | Should Match $ScrubPolicyKeys
                $UcsConfiguration.Server.ScrubPolicy.$Policy.Keys.Count | Should Be 3
                $UcsConfiguration.Server.ScrubPolicy.$Policy.DiskScrub | Should Match $YesNoPattern
                $UcsConfiguration.Server.ScrubPolicy.$Policy.DiskScrub | Should BeOfType String
                $UcsConfiguration.Server.ScrubPolicy.$Policy.BiosScrub | Should Match $YesNoPattern
                $UcsConfiguration.Server.ScrubPolicy.$Policy.BiosScrub | Should BeOfType String
                $UcsConfiguration.Server.ScrubPolicy.$Policy.FlashScrub | Should Match $YesNoPattern
                $UcsConfiguration.Server.ScrubPolicy.$Policy.FlashScrub | Should BeOfType String
            }
            $UcsConfiguration.Server.MemoryPolicy.Keys.Count | Should Not Be 0
            $UcsConfiguration.Server.MemoryPolicy.Values | Should Match $EnablePattern
            $UcsConfiguration.Server.MemoryPolicy.Values | Should BeOfType String
        }
        It 'Contains proper settings for .Lan' {
            $LanKeys = 'NetworkControlPol|UDLDLinkProfile|UDLDLinkPolicy|LinkProtocolPol|'
            $LanKeys += 'LACPPolicy|PFCPolicy|DefaultVnicBehavior|VlanGroups|Vlans|'
            $LanKeys += 'FabricA|FabricB'
            $NetControlPolKeys = 'CDPState|MACRegisterMode|UplinkFailureAction|'
            $NetControlPolKeys += 'MacForging|LLDPTransmit|LLDPReceive'
            $LinkPolicyKeys = 'UDLDState|UDLDMode'
            $LinkProtoKeys = 'UDLDRecoveryAction|UDLDRecoveryInterval'
            $LACPKeys = 'LACPSuspend|LACPRate'
            $PFCKeys = 'PriorityFlowControl|SendFlowControl|ReceiveFlowControl'
            $PortChannelKeys = 'PFCPolicy|LACPPolicy|AdminSpeed|OperSpeed|AutoNegotiate'
            $MacRegisterVals = '^only-native-vlan$|^all-host-vlans$'
            $UplinkFailureVals = '^link-down$|^warning$'
            $MacForgeVals = '^allow$|^deny$'
            $UDLDModeVals = '^normal$|^aggressive$'
            $UDLDRecoveryVals = '^none$|^reset$'
            $PFCVals = '^auto$|^on$'
            $SendReceiveVals = '^on$|^off$'
            $AdminSpeedVals = '^1gbps$|^10gbps$|^40gbps$'
           
            $UcsConfiguration.Lan.Keys | Should Match $LankKeys
            $UcsConfiguration.Lan.Keys.Count | Should Be 11
            $UcsConfiguration.Lan.NetworkControlPol.Keys.Count | Should Not Be 0
            foreach ($Policy in $UcsConfiguration.Lan.NetworkControlPol.Keys) {
                $UcsConfiguration.Lan.NetworkControlPol.$Policy.Keys | Should Match $NetControlPolKeys
                $UcsConfiguration.Lan.NetworkControlPol.$Policy.Keys.Count | Should Be 6
                $UcsConfiguration.Lan.NetworkControlPol.$Policy.CDPState | Should Match $EnablePattern
                $UcsConfiguration.Lan.NetworkControlPol.$Policy.CDPState | Should BeOfType String
                $UcsConfiguration.Lan.NetworkControlPol.$Policy.MacRegisterMode | Should Match $MacRegisterVals
                $UcsConfiguration.Lan.NetworkControlPol.$Policy.MacRegisterMode | Should BeOfType String
                $UcsConfiguration.Lan.NetworkControlPol.$Policy.UplinkFailureAction | Should Match $UplinkFailureVals
                $UcsConfiguration.Lan.NetworkControlPol.$Policy.UplinkFailureAction | Should BeOfType String
                $UcsConfiguration.Lan.NetworkControlPol.$Policy.MacForging | Should Match $MacForgeVals
                $UcsConfiguration.Lan.NetworkControlPol.$Policy.MacForging | Should BeOfType String
                $UcsConfiguration.Lan.NetworkControlPol.$Policy.LLDPTransmit | Should Match $EnablePattern
                $UcsConfiguration.Lan.NetworkControlPol.$Policy.LLDPTransmit | Should BeOfType String
                $UcsConfiguration.Lan.NetworkControlPol.$Policy.LLDPReceive | Should Match $EnablePattern
                $UcsConfiguration.Lan.NetworkControlPol.$Policy.LLDPReceive | Should BeOfType String
            }
            $UcsConfiguration.Lan.UDLDLinkProfile.Keys.Count | Should Not Be 0
            foreach ($Policy in $UcsConfiguration.Lan.UDLDLinkProfile.Keys) {
                $UcsConfiguration.Lan.UDLDLinkProfile.$Policy.Keys | Should Match 'UDLDLinkPolicy'
                $UcsConfiguration.Lan.UDLDLinkProfile.$Policy.UDLDLinkPolicy | Should Not BeNullOrEmpty
                $UcsConfiguration.Lan.UDLDLinkProfile.$Policy.UDLDLinkPolicy | Should BeOfType String
            }
            $UcsConfiguration.Lan.UDLDLinkPolicy.Keys.Count | Should Not Be 0
            foreach ($Policy in $UcsConfiguration.Lan.UDLDLinkPolicy.Keys) {
                $UcsConfiguration.Lan.UDLDLinkPolicy.$Policy.Keys | Should Match $LinkPolicyKeys
                $UcsConfiguration.Lan.UDLDLinkPolicy.$Policy.Keys.Count | Should Be 2
                $UcsConfiguration.Lan.UDLDLinkPolicy.$Policy.UDLDState | Should Match $EnablePattern
                $UcsConfiguration.Lan.UDLDLinkPolicy.$Policy.UDLDState | Should BeOfType String
                $UcsConfiguration.Lan.UDLDLinkPolicy.$Policy.UDLDMode | Should Match $UDLDModeVals
                $UcsConfiguration.Lan.UDLDLinkPolicy.$Policy.UDLDMode | Should BeOfType String
            }
            $UcsConfiguration.Lan.LinkProtocolPol.Keys | Should Match $LinkProtoKeys
            $UcsConfiguration.Lan.LinkProtocolPol.Keys.Count | Should Be 2
            $UcsConfiguration.Lan.LinkProtocolPol.UDLDRecoveryAction | Should Match $UDLDRecoveryVals
            $UcsConfiguration.Lan.LinkProtocolPol.UDLDRecoveryAction | Should BeOfType String
            $UcsConfiguration.Lan.LinkProtocolPol.UDLDRecoveryInterval | Should Not BeNullOrEmpty
            $UcsConfiguration.Lan.LinkProtocolPol.UDLDRecoveryInterval | Should BeOfType Int
            $UcsConfiguration.Lan.LACPPolicy.Keys.Count | Should Not Be 0
            foreach ($Policy in $UcsConfiguration.Lan.LACPPolicy.Keys) {
                $UcsConfiguration.Lan.LACPPolicy.$Policy.Keys | Should Match $LACPKeys
                $UcsConfiguration.Lan.LACPPolicy.$Policy.Keys.Count | Should Be 2
                $UcsConfiguration.Lan.LACPPolicy.$Policy.LACPSuspend | Should Match $TruePattern
                $UcsConfiguration.Lan.LACPPolicy.$Policy.LACPSuspend | Should BeOfType String
                $UcsConfiguration.Lan.LACPPolicy.$Policy.LACPRate | Should Match $LACPRateVals
                $UcsConfiguration.Lan.LACPPolicy.$Policy.LACPRate | Should BeOfType String
            }
            $UcsConfiguration.Lan.PFCPolicy.Keys.Count | Should Not Be 0
            foreach ($Policy in $UcsConfiguration.Lan.PFCPolicy.Keys) {
                $UcsConfiguration.Lan.PFCPolicy.$Policy.Keys | Should Match $PFCKeys
                $UcsConfiguration.Lan.PFCPolicy.$Policy.Keys.Count | Should Be 3
                $UcsConfiguration.Lan.PFCPolicy.$Policy.PriorityFlowControl | Should Match $PFCVals
                $UcsConfiguration.Lan.PFCPolicy.$Policy.PriorityFlowControl | Should BeOfType String
                $UcsConfiguration.Lan.PFCPolicy.$Policy.SendFlowControl | Should Match $SendReceiveVals
                $UcsConfiguration.Lan.PFCPolicy.$Policy.SendFlowControl | Should BeOfType String
                $UcsConfiguration.Lan.PFCPolicy.$Policy.ReceiveFlowControl | Should Match $SendReceiveVals
                $UcsConfiguration.Lan.PFCPolicy.$Policy.ReceiveFlowControl | Should BeOfType String
            }
            $UcsConfiguration.Lan.DefaultVnicBehavior | Should Match $NicBehaviorPattern
            $UcsConfiguration.Lan.DefaultVnicBehavior | Should BeOfType String
            $UcsConfiguration.Lan.VlanGroups.Count | Should Not Be 0
            $UcsConfiguration.Lan.VlanGroups | Should BeOfType String
            $UcsConfiguration.Lan.Vlans.Count | Should Not Be 0
            $UcsConfiguration.Lan.Vlans | Should BeOfType Int
            $UcsConfiguration.Lan.FabricA.Keys.Count | Should Not Be 0
            foreach ($PortChannel in $UcsConfiguration.Lan.FabricA.Keys) {
                $PortChannel | Should Match '[0-9]$'
                $UcsConfiguration.Lan.FabricA.$PortChannel.Keys | Should Match $PortChannelKeys
                $UcsConfiguration.Lan.FabricA.$PortChannel.Keys.Count | Should Be 5
                $UcsConfiguration.Lan.FabricA.$PortChannel.PFCPolicy | Should Not BeNullOrEmpty
                $UcsConfiguration.Lan.FabricA.$PortChannel.PFCPolicy | Should BeOfType String
                $UcsConfiguration.Lan.FabricA.$PortChannel.LACPPolicy | Should Not BeNullOrEmpty
                $UcsConfiguration.Lan.FabricA.$PortChannel.LACPPolicy | Should BeOfType String
                $UcsConfiguration.Lan.FabricA.$PortChannel.AdminSpeed | Should Match $AdminSpeedVals
                $UcsConfiguration.Lan.FabricA.$PortChannel.AdminSpeed | Should BeOfType String
                $UcsConfiguration.Lan.FabricA.$PortChannel.OperSpeed | Should Not BeNullOrEmpty
                $UcsConfiguration.Lan.FabricA.$PortChannel.OperSpeed | Should BeOfType String
                $UcsConfiguration.Lan.FabricA.$PortChannel.OperSpeed | Should Match 'gbps$'
                $UcsConfiguration.Lan.FabricA.$PortChannel.AutoNegotiate | Should Match $YesNoPattern
                $UcsConfiguration.Lan.FabricA.$PortChannel.AutoNegotiate | Should BeOfType String
            }
            $UcsConfiguration.Lan.FabricB.Keys.Count | Should Not Be 0
            foreach ($PortChannel in $UcsConfiguration.Lan.FabricB.Keys) {
                $PortChannel | Should Match '[0-9]$'
                $UcsConfiguration.Lan.FabricB.$PortChannel.Keys | Should Match $PortChannelKeys
                $UcsConfiguration.Lan.FabricB.$PortChannel.Keys.Count | Should Be 5
                $UcsConfiguration.Lan.FabricB.$PortChannel.PFCPolicy | Should Not BeNullOrEmpty
                $UcsConfiguration.Lan.FabricB.$PortChannel.PFCPolicy | Should BeOfType String
                $UcsConfiguration.Lan.FabricB.$PortChannel.LACPPolicy | Should Not BeNullOrEmpty
                $UcsConfiguration.Lan.FabricB.$PortChannel.LACPPolicy | Should BeOfType String
                $UcsConfiguration.Lan.FabricB.$PortChannel.AdminSpeed | Should Match $AdminSpeedVals
                $UcsConfiguration.Lan.FabricB.$PortChannel.AdminSpeed | Should BeOfType String
                $UcsConfiguration.Lan.FabricB.$PortChannel.OperSpeed | Should Not BeNullOrEmpty
                $UcsConfiguration.Lan.FabricB.$PortChannel.OperSpeed | Should BeOfType String
                $UcsConfiguration.Lan.FabricB.$PortChannel.OperSpeed | Should Match 'gbps$'
                $UcsConfiguration.Lan.FabricB.$PortChannel.AutoNegotiate | Should Match $YesNoPattern
                $UcsConfiguration.Lan.FabricB.$PortChannel.AutoNegotiate | Should BeOfType String
            }
        }
        It 'Contains proper settings for .San' {
            $SanKeys = 'DefaultVhbaBehavior|LACPPolicy|FabricA|FabricB'
            $PortChannelKeys = 'VSAN|AdminSpeed|OperSpeed'
            $AdminSpeedVals = '^1gbps$|^2gbps$|^4gbps$|^8gbps$|^Auto$|^16gbps$|'
            $UcsConfiguration.San.Keys | Should Match $SanKeys
            $UcsConfiguration.San.Keys.Count | Should Be 4
            $UcsConfiguration.San.DefaultVhbaBehavior | Should Match $NicBehaviorPattern
            $UcsConfiguration.San.DefaultVhbaBehavior | Should BeOfType String
            $UcsConfiguration.San.FabricA.Keys.Count | Should Not Be 0
            foreach ($PortChannel in $UcsConfiguration.San.FabricA.Keys) {
                $PortChannel | Should Match '[0-9]$'
                $UcsConfiguration.San.FabricA.$PortChannel.Keys | Should Match $PortChannelKeys
                $UcsConfiguration.San.FabricA.$PortChannel.Keys.Count | Should Be 3
                $UcsConfiguration.San.FabricA.$PortChannel.VSAN | Should Not BeNullOrEmpty
                $UcsConfiguration.San.FabricA.$PortChannel.VSAN | Should BeOfType Int
                $UcsConfiguration.San.FabricA.$PortChannel.AdminSpeed | Should Match $AdminSpeedVals
                $UcsConfiguration.San.FabricA.$PortChannel.AdminSpeed | Should BeOfType String
                $UcsConfiguration.San.FabricA.$PortChannel.OperSpeed | Should Not BeNullOrEmpty
                $UcsConfiguration.San.FabricA.$PortChannel.OperSpeed | Should BeOfType Int
            }
            $UcsConfiguration.San.FabricB.Keys.Count | Should Not Be 0
            foreach ($PortChannel in $UcsConfiguration.San.FabricB.Keys) {
                $PortChannel | Should Match '[0-9]$'
                $UcsConfiguration.San.FabricB.$PortChannel.Keys | Should Match $PortChannelKeys
                $UcsConfiguration.San.FabricB.$PortChannel.Keys.Count | Should Be 3
                $UcsConfiguration.San.FabricB.$PortChannel.VSAN | Should Not BeNullOrEmpty
                $UcsConfiguration.San.FabricB.$PortChannel.VSAN | Should BeOfType Int
                $UcsConfiguration.San.FabricB.$PortChannel.AdminSpeed | Should Match $AdminSpeedVals
                $UcsConfiguration.San.FabricB.$PortChannel.AdminSpeed | Should BeOfType String
                $UcsConfiguration.San.FabricB.$PortChannel.OperSpeed | Should Not BeNullOrEmpty
                $UcsConfiguration.San.FabricB.$PortChannel.OperSpeed | Should BeOfType Int
            }

        }
        It 'Contains proper settings for .Other' {
            $OtherKeys = 'PoolUsageThreshold|PoolAssignmentOrder'
            $PoolUsageVals = '^[0-9]$|^[0-9][0-9]$|^100$'
            $PoolOrderVals = '^default$|^sequential$'
            $UcsConfiguration.Other.Keys | Should Match $OtherKeys
            $UcsConfiguration.Other.Keys.Count | Should Be 2
            $UcsConfiguration.Other.PoolUsageThreshold | Should Match $PoolUsageVals
            $UcsConfiguration.Other.PoolUsageThreshold | Should BeOfType Int
            $UcsConfiguration.Other.PoolAssignmentOrder | Should Match $PoolOrderVals
            $UcsConfiguration.Other.PoolAssignmentOrder | Should BeOfType String
        }
    } #Describe
} #Process