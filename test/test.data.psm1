function SetupScoreVariables {
    $variables = '[
        {
            "Name": "HostName",
            "Value": "someDevHostName",
            "Scope": {
                "Environment": [
                    "Dev"
                ]
            }
        },
        {
            "Name": "HostName",
            "Value": "someDevTestHostName",
            "Scope": {}
        },
        {
            "Name": "VariableA",
            "Value": "ValueA",
            "Scope": {
                "Environment": [
                    "QA",
                    "Prod"
                ]
            }
        },
        {
            "Name": "VariableB",
            "Value": "ValueB",
        }
    ]' |  ConvertFrom-Json

    return $variables
}

Export-ModuleMember -Function * -Alias *