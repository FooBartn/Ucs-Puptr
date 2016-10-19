# Contribution

Everyone is welcome to contribute to this project. The goal is to add fine-grained tests that look at specific values within a vSphere environment, compare them to defined configuration value, and optionally remediate discrepancies if the user so decides. However, there is nothing wrong with submitting a pull request (PR) with a non-remediating test. This is a great starting point for those newer to coding with PowerShell!

### Contribution Requirements

Every test that is added to Ucs-Puptr needs three things:

1. An update to the example [`Config.ps1`](https://github.com/FooBartn/Ucs-Puptr/blob/master/Configs/Config.ps1) file with your required configuration value(s), comments, and accepted input type.
2. An update to the [`Config.Tests.ps1`](https://github.com/FooBartn/Ucs-Puptr/blob/master/Configs/Config.Tests.ps1) file to validate that the `Config.ps1` file contains valid entries.
3. A test file using a properly formatted `Verb-Noun` format (use `Get-Verb` for more details) placed into the Tests folder.

### Your First Contribution

If you're looking for your first bit of code to add, try this list:

1. Identify a configuration value in your Cisco UCS environment that isn't being inspected by Ucs-Puptr.
2. Use the [Template](https://github.com/FooBartn/Ucs-Puptr/blob/master/Templates/Update-Template.ps1) to create a test that inspects this value and try it out locally.
3. At this point you can submit a pull request (PR) for a non-remediating test. If someone else wants the remediation code added, they will grab your code and write that portion.
4. Optionally, write the remediation portion yourself to make a fully remediating test.

### Contribution Process

1. Create a fork of the project into your own repository.
2. From your fork, create a new feature branch (other than master) that expresses your feature or enhancement.
3. Make all your necessary changes in your feature branch.
4. Create a pull request with a description on what was added or removed and details explaining the changes in lines of code.

If approved, project owners will merge it.