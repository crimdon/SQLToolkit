# this function runs a SQL backup against the supplied server and database
[CmdletBinding()]
Param()

Trace-VstsEnteringInvocation $MyInvocation

Try
	{
		Import-VstsLocStrings "$PSScriptRoot\Task.json"
		[string]$backupType = Get-VstsInput -Name backupType
		[string]$serverName = Get-VstsInput -Name serverName
		[string]$databaseName = Get-VstsInput -Name databaseName
		[string]$backupFile = Get-VstsInput -Name backupFile
		[string]$withInit = Get-VstsInput -Name withInit
		[string]$copyOnly = Get-VstsInput -Name copyOnly
		[string]$userName = Get-VstsInput -Name userName
		[string]$userPassword = Get-VstsInput -Name userPassword
        [string]$queryTimeout = Get-VstsInput -Name queryTimeout

		if(!(Get-Command "Invoke-Sqlcmd" -errorAction SilentlyContinue))
		{
			Add-PSSnapin SqlServerCmdletSnapin100
			Add-PSSnapin SqlServerProviderSnapin100
		}
		
		#Specify the Action property to generate a FULL backup
		switch($backupType.ToLower())
		{
			"full" {$backupAction = "DATABASE"}
			"log" {$backupAction = "LOG"}
			"differential" {$backupAction = "DATABASE"}
		}
		
		#Initialize the backup if set
		switch($withInit)
		{
			$false {$mediaInit = "NOINIT"}
			$true {$mediaInit = "INIT"}
		}
		
		#Set WITH options
		if($backupType -eq "differential")
		{
			$withOptions = "DIFFERENTIAL, " + $mediaInit;
		}
		else
		{
			switch($copyOnly)
			{
				$false {$withOptions = $mediaInit}
				$true {$withOptions = $mediaInit + ", COPY_ONLY"}
			}
		}
		
		#Build the backup query using Windows Authenication
		$query = "BACKUP " + $backupAction + " " + $databaseName + " TO DISK = N'" + $backupFile + "' WITH " + $withOptions; 
		
		Write-Host "Starting $backupType backup of $databaseName to $backupFile"
		
		#Execute the backup
		if([string]::IsNullOrEmpty($userName))
		{
			Write-Host $query
			Invoke-Sqlcmd -ServerInstance $serverName -Query $query -QueryTimeout $queryTimeout -OutputSqlErrors $true  -ErrorAction 'Stop'
		}
		else
		{
			Write-Host $query
			Invoke-Sqlcmd -ServerInstance $serverName -Query $query -Username $userName -Password $userPassword -QueryTimeout $queryTimeout -OutputSqlErrors $true  -ErrorAction 'Stop'
		}
		
		Write-Host "Finished"
	}
	
Catch
	{
		Write-Error "Error running SQL backup: $_"
	}







