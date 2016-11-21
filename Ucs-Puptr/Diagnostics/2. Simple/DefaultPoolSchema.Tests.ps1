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
    Describe -Name 'UCSM Configuration: Default Pool Schemas' -Tag @('ucsm') -Fixture {
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
            $PuptrUserName = $PuptrUser.Split('\') | Select -Last 1
            $PuptrUserPath = $CredentialDir | Join-Path -ChildPath "$PuptrUserName.txt"
            $UcsDomains = $UcsConfiguration.Connection.UcsDomain

            # Importing credentials
            $SecurePassword = Get-Content -Path $PuptrUserPath | ConvertTo-SecureString
            $Credential = [pscredential]::new($PuptrUser,$SecurePassword)

            # Connect to UCS 
            Connect-Ucs -Name $UcsDomains -Credential $Credential
        }

        # Run test case
        foreach ($UcsDomain in (Get-UcsStatus)) {
            It -Name "$($UcsDomain.Name) does not use the default MAC schema" -Test {
                #
                # Run commands to gather data
                $MacBlocks = @(Get-UcsMacMemberBlock)

                # Assert
                try {
                    foreach ($MacBlock in $MacBlocks) {
                        $MacBlock.From | Should Not Be $DefaultMacSchema
                    }
                } catch {
                    throw $_
                }
            }
            
            It -Name "$($UcsDomain.Name) does not use default UUID schema" -Test {
                #
                # Run commands to gather data
                $UuidBlocks = @(Get-UcsUuidSuffixBlock) 

                # Assert
                try {
                    foreach ($UuidBlock in $UuidBlocks) {
                        $UuidBlock.From | Should Not Be $DefaultUuidSchema
                    }
                } catch {
                    throw $_
                }
            }

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