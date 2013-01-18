function Get-ParameterCompleter {
    <#
       .SYNOPSIS
        Gets registered parameter completion scripts.

       .DESCRIPTION
        Gets registered parameter completion scripts with filtering by command and argument names.

       .PARAMETER CommandName
       Specified the name of the commands to filter.

       .PARAMETER ParameterName
       Specifies the name of the parameters to filter.

       .EXAMPLE
       C:\PS> Get-ParameterCompleter 'Get*' '*x*'

       Gets All parameter completers for commands that start with 'Get' and parameters that contains 'x'.

    #>

    param(
        [Parameter( Position=0)]
        [string]$CommandName = '*',
        [Parameter(Position=1)]
        [string]$ParameterName = '*'
    )

    End {
        $global:options['CustomArgumentCompleters'].Keys `        | Where-Object { $_ -like "$($CommandName):$ParameterName" } `
        | ForEach-Object {
            $splitName = $_.Split(':');
            $completer = New-Object PSObject -Property @{ CommandName = $splitName[0]; ParameterName = $splitName[1]; ScriptBlock = $global:options['CustomArgumentCompleters'][$_] }
            $completer.PSObject.TypeNames.Add('PSCompletion.Completer')
            $completer
        }
    }
}

Register-ParameterCompleter 'Get-ParameterCompleter' 'CommandName' {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $Global:options['CustomArgumentCompleters'].Keys | ForEach-Object { $_.Split(':')[0] } | Where-Object { $_ -like "$wordToComplete*" } `    | ForEach-Object { New-CompletionResult $_  } `
    | Sort-Object CompletionText
}

Register-ParameterCompleter 'Get-ParameterCompleter' 'ParameterName' {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $Global:options['CustomArgumentCompleters'].Keys | Where-Object { $_ -like "$($fakeBoundParameter['CommandName']):$wordToComplete*" } `    | ForEach-Object { New-CompletionResult ($_.Split(':')[1]) } `
    | Sort-Object CompletionText
}