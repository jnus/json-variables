$here = Split-Path $MyInvocation.MyCommand.Definition
$base = Join-Path -Path $here -ChildPath '..'
$path = Join-Path -Path $base -ChildPath 'src'
$module = Join-Path -Path $path -ChildPath 'JsonVariables.psm1'
Import-Module $module -Force

Describe "Set-JsonVariables" {

    $script:secrets = '{ "github_token": "ghs_r3LabcthiSisnoTAvaliDtokEN01abcd", "REPO_SECRET_A": "repo_secret_a" }'
    $script:configFile = Join-Path -Path $here -ChildPath 'variables.minimal.json'

    Context "Given config file is valid" {
        
        It " sets 4 env. variables for Dev" {
  
            $result = Set-JsonVariables -scope 'Dev' -configFile $configFile -secrets $secrets
            
            add-content pester.log $result

            # No idea why this element is added when running in GH context: 
            # E.g. /home/runner/work/_temp/_runner_file_commands/set_env_e21b8381-6780-4a8a-b92d-ca3d48eff565
            $result | Where-Object {$_ -like "/home*"} | ForEach-Object {$result.Remove($_)}
            
            $result.Count | Should -Be 4
        }

        It " sets Url specific to Dev environment" {
            $result = Set-JsonVariables Dev $configFile $secrets
                       
            $result | Where-Object { $_ -like "*someDevHostName*"} | Should -BeTrue 
        }

        It " does not set Url to DevTest environment" {
            $result =  Set-JsonVariables Dev $configFile $secrets
            
            $result | Where-Object { $_ -like "*someDevTestHostName*"} | Should -BeFalse 
        }
    }

    Context "Given a series of different configuration types" {

        It " can parse a minimal configuration file" {
            $configFile = 'variables.minimal.json' 
            
            $result =  Set-JsonVariables "Dev" $configFile $secrets
            
            # No idea why this element is added when running in GH context: 
            # E.g. /home/runner/work/_temp/_runner_file_commands/set_env_e21b8381-6780-4a8a-b92d-ca3d48eff565
            $result | Where-Object {$_ -like "/home*"} | ForEach-Object {$result.Remove($_)}

            $result.Count | Should -Be 4
        }

        It " can parse a full configuration file" {
            $configFile = 'variables.full.json' 
            
            $result =  Set-JsonVariables "Dev" $configFile $secrets
            
            # No idea why this element is added when running in GH context: 
            # E.g. /home/runner/work/_temp/_runner_file_commands/set_env_e21b8381-6780-4a8a-b92d-ca3d48eff565
            $result | Where-Object {$_ -like "/home*"} | ForEach-Object {$result.Remove($_)}

            $result.Count | Should -Be 2
        }

        It " can parse a configuration file with normalized environments" {
            $configFile = 'variables.environments.json' 
            
            $result =  Set-JsonVariables 'Dev' $configFile $secrets
            
            # No idea why this element is added when running in GH context: 
            # E.g. /home/runner/work/_temp/_runner_file_commands/set_env_e21b8381-6780-4a8a-b92d-ca3d48eff565
            $result | Where-Object {$_ -like "/home*"} | ForEach-Object {$result.Remove($_)}

            $result.Count | Should -Be 2
        }
    }

    Context "Given a variable contains a secret" {

        It " substitutes the secret for entire value" {
            $result = Set-JsonVariables -scope Dev -configFile $configFile -secrets $secrets
            
            $result[2] | Should -BeLike "*repo_secret_a"
        }

        It " substitutes the secret for partial value" {
            $result = Set-JsonVariables -scope Dev -configFile $configFile -secrets $secrets
            
            $result[3] | Should -BeLike "*repo_secret_a*"
        }

        It " should not thow an error, when secrets parameter is not provided" {

            { Set-JsonVariables -scope Dev -configFile $configFile } | Should -Not -Throw
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
}
