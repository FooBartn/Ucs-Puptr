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
    Describe -Name 'Comprehensive: Default vNIC Behavior' -Tag @('comprehensive','no-impact') -Fixture {
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
            $DefaultVnicBehavior = $UcsConfiguration.Lan.DefaultVnicBehavior
            # Variable2
        }

        # Run test case
        foreach ($UcsDomain in (Get-UcsStatus)) {
            It -Name "$($UcsDomain.Name) has a default vNIC behavior of $DefaultVnicBehavior" -Test {
                #
                # Run commands to gather data
                $VnicBehPolicy = Get-UcsVnicVnicBehPolicy -Ucs $UcsDomain.Name

                # Assert
                try {
                    $VnicBehPolicy.Action | Should Be $DefaultVnicBehavior
                } catch {
                    if ($Remediate) {
                        Write-Warning -Message $_
                        Write-Warning -Message "Changing default vNIC behavior to $DefaultVnicBehavior"
                        $VnicBehPolicy | Set-UcsVnicVnicBehPolicy -Action $DefaultVnicBehavior -Force
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