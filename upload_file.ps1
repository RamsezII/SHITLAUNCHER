param (
    [string]$fileName,
    [string]$remotePath
)

$command = "scp $fileName debian@www.shitstorm.ovh:/var/www/paragon/$remotePath"

Invoke-Command -ScriptBlock { & $using:command }