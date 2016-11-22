---
external help file: Ucs-Puptr-help.xml
online version: 
schema: 2.0.0
---

# Remove-PuptrConfig

## SYNOPSIS
Remove a configuration file

## SYNTAX

```
Remove-PuptrConfig [-Name] <String> [-WhatIf] [-Confirm]
```

## DESCRIPTION
This function removes an existing UcsPuptr configuration file

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Remove a configuration named Prod
```

Remove-PuptrConfig -Name Prod

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

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
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

