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
    Describe -Name 'UCSM Configuration: Power Control Policy' -Tag @('server','no-impact') -Fixture {
        # Project Environment Variables      
        $ProjectDir = (Get-Item $PSScriptRoot).parent.parent.FullName
        $CredentialDir = "$ProjectDir\Credentials"
        
        # Config Variables
        . $Config
        [string]$PuptrUser = $config.connection.Username
        [string[]]$UcsDomains = $config.connection.Domain
        [string]$PowerRedundancy = $config.server.PowerRedundancy

        # Importing credentials
        $SecurePassword = Get-Content -Path "$CredentialDir\$PuptrUser.txt" | ConvertTo-SecureString
        $Credential = [pscredential]::new($PuptrUser,$SecurePassword)

        # Connect to UCS 
        Connect-Ucs -Name $UcsDomains -Credential $Credential

        # Run test case
        foreach ($UcsDomain in (Get-UcsStatus)) {
            It -Name "$($UcsDomain.Name) has a chassis power redundancy setting of: $PowerRedundancy" -Test {
                #
                # Run commands to gather data
                $PowerControlPolicy = Get-UcsPowerControlPolicy -Ucs $UcsDomain.Name

                # Assert
                try {
                 $PowerControlPolicy.Redundancy | Should Be $PowerRedundancy
                } catch {
                    if ($Remediate) {
                        Write-Warning -Message $_
                        Write-Warning -Message "Setting $($UcsDomain.Name) power redundancy to: $PowerRedundancy"
                        $PowerControlPolicy | Set-UcsPowerControlPolicy -Redundancy $PowerRedundancy
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