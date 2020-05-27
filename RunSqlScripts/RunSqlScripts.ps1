﻿# this function runs all the SQL scripts in a supplied folder against the supplied server
[CmdletBinding()]
Param()

Trace-VstsEnteringInvocation $MyInvocation;

function ReplaceParameters {
    if ([string]::IsNullOrEmpty($SQLparameters)) {
        return;
    }
    $SQLparameters.Split(",") | ForEach-Object {
        $param,$paramvalue = $_.Split("=").Trim();
        $SqlCmd.CommandText = $SqlCmd.CommandText.replace($param, $paramvalue);
    }   
}

Try {
    Import-VstsLocStrings "$PSScriptRoot\Task.json";
    [string]$pathToScripts = Get-VstsInput -Name pathToScripts;
    [string]$executionOrder = Get-VstsInput -Name executionOrder;
    [string]$serverName = Get-VstsInput -Name serverName;
    [string]$databaseName = Get-VstsInput -Name databaseName;
    [string]$userName = Get-VstsInput -Name userName;
    [string]$userPassword = Get-VstsInput -Name userPassword;
    [string]$queryTimeout = Get-VstsInput -Name queryTimeout;
    [string]$removeComments = Get-VstsInput -Name removeComments;
    [string]$SQLparameters = Get-vstsinput -Name SQLparameters;
    [string]$continueAfterError = Get-VstsInput -Name continueAfterError;

    [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null

    $serverName.Split(",") | ForEach-Object {       
        $serverToProcess = $_
        Write-Host "Processing Server " $serverToProcess
        
        $databaseName.Split(",") | ForEach-Object {            
            $databaseToProcess = $_
            Write-Host "Processing database " $databaseToProcess

            $SqlConnection = New-Object System.Data.SqlClient.SqlConnection

            $server = $serverToProcess.Split(":")[0]
            $port = $serverToProcess.Split(":")[1]
            if (![string]::IsNullOrEmpty($port)) {
                $serverToProcess = $server + ',' + $port
            }
            
            $databaseToProcess = $databaseToProcess -replace '[[\]]', ''
            
            if ([string]::IsNullOrEmpty($userName)) {
                $SqlConnection.ConnectionString = "Server=$serverToProcess;Initial Catalog=$databaseToProcess;Trusted_Connection=True;Connection Timeout=30;"		
            }
            else {
                $SqlConnection.ConnectionString = "Server=$serverToProcess;Initial Catalog=$databaseToProcess;User ID=$userName;Password=$userPassword;Connection Timeout=30;"
            }

            $handler = [System.Data.SqlClient.SqlInfoMessageEventHandler] {param($sender, $event) Write-Host $event.Message -ForegroundColor DarkBlue} 
            $SqlConnection.add_InfoMessage($handler) 
            $SqlConnection.Open()
            $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
            $SqlCmd.Connection = $SqlConnection
            $SqlCmd.CommandTimeout = $queryTimeout
            if ([string]::IsNullOrEmpty($executionOrder)) {
                Write-Host "Running all scripts in $pathToScripts";
                foreach ($sqlScript in Get-ChildItem -path "$pathToScripts" -Filter *.sql | sort-object) {	
                    Write-Host "Running Script " $sqlScript.Name
		
                    #Execute the query
                    switch ($removeComments) {
                        $true {
                            (Get-Content $sqlScript.FullName -Encoding UTF8 | Out-String) -replace '(?s)/\*.*?\*/', " " -split '\r?\n\s*go\s*\r\n?' -notmatch '^\s*$' |
                                ForEach-Object { 
                                Try {
                                    $SqlCmd.CommandText = $_.Trim(); 
                                    ReplaceParameters;
                                    $reader = $SqlCmd.ExecuteNonQuery(); 
                                }
                                Catch {
                                    switch ($continueAfterError) {
                                        $true { Write-Host "$($SqlCmd.CommandText) resulted in an error $($Error[0].Exception)"; }
                                        $false {
                                            Write-Host "$($SqlCmd.CommandText) resulted in an error $($Error[0].Exception)" -ForegroundColor Red; 
                                            throw $Error[0];
                                        }
                                    }
                                } 
                            }
                        }
                        $false {
                            (Get-Content $sqlScript.FullName -Encoding UTF8 | Out-String) -split '\r?\n\s*go\s*\r\n?' -notmatch '^\s*$' |
                                ForEach-Object { 
                                Try {
                                    $SqlCmd.CommandText = $_.Trim(); 
                                    ReplaceParameters;
                                    $reader = $SqlCmd.ExecuteNonQuery(); 
                                }
                                Catch {
                                    switch ($continueAfterError) {
                                        $true { Write-Host "$($SqlCmd.CommandText) resulted in an error $($Error[0].Exception)"; }
                                        $false {
                                            Write-Host "$($SqlCmd.CommandText) resulted in an error $($Error[0].Exception)" -ForegroundColor Red; 
                                            throw $Error[0];
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            else {
                Write-Host "Using file $executionOrder"
                $TOCFile = $pathToScripts + "\" + $executionOrder
                Write-Host "Using file $TOCFile"
                Get-Content $TOCFile -Encoding UTF8 | ForEach-Object {
                    $sqlScript = $pathToScripts + "\" + $_
                    Write-Host "Running Script " $sqlScript
                    
                    #Execute the query
                    switch ($removeComments) {
                        $true {
                            (Get-Content $sqlScript -Encoding UTF8 | Out-String) -replace '(?s)/\*.*?\*/', " " -split '\r?\n\s*go\s*\r\n?' -notmatch '^\s*$' |
                                ForEach-Object { 
                                Try {
                                    $SqlCmd.CommandText = $_.Trim(); 
                                    ReplaceParameters;
                                    $reader = $SqlCmd.ExecuteNonQuery();
                                }
                                Catch {
                                    switch ($continueAfterError) {
                                        $true { Write-Host "$($SqlCmd.CommandText) resulted in an error $($Error[0].Exception)"; }
                                        $false {
                                            Write-Host "$($SqlCmd.CommandText) resulted in an error $($Error[0].Exception)" -ForegroundColor Red; 
                                            throw $Error[0];
                                        }
                                    }
                                } }
                        }
                        $false {
                            (Get-Content $sqlScript -Encoding UTF8 | Out-String) -split '\r?\n\s*go\s*\r\n?' |
                                ForEach-Object { 
                                Try {
                                    $SqlCmd.CommandText = $_.Trim(); 
                                    ReplaceParameters;
                                    $reader = $SqlCmd.ExecuteNonQuery(); 
                                }
                                Catch {
                                    switch ($continueAfterError) {
                                        $true { Write-Host "$($SqlCmd.CommandText) resulted in an error $($Error[0].Exception)"; }
                                        $false {
                                            Write-Host "$($SqlCmd.CommandText) resulted in an error $($Error[0].Exception)" -ForegroundColor Red; 
                                            throw $Error[0];
                                        }
                                    }
                                } 
                            }
                        }
                    }
                }
            }
        }

        $SqlConnection.Close()
        $SqlConnection.Dispose()
    }

    Write-Host "Finished";
}

catch {
    Write-Error "Error running SQL script $_";
    throw $Error[0];
}

