function New-CompletionResult {
    <#
       .SYNOPSIS
        Creates a new System.Management.Automation.CompletionResult object to return from
        Register-ParameterCompletion script block.

       .DESCRIPTION
        Creates a new System.Management.Automation.CompletionResult object to return from
        Register-ParameterCompletion script block.

       .PARAMETER CompletionText
       Specified the text used to set completed parameter value.

       .PARAMETER ListItemText
       Specifies the text to display in the completion list in ISE.

       .PARAMETER Tooltip
        Specifies the text to display in the tooltips of the completion list in ISE.
        The text can be multiline.

       .EXAMPLE
       C:\PS> Register-ParameterCompleter 'Get-Info' 'Text' {
         param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
         New-CompletionResult -CompletionText "'$wordToComplete Completed'" -ListItemText 'Text In Completion List' -ToolTip 'Completion List Tooltip'
       }
    #>
    param(
        [Parameter(Mandatory)]
        [string]$CompletionText,
        [string]$ListItemText = $CompletionText,
        [string]$ToolTip = $CompletionText
    )
    
    End {
        New-Object System.Management.Automation.CompletionResult $CompletionText, $ListItemText, 'ParameterValue', $ToolTip
    }
}
