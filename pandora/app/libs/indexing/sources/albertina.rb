class Indexing::Sources::Albertina < Indexing::SourceSuper
  class RecordEmitter
    def initialize(document)
      @document = document
    end

    def each
      @document.each do |reader|
        next unless reader.name == 'record'
        next unless reader.namespace_uri == 'http://www.openarchives.org/OAI/2.0/'
        next unless reader.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT

        doc = Nokogiri::XML(reader.outer_xml)

        # since we ripped the node text from the enclosing document without
        # context information, we need to collect and add the xml namespaces
        doc.collect_namespaces.each do |prefix, href|
          next if prefix == 'xmlns'
          doc.root.add_namespace(prefix.split(':').last, href)
        end

        yield doc
      end
    end

    def count
      @count ||= `cat '#{@document.source.path}' | grep '<record>' | wc -l`.to_i
    end
  end

  def records
    RecordEmitter.new(document)
  end

  def exclude?
    inventory_no.is_a?(String) && inventory_no.match?(/^ALA/)
  end

  def record_id
    extract(record, '//oai:header/oai:identifier').first
  end

  def inventory_no
    extract(pc, 'dc:identifier[2]').first
  end

  def path
    result = extract(ore, 'edm:object').first
    result.gsub /400$/, '1920'
  end

  def artist
    pc.xpath('dc:creator').map do |c|
      name = c.text.strip
      dating = c.attr('creatordated').strip.presence
      dating ? "#{name} (#{dating})" : name
    end
  end

  def date
    extract(pc, 'dcterms:temporal').first
  end

  def date_range
    super(date)
  end

  def collection
    extract(pc, 'dc:type').first
  end

  def source_url
    extract(pc, 'edm:isshownat')
  end

  def rights_work
    'gemeinfrei'
  end

  def rights_reproduction
    extract(ore, 'edm:rights')
  end

  def material_technique
    extract(pc, 'dcterms:medium')
  end

  def genre
    extract(pc, 'dc:subject')
  end

  def language
    extract(pc, 'dc:language')
  end

  def inscription
    extract(pc, 'oai:inscriptions')
  end

  def size
    extract(pc, 'dcterms:extent')
  end

  def title
    extract(pc, 'dc:title')
  end

  def credits
    "Albertina, Wien, Österreich"
  end

  def location
    "Albertina, Wien, Österreich"
  end


  protected

    def ore
      rdf.xpath('//ore:Aggregation')
    end

    def rdf
      record.xpath('//rdf:RDF')
    end

    def pc
      rdf.xpath('//edm:ProvidedCHO')
    end

    def extract(node, xpath)
      node.xpath(xpath).map{|e| e.text.strip}.uniq
    end

end

# example xml record:
# 
# <record>
#   <header>
#     <identifier>Albertina_tms_10003</identifier>
#     <datestamp>2022-03-10T21:54:00Z</datestamp>
#   </header>
#   <rdf:RDF xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:edm="http://www.europeana.eu/schemas/edm/" xmlns:wgs84_pos="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:rdaGr2="http://rdvocab.info/ElementsGr2/" xmlns:oai="http://www.openarchives.org/OAI/2.0/" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:ore="http://www.openarchives.org/ore/terms/" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:dcterms="http://purl.org/dc/terms/">
#     <edm:ProvidedCHO rdf:about="tms_10003">
#       <dc:type>Graphische Sammlung  </dc:type>
#       <dcterms:temporal>Mitte 17. Jahrhundert</dcterms:temporal>
#       <dc:identifier>tms_10003</dc:identifier>
#       <dc:identifier>30358</dc:identifier>
#       <dc:identifier>Albertina_tms_10003</dc:identifier>
#       <edm:isshownat>https://sammlungenonline.albertina.at/?query=search=/record/objectnumbersearch=[30358]&amp;showtype=record</edm:isshownat>
#       <dc:creator alphasort="Anonym (Künstler_in)" creatordated="">Anonym                 </dc:creator>
#       <dc:creator alphasort="Norddeutsch (Zugeschrieben an)" creatordated="">Norddeutsch                 </dc:creator>
#       <dcterms:medium>Rötel</dcterms:medium>
#       <edm:isshownby>https://sammlungenonline.albertina.at/cc/imageproxy.ashx?server=localhost&amp;port=15001&amp;filename=images/30358.jpg&amp;cache=yes</edm:isshownby>
#       <dc:subject>Zeichnung </dc:subject>
#       <dcterms:extent>22,1 x 16,2 cm</dcterms:extent>
#       <dc:rights>Albertina, Wien, Österreich</dc:rights>
#       <dc:coverage_spatial>Deutschland</dc:coverage_spatial>
#       <dc:title xml:lang="German">Mann mit gespreizten Beinen dastehend, in der linken einen Segen, breitrandiger Hut</dc:title>
#       <dcterms:extent>22,1 x 16,2 cm</dcterms:extent>
#       <dc:language>de</dc:language>
#       <dc:publisher>Albertina, Wien, Österreich</dc:publisher>
#       <edm:type>IMAGE</edm:type>
#     </edm:ProvidedCHO>
#     <edm:WebResource rdf:about="tms_10003">
#       <dc:rights>Albertina, Wien, Österreich</dc:rights>
#       <edm:rights>http://rightsstatements.org/page/InC/1.0/?language=en</edm:rights>
#     </edm:WebResource>
#     <ore:Aggregation rdf:resource="tms_10003">
#       <edm:aggregatedCHO rdf:resource="tms_10003"/>
#       <edm:dataProvider>Albertina, Wien, Österreich</edm:dataProvider>
#       <edm:hasView rdf:resource="http://62.221.199.184:15555/images/?cache=yes"/>
#       <edm:isshownat>https://sammlungenonline.albertina.at/?query=search=/record/objectnumbersearch=[30358]&amp;showtype=record</edm:isshownat>
#       <edm:isshownby>https://sammlungenonline.albertina.at/cc/imageproxy.ashx?server=localhost&amp;port=15001&amp;filename=images/30358.jpg&amp;cache=yes</edm:isshownby>
#       <edm:object>https://sammlungenonline.albertina.at/cc/imageproxy.ashx?server=localhost&amp;port=15001&amp;filename=images/30358.jpg&amp;cache=yes&amp;maxwidth=400</edm:object>
#       <edm:provider>Albertina, Wien, Österreich</edm:provider>
#       <edm:rights>http://creativecommons.org/</edm:rights>
#     </ore:Aggregation>
#   </rdf:RDF>
# </record>
