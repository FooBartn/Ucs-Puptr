Cisco UCS Puptr (pronounced "puppeteer")
======================
#### -- Pester for UCS PowerTool Testing and Remediation

* Current tests do function, but this is very much a work in progress. Still revamping the README

Ucs-Puptr is a community project forked from and built on the basis of Vester, which aims to provide an
extremely light-weight approach to vSphere configuration management using Pester and PowerCLI. Ucs-Puptr
will serve the same purpose, but with Pester and Cisco UCS PowerTool.

# Requirements

You'll just need a few free pieces of software.

1. PowerShell version 4+
2. [Cisco UCS PowerTool 2.x+](https://communities.cisco.com/docs/DOC-37154)
5. [Pester](https://github.com/pester/Pester)
4. (optional) [Windows Management Framework 5.0](https://www.microsoft.com/en-us/download/details.aspx?id=50395)

# Installation

Because this repository is simply a collection of Pester tests, there is no installation. Download the files 
contained within this project anywhere you want.

# Variables

This project ultimately uses Pester to provide the testing framework. Because of this, we leverage a combination of 
Pester variables and custom ones written for Ucs-Puptr. If you're wondering why the command structure looks a bit complex, 
reference Pester [#271](https://github.com/pester/Pester/issues/271) and [#423](https://github.com/pester/Pester/issues/423).

### `Path` (string)

* Used to tell `Invoke-Pester` the relative path to where you have downloaded the Ucs-Puptr tests.
* Some folks like to use different versions of tests, or subdivide tests into smaller groups.
* The `path` input is required by Pester when sending parameters as shown in the examples below.
 
Default: None hard-coded. Your current location when calling Invoke-Pester, or the relative/absolute path you provide

### `Remediate` (bool)

* Tells Ucs-Puptr in which mode to operate.
* Set to `$false` to report on differences without any remediation.
* Set to `$true` to report on differences while also trying to remediate them.

Default: `$false`

### `Config` (string)

* The relative path to where you have located a Ucs-Puptr config file.
* You can use multiple config files to represent your different environments, such as Prod and Dev, 
while at the same time using the same testing files.

Default: `Ucs-Puptr\Configs\Config.ps1`

# Usage Instructions

**Make sure to run the default (Example 1) or Configuration tests first.** 

There are integration tests in there that will help with initial setup. They will: 

- Create a credential file
- Turn on support for multiple default UCS connections and
- Test connectivity to each domain defined in the config.

The end-state configuration for each Cisco UCS component is stored inside of the `Config.ps1` file. Make sure to read through 
the configuration items and set them with your specific environmental variables for DRS, NTP, SSH, etc.

If you have multiple environments that have unique settings, create a copy of the `Config.ps1` file for each environment and call 
it whatever you wish (such as `Config-Prod.ps1` for Production and `Config-Dev.ps1` for your Dev).

### Example 1 - Validation using Defaults
`Invoke-Pester .\Ucs-Puptr`

* Runs all tests underneath directory `.\Ucs-Puptr`
* Will validate that the default config file has proper values first, then run all tests
* Uses the default remediation value of `$false` (disabled) - drift will be shown but not corrected
* Uses the default configuration settings found in `.\Ucs-Puptr\Configs\Config.ps1`

### Example 2 - Validation using Different Config Values
`Invoke-Pester -Script @{Path = '.\Ucs-Puptr'; Parameters = @{ Config = '.\Ucs-Puptr\Configs\Config-Prod.ps1' }}`

* Runs all tests underneath directory `.\Ucs-Puptr`. Path is mandatory if supplying a parameter
* Will validate config and then run all tests
* Configuration settings found in `.\Ucs-Puptr\Configs\Config-Prod.ps1` will be used
* By not supplying the Remediate parameter, it defaults to $false

### Example 3 - Remediation using Different Config Values
`Invoke-Pester -Script @{Path = '.\Ucs-Puptr\Tests'; Parameters = @{ Remediate = $true ; Config = '.\Ucs-Puptr\Configs\Config-Prod.ps1' }}`

* Runs all tests found in the path `.\Ucs-Puptr\Tests`
* Remediation is `$true` (enabled) - drift will be shown and also corrected
* Configuration settings found in `.\Ucs-Puptr\Configs\Config-Prod.ps1` will be used

### Example 4 - Single Test Validation and NUnit Output (for Jenkins, AppVeyor, etc.)
`Invoke-Pester .\Ucs-Puptr\Tests -TestName '*DNS*' -OutputFormat NUnitXml -OutputFile .\Ucs-Puptr\results.xml`

* Runs any test under the path `.\Ucs-Puptr\Tests` with the string `DNS` found in the name
* NUnitXml output will be created in the file .\Ucs-Puptr\results.xml
* Because there are no hashtables `@{}`, defaults for Config/Remediate would be used
* Can easily be combined with Examples 2-3 to use a different config file and/or remediate

### Example 5 - Validation using Tags
`Invoke-Pester .\Ucs-Puptr\Tests -Tag host -ExcludeTag nfs`

* At the path `.\Ucs-Puptr\Tests`, runs all tests with the "host" tag, except for those also tagged "nfs"
* Because there are no hashtables `@{}`, defaults for Config/Remediate would be used
* Can easily be combined with Examples 2-3 to use a different config file and/or remediate
 
# Future

The community module is not officially supported and should be **used at your own risk**.

> Notes to come on future intentions