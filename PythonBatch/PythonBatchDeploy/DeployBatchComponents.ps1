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

###  Configure Batch account

###  Configure Storage account

#  Fetch storage account access keys
$keys = Get-AzureRmStorageAccountKey -ResourceGroupName $rg -Name $storageAccount
#  Create a context for storage account commands
$context = New-AzureStorageContext -StorageAccountName $storageAccount -StorageAccountKey $keys.Value[0]
#  Create a container for resource files
New-AzureStorageContainer -Name resources -Context $context

#  Create a folder to copy resources locally
mkdir tmp-resources

#  Copy the package locally
wget $packageUrl > tmp-resources/Sample.py

#  Copy
Set-AzureStorageBlobContent -File `
    "https://github.com/vplauzon/batch/raw/master/PythonBatch/PythonBatchDeploy/PythonScripts/Sample.py" `
    -Container resources -Blob "mypath/sample.py" -BlobType Block -Force -Context $context

#  Clean temporary folder
rmdir tmp-resources -Force -Recurse

#  Create a container for data files
New-AzureStorageContainer -Name data -Context $context
