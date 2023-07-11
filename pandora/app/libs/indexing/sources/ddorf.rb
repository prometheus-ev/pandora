class Indexing::Sources::Ddorf < Indexing::Sources::Parents::Dilps
  def record_id
    if record.xpath('.//id/text()').to_s.blank?
      [record.xpath('imageid'), record.xpath('collectionid')]
    else
      record.xpath('.//id/text()')
    end
  end

  def path
    return miro if miro?

    path_for('duesseldorf_khi')
  end

  # bildnachweis
  def credits
    "#{record.xpath('.//literature/text()')}" +
    " S. #{record.xpath('.//page/text()')}, ".gsub(/ S\. ,/, '') +
    " Abb. #{record.xpath('.//figure/text()')}.".gsub(/ Abb\. \./, '') +
    " Taf. #{record.xpath('.//table/text()')}.".gsub(/ Taf\. \./, '')
  end

  def date_range
    d = date
    d = d.sub('7. Jh. v.Chr. / bis', '7. Jh. v.Chr.')
    d = d.sub('ca. 13480', 'ca. 1380')

    super(d)
  end

  def rights_reproduction
    record.xpath('.//copyright/text()')
  end
end
