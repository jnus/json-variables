$here = Split-Path -Parent $MyInvocation.MyCommand.Path

function RunUnitTests
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $Path
    )

    Import-Module Pester -ErrorAction Stop

    $testResults = Invoke-Pester -Output Detailed # -OutputFile Test.xml -OutputFormat NUnitXml

    if ($testResults.FailedCount -gt 0)
    {
        $testResults | format-table
        throw 'One or more unit tests failed to pass.  Build aborting.'
    }
}

$path = Join-Path -Path $here -ChildPath 'set-jsonvariables.tests.ps1'
RunUnitTests $path
