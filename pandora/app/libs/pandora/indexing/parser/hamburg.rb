class Pandora::Indexing::Parser::Hamburg < Pandora::Indexing::Parser::Parents::Hamburg
  def preprocess
    Pandora.puts "#{@source[:name]}: loading HamburgDilpsIds..."
    @mapping = {}

    ids_file = File.open(File.join(Rails.configuration.x.dumps_path, "hamburg_dilps_ids"))
    ids_document = Nokogiri::XML(File.open(ids_file)) do |config|
      config.noblanks
    end

    ids_document.xpath('//objekt').each do |e|
      id = e.xpath('id').text
      dilps_id = e.xpath('dilps_id').text
      if id.present? && dilps_id.present?
        @mapping[id] = dilps_id
      end
    end

    super
  end
end
