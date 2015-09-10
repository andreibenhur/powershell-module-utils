# powershell-module-utils

This first powershell module is my way to pratice and learn about it a little. This son of a gun is (a lot) trickier than it looks.

The main idea is: create some powershell functions to help me handle Environment Variable through command line -- permanently.

I kinda have something like milestones.. but I will not put it here.


### Functions to handle PATH EnvVar

**Create backup file with the last version of PATH**
New-PathBackupFile ()

**Pretty obvious, isn't it? (at the end) (should call "Find-inPath" function under the bonnet)**
Add-toPath ($Value)

**Check if some EnvVar is already in PATH**
Find-InPath ($Value)

**Check if some EnvVar is already in PATH (should call "Find-inPath" function under the bonnet)**
Remove-InPath ($Value)


### Functions for Generics EnvVars

$Target defaults to 'Machine'

**Check if EnvVar already exists**
Get-EnvVar($Name, $Target)

**Create New Environment Variable**
New-EnvVar($Name, $Value, $Target)

**Edit/Alter EnvVar (should call "Get-EnvVar" function under the bonnet)**
Set-EnvVar($Name, $Value, $Target)

**Remove EnvVar (should call "Get-EnvVar" function under the bonnet)**
Remove-EnvVar($Name, $Target)