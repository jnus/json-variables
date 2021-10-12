$regexGithubExpression = '\${{\s*secrets.?(.*)\s*}}'
$regexJsonVarExpression = '#{\s*?(.*)\s*}'
function Set-JsonVariables {

    [CmdletBinding()]
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
    $ErrorActionPreference = "Stop"

    $secretsList = ($secrets | ConvertFrom-Json -AsHashtable )
    $config = $configFile
    
    if(!(Test-Path $config)) {
        $config = Get-ChildItem -filter $configFile -recurse | Select-Object -First 1
    }

    if(!(Test-Path $config)) {
        Write-Error "Config file path does not exit: $config"
    }

    $json = Get-Content $config | out-string | ConvertFrom-Json

    # Add environment to variable
    $json.Variables += [PSCustomObject]@{
        Name='Environment';
        Value=$scope;
    }

    # Find scoped environment if present
    $scopedEnvironment = $json.ScopeValues.Environments | Where-Object {$_.Name -eq $scope}

    # Find scoped variables based on target environment
    $targetVariables = $json.Variables | Where-Object {
        $_.Scope.Environment -contains $scopedEnvironment.Id `
        -OR $_.Scope.Environment -contains $scope `
        -OR [bool]($_.Scope.PSobject.Properties.name -match 'Environment') -eq $false 
        }

    Invoke-ScoreVariables -$targetVariables

    $targetVariables = Get-VariablesByPrecedens -variables $targetVariables

     if(!($null -eq $secretsList)) {

        # Find variables with secrets needing substitution    
        $needsSecretSubstituting = $targetVariables | Where-Object {
            $_.Value -match $regexGithubExpression
        }

        # Substitute secrets in variables
        $needsSecretSubstituting | ForEach-Object {
            $m = $_.Value | Select-String -pattern $regexGithubExpression
            $value = $m.Matches.Groups[1].Value
            
            $substition = $secretsList[$value]
            $_.Value = $_.Value -replace $regexGithubExpression, $substition
        }
     }

   

    # Find variables needing substitution    
    $needsSubstituting = $targetVariables | Where-Object {
        $_.Value -match $regexJsonVarExpression
    }


    # Substitute variables
    $needsSubstituting | ForEach-Object {
        $m = $_.Value | Select-String -pattern $regexJsonVarExpression
        $value = $m.Matches.Groups[1].Value
        $substition = $targetVariables | Where-Object {$_.Name -eq $value}
        $_.Value = $_.Value -replace $regexJsonVarExpression, $substition.Value
    }


    $envValues = @()

    # Write alle variables to env
    $targetVariables | ForEach-Object {
        Write-Output "$($_.Name)=$($_.Value)" >> $Env:GITHUB_ENV
        $envValues += "$($_.Name)=$($_.Value)"
    }

    $Env:GITHUB_ENV | format-table

    return $envValues
}

 function Get-VariablesByPrecedens {
    [CmdletBinding()]
    param (
        [Parameter()]
        [PSCustomObject[]]
        $variables
    )

    $precedence = @()
    
    $groups = $variables | Group-Object -Property Name
    $groups | Foreach-Object {
            $precedence += $_.Group | Sort-Object -Property Score -Descending | Select-Object -First 1
    }

    return $precedence
}
function Invoke-ScoreVariables {
    [CmdletBinding()]
    param (
        [Parameter()]
        [PSCustomObject[]]
        $variables
    )
    $variables | ForEach-Object {
        $score = Get-Score $_
        $_ | Add-Member NoteProperty -Name Score -Value $score
    }
    return $variables
}

function Get-Score {
    [CmdletBinding()]
    param (
        [Parameter()]
        [PSCustomObject]
        $variable
    )

    $score = 0

    # Environment Scope
    if( [bool]($variable.PSobject.Properties.name -match "Scope") -eq $true `
        -AND [bool]($variable.Scope.PSobject.Properties.name -match "Environment") -eq $true `
        -AND $variable.Scope.Environment.Length -gt 0) {
            $score += 100
    }
    # No Scope
    else {
        $score += 10
    }

    return $score
}

Export-ModuleMember -Function Set-JsonVariables, Invoke-ScoreVariables,  Get-Score, Get-VariablesByPrecedens
Export-ModuleMember -Variable regexGithubExpression, regexJsonVarExpression