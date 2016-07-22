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

	Write-Host "Running all scripts in $pathToScripts";

	foreach ($f in Get-ChildItem -path "$pathToScripts" -Filter *.sql | sort-object)
	{	
		Write-Host "Running Script " $f.Name;
		
		#Execute the query
		if([string]::IsNullOrEmpty($userName))
		{
			Invoke-Sqlcmd -ServerInstance $serverName -Database $databaseName -InputFile $f.FullName;
		}
		else
		{
			Invoke-Sqlcmd -ServerInstance $serverName -Database $databaseName -InputFile $f.FullName -Username $userName -Password $userPassword;
		}
	}

	Write-Host "Finished";
}

catch
{
	Write-Error "Error running SQL scripts";
	Write-Error $_.Exception.GetType().FullName;
	Write-Error $_.Exception.Message;
}

