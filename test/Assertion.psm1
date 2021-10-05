function Assert-String {

    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $actual,
        [Parameter()]
        [string]
        $expected
    )
    $ErrorActionPreference = "Stop"

    if(!($actual -eq $expected)) {
        Write-Error "ERROR: Expected $expected, but found $actual"
    } else {
        Write-Host "SUCCESS: Expected $expected, and found $actual"
    }

}

Export-ModuleMember -Function Assert-String