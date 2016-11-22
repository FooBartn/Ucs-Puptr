---
external help file: Ucs-Puptr-help.xml
online version: 
schema: 2.0.0
---

# Export-PuptrConfig

## SYNOPSIS
Makes a backup copy of a UcsPuptr configuration file

## SYNTAX

```
Export-PuptrConfig [-Name] <String> [-Path] <String>
```

## DESCRIPTION
This function will make a copy of the named configuration file and save
it in the specified path

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Export Prod configuration
```

Export-PuptrConfig -Name Prod -Path C:\

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

### -Path
Path to save specified configuration file

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: 2
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

