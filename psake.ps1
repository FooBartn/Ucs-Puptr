# PSake makes variables declared here available in other scriptblocks
# Init some things
Properties {
    # Find the build folder based on build system
    $ProjectRoot = $ENV:BHProjectPath
    if(-not $ProjectRoot)
    {
        $ProjectRoot = $PSScriptRoot
    }
    
    $PesterTestDir = $ProjectRoot | Join-Path 'Tests'
    $Timestamp = Get-date -uformat "%Y%m%d-%H%M%S"
    $PSVersion = $PSVersionTable.PSVersion.Major
    $TestFile = "TestResults_PS$PSVersion`_$TimeStamp.xml"
    $TestPath = $ProjectRoot | Join-Path $TestFile
    $AppveyorURL = "https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)"
    $lines = '----------------------------------------------------------------------'

    $Verbose = @{}
    if($ENV:BHCommitMessage -match "!verbose")
    {
        $Verbose = @{Verbose = $True}
    }
}

Task Default -Depends Deploy

Task Init {
    $lines
    Set-Location $ProjectRoot
    "Build System Details:"
    Get-Item ENV:BH*
    Write-Output " "    # blank line
}

Task Test -Depends Init  {
    $lines
    Write-Output " "     # blank line
    "STATUS: Testing with PowerShell $PSVersion"

    # Gather test results. Store them in a variable and file
    $TestResults = Invoke-Pester -Path $PesterTestDir -PassThru -OutputFormat NUnitXml -OutputFile $TestPath

    # Upload Appveyor tests
    (New-Object 'System.Net.WebClient').UploadFile($AppveyorURL,$TestPath)

    # Remove Test file
    Remove-Item $TestPath -Force

    # Failed tests?
    # Need to tell psake or it will proceed to the deployment. Danger!
    if($TestResults.FailedCount -gt 0)
    {
        Write-Error "Failed '$($TestResults.FailedCount)' tests, build failed"
    }

    # blank line
    Write-Output " "
}

Task Build -Depends Test {
    $lines

    # Bump the module version
    Try{
        $Version = Get-NextPSGalleryVersion -Name $env:BHProjectName -ErrorAction Stop
        Update-Metadata -Path $env:BHPSModuleManifest -PropertyName ModuleVersion -Value $Version -ErrorAction stop
    } Catch {
        Write-Output "Failed to update version for '$env:BHProjectName': $_."
        Write-Output "Continuing with existing version"
    }
}

Task Deploy -Depends Build {
    $lines

    $Params = @{
        Path = $ProjectRoot
        Force = $true
        Recurse = $false # We keep psdeploy artifacts, avoid deploying those : )
    }
    Invoke-PSDeploy @Verbose @Params
}