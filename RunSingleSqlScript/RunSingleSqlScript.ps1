# this function runs all the SQL scripts in a supplied folder against the supplied server
[CmdletBinding()]
Param()

Trace-VstsEnteringInvocation $MyInvocation

Try
{
	Import-VstsLocStrings "$PSScriptRoot\Task.json"
    [string]$sqlScript = Get-VstsInput -Name sqlScript
	[string]$serverName = Get-VstsInput -Name serverName
	[string]$databaseName = Get-VstsInput -Name databaseName
	[string]$userName = Get-VstsInput -Name userName
	[string]$userPassword = Get-VstsInput -Name userPassword
	[string]$queryTimeout = Get-VstsInput -Name queryTimeout

	Write-Host "Running Script " $sqlScript " on Database " $databaseName
		
	#Execute the query
	if([string]::IsNullOrEmpty($userName))
		{
			Invoke-Sqlcmd -ServerInstance $serverName -Database $databaseName -InputFile $sqlScript -QueryTimeout $queryTimeout
		}
	else
		{
			Invoke-Sqlcmd -ServerInstance $serverName -Database $databaseName -InputFile $sqlScript -Username $userName -Password $userPassword -QueryTimeout $queryTimeout
		}

	Write-Host "Finished"
}

catch
{
	Write-Error "Error running SQL script"
	Write-Debug $_.Exception.GetType().FullName
	Write-Error $_.Exception.Message
}

