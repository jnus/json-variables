param (
    [Parameter()]
    [string]
    $scope,
    [Parameter()]
    [string]
    $configFile,
    [Parameter()]
    [string]
    $secrets
)
$here = Split-Path $MyInvocation.MyCommand.Definition
$modulePath = Join-Path -Path $here -ChildPath 'JsonVariables.psm1'
Import-Module $modulePath -Force

Set-JsonVariables -scope $scope -configFile $configFile -secrets $secrets