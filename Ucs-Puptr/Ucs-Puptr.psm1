$FunctionList = Get-ChildItem -Path $PSScriptRoot\Functions
foreach ($Function in $FunctionList) {
    Write-Verbose -Message ('Importing function file: {0}' -f $Function.FullName)
	. $Function.FullName
}