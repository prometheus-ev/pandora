# Select NodeSets of a XML Reader document by element name and XPath query.
class Indexing::XmlReaderNodeSet
  # Initialize.
  # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  # BEWARE when using XmlReaderNodeSet, add source name to xml_reader_source_names 
  # in SourceParent#document
  # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  #
  # @param document [Nokogiri::XML::Document] The XML Reader document.
  # @param record_element_name [String] The name of the record element.
  # @param xpath_query [String] A XPath query that further restricts the element selection.
  def initialize(document, record_element_name, xpath_query = '.')
    @document = document
    @record_element_name = record_element_name
    @xpath_query = xpath_query
  end

  # Implementation of each to iterate over the selected document record elements.
  def each
    @document.each do |reader|
      if reader.name == @record_element_name && reader.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT
        element = Nokogiri::XML(reader.outer_xml, nil, reader.encoding).remove_namespaces!
        if sub_elements = element.root.xpath(@xpath_query)
          sub_elements.each do |sub_element|
            yield sub_element
          end
        end
      end
    end
  end

  # Count the records, need to iterate since Nokogiri::XML::Reader is used.
  def count
    count = 0

    each do |record|
      count += 1
    end

    count
  end
end
