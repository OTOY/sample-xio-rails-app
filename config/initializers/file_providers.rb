$box = Otoy::Box.new(ENV['BOX_ID'], ENV['BOX_SECRET'])
$dropbox = Otoy::Dropbox.new(ENV['DROPBOX_KEY'], ENV['DROPBOX_SECRET'])
$google_drive = Otoy::GoogleDrive.new(ENV['GOOGLE_DRIVE_ID'], ENV['GOOGLE_DRIVE_SECRET'])
$onedrive = Otoy::OneDrive.new(ENV['ONE_DRIVE_ID'], ENV['ONE_DRIVE_SECRET'])
