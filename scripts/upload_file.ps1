param (
    [string]$localPath,
    [string]$remotePath
)

scp $localPath "debian@www.shitstorm.ovh:/var/www/paragon/$remotePath"