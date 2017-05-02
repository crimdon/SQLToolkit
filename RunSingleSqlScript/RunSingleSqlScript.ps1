# this function runs all the SQL scripts in a supplied folder against the supplied server
[CmdletBinding()]
Param()

Trace-VstsEnteringInvocation $MyInvocation

Try {
    Import-VstsLocStrings "$PSScriptRoot\Task.json"
    [string]$sqlScript = Get-VstsInput -Name sqlScript
    [string]$serverName = Get-VstsInput -Name serverName
    [string]$databaseName = Get-VstsInput -Name databaseName
    [string]$userName = Get-VstsInput -Name userName
    [string]$userPassword = Get-VstsInput -Name userPassword
    [string]$queryTimeout = Get-VstsInput -Name queryTimeout

    [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null
    $SqlConnection = New-Object System.Data.SqlClient.SqlConnection
	
	if([string]::IsNullOrEmpty($userName)) {
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

    Write-Host "Running Script " $sqlScript " on Database " $databaseName
		
    #Execute the query
    (Get-Content $sqlScript | Out-String) -split '(?s)/\*.*?\*/' -split '\r?\ngo\r?\n' -notmatch '^\s*$' |
        ForEach-Object { $SqlCmd.CommandText = $_.Trim(); $reader = $SqlCmd.ExecuteNonQuery() }

    $SqlConnection.Close()
    Write-Host "Finished"
}

Catch {
	Write-Host "Error running SQL script: $_" -ForegroundColor Red
	throw $_
}

