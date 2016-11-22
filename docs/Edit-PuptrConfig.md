---
external help file: Ucs-Puptr-help.xml
online version: 
schema: 2.0.0
---

# Edit-PuptrConfig

## SYNOPSIS
Edit a UcsPuptr configuration file

## SYNTAX

```
Edit-PuptrConfig [-Name] <String>
```

## DESCRIPTION
This function will use Invoke-Item to open a configuration file
in the default .ps1 editor

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Edit Prod configuration
```

Edit-PuptrConfig -Name Prod

## PARAMETERS

### -Name
Name of the configuration
Can get a list of configuration names using Get-PuptrConfig

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

