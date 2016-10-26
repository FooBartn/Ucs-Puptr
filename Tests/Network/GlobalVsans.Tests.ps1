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
    Describe -Name 'Network Configuration: Global vSANs' -Tag @('network') -Fixture {
        # Project Environment Variables      
        $ProjectDir = (Get-Item $PSScriptRoot).parent.parent.FullName
        $CredentialDir = "$ProjectDir\Credentials"
        
        # Config Variables
        . $Config
        [string]$PuptrUser = $config.connection.Username
        [string[]]$UcsDomains = $config.connection.Domain

        # Importing credentials
        $SecurePassword = Get-Content -Path "$CredentialDir\$PuptrUser.txt" | ConvertTo-SecureString
        $Credential = [pscredential]::new($PuptrUser,$SecurePassword)

        # Connect to UCS 
        Connect-Ucs -Name $UcsDomains -Credential $Credential

        # Run test case
        foreach ($UcsDomain in (Get-UcsStatus)) {
            $Vsans = Get-UcsSanCloud | Get-UcsVsan |
                    where {$_.Id -ne 1} 
            foreach ($Vsan in $Vsans) {
                It -Name "$($UcsDomain.Name) vSAN $($Vsan.Id) is not a global vSAN" -Test {
                    # Assert
                    try {
                        $Vsan.SwitchId | Should Not Be 'dual'
                    } catch {
                        throw $_
                    }
                }
            }        
            
        }

        # Disconnect from UCS
        Disconnect-Ucs
    }
}