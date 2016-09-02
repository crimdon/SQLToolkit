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

	if(!(Get-Command "Invoke-Sqlcmd" -errorAction SilentlyContinue))
	{
		Add-PSSnapin SqlServerCmdletSnapin100
        Add-PSSnapin SqlServerProviderSnapin100
	}

	Write-Host "Running Stored Procedure " $sprocName " on Database " $databaseName
	
	#Construct to the SQL to run
	
	[string]$sqlQuery = "EXEC " + $sprocName + " " + $sprocParameters
		
	#Execute the query
	if([string]::IsNullOrEmpty($userName))
		{
			Invoke-Sqlcmd -ServerInstance $serverName -Database $databaseName -Query $sqlQuery -QueryTimeout $queryTimeout -OutputSqlErrors $true
		}
	else
		{
			Invoke-Sqlcmd -ServerInstance $serverName -Database $databaseName -Query $sqlQuery -Username $userName -Password $userPassword -QueryTimeout $queryTimeout -OutputSqlErrors $true
		}

	Write-Host "Finished"
}

catch
{
	Write-Error "Error running SQL script: $_"
}

