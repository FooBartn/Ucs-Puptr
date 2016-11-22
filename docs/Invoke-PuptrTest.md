---
external help file: Ucs-Puptr-help.xml
online version: 
schema: 2.0.0
---

# Invoke-PuptrTest

## SYNOPSIS
Provide an extremely light-weight approach to Cisco UCS configuration management

## SYNTAX

```
Invoke-PuptrTest [[-TestPath] <String>] [[-ConfigName] <String>] [-Remediate] [[-TestName] <String[]>]
 [[-Tag] <String[]>] [[-ExcludeTag] <String[]>] [[-OutputFormat] <String>] [[-OutputFile] <String>]
 [-Initialize] [-Passthru]
```

## DESCRIPTION
Utilize Pester and Cisco UCS PowerTool to provide a set if Operation Validation tests with the option
to remediate if applicable.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Run all config and operational validation tests. (Default)
```

.\Invoke-UcsPuptr

### -------------------------- EXAMPLE 2 --------------------------
```
Run all config and operational validation tests and remediate.
```

.\Invoke-UcsPuptr -Remediate

### -------------------------- EXAMPLE 3 --------------------------
```
Run all tests with Configuration in the name.
```

.\Invoke-UcsPuptr -TestName '*Configuration*'

### -------------------------- EXAMPLE 4 --------------------------
```
Run and exclude specifically tagged tests.
```

.\Invoke-UcsPuptr -Tag 'ucsm' -ExcludeTag 'server'

## PARAMETERS

### -TestPath
Directory of the tests that you want to run.
Default = '.\Ucs-Puptr'

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 1
Default value: "$PSScriptRoot\..\Diagnostics"
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigName
Location of the configuration file you want to use.
Default = 'Config'

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 2
Default value: Config
Accept pipeline input: False
Accept wildcard characters: False
```

### -Remediate
Defines whether or not to remediate applicable tests that have failed.
Default = $false

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -TestName
Informs Invoke-Pester to only run Describe blocks that match this name.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tag
Informs Invoke-Pester to only run Describe blocks tagged with the tags specified.
Aliased 'Tags' for backwards
compatibility.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeTag
Informs Invoke-Pester to not run blocks tagged with the tags specified.
Default: 'ucspuptr' : Keeps invoke-puptr from running pester on itself.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutputFormat
OutputFile format
Options: LegacyNUnitXml, NUnitXml

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutputFile
Location to dump pester results in format: $OutputFormat

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Initialize
Initial setup after you have edited your configuration files
Default = $false

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Passthru
{{Fill Passthru Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

### None

## OUTPUTS

### $OutputFile

## NOTES
Author:         Joshua Barton (@foobartn)
Creation Date:  11.21.2016

## RELATED LINKS

