# SQL Toolkit

This is a set of build and deployment tasks to support SQL Server.
-- This extension supports on premises SQL servers only. It will not work for Azure or Visual Studio Team Services
-- New version no longer needs SQL Server Management Objects (SMO).
-- You can use SQL Authenication to run these tasks.

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

In order to run this extension, the SQL Powershell modules must be installed on the server running
the build agent.

[Import the SQLPS Module](https://msdn.microsoft.com/en-GB/library/hh231286.aspx)

## Website:

[SQL Toolkit](https://github.com/crimdon/SQLToolkit/)