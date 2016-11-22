---
external help file: Ucs-Puptr-help.xml
online version: 
schema: 2.0.0
---

# New-PuptrConfig

## SYNOPSIS
Create a new configuration file

## SYNTAX

```
New-PuptrConfig [-Name] <String> [[-Edit] <Boolean>]
```

## DESCRIPTION
This function creates a new configuration file from template and opens it in the default .ps1 editor

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Create a new configuration named Prod
```

New-PuptrConfig -Name Prod

## PARAMETERS

### -Name
Name of configuration file (Test, Prod, Peanuts, etc)

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

### -Edit
{{Fill Edit Description}}

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases: 

Required: False
Position: 2
Default value: True
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

