
Login-AzureRMAccount 
 
# Set the Azure subscription, needed if your Microsoft account is associated with multiple subscriptions  <<< ***

$AzureSubscriptionName = 'Production and DR'
$Subscription = Get-AzureRmSubscription -SubscriptionName $AzureSubscriptionName | Select-AzureRmSubscription

$SubscriptionId = $Subscription.Subscription.SubscriptionId

## Get SQL Server credentials.  NOTE: same credential assumed for all source servers <<< ***

$sourceCred = Get-Credential -Message 'User name and password for source server' -UserName 'pflorenzano@Thunderhead.com' # add user name here
$outputServerCred = Get-Credential -Message 'User name and password for telemetry database' -UserName 'dbops' # add user name here 

## Resource group and server used for source server selection  <<< ***

$resourceGroupName = 'th-dca4-sqldb' # name of resource group containing the server from which telemetry will be gathered - see https://portal.azure.com
$serverName = 'th-dca4-psql05' # name of server from which telemetry will be gathered - e.g. "myappserver"

## Establish the job connection to the DCA4 Elastic Pool

Use-AzureSqlJobConnection -CurrentAzureSubscription

## Execute the DBM - Rebuild Index job

$JobName = 'DBM - Rebuild Indexes'
$jobExecution = Start-AzureSqlJobExecution -JobName $JobName
Write-Output $jobExecution

## Job schedule

$scheduleName = "Daily Schedule"
$dailyInterval = 1
$startTime = (New-Object -TypeName System.DateTime -ArgumentList (2016, 10, 03, 03, 00, 00)).ToUniversalTime()
$schedule = New-AzureSqlJobSchedule 
-DailyInterval $dailyInterval 
-ScheduleName $scheduleName 
-StartTime $startTime 
Write-Output $schedule








