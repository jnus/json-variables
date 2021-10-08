param (
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]
    $scope,
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]
    $configFile,
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]
    $secrets
)
$here = Split-Path $MyInvocation.MyCommand.Definition
$modulePath = Join-Path -Path $here -ChildPath 'JsonVariables.psm1'
Import-Module $modulePath -Force

$result = Set-JsonVariables -scope $scope -configFile $configFile -secrets $secrets

return $result