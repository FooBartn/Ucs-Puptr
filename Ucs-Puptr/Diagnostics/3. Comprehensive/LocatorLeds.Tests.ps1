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
    Describe -Name 'Comprehensive: Disabling Locator LEDs' -Tag @('comprehensive','no-impact') -Fixture {
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

        }

        # Run test case
        foreach ($UcsDomain in (Get-UcsStatus)) {
            #
            # Run commands to gather data
            $LocatorLeds = Get-UcsLocatorLed

            foreach ($LocatorLed in $LocatorLeds) {
                It -Name "$($LocatorLed.Dn) in $($UcsDomain.Name) is not enabled" -Test {
                    # Assert
                    try {
                    $LocatorLed.OperState | Should Be "off"
                    } catch {
                        if ($Remediate) {
                            Write-Warning -Message $_
                            Write-Warning -Message "Disabling locator LED: $($LocatorLed.Dn)"
                            $LocatorLed | Set-UcsLocatorLed -AdminState off -Force
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