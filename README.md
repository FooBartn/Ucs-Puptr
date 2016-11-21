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

Install-Module Ucs-Puptr

# Basic Usage Instructions

1. New-PuptrConfig -Name Test
2. Edit the file that comes up to match your environment
3. Invoke-PuptrTest -ConfigName Test

To include remediation run: Invoke-PuptrTest -ConfigName Test -Remediate

> The end-state configuration for each Cisco UCS component is stored inside of the configuration file. 
>Make sure to read through the configuration items and set them with your specific environmental variables

 
# Future

The community module is not officially supported and should be **used at your own risk**.

> Notes to come on future intentions