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
    Describe -Name 'Server Configuration: Chassis Discovery Policy' -Tag @('server','no-impact') -Fixture {
        # Project Environment Variables      
        $ProjectDir = (Get-Item $PSScriptRoot).parent.parent.FullName
        $CredentialDir = "$ProjectDir\Credentials"
        
        # Config Variables
        . $Config
        [string]$PuptrUser = $config.connection.Username
        [string[]]$UcsDomains = $config.connection.Domain
        [string]$MinimumChassisUplinks = $config.server.MinimumChassisUplinks
        [string]$LinkAggregation = $config.server.LinkAggregation

        # Importing credentials
        $SecurePassword = Get-Content -Path "$CredentialDir\$PuptrUser.txt" | ConvertTo-SecureString
        $Credential = [pscredential]::new($PuptrUser,$SecurePassword)

        # Connect to UCS 
        Connect-Ucs -Name $UcsDomains -Credential $Credential

        # Run test case
        foreach ($UcsDomain in (Get-UcsStatus)) {
            # Get Chassis Info
            $ChassisDiscoveryPolicy = Get-UcsChassisDiscoveryPolicy -Ucs $UcsDomain.Name

            It -Name "$($UcsDomain.Name) has a minimum chassis uplink requirement of: $MinimumChassisUplinks" -Test {

                # Assert
                try {
                 $ChassisDiscoveryPolicy.Action | Should Be $MinimumChassisUplinks
                } catch {
                    if ($Remediate) {
                        Write-Warning -Message $_
                        Write-Warning -Message "Changing minimum uplink requirement to $MinimumChassisUplinks"
                        $ChassisDiscoveryPolicy | Set-UcsChassisDiscoveryPolicy -Action $MinimumChassisUplinks -Force
                    } else {
                        throw $_
                    }
                }
            }

            It -Name "$($UcsDomain.Name) has a link aggregation setting of: $LinkAggregation" -Test {

                # Assert
                try {
                 $ChassisDiscoveryPolicy.LinkAggregationPref | Should Be $LinkAggregation
                } catch {
                    if ($Remediate) {
                        Write-Warning -Message $_
                        Write-Warning -Message "Changing link aggregation preference to $LinkAggregation"
                        $ChassisDiscoveryPolicy | Set-UcsChassisDiscoveryPolicy -LinkAggregationPref $LinkAggregation -Force 
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