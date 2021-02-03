#Create Backup Dir
$dir = mkdir "c:\backup"

#backup up user data
Start-Sleep 2
xcopy  "$env:APPDATA\Microsoft\Signatures" "$dir\Signatures\" /h/s/e/k/c/f/y
xcopy "$env:LOCALAPPDATA\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe" "$dir\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe\" /h/s/e/k/c/y
xcopy "$env:APPDATA\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar" "$dir\Taskbar\" /h/s/e/k/c/y
xcopy "$env:APPDATA\Microsoft\Outlook" "$dir\Outlook\"  /h/s/e/k/c/y
xcopy "$env:APPDATA\Microsoft\Network" "$dir\Network\"  /h/s/e/k/c/y
xcopy "$env:LOCALAPPDATA\Google\Chrome\User Data\Default"  "$dir\Default\" /h/s/e/k/c/y

#copy taskbar and synced sharepoint sites
REG EXPORT HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband "$dir\Taskbar.reg" /y
Get-ItemProperty -Path HKCU:\SOFTWARE\SyncEngines\Providers\OneDrive\*  | select MountPoint, UrlNamespace | Out-File -Width 600 $dir\SharepointSites.txt

#export startlayout and reimport as deafult
Export-StartLayout -Path $dir\startlayout.xml
Import-StartLayout -LayoutPath "$dir\startlayout.xml" -MountPath "C:\"

#Config Auto admin login
$regpath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
$regs =  @(
        "AutoAdminLogon,1,string", 
        "DefaultUsername,AzureAdmin,string",
        "DefaultPassword,Welcome1,string",
        "AutoLogonCount,1,dword"
)
    foreach ($reg in $regs) {
    $regname = $reg.Split(",")[-3]
    $regvalue = $reg.Split(",")[-2]
    $regtype = $reg.Split(",")[-1]
    $testpath = Get-ItemProperty -Path $regpath $regname -ErrorAction SilentlyContinue
    
   if  (!($testpath)) {
        New-ItemProperty -Path "$regpath" -Name $regname -Value $regvalue -PropertyType $regtype -ErrorAction SilentlyContinue }  
    
    else {
        Set-ItemProperty -Path "$regpath" -Name $regname -Value $regvalue -ErrorAction SilentlyContinue
   }
    }
#Skip Privacy Settings Experience at Sign-in
$key = 'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\OOBE'
New-ItemProperty -Path "$key" -Name 'DisablePrivacyExperience' -Value '1' -PropertyType dword -ErrorAction SilentlyContinue


#Create local admin
Start-Sleep -Seconds 2
$user = "AzureAdmin"
$Password =  ConvertTo-SecureString "Welcome1" -AsPlainText -Force
New-LocalUser $user -Password $Password -FullName $user -Description "Temp for azure"
Add-LocalGroupMember -Group "Administrators" -Member $user

#create RunOnce key
$runkey = "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
Set-ItemProperty $runkey -Name '!JoinAzureAD' -Value ('c:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe -executionpolicy bypass -File ' + "C:\AzureOnboarding\Script2.ps1")

#import certificate
Start-Sleep 2
Import-Certificate -FilePath "$PSScriptRoot\Cisco_Umbrella_Root_CA.Cer" -CertStoreLocation Cert:\LocalMachine\Root

#install Cisco Umbrella
Start-Sleep -Seconds 2
msiexec /i $PSScriptRoot\setup.msi /passive 

#unjoin computer from domain
Start-Sleep -Seconds 7
Remove-Computer -Restart -Force 






