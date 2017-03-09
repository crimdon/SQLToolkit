# SQL Toolkit

This is a set of build and deployment tasks to support SQL Server.
-- This extension supports on premises SQL servers only. It will not work for Azure or Visual Studio Team Services
-- Major update. This version no longer uses the Powershell commandlet Involk-Sqlcmd as there were bugs regarding error handling. 
-- Also Informational messages from TSQL commands such as PRINT will be displayed.

## Tasks

- SqlBackup
-- This task will perform a backup of your database to a file. 

- RunStoredProcedure
-- This task will run a Stored Procedure against your database.

- RunSqlScripts
-- This task will run all of the SQL scripts in the specifed folder against your database.

- RunSqlCommand
-- This task will run an adhoc query aganst your database.

- RunSingleSqlScript
-- This task will run a specified SQL script against your database.

- RunDACPAC
-- This task will deploy a specified DACPAC package file against your database.


## Setup

In order to run this extension, SQL Managed Objects must be installed on the server running
the build agent.

## Website:

[SQL Toolkit](https://github.com/crimdon/SQLToolkit/)