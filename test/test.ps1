Import-Module  "./../src/JsonVariables.psm1" -Force
Describe "Set-JsonVariables" {
    Context "Given config file is valid" {

        $configFile = "variables.minimal.json"
        
        It "sets 2 env. variables for Dev" {
            $result = .  Set-JsonVariables Dev $configFile 
            
            $result.Count | Should -Be 2
        }

        It "sets Url specific to Dev environment" {
            $result = Set-JsonVariables Dev $configFile 
            
            $result | Where-Object { $_ -like "*someDevHostName*"} | Should -BeTrue 
        }

        It "does not set Url to DevTest environment" {
            $result =  Set-JsonVariables Dev $configFile 
            
            $result | Where-Object { $_ -like "*someDevTestHostName*"} | Should -BeFalse 
        }
    }

    Context "Given a series of different configuration types" {

        It "can parse a minimal configuration file" {
            $configFile = "variables.minimal.json"
            
            $result =  Set-JsonVariables Dev $configFile
            
            $result.Count | Should -Be 2
        }

        It "can parse a full configuration file" {
            $configFile = "variables.full.json"
            
            $result =  Set-JsonVariables Dev $configFile
            
            $result.Count | Should -Be 2
        }

        It "can parse a configuration file with normalized environments" {
            $configFile = "variables.full.json"
            
            $result =  Set-JsonVariables Dev $configFile
            
            $result.Count | Should -Be 2
        }
    }
}
