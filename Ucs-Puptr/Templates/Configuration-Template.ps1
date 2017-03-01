$UcsConfiguration = @{}

<########################################################################################
        Connection Details
        Username = [string] Username for connecting to UCS domains
        Domain = [string[]] List of UCS domains to connect to (Hostname or IP)
#>

$UcsConfiguration.Connection = @{
    Username = [string]'PlayerOne'
    UcsDomain = @(
        '10.10.1.100'
    )
}

<########################################################################################
        Equipment Settings

        InfoPolicyState = [string] Info Policy state (enabled/disabled)
        EthernetSwitchMode = [string] Ethernet (LAN) switch mode (end-host/switch)
        FcSwitchMode = [string] Fiber Channel (SAN) switch mode (end-host/switch) 
        FirmwareVersion = [string] Expected firmware release (usually formed as Major.Minor(BugFix). Example: 3.1(1g))
        MinimumChassisUplinks = [string] Minimum number of uplinks required to discover Chassis/FEX(1-link/2-link/4-link/8-link/platform-max)
        LinkAggregation = [string] Link aggregation (none/port-channel)
        PowerRedundancy = [string] Power redundancy setting (non-redundant/n+1/grid)
        SELPolicy
            Protocol = [string] Protocol for sending SEL logs to remote location (ftp/tftp/scp/sftp)
            RemoteStore = [string] Hostname or IP for remote storage location
            RemotePath = [string] Storage path on remote location
            ClearOnBackup = [string] Clear SEL logs when they are backed up (yes/no)
            Action = [string[]] When to offload SEL logs. Use braces and choose one or more options separated by commas {log-full, on-assoc-change, on-clear, timer}
            Interval = [string] Interval if timer is set as a SelAction.  {1 hour/2 hours/4 hours/8 hours/24 hours/1 week/1 month}        
#>

$UcsConfiguration.Equipment = @{
    InfoPolicyState = [string]'enabled'
    EthernetSwitchMode = [string]'end-host'
    FcSwitchMode = [string]'end-host'
    FirmwareVersion = [string]'3.1(1g)'
    MinimumChassisUplinks = [string]'4-link'
    LinkAggregation = [string]'port-channel'
    PowerRedundancy = [string]'grid'
    SELPolicy = @{
        Protocol = [string]'sftp'
        RemoteStore = [string]'sftp.domain.org'
        RemotePath = [string]'/'
        ClearOnBackup = [string]'yes'
        Action = @('log-full','on-clear')
        Interval = [string]'1 hour'
    }
}

<########################################################################################
        Admin Settings

        Fault
            Severity = [string[]] Fault severity levels to check for (critical/major/warning/info)
            RetentionInterval = [string] Fault retention interval. 'forever' or days:hours:minutes:seconds
        Authentication
            Native Authentication
                Realm = [string] Default realm to use when logging in via HTTP/s (ldap/local/tacacs/radius/none)
                ProviderGroup = [string] Group you created to manage authentication for a specific realm
                WebSessionRefresh = [int] Refresh requests to Cisco UCS Manager to keep the web session active in seconds
                WebSessionTimeout = [int] Amount of time that can elapse after the last refresh before session considered inactive.
            Console Authentication
                Realm = [string] Default realm to use when logging in via Console (ldap/local/tacacs/radius/none)
        Call Home
            State = [string] Enable/Disable call home service (on/off)
        Communication Services
            WebSession
                Max Sessions Per User = [int] Number of sessions allowed for each web user
                Max Sessions = [int] Number of web sessions allowed total
            ShellSession
                Max Sessions Per User = [int] Number of sessions allowed for each ssh user
                Max Sessions = [int] Number of ssh sessions allowed total
            CimcWebService = [string] Allows direct access a server CIMC using the KVM IP addresses (enabled/disabled)
            HttpService
                State = [string] Enables access via HTTP. (enabled/disabled)
                Port = [int] HTTP Port
                RedirectToHttps = [string] Whether or not to redirect all HTTP requests to HTTPS (enabled/disabled)
            HttpsService
                State = [string] Enables access via HTTP. (enabled/disabled)
                Port = [int] HTTPS Port
                Keyring = [string] Name of keyring certificate to use for HTTPS
                CipherMode = [string] The level of Cipher Suite security used by the Cisco UCS domain. (High-Strength/Medium-Strength/Low-Strength/Custom)
            Telnet = [string] Defines whether or not the telnet service is available (enabled/disabled)
            CimXml = [string] Defines whether or not the CimXML service is available (enabled/disabled)
            Snmp = [string] Defines whether or not the SNMP service is available (enabled/disabled)
        DNS Servers = [array] List of DNS Servers for use by this UCS domain


#>

$UcsConfiguration.Admin = @{
    Fault = @{
        Severity = @('critical','major')
        RetentionInterval = '07:00:00:00'
    }
    Authentication = @{
        NativeAuth = @{
            Realm = 'ldap'
            ProviderGroup = 'MyProviderGroup'
            WebSessionRefresh = 600
            WebSessionTimeout = 7200
        }
        ConsoleAuth = @{
            Realm = 'local'
        }
    }
    CallHome = @{
        State = 'off'
    }
    CommServices = @{
        WebSession = @{
            MaxSessionsPerUser = 32
            MaxSessions = 256
        }
        ShellSession = @{
            MaxSessionsPerUser = 32
            MaxSessions = 32
        }
        CimcWebService = 'enabled'
        HttpService = @{
            State = 'enabled'
            Port = 80
            RedirectToHttps = 'enabled'
        }
        HttpsService = @{
            State = 'enabled'
            Port = 443
            KeyRing = 'default'
            CipherMode = 'medium-strength'
        }
        Telnet = 'disabled'
        CimXml = 'disabled'
        Snmp = 'enabled'
    }
    DnsServers = @(
        '10.1.100.1',
        '10.1.100.2'
    )
}

<########################################################################################
        Server Settings

        Maintenance Policy = [hashtable] Maintenance Policy disruption settings
            Format: [string]policyname = [string]value (user-ack/immediate/timer-automatic)
        Power Control Policy = [hashtable] Power Control Policy settings
            Format: [string]policyname =
                Fanspeed = [string] Set Fan Speed (low-power/balanced/performance/high-power/max-power/any)
                PowerCap = [string] Power Capping allocates power to a server based on its Priority (cap/no-cap)
                Priority = [int] Values range from 1-10, with 1 being the highest priority (1-10)
        Scrub Policy = [hashtable] Disk Scrub Policy settings
            Format: [string]policyname =
                DiskScrub = [string] Scrub the disk when disassociating the profile (yes/no)
                BiosScrub = [string] Scrub the bios when disassociating the profile (yes/no)
                FlashScrub = [string] Scrub the flash disk when disassociating the profile (yes/no)
        Memory Policy = [hashtable] Memory Policy setting
            Format: [string]policyname = [string] Define whether blacklisting is enabled or not (enabled/disabled)
#>

$UcsConfiguration.Server = @{
    MaintenancePolicy = @{
        default = 'user-ack'
    }
    PowerControlPol = @{
        default = @{
            FanSpeed = 'Any'
            PowerCap = 'cap'
            Priority = 5
        }
    }
    ScrubPolicy = @{
        default = @{
            DiskScrub = 'no'
            BiosScrub = 'no'
            FlashScrub = 'no'
        }
    }
    MemoryPolicy = @{
        default = 'enabled'
    }
    
}

<########################################################################################
        LAN Settings
        
        NetworkControlPolicy = [hashtable] Network Control Policy setting
            Format: [string]policyname =
                Org = [string] Name of UCSM Org that policy belongs to (default is root)
                CDPState = [string] Cisco Discovery Protocol state (enabled/disabled)
                MACRegisterMode = [string] MAC address register mode (only-native-vlan/all-host-vlans)
                UplinkFailureAction = [string] Action to take on  uplink failure (link-down/warning)
                MacForging = [string] Mac Forging setting (allow/deny)
                LLDPTransmit = [string] Link Layer Discovery Protocol transmit (enabled/disabled)
                LLDPReceive = [string] Link Layer Discovery Protocol receive (enabled/disabled)
        UDLDLinkProfile = [hashtable] UDLD Link Profile setting
            Format: [string]profilename =
                UDLDLinkPolicy = [string] Which UDLD Link Policy to use for this profile
        UDLDLinkPolicy = [hashtable] UDLD Link Policy setting
            Format: [string]policyname =
                UDLDState = [string]  Unidirectional Link Detection setting (enabled/disabled)
                UDLDMode = [string] UDLD Mode setting (normal/aggressive)
        LinkProtocolPol = [hashtable] UDLD Link Protocol Policy setting
            Format: [string]policyname =
                UDLDRecoveryAction = [string] UDLD Recovery Action setting (none/reset)
                UDLDRecoveryInterval = [int] Seconds between UDLD attempting recovery action
        LACPPolicy = [hashtable] LACP Policy setting
            Format: [string]policyname =
                LACPSuspend = [string] LACP Suspend Individual enabled (true/false)
                LACPRate = [string] LACP Rate setting (normal/fast)
        PFCPolicy = [hashtable] Priority Flow Control Policy setting
            Format: [string]policyname =
                PriorityFlowControl = [string] Priority Flow Control setting (auto/on)
                SendFlowControl = [string] Send Flow Control setting (on/off)
                ReceiveFlowControl = [string] Receive Flow Control setting (on/off)
        DefaultVnicBehavior = [string] Default vNIC creation behavior setting (none/hw-inherit)
        VLANGroups = [array] List of VLAN Groups expected to exist on UCS Domain
        VLANs = [array] List of VLANs expected to exist on UCS Domain
        FabricA = [hashtable] LAN settings on Fabric Interconnect A
            Format: [string]PortChannel(integer to specify port channel, 0 being the first) =
                PFCPolicy = [string] What Priority Flow Control Policy to use
                LACPPolicy = [string] What LACP Policy to use
                AdminSpeed = [int] Single member speed in the port channel (1/10/40)
                OperSpeed = [int] Expected aggregate speed of all members together (2x10Gbps members = 20Gbps)
                AutoNegotiate = [string] Auto-negotiate speed between FI ports and upstream switches (true/false)
        FabricB = [hashtable] LAN settings on Fabric Interconnect B
            Format: [string]PortChannel(integer to specify port channel, 0 being the first) =
                PFCPolicy = [string] What Priority Flow Control Policy to use
                LACPPolicy = [string] What LACP Policy to use
                AdminSpeed = [int] Single member speed in the port channel (1/10/40)
                OperSpeed = [int] Expected aggregate speed of all members together (2x10Gbps members = 20Gbps)
                AutoNegotiate = [string] Auto-negotiate speed between FI ports and upstream switches (true/false)
#>

$UcsConfiguration.Lan = @{
    NetworkControlPol = @{
        default = @{
            Org = 'root'
            CDPState = [string]'enabled'
            MACRegisterMode = [string]'only-native-vlan'
            UplinkFailureAction = [string]'link-down'
            MacForging = [string]'allow'
            LLDPTransmit = [string]'disabled'
            LLDPReceive = [string]'disabled'
        }
    }
    UDLDLinkProfile = @{
        default = @{
            UDLDLinkPolicy = [string]'default'
        }
    }
    UDLDLinkPolicy = @{
        default = @{
            UDLDState = [string]'enabled'
            UDLDMode = [string]'aggressive'
        }
    }
    LinkProtocolPol = @{
        UDLDRecoveryAction = [string]'reset'
        UDLDRecoveryInterval = [int]15
    }
    LACPPolicy = @{
        default = @{
            LACPSuspend = [string]'true'
            LACPRate = [string]'normal'
        }
    }
    PFCPolicy = @{
        default = @{
            PriorityFlowControl = [string]'auto'
            SendFlowControl = [string]'on'
            ReceiveFlowControl = [string]'on'
        }
    }
    DefaultVnicBehavior = [string]'none'
    VlanGroups = @(
        'Production'
    )
    Vlans = @(
        100,
        101
    )
    FabricA = @{
        PortChannel0 = @{
            PFCPolicy = 'default'
            LACPPolicy = 'default'
            AdminSpeed = '10gbps'
            OperSpeed = '20gbps'
            AutoNegotiate = 'yes'
        }
    }
    FabricB = @{
        PortChannel0 = @{
            PFCPolicy = 'default'
            LACPPolicy = 'default'
            AdminSpeed = '10gbps'
            OperSpeed = '20gbps'
            AutoNegotiate = 'yes'
        }
    }
}

<########################################################################################
        SAN Settings

        DefaultVhbaBehavior = [string] Default vHBA creation behavior setting (none/hw-inherit)
        LACPPolicy = [hashtable] LACP Policy setting
            Format: [string]policyname =
                LACPSuspend = [string] LACP Suspend Individual enabled (true/false)
                LACPRate = [string] LACP Rate setting (normal/fast)
        FabricA = [hashtable] SAN settings on Fabric Interconnect A
            Format: [string]PortChannel(integer to specify port channel, 0 being the first) =
                VSAN = [string] What VSAN is assigned to this port channel
                AdminSpeed = [int] Single member speed in the port channel (1/10/40)
                OperSpeed = [int] Expected aggregate speed of all members together (2x10Gbps members = 20Gbps)
        FabricB = [hashtable] SAN settings on Fabric Interconnect B
            Format: [string]PortChannel(integer to specify port channel, 0 being the first) =
                VSAN = [string] What VSAN is assigned to this port channel
                AdminSpeed = [int] Single member speed in the port channel (4/8/16)
                OperSpeed = [int] Expected aggregate speed of all members together (4x8Gbps members = 32Gbps)  
#>    

$UcsConfiguration.San = @{    
    DefaultVhbaBehavior = [string]'none'
    LACPPolicy = @{
        default = @{
            LACPSuspend = [string]'true'
            LACPRate = [string]'normal'
        }
    }
    FabricA = @{
        PortChannel0 = @{
            VSAN = 10
            AdminSpeed = 'auto'
            OperSpeed = 32
        }
    }
    FabricB = @{
        PortChannel0 = @{
            VSAN = 11
            AdminSpeed = 'auto'
            OperSpeed = 32
        }
    }
}


<########################################################################################
        Other Settings
        
        PoolUsageThreshold = [string] Threshold for percentage of UID pool used
        PoolAssignmentOrder = [string] Pool assignment order (default/sequential)
#>

$UcsConfiguration.Other = @{
    PoolUsageThreshold = [int]80
    PoolAssignmentOrder = [string]'sequential'
}