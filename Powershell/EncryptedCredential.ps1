$credentialName = "ElasticJobCredential"
$databaseCredential = Get-Credential
$credential = New-AzureSqlJobCredential -Credential $databaseCredential -CredentialName $credentialName
Write-Output $credential