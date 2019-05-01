# this function runs all the SQL scripts in a supplied folder against the supplied server
[CmdletBinding()]
Param()

Trace-VstsEnteringInvocation $MyInvocation

Try {
    $ErrorActionPreference = "Stop";

    Import-VstsLocStrings "$PSScriptRoot\Task.json"
    [string]$serverName = Get-VstsInput -Name serverName
    [string]$databaseName = Get-VstsInput -Name databaseName
    [string]$sqlCommand = Get-VstsInput -Name sqlCommand
    [string]$userName = Get-VstsInput -Name userName
    [string]$userPassword = Get-VstsInput -Name userPassword
    [string]$queryTimeout = Get-VstsInput -Name queryTimeout

    [string]$batchDelimiter = "[gG][oO]"
	
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
		
    Write-Host "Running SQl Command on Database " $databaseName
		
    #Execute the query
    $sqlCommand -split '\r?\n\s*go' -notmatch '^\s*$' |
        ForEach-Object { $SqlCmd.CommandText = $_.Trim(); $reader = $SqlCmd.ExecuteNonQuery()
    }
    $SqlConnection.Close()
    Write-Host "Finished"
}


Catch {
    Write-Host "Error running SQL command: $_" -ForegroundColor Red
    throw $_
}

