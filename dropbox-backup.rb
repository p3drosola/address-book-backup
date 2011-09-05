`osascript<<EOS
tell application "Address Book" to activate
tell application "Address Book"
	set the clipboard to (vcard of people) as text
	do shell script "pbpaste > ~/Dropbox/Address-Book.vcf"
end tell
tell application "Address Book" to quit
EOS`