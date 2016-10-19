Cisco UCS Puptr (pronounced "puppeteer")
======================
#### -- `P`ester for `U`CS `P`owerTool `T`esting and `R`emediation

Ucs-Puptr is a community project forked from Vester and then completely rebuilt to provide light-weight
configuration management using Pester and Cisco UCS PowerTool.

# Requirements

You'll just need a few free pieces of software.

1. PowerShell version 4+
2. [Cisco UCS PowerTool 2.x+](https://communities.cisco.com/docs/DOC-37154)
5. [Pester](https://github.com/pester/Pester)

# Installation

Because this repository is simply a collection of Pester tests, there is no installation. Download the files 
contained within this project anywhere you want.

# Basic Usage Instructions

1. Edit configuration file. (Default: `Ucs-Puptr\Configs\Config.ps1`)
2. Run: ./Invoke-UcsPuptr.ps1 -Initialize
3. If all initalization tests pass run:
4. ./Invoke-UcsPuptr.ps1

To include remediation run: ./Invoke-UcsPuptr.ps1 -Remediate

> The end-state configuration for each Cisco UCS component is stored inside of the `Config.ps1` file. Make sure to read through 
> the configuration items and set them with your specific environmental variables

See the [wiki](https://github.com/FooBartn/Ucs-Puptr/wiki) for further examples.

 
# Future

The community module is not officially supported and should be **used at your own risk**.

> Notes to come on future intentions