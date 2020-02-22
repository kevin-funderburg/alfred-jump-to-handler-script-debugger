(*
===============================================================================
                        Jump to Handler in Script Debugger
===============================================================================

Version: 1.0                                    Updated: 2/22/20, 2:45:29 PM
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
								
								set itm to wf's ¬
									(its newItemWithUID:(missing value) arg:((insert & "," & selectionend) as text) title:_title subtitle:"press ↩︎ to select" icon:(missing value) autocomplete:p |type|:"default" valid:true quicklookurl:(missing value) |text|:(missing value))
								tell itm
									(its setIcon:"filepath" thePath:"icon.png")
									addItem()
								end tell
								
							end if
							
						end repeat
					end ignoring
				end if
				
				if wf's _results = {} then
					set itm to wf's (its newItemWithUID:"q_err" arg:"q_err" title:"No handlers found!" subtitle:"No unread messages found" icon:(wf's ICON_ERROR) autocomplete:(missing value) |type|:"file" valid:"no" quicklookurl:(missing value) |text|:(missing value))
					itm's addItem()
					
				end if
				
			end tell
		end tell
	on error errMsg number errNum
		set itm to wf's (its newItemWithUID:"q_err" arg:"q_err" title:"An error occurred..." subtitle:errMsg icon:(wf's ICON_ERROR) autocomplete:(missing value) |type|:"default" valid:"no" quicklookurl:(missing value) |text|:(missing value))
		itm's addItem()
	end try
	
	return wf's wftoJSON()
	
end main


on run argv
	# get the workflow's source folder
	set workflowFolder to do shell script "pwd"
	
	# load the Workflow library
	set wlib to load script workflowFolder & "/q_workflow.scpt" as POSIX file
	
	set wf to wlib's newWorkflow()
	main(wf)
end run

