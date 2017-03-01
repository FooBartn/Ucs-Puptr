if(-not $ENV:BHProjectPath){
    Set-BuildEnvironment -Path $PSScriptRoot\..
}

Remove-Module $ENV:BHProjectName -ErrorAction SilentlyContinue
Import-Module (Join-Path $ENV:BHProjectPath $ENV:BHProjectName) -Force

InModuleScope 'Ucs-Puptr' {
    $PSVersion = $PSVersionTable.PSVersion.Major
    $ProjectRoot = $ENV:BHProjectPath
    $ModulePath = $ENV:BHPSModulePath.replace('Tests\..\','')
    $ConfigPath =  $ModulePath | Join-Path -ChildPath 'Configs'

    $Verbose = @{}

    if (
        $ENV:BHBranchName -notlike "master" -or 
        $env:BHCommitMessage -match "!verbose"
    ) {
        $Verbose.add("Verbose",$True)
    }

     Describe -Name "Ucs-Puptr PS$PSVersion" -Fixture {                
        $TestDrive = "TestDrive:\"
        $ConfigName = 'X303'
        $ConfigFile = $ConfigPath | Join-Path -ChildPath "$ConfigName.ps1"
        $TestDriveConfig = $TestDrive | Join-Path -ChildPath "$ConfigName.ps1"

        It "Environment should be clean" {
            $ConfigPath | Should Not Exist
            $ConfigFile | Should Not Exist
        }

        Context -Name "New-PuptrConfig" -Fixture {
            It "Should create configuration file" {
                New-PuptrConfig -Name 'X303' -Edit $false
                $ConfigFile | Should Exist
            }
        }

        Context -Name "Get-PuptrConfig" -Fixture {
            It "Should list $ConfigName configuration" {
                (Get-PuptrConfig).Name | Should Be $ConfigName
            }

            It "Should have the correct path" {
                (Get-PuptrConfig).Path | Should Be $ConfigFile
            }
        }

        Context -Name "Import,Export,Remove-PuptrConfig" -Fixture {
            It "Should create a backup copy of $ConfigName" {
                Export-PuptrConfig -Name $ConfigName -Path $TestDrive
                $TestDriveConfig | Should Exist
            }

            It "Should remove configuration file $ConfigName" {
                Remove-PuptrConfig -Name $ConfigName -Confirm:$false
                $ConfigFile | Should Not Exist
                (Get-PuptrConfig).Name | Should BeNullOrEmpty
            }

            It "Should import configuration file $ConfigName" {
                Import-PuptrConfig -Path $TestDriveConfig
                $ConfigFile | Should Exist
                (Get-PuptrConfig).Name | Should Be $ConfigName
            }
        }

        Context -Name "Get,Enable,Disable-PuptrTest" -Fixture {
            It "Should disable a test" {
                Disable-PuptrTest -Name ChassisDiscovery
                (Get-PuptrTest | Where-Object {
                    $_.Name -eq 'ChassisDiscovery'
                }).State | Should Be 'Disabled' 
            }

            It "Should enable a test" {
                Enable-PuptrTest -Name ChassisDiscovery
                (Get-PuptrTest | Where-Object {
                    $_.Name -eq 'ChassisDiscovery'
                }).State | Should Be 'Enabled'
            }
        }

        Remove-Item -Path $ConfigPath -Recurse -Force
     }
}