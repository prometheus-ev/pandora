class Pandora::Indexing::Parser::ArtigoParser
  def initialize(source_name)
    filename = "#{source_name}.xml"
    keywords_file = File.open(File.join(Rails.configuration.x.dumps_path, "artigo_tags", filename))
    keywords_document = Nokogiri::XML(File.open(keywords_file)) do |config|
      config.noblanks
    end

    @keywords_by_id = begin
      results = {}

      keywords_document.xpath("//artwork").each do |artwork|
        keywords = []

        artwork.xpath('./tag').each do |tag|
          name = tag.at_xpath("@name").to_s
          language = tag.at_xpath("@language").to_s
          count = tag.at_xpath("@count").to_s
          keywords << "#{name},#{language},#{count}"
        end

        results[artwork['id']] = keywords
      end

      results
    end
  end

  def keywords(record_id)
    @keywords_by_id[record_id.to_s]
  end
end
