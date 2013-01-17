<#
    jeremie.chassaing / thinkbeforecoding 2013

    The following code is based on
    http://www.powershellmagazine.com/2012/11/29/using-custom-argument-completers-in-powershell-3-0/
    
    It proposes a convenient packaging to use this method easily and extensively.
#>

<#
    Create a global options to pass to [System.Management.Automation.CommandCompletion]::CompleteInput
    containing registered argument completers
#>
if (-not $global:options) { 
    $global:options = @{CustomArgumentCompleters = @{};NativeArgumentCompleters = @{}}
}

<# 
    Change the orignal TabExpansion2 function used for PS 3.0 completion
    to merge passed $options with $global:options

    The change will happen only once event if executed several times because
    on second pass, the function text doesn't match anymore
#>
$function:tabexpansion2 = $function:tabexpansion2 -replace 'End\r\n{','End { if ($null -ne $options) { $options += $global:options} else {$options = $global:options}'

function Register-ParameterCompleter {
    <#
       .SYNOPSIS
       Registers a custom argument completer.

       .DESCRIPTION
       Registers a custom argument completer.
       Powershell console will use it to provide tab completion of specified command parameter.
       Powershell ISE will also used provided information to populate a dropdown list and tooltips
       when ctrl+space is pressed.


       .PARAMETER CommandName
       Specifies the name of the function to complete

       .PARAMETER ParameterName
       Specifies the name of the argument to complete

       .PARAMETER ScriptBlock
       Specifies the script to use for completion.
       The script block should take 5 arguments: 
            $commandName : the name of the completed command 
            $parameterName : the name of the completed parameter
            $wordToComplete : the start of the word to complete
            $commandAst : the abstract syntax tree when completion is done using Ast
            $fakeBoundParameter : A hashtable container names/values of other specified parameters

       .EXAMPLE
       C:\PS> Register-ParameterCompleter 'Get-Info' 'Text' {
       param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
       New-CompletionResult -CompletionText "'$wordToComplete Completed'" -ListItemText 'Text In Completion List' -ToolTip 'Completion List Tooltip'
       }
    #>
    param(
        [Parameter(Position=0, Mandatory)]
        [string]$CommandName,
        [Parameter(Position=1, Mandatory)]
        [string]$ParameterName,
        [Parameter(Position=2, Mandatory)]
        [scriptblock]$ScriptBlock
        )

    End {
        $global:options['CustomArgumentCompleters']["$($CommandName):$ParameterName"] = $ScriptBlock
    }
}

<#
    Register completion on the CommandName parameter of Register-ParameterCompleter
    to propose available commands
#>
Register-ParameterCompleter -CommandName 'Register-ParameterCompleter' -ParameterName 'CommandName' -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    Get-Command "$wordToComplete*" `
    | Where-Object { !$_.Name.EndsWith(':') -and $_.CommandType -ne [System.Management.Automation.CommandTypes]::Alias -and $_.CommandType -ne [System.Management.Automation.CommandTypes]::Application } `
    | Sort-Object Name `
    | ForEach-Object { New-CompletionResult $_.Name -ToolTip ('{0} ({1})' -f $_.Name, $_.ModuleName ) }
}

<#
    Register completion on the ParameterName parameter of Register-ParameterCompleter
    to propose available command parameters
#>
Register-ParameterCompleter -CommandName 'Register-ParameterCompleter' -ParameterName 'ParameterName' -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    Get-Command ($fakeBoundParameter['CommandName']) `
    | ForEach-Object {
        $parameters =  $_.Parameters
        $parameters.Keys | ForEach-Object { [pscustomobject]@{Name = $_; Value = $parameters[$_] } }
      } `
    | Where-Object { @('Verbose','Debug','ErrorAction','WarningAction','ErrorVariable','WarningVariable','OutVariable','OutBuffer','WhatIf','Confirm') -notcontains $_.Name } `
    | ForEach-Object { 
        $type = $_.Value.ParameterType
        New-CompletionResult $_.Name ('{0} [{1}]' -f $_.Name, $type.Name) ("{0}`n{1}" -f $_.Name, $type.FullName ) }
}

<#
    Register completion on the ScriptBloc parameter of Register-ParameterCompleter
    to create a stub script block
#>
Register-ParameterCompleter -CommandName 'Register-ParameterCompleter' -ParameterName 'ScriptBlock' -ScriptBlock {
    New-CompletionResult -CompletionText @'
{
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    New-CompletionResult "Result"
}
'@
}