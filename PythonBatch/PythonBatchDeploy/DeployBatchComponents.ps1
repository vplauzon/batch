#	Many components under an Azure Batch account can't be provisioned via an ARM template
#	yet.  For this reason we use this PowerShell script after running the ARM template

###  Replace the following variable values with yours

#  Resource group name where the batch account is deployed
$rg = "PythonBatch"
#  Name of the batch account as specified when running the ARM template
$batchAccount = "vplbatch"
#  Name of the storage account as specified when running the ARM template
$storageAccount = "vplbatchsto"

###  Those variable values do not need to be changed
$appID = "PythonScript"
$packageUrl = "https://github.com/vplauzon/batch/raw/master/PythonBatch/PythonBatchDeploy/AppPackages/Sample.zip"
$appVersion = "1.0"

###  Configure Batch account

#  Create the batch application
New-AzureRmBatchApplication -ResourceGroupName $rg -AccountName $batchAccount -ApplicationId $appID

#  Copy the package locally
wget $packageUrl > Sample.zip

#  Upload the batch application package
New-AzureRmBatchApplicationPackage -ResourceGroupName $rg -AccountName $batchAccount `
    -ApplicationVersion $appVersion -ApplicationId $appID -Format zip -FilePath Sample.zip

#  Set default version of the application
Set-AzureRmBatchApplication -ResourceGroupName $rg -AccountName $batchAccount -ApplicationId $appID `
    -DefaultVersion $appVersion

#  Clean local copy of the package
rm Sample.zip

#  Remove-AzureRmBatchApplicationPackage -ResourceGroupName $rg -AccountName $batchAccount -ApplicationId $appID -ApplicationVersion $appVersion
#  Remove-AzureRmBatchApplication -ResourceGroupName $rg -AccountName $batchAccount -ApplicationId $appID

###  Configure Storage account

$keys = Get-AzureRmStorageAccountKey -ResourceGroupName $rg -Name $storageAccount
$context = New-AzureStorageContext -StorageAccountName $storageAccount -StorageAccountKey $keys.Value[0]
New-AzureStorageContainer -Name test -Context $context