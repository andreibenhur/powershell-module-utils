Set-Variable -Name 'SlugLocalMachine' -Option ReadOnly -Value 'LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager'
Set-Variable -Name 'SlugCurrentUser' -Option ReadOnly -Value 'CURRENT_USER'
Set-Variable -Name 'ProviderSlug' -Option ReadOnly -Value 'Registry::HKEY_{0}\Environment'

Function Get-EnvVar {
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$false, Position=0)] [string] $Name,
		[Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$false, Position=1)] [string] $Target = 'Machine'
	)

	$RegistryPath = ''

	If ($Target -eq 'Machine') {
		$RegistryPath = $ProviderSlug -f $SlugLocalMachine
	} ElseIf ($Target -eq 'User') {
		$RegistryPath = $ProviderSlug -f $SlugCurrentUser
	}

	$EnvVar = (Get-ItemProperty -Path $RegistryPath -Name $Name -ErrorAction SilentlyContinue).$Name

	If ($EnvVar.Length -gt 0) {
		return $EnvVar
	} Else {
		return $false
	}
}

Function New-EnvVar {
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$false, Position=0)] [string] $Name,
		[Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$false, Position=1)] [string] $Value,		
		[Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$false, Position=2)] [string] $Target = 'Machine'
	)

	$RegistryPath = ''

	If ($Target -eq 'Machine') {
		$RegistryPath = $ProviderSlug -f $SlugLocalMachine
	} ElseIf ($Target -eq 'User') {
		$RegistryPath = $ProviderSlug -f $SlugCurrentUser
	}

	If (!(Get-EnvVar -Name $Name -Target $Target)) {
		New-ItemProperty -Path $RegistryPath -Name $Name -Value $Value
		Format-ResultMessage -Message "Environment variable '$Name' created."
	} Else {
		Format-ResultMessage -Message "The environment variable '$Name' already exists in the '$Target' scope."
	}

}

Function Remove-EnvVar  {
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$false,Position=0)] [string] $Name,
		[Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$false, Position=1)] [string] $Target = 'Machine'
	)

	$RegistryPath = ''

	If ($Target -eq 'Machine') {
		$RegistryPath = $ProviderSlug -f $SlugLocalMachine
	} ElseIf ($Target -eq 'User') {
		$RegistryPath = $ProviderSlug -f $SlugCurrentUser
	}

	If (Get-EnvVar -Name $Name -Target $Target) {
		Remove-ItemProperty -Path $RegistryPath -Name $Name -ErrorAction SilentlyContinue
		Format-ResultMessage -Message "Environment variable '$Name' removed from '$Target' scope/target."
	} Else {
		Format-ResultMessage -Message "The environment variable '$Name' does already not exists in the '$Target' scope/target."
	}
}

Function Set-EnvVar {
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$false, Position=0)] [string] $Name,
		[Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$false, Position=1)] [string] $Value,
		[Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$false, Position=2)] [string] $Target = 'Machine'
	)

	$RegistryPath = ''

	If ($Target -eq 'Machine') {
		$RegistryPath = $ProviderSlug -f $SlugLocalMachine
	} ElseIf ($Target -eq 'User') {
		$RegistryPath = $ProviderSlug -f $SlugCurrentUser
	}

	If (Get-EnvVar -Name $Name -Target $Target) {
		Set-ItemProperty -Path $RegistryPath -Name $Name -Value $Value
		Format-ResultMessage -Message "Environment variable '$Name' changed."
	} Else {
		Format-ResultMessage -Message "The environment variable '$Name' does not exists in the '$Target' scope/target."
	}
}

Function Add-toEnvVar {
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$false, Position=0)] [string] $TargetEnvVar,		
		[Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$false, Position=1)] [string] $Value,
		[Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$false, Position=2)] [string] $Target = 'Machine'
	)

	$RegistryPath = ''

	If ($Target -eq 'Machine') {
		$RegistryPath = $ProviderSlug -f $SlugLocalMachine
	} ElseIf ($Target -eq 'User') {
		$RegistryPath = $ProviderSlug -f $SlugCurrentUser
	}

	If (Get-EnvVar -Name $TargetEnvVar -Target $Target) {
		$Old = Get-EnvVar -Name $TargetEnvVar -Target $Target
		$New = $Old + ';' + $Value
		Set-ItemProperty -Path $RegistryPath -Name $TargetEnvVar -Value $New
		Format-ResultMessage -Message "Environment variable '$TargetEnvVar' changed."
	} Else {
		Format-ResultMessage -Message "The environment variable '$TargetEnvVar' does not exists in the '$Target' scope/target."
	}

}

Function Format-ResultMessage {
	[CmdletBinding()]
	Param([Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$false, Position=0)] [string] $Message)
	Write-Host `n`# $Message `#`n
}

# Creates a back-up of the path variable
Function New-PathEnvVarBackup () {
	$CurrentDateTime = Get-Date -Format FileDateTime
	$BackupFolder = $profile_location + '\Back-Up' 
	$Filename = $BackupFolder + '\PathEnvVar_ ' + $CurrentDateTime + '.txt'

	If (!(Test-Path '.\Back-Up')) {
		New-Item $BackupFolder -Type Directory
	}

	$Env:Path | Out-File -FilePath $Filename -Encoding 'UTF8'
}

Function Add-Path () {
	[Cmdletbinding()] 
	Param([Parameter(Mandatory=$True, ValueFromPipeline=$True, Position=0)] [string] $addedPath)

	# Get the current search path from the environment keys in the registry.
	$oldPath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).Path

	# See if a new folder has been supplied.
	if (!$addedPath) {
		return 'No Folder Supplied. $ENV:PATH Unchanged'
	}

	# See if the new folder exists on the file system.
	if (!(TEST-PATH $addedPath)) { 
		return 'Folder Does not Exist, Cannot be added to $ENV:PATH'
	}

	# See if the new Folder is already in the path.
	if ($ENV:PATH | Select-String -SimpleMatch $addedPath) {  
		return 'Folder already within $ENV:PATH'
	}
	
	# Set the New Path
	$newPath = $oldPath + ';'+ $addedPath

	Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $newPath

	# Show our results back to the world
	return $newPath
}