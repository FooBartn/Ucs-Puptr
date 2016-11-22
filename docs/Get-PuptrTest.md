---
external help file: Ucs-Puptr-help.xml
online version: 
schema: 2.0.0
---

# Get-PuptrTest

## SYNOPSIS
Gets list of UcsPuptr tests and their state

## SYNTAX

```
Get-PuptrTest [[-Type] <String[]>] [[-State] <String[]>]
```

## DESCRIPTION
This function gets a list of tests depending on the Type parameter.
It will return the names of the tests and whether or not they are enabled

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Gets all tests that don't remediate
```

Get-PuptrTest -Type Simple

### -------------------------- EXAMPLE 2 --------------------------
```
Gets all tests that do remediate
```

Get-PuptrTest -Type Comprehensive

### -------------------------- EXAMPLE 3 --------------------------
```
Gets all tests
```

Get-PuptrTest

## PARAMETERS

### -Type
Type of test to retreive: Simple, Comprehensive, All
Default = All

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 

Required: False
Position: 1
Default value: @('Simple','Comprehensive')
Accept pipeline input: False
Accept wildcard characters: False
```

### -State
{{Fill State Description}}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 

Required: False
Position: 2
Default value: @('Enabled','Disabled')
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

