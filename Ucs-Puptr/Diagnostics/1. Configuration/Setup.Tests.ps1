#requires -Version 3 -Modules Pester, Cisco.UcsManager

[CmdletBinding()]
Param(
    # Optionally fix all config drift that is discovered. Defaults to false (off)
    [switch]$Remediate = $false,

    # Optionally define a different config file to use. Defaults to Vester\Configs\Config.ps1
    [string]$ConfigName
)

Process {
    Describe -Name 'Configuration Integration Testing' -Tag @('config','integration') -Fixture {
        BeforeAll {
            # Project Environment Variables 
            $ProjectDir = (Get-Item $PSScriptRoot).parent.parent.FullName
            $ConfigDir = $ProjectDir | Join-Path -ChildPath 'Configs'
            $ConfigFile = $ConfigDir | Join-Path -ChildPath "$ConfigName.ps1"
            $CredentialDir = $ProjectDir | Join-Path -ChildPath 'Credentials'
            
            # Ensure $UcsConfiguration is loaded into the session
            . $ConfigFile

            # Set var for .connection.Username
            $PuptrUser = $UcsConfiguration.Connection.Username
            $PuptrUserName = $PuptrUser.Split('\') | Select -Last 1
            $PuptrUserPath = $CredentialDir | Join-Path -ChildPath "$PuptrUserName.txt"
        }

        It "Tests that $CredentialDir exists" {
            # Test if credential directory exists. If not, create it.
            try {
                $CredentialDir | Should Exist
            } catch {
                Write-Warning -Message $_
                Write-Warning -Message "Creating secure credential directory at $CredentialDir"
                New-Item -Path $CredentialDir -ItemType Directory -Force
            }
        }

        It "Tests that secure credential file $PuptrUserPath exists" {
            # Test if secure file exists. If not, create it.
            try {
                $PuptrUserPath | Should Exist
            } catch {
                Write-Warning -Message $_
                Write-Warning -Message "Creating secure password file for $PuptrUser"
                $Credential = Get-Credential -UserName $PuptrUser -Message 'Credentials for connecting to UCS Domains with Ucs-Puptr'
                $Credential.Password | ConvertFrom-SecureString | Out-File -FilePath $PuptrUserPath
            }
        }

        It "Tests that multiple default ucs support is enabled if necessary" {
            # Support multiple default ucs connections if necessary
            try {
                if ($UcsConfiguration.Connection.UcsDomain.Count -gt 1) {
                    (Get-UcsPowerToolConfiguration).SupportMultipleDefaultUcs | Should Be True
                }
            } catch {
                Write-Warning -Message $_
                Write-Warning -Message "Enabling support for multiple default Ucs connections"
                Set-UcsPowerToolConfiguration -SupportMultipleDefaultUcs $true -Force
            }
        }

        It "Tests that connections to all domains are successful" {
            # Importing credentials
            $SecurePassword = Get-Content -Path $PuptrUserPath | ConvertTo-SecureString
            $Credential = [pscredential]::new($PuptrUser,$SecurePassword)

            # Test connectivity
            foreach ($Domain in $UcsConfiguration.Connection.UcsDomain) {
                try {
                    Connect-Ucs -Name $Domain -Credential $Credential -ErrorAction Stop | Should Not BeNullOrEmpty
                } catch {
                    throw $_
                } finally {
                    Disconnect-Ucs
                }
            }
        }
    } #Describe
} #Process