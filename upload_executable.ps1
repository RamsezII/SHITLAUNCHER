# Define variables
$localFilePath = "dist/SHITLAUNCHER.exe"
$remoteFilePath = "debian@www.shitstorm.ovh:/var/www/paragon/launchers/SHITLAUNCHER.exe"

# Upload the file using SCP
scp $localFilePath $remoteFilePath

# Verify the upload
if ($?) {
    Write-Output "File uploaded successfully to $remoteFilePath."
} else {
    Write-Output "File upload failed."
}