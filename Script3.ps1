#open outlook and wait for exit 
start-process 'C:\Program Files\Google\Chrome\Application\chrome.exe' -Wait 5 | stop-process 
Start-Process outlook.exe -NoNewWindow -Wait

#backup folder
$dir = "c:\backup"
Start-Sleep 2

#restore user data
xcopy "$dir\Signatures" "$env:APPDATA\Microsoft\Signatures\" /h/s/e/k/c/f/y
xcopy "$dir\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe" "$env:LOCALAPPDATA\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe\"  /h/s/e/k/c/y
xcopy "$dir\Taskbar" "$env:APPDATA\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\"  /h/s/e/k/c/y
xcopy "$dir\Outlook" "$env:APPDATA\Microsoft\Outlook\"   /h/s/e/k/c/y
xcopy "$dir\Network" "$env:APPDATA\Microsoft\Network\"   /h/s/e/k/c/y
xcopy "$dir\Default" "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\" /h/s/e/k/c/y

#restore taskbar
regedit /s "$dir\Taskbar.reg"

rm -r -fo "C:\AzureOnboarding"

Remove-LocalUser -Name "AzureAdmin" -Confirm:$false

start-sleep 1
Stop-Process -ProcessName explorer







