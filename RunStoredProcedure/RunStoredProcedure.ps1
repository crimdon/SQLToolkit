# this function runs all the SQL scripts in a supplied folder against the supplied server
[CmdletBinding()]
Param()

Trace-VstsEnteringInvocation $MyInvocation

Try
{
	Import-VstsLocStrings "$PSScriptRoot\Task.json"
	[string]$serverName = Get-VstsInput -Name serverName
	[string]$databaseName = Get-VstsInput -Name databaseName
	[string]$sprocName = Get-VstsInput -Name sprocName
	[string]$sprocParameters = Get-VstsInput -Name sprocParameters
	[string]$userName = Get-VstsInput -Name userName
	[string]$userPassword = Get-VstsInput -Name userPassword
	[string]$queryTimeout = Get-VstsInput -Name queryTimeout


	Write-Host "Running Stored Procedure " $sprocName " on Database " $databaseName
	
	#Construct to the SQL to run
	
	[string]$sqlQuery = "EXEC " + $sprocName + " " + $sprocParameters
		
	#Execute the query
	if([string]::IsNullOrEmpty($userName))
		{
			Invoke-Sqlcmd -ServerInstance $serverName -Database $databaseName -Query $sqlQuery -QueryTimeout $queryTimeout
		}
	else
		{
			Invoke-Sqlcmd -ServerInstance $serverName -Database $databaseName -Query $sqlQuery -Username $userName -Password $userPassword -QueryTimeout $queryTimeout
		}

	Write-Host "Finished"
}

catch
{
	Write-Error "Error running Stored Procedure"
	Write-Debug $_.Exception.GetType().FullName
	Write-Error $_.Exception.Message
}

