This is where all the magic happens.

...

Actually it's just a wrapper for Pester, built to run against a specified set of tests/configurations

# Running Ucs-Puptr

> Note: This requires a configuration to exist

Let's assume you have your Prod configuration, you want to run all of the tests against it, but you do not
want to remediate anything.

```PowerShell
Invoke-PuptrTest -ConfigName Prod
```

That's it. That will run all of the enabled tests on your configuration.

Want to remediate?

```PowerShell
Invoke-PuptrTest -ConfigName Prod -Remediate
```

It also supports all of these standard Pester parameters:

.PARAMETER TestName
    Informs Invoke-Pester to only run Describe blocks that match this name.

.PARAMETER Tag
    Informs Invoke-Pester to only run Describe blocks tagged with the tags specified. Aliased 'Tags' for backwards
compatibility.

.PARAMETER ExcludeTag
    Informs Invoke-Pester to not run blocks tagged with the tags specified.

.PARAMETER OutputFormat
    OutputFile format
    Options: LegacyNUnitXml, NUnitXml

.PARAMETER OutputFile
    Location to dump pester results in format: $OutputFormat