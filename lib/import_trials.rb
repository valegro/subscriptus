require 'csv'

$publication = Publication.find(1)

CSV.foreach(ARGV[0]) do |row|
  email, publication_id, state, start, end_date, weekender, solus = row
  p email
  attributes = {
    :email => email,
    :first_name => 'Trial',
    :last_name => 'User',
    :solus => (solus == 'Yes'),
    :weekender => (weekender == 'Yes'),
    :overide_wordpress => true
  }
  begin
    User.find_or_create_with_trial($publication, Publication::DEFAULT_TRIAL_EXPIRY, 'direct_import', attributes)
  rescue
    puts $!
  end
end
