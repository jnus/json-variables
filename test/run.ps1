$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$rootPath = Join-Path -Path $here -ChildPath '..'
$srcPath = Join-Path -Path $rootPath -ChildPath 'src'
function RunUnitTests {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $Path
    )

    Import-Module Pester -ErrorAction Stop

    # get default from static property
    $configuration = [PesterConfiguration]::Default
    # assing properties & discover via intellisense
    # $configuration.Run.Path = 'C:\projects\tst'
    # $configuration.Filter.Tag = 'Acceptance'
    # $configuration.Filter.ExcludeTag = 'WindowsOnly'
    $configuration.Should.ErrorAction = 'Continue'
    $configuration.CodeCoverage.Enabled = $true
    $configuration.CodeCoverage.Path = $srcPath 
    $configuration.CodeCoverage.ExcludeTests
    # $configuration.Output.Verbosity = 'Detailed'
    $configuration.TestResult.Enabled = $true
    $configuration.TestResult.OutputPath = 'testresult.xml'
    $configuration.TestResult.OutputFormat = 'JUnitXml'

    $testResults = Invoke-Pester -Configuration $configuration

    if ($testResults.FailedCount -gt 0) {
        $testResults | format-table
        throw 'One or more unit tests failed to pass.  Build aborting.'
    }
}

$path = Join-Path -Path $here -ChildPath 'set-jsonvariables.tests.ps1'
RunUnitTests $path
