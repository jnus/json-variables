$here = Split-Path $MyInvocation.MyCommand.Definition
$base = Join-Path -Path $here -ChildPath '..'
$path = Join-Path -Path $base -ChildPath 'src'
$module = Join-Path -Path $path -ChildPath 'JsonVariables.psm1'
Import-Module $module -Force
Import-Module "$here/test.data.psm1" -Force

Describe "Set-JsonVariables" {

    $script:secrets = '{ "github_token": "ghs_r3LabcthiSisnoTAvaliDtokEN01abcd", "REPO_SECRET_A": "repo_secret_a" }'
    $script:configFile = Join-Path -Path $here -ChildPath 'variables.minimal.json'

    Context "Given config file is valid" {

        it " sets 4 environment variables or more (GH injects object when returning from actions" {
            $result = Set-JsonVariables -scope 'Dev' -configFile $configFile -secrets $secrets

            $result.Count | Should -BeGreaterOrEqual 4
        }

        It " sets HostName to Dev environment" {

            $result = Set-JsonVariables -scope 'Dev' -configFile $configFile -secrets $secrets

            $result | Where-Object { $_ -like "HostName=someDevHostName"}
        }

        It " sets Url specific to Dev environment" {
            $result = Set-JsonVariables Dev $configFile $secrets

            $result | Where-Object { $_ -like "Url=https://someDevHostName.com"} | Should -BeTrue
        }

        It " does not set Url to DevTest environment" {
            $result =  Set-JsonVariables Dev $configFile $secrets

            $result | Where-Object { $_ -like "*someDevTestHostName*"} | Should -BeFalse
        }

        It " adds Environment variable with the scope value on runtime" {
            $result = Set-JsonVariables Dev $configFile $secrets

            $result | Where-Object { $_ -like "Environment=Dev"} | Should -BeTrue
        }
    }

    Context "Given a series of different configuration types" {

        It " can parse a minimal configuration file" {
            $configFile = 'variables.minimal.json'

            $result =  Set-JsonVariables "Dev" $configFile $secrets

            $result.Count | Should -BeGreaterOrEqual 4
        }

        It " can parse a full configuration file" {
            $configFile = 'variables.full.json'

            $result =  Set-JsonVariables "Dev" $configFile $secrets

            $result.Count | Should -BeGreaterOrEqual 2
        }

        It " can parse a configuration file with normalized environments" {
            $configFile = 'variables.environments.json'

            $result =  Set-JsonVariables 'Dev' $configFile $secrets

            $result.Count | Should -BeGreaterOrEqual 2
        }
    }

    Context "Given a variable contains a secret" {

        It " substitutes the secret for entire value" {
            $result = Set-JsonVariables -scope Dev -configFile $configFile -secrets $secrets

            $result | Where-Object {$_ -like "SecretA*"} | Should -BeLike "*repo_secret_a"
        }

        It " substitutes the secret for partial value" {
            $result = Set-JsonVariables -scope Dev -configFile $configFile -secrets $secrets

            $result | Where-Object {$_ -like "ConnectionString*"} | Should -BeLike "*repo_secret_a*"
        }

        It " should not thow an error, when secrets parameter is not provided" {

            { Set-JsonVariables -scope Dev -configFile $configFile } | Should -Not -Throw
        }

        It " substitutes the Environment substitution" {
            $result = Set-JsonVariables -scope Dev -configFile $configFile -secrets $secrets

            $result | Where-Object {$_ -like "Environment*"} | Should -BeLike "*Dev"
        }
    }

    Context "Misc" {

        $script:githubRegex = $regexGithubExpression
        $script:jsonVarRegex = $regexJsonVarExpression

        It " should be possible to index by key" {
            $secrets = '{
                "github_token": "ghs_r3Labcd8qTVbHKSabcdePq4Epjbq01abcd",
                "REPO_SECRET_A": "repo_secret_a"
              }'
              $secretList = ($secrets | ConvertFrom-Json -AsHashtable )
              $key = "REPO_SECRET_A"

              $actual = $secretList[$key]

              $actual | Should -Be "repo_secret_a"
        }

        It " Should match github substitute expression" {
            $value = '${{secrets.REPO_SECRET_A}}'

            $m = $value | Select-String -pattern $githubRegex

            $value = $m.Matches.Groups[1].Value | Should -Be "REPO_SECRET_A"
        }

        It " Should match json-variable substitute expression" {
            $value = '#{someVar}'

            $m = $value | Select-String -pattern $jsonVarRegex

            $value = $m.Matches.Groups[1].Value | Should -Be "someVar"
        }

        It " Should replace github substitute expression" {
            $value = '${{secrets.REPO_SECRET_A}}'

            $actual = $value -replace $githubRegex, "some_secret"

            $actual | Should -Be "some_secret"
        }

        It " Should replace github substitute expression with single white spaces" {
            $value = '${{ secrets.REPO_SECRET_A }}'

            $actual = $value -replace $githubRegex, "some_secret"

            $actual | Should -Be "some_secret"
        }

        It " Should replace github substitute expression with multiple white spaces" {
            $value = '${{  secrets.REPO_SECRET_A    }}'

            $actual = $value -replace $githubRegex, "some_secret"

            $actual | Should -Be "some_secret"
        }
    }

    

    Context "Givin a valid variable array" {
        
        It " should score a single variable" {
            $variables = SetupScoreVariables

            $result = Get-Score $variables[0]

            $result | Should -BeGreaterThan 0
        }

        It " should score a variable with environment scope to 100" {
            $variables = SetupScoreVariables

            $result = Get-Score $variables[0]

            $result | Should -Be 100
        }

        It " should score a variable with no scope to 10" {
            $variables = SetupScoreVariables
            
            $result = Get-Score $variables[1]

            $result | Should -Be 10
        }

        It " should score a variable with 2 environments to 100" {
            $variables = SetupScoreVariables
            
            $result = Get-Score $variables[2]

            $result | Should -Be 100
        }

        It " should score a variable with scope section to 10" {
            $variables = SetupScoreVariables
            
            $result = Get-Score $variables[3]

            $result | Should -Be 10
        }
    }

    Context "Given 2 variables with same name, one with an environment scope and on with no scope" {
    
        It " should add a Score member all objects" {
            $variables = SetupScoreVariables

            $result = Invoke-ScoreVariables $variables

            $result | ForEach-Object {  ([bool]$_.PSObject.Properties['Score']) | Should -BeTrue }
        }

        It " should score all objects" {
            $variables = SetupScoreVariables

            $result = Invoke-ScoreVariables $variables

            $result | ForEach-Object {  $_.Score | Should -BeGreaterThan 0 }
        }

        It " should return variable with a environment scope due to higher score" {
            $variables = SetupScoreVariables

            $result = Get-VariablesByPrecedens $variables

            ($result | Where-Object { $_.Name -eq 'HostName'} | Measure-Object).Count | Should -Be 1

        }

        It " should return HostName with value someDevHostName, due to higher score" {
            $variables = SetupScoreVariables

            $result = Get-VariablesByPrecedens $variables

            $variable = ($result | Where-Object { $_.Name -eq 'HostName'} | Select-Object -First 1) 
            $variable.Value | Should -Be 'someDevHostName'

        }
    
    }
        

}

