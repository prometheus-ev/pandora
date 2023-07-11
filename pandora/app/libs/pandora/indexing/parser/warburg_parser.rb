class Pandora::Indexing::Parser::WarburgParser
  def initialize
    @warburg_record_ids_list = Rails.configuration.x.indexing_warburg_and_miro_record_ids[:warburg]
  end

  def is_record_id_a_rights_work_warburg_record_id?(record_id, name)
    if @warburg_record_ids_list.include?(Indexing::FieldProcessor.new.process_record_id(record_id, name))
      true
    else
      false
    end
  end

  def rights_work_warburg
    'rights_work_warburg'
  end
end
