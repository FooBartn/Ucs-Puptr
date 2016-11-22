---
external help file: Ucs-Puptr-help.xml
online version: 
schema: 2.0.0
---

# Disable-PuptrTest

## SYNOPSIS
Disables a UcsPuptr test

## SYNTAX

```
Disable-PuptrTest [-Name] <String>
```

## DESCRIPTION
This function disables a UcsPuptr test in the Diagnostics folder by name

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Disable test
```

Disable-PuptrTest -Name ChassisDiscovery

## PARAMETERS

### -Name
Name of test to disable

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

