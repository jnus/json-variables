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
        Write-Error "Expected $expected, but found $actual"
    }

}

Export-ModuleMember -Function Assert-String