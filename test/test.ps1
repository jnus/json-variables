$SetJsonVariables = "./../src/Set-JsonVariables.ps1"
Describe "Set-JsonVariables" {
    Context "Given config file is valid" {

        $configFile = "variables.minimal.json"
        
        It "Sets 2 env. variables for Dev" {
            $result = . $SetJsonVariables Dev $configFile 
            $result.Count | Should -Be 2
        }

        It "Sets Url specific to Dev environment" {
            $result = . $SetJsonVariables Dev $configFile 
            $result | Where-Object { $_ -like "*someDevHostName*"} | Should -BeTrue 
        }

        It "Does not set Url to DevTest environment" {
            $result = . $SetJsonVariables Dev $configFile 
            $result | Where-Object { $_ -like "*someDevTestHostName*"} | Should -BeFalse 
        }
    }
}
