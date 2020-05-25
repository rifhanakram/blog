param (
    [Parameter(Mandatory=$true)][string]$msg
)
$errorActionPreference="stop"

Write-Host "Deploying Updates to Github Pages"

Get-ChildItem -Path .\public -Include *.* -Recurse | foreach { $_.Delete()}

hugo.exe -t anubis

cd public

git add .

git commit -m $msg

git push origin master

cd ..
