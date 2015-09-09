# powershell-module-utils

## Functions to handle PATH EnvVar

*** Create backup file with the last version of PATH ***
New-PathBackupFile ()

*** Pretty obvious, isn't it? (at the end) (should call "Find-inPath" function under the bonnet) ***
Add-toPath ($Value)

*** Check if some EnvVar is already in PATH ***
Find-InPath ($Value)

*** Check if some EnvVar is already in PATH (should call "Find-inPath" function under the bonnet) ***
Remove-InPath ($Value)


## Functions for Generics EnvVars

$Target defaults to 'Machine'

*** Check if EnvVar already exists ***
Get-EnvVar($Name, $Target)

*** Create New Environment Variable ***
New-EnvVar($Name, $Value, $Target)

*** Edit/Alter EnvVar (should call "Get-EnvVar" function under the bonnet) ***
Set-EnvVar($Name, $Value, $Target)

*** Remove EnvVar (should call "Get-EnvVar" function under the bonnet) ***
Remove-EnvVar($Name, $Target)
