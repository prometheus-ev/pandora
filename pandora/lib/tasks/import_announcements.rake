namespace :import do
  desc "import json data as announcements"
  task :import_announcements, [:path] => :environment do |t, args|
    annoncements_collection = JSON.parse(File.read(args[:path]))
    annoncements_collection.each do |announcement_hash|
      Announcement.create!(announcement_hash)
    end
  end
end
