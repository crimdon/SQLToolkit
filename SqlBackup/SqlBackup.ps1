# this function runs a SQL backup against the supplied server and database
[CmdletBinding()]
Param()

Trace-VstsEnteringInvocation $MyInvocation

Try {
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
    [string]$backupCompression = Get-VstsInput -Name backupCompression

    [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null
    $SqlConnection = New-Object System.Data.SqlClient.SqlConnection

    if ([string]::IsNullOrEmpty($userName)) {
        $SqlConnection.ConnectionString = "Server=$serverName;Initial Catalog=$databaseName;Trusted_Connection=True;Connection Timeout=30;"		
    }
    else {
        $SqlConnection.ConnectionString = "Server=$serverName;Initial Catalog=$databaseName;User ID=$userName;Password=$userPassword;Connection Timeout=30;"
    }

    $handler = [System.Data.SqlClient.SqlInfoMessageEventHandler] {param($sender, $event) Write-Host $event.Message -ForegroundColor DarkBlue} 
    $SqlConnection.add_InfoMessage($handler) 
    $SqlConnection.Open()
    $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
    $SqlCmd.Connection = $SqlConnection
    $SqlCmd.CommandTimeout = $queryTimeout
			
    #Specify the Action property to generate a FULL backup
    switch ($backupType.ToLower()) {
        "full" {
            $backupAction = "DATABASE"
        }
        "log" {
            $backupAction = "LOG"
        }
        "differential" {
            $backupAction = "DATABASE"
        }
    }
		
    #Initialize the backup if set
    switch ($withInit) {
        $false {
            $mediaInit = "NOFORMAT"
        }
        $true {
            $mediaInit = "FORMAT"
        }
    }

    #Set copy only option
    switch ($copyOnly) {
        $false {$copyOnlyAction = ""}
        $true {$copyOnlyAction = ", COPY_ONLY"}
    }

    #Set compression option
    $sqlCmd.CommandText = "SELECT ISNULL((SELECT value FROM sys.configurations WHERE name = 'backup compression default'),-1)"
    [int]$returnVal = $sqlCmd.ExecuteScalar()  
    if ($returnVal -eq -1) {
        $compressionAction = ""
    }
    else {
        switch ($backupCompression) {
            "Default" {$compressionAction = ""}
            "Compress" {$compressionAction = ", COMPRESSION"}
            "NoCompress" {$compressionAction = ", NO_COMPRESSION"}
        }
    }

    #Set WITH options
    if ($backupType -eq "differential") {
        $withOptions = "DIFFERENTIAL, " + $mediaInit + $compressionAction;
    }
    else {
        $withOptions = $mediaInit + $copyOnlyAction + $compressionAction;
    }
		
    #Build the backup query using Windows Authenication
    $sqlCommand = "BACKUP " + $backupAction + " " + $databaseName + " TO DISK = N'" + $backupFile + "' WITH " + $withOptions; 
		
    Write-Host "Starting $backupType backup of $databaseName to $backupFile"
		
    #Execute the backup
    $SqlCmd.CommandText = $sqlCommand
    Write-Host $sqlCommand
    $reader = $SqlCmd.ExecuteNonQuery()

    $SqlConnection.Close()
		
    Write-Host "Finished"
}
	
Catch {
    Write-Host "Error running SQL Backup: $_" -ForegroundColor Red
    throw $_
}