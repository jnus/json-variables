[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $TargetEnvironment,
    [Parameter()]
    [string]
    $ConfigFile
)
$here = Split-Path $MyInvocation.MyCommand.Definition

Import-Module "$here/JsonVariables.psm1" -Force

Set-JsonVariables -TargetEnvironment $TargetEnvironment -ConfigFile $ConfigFile