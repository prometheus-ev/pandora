namespace :pandora do
  desc 'show institution hierarchy'
  task institutions: :environment do
    Institution.includes(:sources, :departments).order(:title).where(campus_id: nil).each do |i|
      sources = i.sources.map{|s| s.name}.join(', ')
      sources = " (sources: #{sources})" if sources.present?
      puts "[#{i.id}, #{i.name}] #{i.title}#{sources}"
      i.departments.includes(:sources).order(:title).each do |i|
        sources = i.sources.map{|s| s.name}.join(', ')
        sources = " (sources: #{sources})" if sources.present?
        puts "  [#{i.id}, #{i.name}] #{i.title}#{sources}"
      end
    end
  end
end