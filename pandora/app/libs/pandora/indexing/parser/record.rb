class Pandora::Indexing::Parser::Record
  def initialize(
    name: ,
    record: ,
    object: ,
    record_object_id_count: {},
    date_parser: ,
    artist_parser: ,
    vgbk_parser: ,
    warburg_parser: ,
    artigo_parser: ,
    miro_parser: )

    @name = name
    @record = record
    @object = object
    @record_object_id_count = record_object_id_count

    @artist_parser = artist_parser
    @date_parser = date_parser
    @vgbk_parser = vgbk_parser
    @warburg_parser = warburg_parser
    @artigo_parser = artigo_parser
    @miro_parser = miro_parser
  end

  protected

  def generate_record_id(record_id)
    [name, Digest::SHA1.hexdigest(record_id)].join('-')
  end

  private

  attr_reader :name
  attr_reader :record
  attr_reader :object
end
