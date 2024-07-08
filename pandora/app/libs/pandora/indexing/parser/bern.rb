class Pandora::Indexing::Parser::Bern < Pandora::Indexing::Parser::XmlReader
  def initialize(source)
    source[:kind] = Source::KINDS[:institutional]

    super(
      source,
      record_node_name: "row",
      record_node_query: "Bilder/bild/text()")
  end

  def preprocess
    Pandora.puts "#{@source[:name]}: loading MiroParser..."
    @miro_parser = Pandora::Indexing::Parser::MiroParser.new(@source[:name])

    Pandora.puts "#{@source[:name]}: loading bern_paths.xml..."
    paths_file = File.open(Rails.configuration.x.dumps_path + "bern_paths.xml")
    @mapping = Nokogiri::XML(File.open(paths_file)) do |config|
      config.noblanks
    end

    super
  end
end
