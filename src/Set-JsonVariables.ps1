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

# No idea why this element is added when running in GH context: 
# E.g. /home/runner/work/_temp/_runner_file_commands/set_env_e21b8381-6780-4a8a-b92d-ca3d48eff565

$result | Where-Object {$_ -like "/home*"} | ForEach-Object {$result.Remove($_)}
return $result