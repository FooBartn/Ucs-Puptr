---
external help file: Ucs-Puptr-help.xml
online version: 
schema: 2.0.0
---

# Import-PuptrConfig

## SYNOPSIS
Import a UcsPuptr configuration file

## SYNTAX

```
Import-PuptrConfig [-Path] <String>
```

## DESCRIPTION
This function will import a configuration file into UcsPuptr

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Import configuration file C:\Prod.ps1
```

Import-PuptrConfig -Path C:\Prod.ps1

## PARAMETERS

### -Path
Path to configuration file

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

### None

## OUTPUTS

### None

## NOTES
Author:         Joshua Barton (@foobartn)
Creation Date:  11.21.2016

## RELATED LINKS

