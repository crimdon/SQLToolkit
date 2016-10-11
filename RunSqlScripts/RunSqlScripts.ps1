# this function runs all the SQL scripts in a supplied folder against the supplied server
[CmdletBinding()]
Param()

Trace-VstsEnteringInvocation $MyInvocation;

Try
{
	Import-VstsLocStrings "$PSScriptRoot\Task.json";
    [string]$pathToScripts = Get-VstsInput -Name pathToScripts;
	[string]$serverName = Get-VstsInput -Name serverName;
	[string]$databaseName = Get-VstsInput -Name databaseName;
	[string]$userName = Get-VstsInput -Name userName;
	[string]$userPassword = Get-VstsInput -Name userPassword;
	[string]$queryTimeout = Get-VstsInput -Name queryTimeout;

	if(!(Get-Command "Invoke-Sqlcmd" -errorAction SilentlyContinue))
	{
		Add-PSSnapin SqlServerCmdletSnapin100
        Add-PSSnapin SqlServerProviderSnapin100
	}

	Write-Host "Running all scripts in $pathToScripts";

	foreach ($f in Get-ChildItem -path "$pathToScripts" -Filter *.sql | sort-object)
	{	
		Write-Host "Running Script " $f.Name;
		
		#Execute the query
		if([string]::IsNullOrEmpty($userName))
		{
			Invoke-Sqlcmd -ServerInstance $serverName -Database $databaseName -InputFile $f.FullName -QueryTimeout $queryTimeout -OutputSqlErrors $true  -ErrorAction 'Stop';
		}
		else
		{
			Invoke-Sqlcmd -ServerInstance $serverName -Database $databaseName -InputFile $f.FullName -Username $userName -Password $userPassword -QueryTimeout $queryTimeout -OutputSqlErrors $true -ErrorAction 'Stop';
		}
	}

	Write-Host "Finished";
}

catch
{
	Write-Error "Error running SQL script: $f.FullName"
	Write-Error "SQL error: $_" -ForegroundColor Red
}

