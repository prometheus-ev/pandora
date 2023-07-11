namespace :pandora do
  desc "Inform users about upcoming expiration of their account"
  task expiration_notification: :environment do
    Pandora::UpcomingExpiry.new.run
  end
end
