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
    Describe -Name 'Comprehensive: DNS Servers' -Tag @('comprehensive','no-impact') -Fixture {
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
            $DnsServers = $UcsConfiguration.Admin.DnsServers
        }

        # Run test case
        foreach ($UcsDomain in (Get-UcsStatus)) {
            foreach ($DnsServer in $DnsServers) {
                It -Name "$($UcsDomain.Name) includes DNS Server: $DnsServer" -Test {
                    #
                    # Run commands to gather data
                    $DnsServerList = Get-UcsDnsServer -Ucs $UcsDomain.Name

                    # Assert
                    try {
                        $DnsServerList -contains $DnsServer | Should Be True
                    } catch {
                        if ($Remediate) {
                            Write-Warning -Message $_
                            Write-Warning -Message "Adding DNS Server: $DnsServer"
                            Get-UcsDns -Ucs $UcsDomain.Name | Add-UcsDnsServer -Name $DnsServer
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