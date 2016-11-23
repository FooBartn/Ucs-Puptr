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
    Describe -Name 'Simple: Fault(s)' -Tag @('simple') -Fixture {
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

            # Test Variables
            $SeverityFilter = $UcsConfiguration.Admin.Fault.Severity
        }
        
        # Run test case
        foreach ($UcsDomain in (Get-UcsStatus)) {
            It -Name "$($UcsDomain.Name) has no faults of severity: $SeverityFilter" -Test {
                # Gather faults according to severity filter
                $UcsFaults = Get-UcsFault -Ucs $UcsDomain.Name |
                Where-Object -FilterScript {
                    $SeverityFilter -contains $_.Severity
                }

                # Assert
                try {
                    $UcsFaults.count | Should Be 0
                } catch {
                    throw $_
                }
            }
        }

        # Disconnect from UCS
        Disconnect-Ucs
    }
}