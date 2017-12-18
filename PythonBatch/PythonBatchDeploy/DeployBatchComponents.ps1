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
$pythonAppID = "PythonScript"
$pythonAppVersion = "1.0"
$setupAppID = "PythonSetup"
$setupAppVersion = "1.0"

#  Create a folder to copy resources locally
mkdir tmp-resources

#  Copy resources locally
wget "https://github.com/vplauzon/batch/raw/master/PythonBatch/PythonBatchDeploy/Resources/sample.py" `
    > tmp-resources/sample.py
wget "https://github.com/vplauzon/batch/raw/master/PythonBatch/PythonBatchDeploy/Resources/setup-python.sh" `
    > tmp-resources/setup-python.sh

#  Build an archive for each resource separately
Compress-Archive -Path "tmp-resources\sample.py" -DestinationPath "tmp-resources/sample.zip" `
    -CompressionLevel Optimal
Compress-Archive -Path "tmp-resources\setup-python.sh" -DestinationPath "tmp-resources/setup-python.zip" `
    -CompressionLevel Optimal

###  Configure Batch account

#  Create 2 batch applications
New-AzureRmBatchApplication -ResourceGroupName $rg -AccountName $batchAccount -ApplicationId $pythonAppID
New-AzureRmBatchApplication -ResourceGroupName $rg -AccountName $batchAccount -ApplicationId $setupAppID

#  Upload 2 batch application packages
New-AzureRmBatchApplicationPackage -ResourceGroupName $rg -AccountName $batchAccount `
    -ApplicationVersion $pythonAppVersion -ApplicationId $pythonAppID -Format zip -FilePath `
    "tmp-resources/sample.zip"
New-AzureRmBatchApplicationPackage -ResourceGroupName $rg -AccountName $batchAccount `
    -ApplicationVersion $setupAppVersion -ApplicationId $setupAppID -Format zip -FilePath `
    "tmp-resources/setup-python.zip"

#  Set default version of the applications
Set-AzureRmBatchApplication -ResourceGroupName $rg -AccountName $batchAccount -ApplicationId $pythonAppID `
    -DefaultVersion $pythonAppVersion
Set-AzureRmBatchApplication -ResourceGroupName $rg -AccountName $batchAccount -ApplicationId $setupAppID `
    -DefaultVersion $setupAppVersion

###  Configure Storage account

#  Fetch storage account access keys
$keys = Get-AzureRmStorageAccountKey -ResourceGroupName $rg -Name $storageAccount
#  Create a context for storage account commands
$context = New-AzureStorageContext -StorageAccountName $storageAccount -StorageAccountKey $keys.Value[0]

#  Create a container for data files
New-AzureStorageContainer -Name data -Context $context

###  Clean temporary folder
rmdir tmp-resources -Force -Recurse

