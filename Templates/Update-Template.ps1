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
    Describe -Name 'Describe Whats Happening' -Tag @('Set','Tags','Here') -Fixture {
        # Project Environment Variables      
        $ProjectDir = (Get-Item $PSScriptRoot).parent.FullName
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
            It -Name "$($UcsDomain.Name) has..." -Test {
                #
                # Run commands to gather data
                #

                # Assert
                try {
                 #   Data gathered | Should ...
                } catch {
                    if ($Remediate) {
                        Write-Warning -Message $_
                        Write-Warning -Message "Enter Remediation Message Here" 
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