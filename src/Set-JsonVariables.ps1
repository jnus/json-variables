param (
    [Parameter()]
    [string]
    $scope,
    [Parameter()]
    [string]
    $configFile
)
$here = Split-Path $MyInvocation.MyCommand.Definition
$modulePath = Join-Path -Path $here -ChildPath 'JsonVariables.psm1'
gci $here
Import-Module $modulePath -Force

Set-JsonVariables -scope $scope -configFile $configFile