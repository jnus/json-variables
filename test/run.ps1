$ErrorActionPreference = "Stop"
$here = Split-Path $MyInvocation.MyCommand.Definition
$json = Get-Content "$here/variablesubstitution-variables.explicitenvironments.json" | out-string | ConvertFrom-Json

$TargetEnvironment = 'DevTest'

$scopedEnvironment = $json.ScopeValues.Environments | Where-Object {$_.Name -eq $targetEnvironment}

$targetVariables = $json.Variables | Where-Object {
       $_.Scope.Environment -contains $scopedEnvironment.Id `
       -OR $_.Scope.Environment -contains $targetEnvironment `
       -OR [bool]($_.Scope.PSobject.Properties.name -match 'Environment') -eq $false 
    }

$targetVariables | format-table

$needsSubstituting = $targetVariables | Where-Object {
    $_.Value -match '#{?(.*)}'
}

$needsSubstituting | ForEach-Object {
    $m = $_.Value | Select-String -pattern '#{?(.*)}'
    $value = $m.Matches.Groups[1].Value
    $substition = $targetVariables | Where-Object {$_.Name -eq $value}
    $_.Value = $_.Value -replace '#{?(.*)}', $substition.Value
}

$GITHUB_ENV = $null
$targetVariables | ForEach-Object {
    echo "$($_.Name)=$($_.Value)"
    echo "$($_.Name)=$($_.Value)" >> $Env:GITHUB_ENV
}

$GITHUB_ENV | format-table
