$config = @{}

<########################################################################################
        Connection Details
        Username = [string] Username for connecting to UCS domains
        Domain = [string[]] List of UCS domains to connect to (Hostname or IP)
#>

$config.connection = @{
    Username = 'PlayerOne'
    Domain = @(
        '10.10.1.100'
    )
}

<########################################################################################
        UCSM Settings
        PoolUsageThreshold = [string] Threshold for percentage of UID pool used
        FaultSeverity = [string[]] Fault severity levels to check for (critical/major/warning/info)
        FaultRetentionInterval = [string] Fault retention interval. 'forever' or days:hours:minutes:seconds
        MaintenancePolicy = [string] Maintenance Policy disruption setting (user-ack/immediate/timer-automatic)
        PoolAssignmentOrder = [string] Pool assignment order (default/sequential)
        InfoPolicyState = [string] Info Policy state (enabled/disabled)
        FirmwareVersion = [string] Expected firmware release (usually formed as Major.Minor(BugFix). Example: 3.1(1g))
#>

$config.ucsm = @{
    PoolUsageThreshold = [int]80
    FaultSeverity = @('critical','major')
    FaultRetentionInterval = '07:00:00:00'
    MaintenancePolicy = [string]'user-ack'
    PoolAssignmentOrder = [string]'sequential'
    InfoPolicyState = [string]'enabled'
    FirmwareVersion = [string]'3.1(1g)'
}

<########################################################################################
        Fabric Interconnect Settings
        EthernetSwitchMode = [string] Ethernet (LAN) switch mode (end-host/switch)
        FcSwitchMode = [string] Fiber Channel (SAN) switch mode (end-host/switch) 
#>

$config.fabric = @{
    EthernetSwitchMode = [string]'end-host'
    FcSwitchMode = [string]'end-host'
}

<########################################################################################
        Chassis/Server Settings
        MinimumChassisUplinks = [string] Minimum number of uplinks required to discover Chassis/FEX(1/2/4/8/platform-max)
        LinkAggregation = [string] Link aggregation (none/port-channel)
        PowerRedundancy = [string] Power redundancy setting (non-redundant/n+1/grid)
        SELProtocol = [string] Protocol for sending SEL logs to remote location (ftp/tftp/scp/sftp)
        SELRemoteStore = [string] Hostname or IP for remote storage location
        SELRemotePath = [string] Storage path on remote location
        SELClearOnBackup = [string] Clear SEL logs when they are backed up (yes/no)
        SELAction = [string[]] When to offload SEL logs. Use braces and choose one or more options separated by commas {log-full, on-assoc-change, on-clear, timer}
        SELInterval = [string] Interval if timer is set as a SelAction.  {1 hour/2 hours/4 hours/8 hours/24 hours/1 week/1 month}
#>

$config.server = @{
    MinimumChassisUplinks = [string]'4'
    LinkAggregation = [string]'port-channel'
    PowerRedundancy = [string]'grid'
    SELProtocol = [string]'sftp'
    SELRemoteStore = [string]'sftp.domain.org'
    SELRemotePath = [string]'/'
    SELClearOnBackup = [string]'yes'
    SELAction = @('log-full','on-clear')
    SELInterval = '1 hour'
}

<########################################################################################
        Network Settings
        CDPState = [string] Cisco Discovery Protocol state (enabled/disabled)
        MACRegisterMode = [string] MAC address register mode (only-native-vlan/all-host-vlans)
        UplinkFailureAction = [string] Action to take on  uplink failure (link-down/warning)
        PriorityFlowControl = [string] Priority Flow Control setting (auto/on)
        SendFlowControl = [string] Send Flow Control setting (on/off)
        ReceiveFlowControl = [string] Receive Flow Control setting (on/off)
        LACPSuspend = [string] LACP Suspend Individual enabled (true/false)
        LACPRate = [string] LACP Rate setting (normal/fast)
        UDLDState = [string]  Unidirectional Link Detection setting (enabled/disabled)
        UDLDMode = [string] UDLD Mode setting (normal/aggressive)
        UDLDRecoveryAction = [string] UDLD Recovery Action setting (none/reset)
        UDLDRecoveryInterval = [int] Seconds between UDLD attempting recovery action
        DefaultVnicBehavior = [string] Default vNIC creation behavior setting (none/hw-inherit)
        DefaultVhbaBehavior = [string] Default vHBA creation behavior setting (none/hw-inherit)
        MacForging = [string] Mac Forging setting (allow/deny)
#>

$config.network = @{
    CDPState = [string]'enabled'
    MACRegisterMode = [string]'only-native-vlan'
    UplinkFailureAction = [string]'link-down'
    PriorityFlowControl = [string]'auto'
    SendFlowControl = [string]'on'
    ReceiveFlowControl = [string]'on'
    LACPSuspend = [string]'true'
    LACPRate = [string]'normal'
    UDLDState = [string]'enabled'
    UDLDMode = [string]'aggressive'
    UDLDRecoveryAction = [string]'reset'
    UDLDRecoveryInterval = [int]15
    DefaultVnicBehavior = [string]'none'
    DefaultVhbaBehavior = [string]'none'
    MacForging = [string]'allow'
}