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
    Describe -Name 'UCSM Configuration: Fault(s)' -Tag @("ucsm") -Fixture {
        # Variables
        . $Config
        [array]$SeverityFilter = $config.ucsm.FaultSeverity

        It -Name "UCSM has no faults of severity: $SeverityFilter" -Test {
            # Gather faults according to severity filter
            $UcsFaults = Get-UcsFault |
            Where-Object -FilterScript {
                $SeverityFilter -contains $_.Severity
            }

            # Assert
            try {
                $UcsFaults | Should BeNullOrEmpty
            } catch {
                throw $_
            }
        }
    }
}