class Indexing::Sources::Ddorf < Indexing::Sources::Parents::Dilps
  def record_id
    if record.xpath('.//id/text()').to_s.blank?
      [record.xpath('imageid'), record.xpath('collectionid')]
    else
      record.xpath('.//id/text()')
    end
  end

  def path
    @miro_record_ids ||= Rails.configuration.x.athene_search_record_ids['miro'][name]
    if @miro_record_ids.include?(process_record_id(record_id))
      "miro"
    else
      path_for('duesseldorf_khi')
    end
  end

  # bildnachweis
  def credits
    "#{record.xpath('.//literature/text()')}" +
    " S. #{record.xpath('.//page/text()')}, ".gsub(/ S\. ,/, '') +
    " Abb. #{record.xpath('.//figure/text()')}.".gsub(/ Abb\. \./, '') +
    " Taf. #{record.xpath('.//table/text()')}.".gsub(/ Taf\. \./, '')
  end

  def rights_reproduction
    record.xpath('.//copyright/text()')
  end
end
