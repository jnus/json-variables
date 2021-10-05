function Assert-EnvVar {

    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $actual,
        [Parameter()]
        [string]
        $expected,
        [Parameter()]
        [string]
        $envVar

    )
    $ErrorActionPreference = "Stop"

    if(!($actual -eq $expected)) {
        Write-Error "ERROR: Expected value $expected for $envVar but found value $actual"
    } else {
        Write-Host "SUCCESS: Expected value $expected for $envVar and found value $actual"
    }

}

Export-ModuleMember -Function Assert-String