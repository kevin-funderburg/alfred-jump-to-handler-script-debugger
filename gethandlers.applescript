(*
===============================================================================
                        Jump to Handler in Script Debugger
===============================================================================

Version: 1.0                                    Updated: 05/09/19 10:51:28 CST
By: Kevin Funderburg

PURPOSE:

Get the all the handlers in the front script of Script Debugger and create a
Alfred workflow that will allow you to search the handlers and select them in
the script.

REQUIRED:
	1.	Mac OS X Yosemite 10.10.5+
	2.	Mac Applications
			• Alfred 3
				
	3.	EXTERNAL OSAX Additions/LIBRARIES/FUNCTIONS
			• q_workflow.scpt
					
	4.	INTERNAL FUNCTIONS:
			• 

VERSION HISTORY:
1.0 - Initial version.
===============================================================================
*)
use AppleScript version "2.4" -- Yosemite (10.10) or later
use framework "Foundation"
use scripting additions

property wf : missing value

on main(wf)
	local p
	local argv
	local chcnt
	
	try
		tell application "Script Debugger"
			tell front document
				set src to source text
				if (count of script handlers) > 1 then
					
					set chcnt to 0
					ignoring white space
						
						repeat with i from 1 to count of paragraphs of src
							set p to paragraph i of src
							set chcnt to chcnt + (count of characters of p) + 1
							
							if p begins with "on " and p does not contain "error" then
								if p begins with tab then
									set tid to AppleScript's text item delimiters
									set AppleScript's text item delimiters to tab
									set newText to text items of p
									set AppleScript's text item delimiters to ""
									set p to newText as text
									set AppleScript's text item delimiters to tid
								end if
								if p begins with "on " then
									set num to i
									set insert to (chcnt - (count of characters of p)) + 3
									set _title to characters 3 thru -1 of p as text
									set selectionend to (count of characters of p) - 3
								else if p begins with "its " then
									set num to i
									set insert to (chcnt - (count of characters of p)) + 4
									set _title to characters 3 thru -1 of p as text
									set selectionend to (count of characters of p) - 4
								end if
								
								add_result of wf given theUid:(missing value), theArg:insert & "," & selectionend, theTitle:_title, theSubtitle:missing value, theIcon:{theType:"filepath", thePath:"icon.png"}, theAutocomplete:p, theType:missing value, isValid:"yes", theQuicklook:missing value, theVars:missing value, theMods:missing value, theText:missing value
							end if
							
						end repeat
					end ignoring
				end if
				
				if wf's _results = {} then
					add_result of wf given theUid:(missing value), theArg:missing value, theTitle:"No handlers found!", theSubtitle:missing value, theIcon:wf's ICON_ERROR, theAutocomplete:missing value, theType:"file", isValid:"no", theQuicklook:missing value, theVars:missing value, theMods:missing value, theText:missing value
				end if
				
			end tell
		end tell
	on error errMsg number errNum
		add_result of wf given theUid:(missing value), theArg:missing value, theTitle:errMsg, theSubtitle:errNum, theIcon:wf's ICON_ERROR, theAutocomplete:missing value, theType:"file", isValid:"no", theQuicklook:missing value, theVars:missing value, theMods:missing value, theText:missing value
	end try
	
	return wf's to_json(missing value)
end main


on run argv
	# get the workflow's source folder
	set workflowFolder to do shell script "pwd"
	
	# load the Workflow library
	set wlib to load script workflowFolder & "/q_workflow.scpt" as POSIX file
	
	set wf to wlib's newWorkflow()
	main(wf)
end run