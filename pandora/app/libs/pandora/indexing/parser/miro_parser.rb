class Pandora::Indexing::Parser::MiroParser
  def initialize(source_name)
    @miro_record_ids = Rails.configuration.x.indexing_warburg_and_miro_record_ids[:miro][source_name.to_sym] || []
  end

  def miro?(record_id, source_name)
    if @miro_record_ids.include?(Pandora::Indexing::FieldProcessor.new.process_record_id(record_id, source_name)) && !@create_institutional_uploads
      true
    else
      false
    end
  end

  def miro
    'miro'
  end
end
