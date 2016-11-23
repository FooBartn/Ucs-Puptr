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
    Describe -Name 'Simple: Unassociated Profiles' -Tag @('simple') -Fixture {
        BeforeAll {
            # Project Environment Variables 
            $ProjectDir = (Get-Item $PSScriptRoot).parent.parent.FullName
            $ConfigName = "$ConfigName.ps1"
            $ConfigDir = $ProjectDir | Join-Path -ChildPath 'Configs'
            $ConfigFile = $ConfigDir | Join-Path -ChildPath $ConfigName
            $CredentialDir = $ProjectDir | Join-Path -ChildPath 'Credentials'
            
            # Ensure $UcsConfiguration is loaded into the session
            . $ConfigFile

            # Set variables from .connection
            $PuptrUser = $UcsConfiguration.Connection.Username
            $PuptrUserPath = $CredentialDir | Join-Path -ChildPath "$PuptrUser.txt"
            $UcsDomains = $UcsConfiguration.Connection.UcsDomain

            # Importing credentials
            $SecurePassword = Get-Content -Path $PuptrUserPath | ConvertTo-SecureString
            $Credential = [pscredential]::new($PuptrUser,$SecurePassword)

            # Connect to UCS 
            Connect-Ucs -Name $UcsDomains -Credential $Credential
        }

        # Run test case
        foreach ($UcsDomain in (Get-UcsStatus)) {
             # Run commands to gather data
            $SvcProfiles = Get-UcsServiceProfile -Type instance | Sort Name
            foreach ($SvcProfile in $SvcProfiles) {
                It -Name "Service Profile $($ServiceProfile.Name) in $($UcsDomain.Name) is associated" -Test {
                    # Assert
                    $SvcProfile.AssocState | Should Be 'associated'
                }
            }
        }

        # Disconnect from UCS
        Disconnect-Ucs
    }
}