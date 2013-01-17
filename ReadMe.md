PSCompletion Powershell module
==============================

jeremie.chassaing / thinkbeforecoding
http://thinkbeforecoding.com

Installation
============

Install this module in your usual PS module directory.
If you don't have one, create a Modules directory where you want, copy the PSCompletion folder into it.
Add then the Modules directory path to the PSModulePath environment variable.
You can do it by adding the following line to the %User%/Documents/WindowsPowerShell/Profile.ps1 file :

   $env:PSModulePath += ';*PathToYouModuleFile*'

You can also load this module by default in your profile.ps1 file :

   Import-Module PSCompletion

You can then use it in your own modules or functions.

Usage
=====

The modules contains 3 commands :
- Register-ParameterCompleter: registers a parameter completer
- New-CompletionResult: creates a CompletionResult object used by PS completion
- Test-ParameterCompleter : tests a parameter completer for debugging purpose

Say you have a function with 2 parameters :

	function Test-Info($Param1, $Param2) {
	 	#...
	}

You can provide completion for the second parameter this way:

	Register-ParameterCompleter Test-Info Param2 {
		param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
		Get-Info -Filter $fakeBoundParameter['Param1'] `
		| ? { $_.Text -like "$wordToComplete*" } `
		| Sort-Object Text
		| % { New-CompletionResult $_.Text }
	}

In this sample, you can see the use of $wordToComplete parameter with a trailing '*'. This
enables to find all items starting with the wordToComplete. When $wordToComplete also contains
wildchars, those wildchars will also be used. For instance, completion on *Test will find all
selected values containing the test Test string.  

The New-CompletionResult command is used to create the output object.

You can also notice the usage of $fakeBoundParameter['Param1'].
$fakeBoundParameter is a hashtable of specified parameters. When completion is called for Param2,
Param1 has usualy been provided and can be used to narrow the selection.

$commandName and $parameterName contains the Command and Parameter names. It can be usefull when
using the same script block for several commands/parameters like this :

    $completer = { 
	     param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
	     # ...
    }

    Register-ParameterCompleter Test-Info Param2 $completer
    Register-ParameterCompleter Test-OtherFunction OtherParam $completer

The New-CompletionResult command takes three parameters :
- CompletionText: The text to replace the completed word
- ListItemText: The text displayed in ISE completion dropdown
- Tooltip : The tooltip to display next to items in ISE completion dropdown. It can be multiline.


Test-ParameterComplete is usefull to test completion script blocks.

	Test-ParameterCompleter 'Get-Info' 'Param2' '*val' @{Param1='SomeValue'}

This will call the previously register parameter completer with the $wordToComplete variable
set to '*val' and the $fakeBoundParameter containing Param1 to SomeValue

You can put breakpoints in your completer script block or simply check error message and output
to see if it matches expected result.

Hint
====

Register-ParameterCompleter already has completion on its parameters:
- CommandName: proposes available powershell command names
- ParameterName : proposes selected command parameters
- ScriptBlock : proposes a stub script block to be filled by your own

Test-ParameterCompleter also :
- CommandName: proposes registered completer function names
- ParameterName: proposes registered parameters for selected function



Have fun ! 

jeremie chassaing / thinkbeforecoding
http://thinkbeforecoding.com
