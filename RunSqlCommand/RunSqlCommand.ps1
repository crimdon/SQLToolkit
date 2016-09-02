# this function runs all the SQL scripts in a supplied folder against the supplied server
[CmdletBinding()]
Param()

Trace-VstsEnteringInvocation $MyInvocation

Try
{
	Import-VstsLocStrings "$PSScriptRoot\Task.json"
	[string]$serverName = Get-VstsInput -Name serverName
	[string]$databaseName = Get-VstsInput -Name databaseName
	[string]$sqlCommand = Get-VstsInput -Name sqlCommand
	[string]$sprocParameters = Get-VstsInput -Name sprocParamters
	[string]$userName = Get-VstsInput -Name userName
	[string]$userPassword = Get-VstsInput -Name userPassword
	[string]$queryTimeout = Get-VstsInput -Name queryTimeout

	if(!(Get-Command "Invoke-Sqlcmd" -errorAction SilentlyContinue))
	{
		Add-PSSnapin SqlServerCmdletSnapin100
        Add-PSSnapin SqlServerProviderSnapin100
	}

	Write-Host "Running SQl Command on Database " $databaseName
		
	#Execute the query
	if([string]::IsNullOrEmpty($userName))
		{
			Invoke-Sqlcmd -ServerInstance $serverName -Database $databaseName -Query "$sqlCommand" -QueryTimeout $queryTimeout -OutputSqlErrors $true
		}
	else
		{
			Invoke-Sqlcmd -ServerInstance $serverName -Database $databaseName -Query "$sqlCommand" -Username $userName -Password $userPassword -QueryTimeout $queryTimeout -OutputSqlErrors $true
		}

	Write-Host "Finished"
}

catch
{
	Write-Error "Error running SQL command"
	Write-Debug $_.Exception.GetType().FullName
	Write-Error $_.Exception.Message
}

