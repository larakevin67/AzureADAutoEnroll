# Join azure ad
Install-ProvisioningPackage -packagepath 'c:\AzureOnboarding\AzureJoin.ppkg' -ForceInstall -QuietInstall
Start-Sleep -Seconds 2

#restart
Restart-Computer -Force 
