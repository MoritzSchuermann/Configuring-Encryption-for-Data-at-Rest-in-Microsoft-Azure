#Prefix for resources
$prefix = "ced"

#Log into Azure
Add-AzAccount

#Select the correct subscription
Get-AzSubscription -SubscriptionName "SUB_NAME" | Select-AzSubscription

#Let's create a SQL DB that we will encrypt
$Location = "eastus"
$id = Get-Random -Minimum 1000 -Maximum 9999
$ResourceGroupName = "$prefix-sql-$id"
$SQLServerName = "$prefix-sql-$id"
$SQLDatabaseName = "$prefix-sql-db"
$SQLAdmin = "sqladmin"
$SQLAdminPassword = ConvertTo-SecureString -String 'n6Uz^)N.d!j+uE' -AsPlainText -Force
$SQLAdminCredentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $SQLAdmin,$SQLAdminPassword

#Now Create a resource group
$sqlRG = New-AzResourceGroup -Name $ResourceGroupName -Location $Location

#Create the SQL Server
$sqlServerParameters = @{
    ResourceGroupName = $sqlRG.ResourceGroupName
    Location = $Location
    ServerName = $SQLServerName
    SqlAdministratorCredentials = $SQLAdminCredentials
}

$sqlServer = New-AzSqlServer @sqlServerParameters

#Create the database
$databaseParameters = @{
    ResourceGroupName = $sqlRG.ResourceGroupName
    ServerName = $sqlServer.ServerName
    DatabaseName = $SQLDatabaseName
    RequestedServiceObjectiveName = "S0" 
    SampleName = "AdventureWorksLT"
}

$database = New-AzSqlDatabase @databaseParameters

#Check the TDE settings and remove encryption
$tdeParameters = @{
    ResourceGroupName = $sqlRG.ResourceGroupName
    ServerName = $sqlServer.ServerName
    DatabaseName = $database.DatabaseName
}

Get-AzSqlDatabaseTransparentDataEncryption @tdeParameters

Set-AzSqlDatabaseTransparentDataEncryption @tdeParameters -State Disabled
