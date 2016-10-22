#requires -Modules Pester, Cisco.UcsManager

[CmdletBinding()]
Param(
    # Optionally fix all config drift that is discovered. Defaults to false (off)
    [switch]$Remediate = $false,

    # Optionally define a different config file to use. Defaults to Vester\Configs\Config.ps1
    [string]$Config = (Split-Path $PSScriptRoot) + '\Configs\Config.ps1'
)

Process {
    # Tests
    Describe -Name 'UCSM Configuration: Default WWN Schema' -Tag @('ucsm') -Fixture {
        # Project Environment Variables      
        $ProjectDir = (Get-Item $PSScriptRoot).parent.parent.FullName
        $CredentialDir = "$ProjectDir\Credentials"
        
        # Config Variables
        . $Config
        [string]$PuptrUser = $config.connection.Username
        [string[]]$UcsDomains = $config.connection.Domain
        [string]$DefaultWwnSchema = '20:00:00:25:B5:00:00:00'

        # Importing credentials
        $SecurePassword = Get-Content -Path "..\$PuptrUser.txt" | ConvertTo-SecureString
        $Credential = [pscredential]::new($PuptrUser,$SecurePassword)

        # Connect to UCS 
        Connect-Ucs -Name $UcsDomains -Credential $Credential

        # Run test case
        foreach ($UcsDomain in (Get-UcsStatus)) {
            It -Name "$($UcsDomain.Name) does not use default WWN schema" -Test {
                #
                # Run commands to gather data
                $WwnBlocks = @(Get-UcsWwnMemberBlock)

                # Assert
                try {
                    foreach ($WwnBlock in $WwnBlocks) {
                        $WwnBlock.From | Should Not Be $DefaultWwnSchema
                    }
                } catch {
                    throw $_
                }
            }
        }

        # Disconnect from UCS
        Disconnect-Ucs
    }
}