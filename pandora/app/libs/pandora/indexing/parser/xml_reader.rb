# https://blog.appsignal.com/2018/05/29/ruby-magic-enumerable-and-enumerator.html
#
# https://www.rubydoc.info/github/sparklemotion/nokogiri/Nokogiri/XML/NodeSet
# https://www.rubydoc.info/github/sparklemotion/nokogiri/Nokogiri/XML/Reader
# https://ruby-doc.org/core-3.0.3/Enumerator.html
# https://ruby-doc.org/core-3.0.3/Enumerable.html
class Pandora::Indexing::Parser::XmlReader < Pandora::Indexing::Parser
  def initialize(
    source,
    filenames: nil,
    record_node_name:,
    record_node_query: nil,
    object_node_name: nil,
    namespaces: false,
    namespace_uri: nil,
    records_to_exclude: [])

    super(source)

    @filenames = filenames || default_filenames
    @record_node_name = record_node_name
    @object_node_name = object_node_name
    @record_node_query = record_node_query
    @namespaces = namespaces
    @namespace_uri = namespace_uri
    @records_to_exclude = records_to_exclude
  end

  attr_writer :filename

  def preprocess
    if has_objects?
      preprocess_objects
    else
      @record_count = total
      @object_count = @record_count
    end
  end

  def preprocess_objects
    @record_object_id_count = {}
    @object_count = 0
    @record_count = 0

    enumerator = read

    enumerator.each do |doc|
      if @object_node_name && @object_node_name == doc.root.name
        @object = doc.root
      else
        record_class = new_record(doc.root)
        r_object_id = record_class.record_object_id

        unless r_object_id.blank?
          if @record_object_id_count.has_key?(r_object_id)
            @record_object_id_count[r_object_id] += 1
          else
            @record_object_id_count[r_object_id] = 1
            @object_count += 1
          end
        end

        @record_count += 1

        printf "#{@source[:name]}: #{@object_count} objects with #{@record_count} records preprocessed".ljust(60) + "\r"
      end
    end

    puts
  end

  def to_enum
    enumerator = read

    enumerator = enumerator.filter_map do |doc|
      if @object_node_name == doc.root.name
        @object = doc.root
        # We want to save the object, but filter the doc.
        false
      else
        # The parser of a source accesses the XML document of each record
        # which is set here.
        record_class = new_record(doc.root)

        if @records_to_exclude.include?(record_class.record_id.to_s)
          false
        else
          # document returns the indexable hash
          # See: app/libs/pandora/indexing/parser.rb
          document(record_class)
        end
      end
    end
  end

  def total
    enumerator = reader.lazy

    enumerator = enumerator.select do |node|
      (@object_node_name == node.name || @record_node_name == node.name) &&
      (!@namespace_uri || node.namespace_uri == @namespace_uri) &&
      (node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT)
    end

    if @record_node_query
      enumerator = enumerator.select do |node|
        if @record_node_name == node.name
          doc = Nokogiri::XML(node.outer_xml, nil)

          if @namespaces
            doc.collect_namespaces.each do |prefix, href|
              next if prefix == 'xmlns'
              doc.root.add_namespace(prefix.split(':').last, href)
            end
          else
            doc.remove_namespaces!
          end

          doc.root.xpath(@record_node_query)
        end
      end
    end

    enumerator.count - @records_to_exclude.size
  end

  protected

  def default_filenames
    directory = "#{ENV['PM_DUMPS_DIR']}#{self.class.name.demodulize.underscore}"
    filename = "#{directory}.xml"

    if File.exist?(filename) 
      [filename]
    elsif File.directory?(directory)
      children = Dir["#{directory}/*"]
      puts "#{@source[:name]}: #{children.count} dump files"
      children
    end
  end

  def read
    enumerator = reader.lazy

    # Filter irrelevant xml content.
    enumerator = enumerator.select do |node|
      (@object_node_name == node.name || @record_node_name == node.name) &&
      (!@namespace_uri || node.namespace_uri == @namespace_uri) &&
      (node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT)
    end

    enumerator = enumerator.map do |node|
      doc = Nokogiri::XML(node.outer_xml, nil)

      if @namespaces
        # Since we ripped the node text from the enclosing document without
        # context information, we need to collect and add the xml namespaces.
        doc.collect_namespaces.each do |prefix, href|
          next if prefix == 'xmlns'
          doc.root.add_namespace(prefix.split(':').last, href)
        end
      else
        doc.remove_namespaces!
      end

      doc
    end

    if @record_node_query
      enumerator = enumerator.select do |doc|
        doc_root_name = doc.root.name
        doc_root_name = "#{doc.root.namespace.prefix}:#{doc.root.name}" if @namespaces

        if @record_node_name == doc_root_name
          doc.root.xpath(@record_node_query)
        end
      end
    end

    enumerator
  end

  private

  def reader
    io = File.open(@filename)
    encoding = Nokogiri::XML(IO.readlines(io)[0]).encoding
    Nokogiri::XML::Reader.from_io(io, nil, encoding)
  end

  def new_record(record)
    @record_class_name.constantize.new(
      name: @source[:name],
      record: record,
      object: @object,
      record_object_id_count: @record_object_id_count,
      artist_parser: @artist_parser,
      date_parser: @date_parser,
      vgbk_parser: @vgbk_parser,
      warburg_parser: @warburg_parser,
      artigo_parser: @artigo_parser,
      miro_parser: @miro_parser)
  end
end
