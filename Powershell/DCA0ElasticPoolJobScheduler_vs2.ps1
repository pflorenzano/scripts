Login-AzureRMAccount 
 
# Set the Azure subscription, needed if your Microsoft account is associated with multiple subscriptions  <<< ***

Select-AzureRmSubscription -SubscriptionName 'DCA0 and Test'

# Set the Azure job connection

Use-AzureSqlJobConnection -ServerName "edjdaa2aea7f52c4d6a88189.database.windows.net" -DatabaseName "ElasticPoolJobRepository"

# Create the encrypted credential named DCA0Credential

# $credentialName = "DCA0Credential"
# $databaseCredential = Get-Credential
# $credential = New-AzureSqlJobCredential -Credential $databaseCredential -CredentialName $credentialName
# Write-Output $credential

# Execute the DBM - Rebuild Index job

$jobName = "{Job Name}"
$jobExecution = Start-AzureSqlJobExecution -JobName $jobName 
Write-Output $jobExecution

# State of job execution

$jobExecutionId = "{Job Execution Id}"
$jobExecution = Get-AzureSqlJobExecution -JobExecutionId $jobExecutionId
Write-Output $jobExecution


