
#Log onto SQL Azure

Login-AzureRMAccount 
 
# Set the Azure subscription, needed if your Microsoft account is associated with multiple subscriptions  <<< ***

Select-AzureRmSubscription -SubscriptionName 'Production and DR'

# Set the Azure job connection -- Need to upgrade the Elastic Database Jobs Service

Use-AzureSqlJobConnection -ServerName "edjcb449dff1bb14854be135.database.windows.net" -DatabaseName "edjcb449dff1bb14854be135"

# Create the encrypted credential named DCA0Credential

# $credentialName = "DCA4Credential"
# $databaseCredential = Get-Credential
# $credential = New-AzureSqlJobCredential -Credential $databaseCredential -CredentialName $credentialName
# Write-Output $credential

# Execute the DBM - Rebuild Index job

$jobName = "DBM - Rebuild All DB Indexes"
$jobExecution = Start-AzureSqlJobExecution -JobName $jobName 
Write-Output $jobExecution

# Create a new job schedule - 3:00AM EST

$scheduleName = "Index Rebuild Job Schedule"
$dailyInterval = 1
$startTime = (New-Object -TypeName System.DateTime -ArgumentList (2016, 10, 07, 11, 00, 00)).ToUniversalTime()
$schedule = New-AzureSqlJobSchedule 
-DailyInterval $minuteInterval 
-ScheduleName $scheduleName 
-StartTime $startTime 
Write-Output $schedule

# Trigger a job executed on a time schedule

$jobName = "DBM Rebuild All DB Indexes"
$scheduleName = "Index Rebuild Job Schedule"
$jobTrigger = New-AzureSqlJobTrigger
–JobName $jobName
-ScheduleName $scheduleName
Write-Output $jobTrigger

