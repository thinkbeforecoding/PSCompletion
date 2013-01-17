function Test-ParameterCompleter {
    <#
       .SYNOPSIS
        Tests a registered parameter completion script for debugging purpose.

       .DESCRIPTION
        Tests a registered parameter completion script for debugging purpose.

       .PARAMETER CommandName
       Specified the name of the command to test.

       .PARAMETER ParameterName
       Specifies the name of the parameter to test.

       .PARAMETER WordToComplete
        Specifies the text value of the parameter to complete.
        It is often usefull to handle wildchars.

       .PARAMETER CommandAst
        Specifies the abstract syntax tree when completion is called in ast mode.
        This parameter use usually $null.

       .PARAMETER FakeBoundParameter
        A hashtable containing specified parameter name/value

       .EXAMPLE
       C:\PS> Test-ParameterCompleter 'GetInfo' 'Text' '*part' $null @{OtherParameter='SomeValue'}

    #>

    param(
        [Parameter(Mandatory, Position=0)]
        [string]$CommandName,
        [Parameter(Mandatory, Position=1)]
        [string]$ParameterName,
        [Parameter(Position=2)]
        [string]$WordToComplete,
        $CommandAst = $null,
        [Parameter(Position=3)]
        [hashtable]$FakeBoundParameter = @{})

    End {
        $scriptBloc = $global:options['CustomArgumentCompleters']["$($CommandName):$ParameterName"]
        if ($scriptBloc) {
            Invoke-Command $scriptBloc -ArgumentList $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter
        } else {
            Write-Error "Completer not found for parameter $parameterName of command $commandName"
        }
    }
}

Register-ParameterCompleter 'Test-ParameterCompleter' 'CommandName' {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $Global:options['CustomArgumentCompleters'].Keys | ForEach-Object { $_.Split(':')[0] } | Where-Object { $_ -like "$wordToComplete*" } `    | ForEach-Object { New-CompletionResult $_  } `
    | Sort-Object CompletionText
}

Register-ParameterCompleter 'Test-ParameterCompleter' 'ParameterName' {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $Global:options['CustomArgumentCompleters'].Keys | Where-Object { $_ -like "$($fakeBoundParameter['CommandName']):$wordToComplete*" } `    | ForEach-Object { New-CompletionResult ($_.Split(':')[1]) } `
    | Sort-Object CompletionText
}