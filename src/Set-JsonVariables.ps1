param (
    [Parameter()]
    [string]
    $scope,
    [Parameter()]
    [string]
    $configFile,
    [Parameter()]
    [System.Object]
    $secrets
)
$here = Split-Path $MyInvocation.MyCommand.Definition
$modulePath = Join-Path -Path $here -ChildPath 'JsonVariables.psm1'
Import-Module $modulePath -Force

$secrets | write-host

add-content secrets.log $secrets

# Set-JsonVariables -scope $scope -configFile $configFile