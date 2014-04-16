set dumpDate to current date
set dateString to short date string of dumpDate
set timeString to do shell script "echo '" & (time string of dumpDate) & "' | sed s/:/./g"
set dumpTitle to "Link Dump " & dateString & " " & timeString
set dumpItems to {"# " & dumpTitle}
set linkCount to 0

set AppleScript's text item delimiters to return
tell application "Safari"
	set windowCount to 0
	repeat with thisWindow in windows
		set windowCount to windowCount + 1
		set windowTitles to {}
		set windowURLs to {}
		try
			set windowTabs to tabs of thisWindow -- TODO: This sometimes fails for the last pseudo-window. Why?
		on error
			exit repeat
		end try
		set tabCount to 0
		repeat with thisTab in (tabs of thisWindow)
			set tabCount to tabCount + 1
			try
				set linkRef to (windowCount as text) & "." & (tabCount as text)
				set tabTitle to "* [" & name of thisTab & "][" & linkRef & "]"
				set tabURL to "[" & linkRef & "]: " & URL of thisTab
				set end of windowTitles to tabTitle
				set end of windowURLs to tabURL
			on error
				set miniaturized of thisWindow to false
				tell me to display notification "Tab needs a refresh. Try again." with title "Dump Safari Links"
				error -128
			end try
		end repeat
		set windowDump to windowTitles & {""} & windowURLs as text
		set end of dumpItems to windowDump
		set linkCount to linkCount + tabCount
	end repeat
end tell

set AppleScript's text item delimiters to (return & return & return & "----" & return & return)
set fileContent to (dumpItems as text) & return
set filePath to (path to desktop folder as text) & dumpTitle & ".md"
set dumpFile to (open for access filePath with write permission)
write fileContent to dumpFile as «class utf8» starting at 0
close access dumpFile
display notification (linkCount as text) & " links dumped." with title "Dump Safari Links" sound name "Glass"
