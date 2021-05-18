namespace :pandora do
  desc "Check institutional licenses for next year"
  task :check_licenses => :environment do
    current = License.count_institutional
    newyear = License.count_institutional(Time.now.utc.next_year.at_beginning_of_year)

    puts "There are #{newyear} licenses valid for next year (currently: #{current})."
  end
end
