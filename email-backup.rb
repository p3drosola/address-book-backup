require 'rubygems'
require 'mail'

# @todo: better error handling
# @todo: add dates

# gmail email & password
# could be easily modified to work with other SMTP provider
name = "Your Name"
email = "your.email@gmail.com"
password = "your password"
filename = "/tmp/address-book-backup.vcf"

# function to keep log
@debug = true
@runlog = []

def log( text )
  @runlog.push text
  puts "\n- " + text unless !@debug
end

log "Exporting Address Book to #{filename}..."

result = `osascript<<EOS
tell application "Address Book" to activate
tell application "Address Book"
	set the clipboard to (vcard of people) as text
	do shell script "pbpaste >/tmp/address-book-backup.vcf"
end tell
tell application "Address Book" to quit
EOS`
# @TODO: fix this to catch errors
log result unless result == ''

body = %{
Now your Address book is safe and sound, on the cloud!
Have a great day!

--
Address Book backups by Pedro Sola 
http://github.com/p3drosola/address-book-backup
}



Mail.defaults do
  delivery_method :smtp, {
    :address              => "smtp.gmail.com",
    :port                 => 587,
    :domain               => 'gmail.com',
    :user_name            => email,
    :password             => password,
    :authentication       => 'plain',
    :enable_starttls_auto => true  }
end

mail = Mail.new do
  from     "Address Book Backup <#{email}>"
  to       "#{name} <#{email}>"
  subject  'Address Book Backup'
  body     body
  add_file :filename => 'AddressBook.vcf', :content => File.read(filename)
end

log "Sending email to #{email}..."

mail.deliver!
log "Email sent!"
log "Removing backup file..."
exec("rm #{filename}")
log "All done!"