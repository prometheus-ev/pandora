class Indexing::Sources::DarmstadtTu < Indexing::Sources::Parents::Dilps
  def records
    document.xpath('//row[contains(status, "reviewed")]')
  end

  def path
    path_for('darmstadt_tu')
  end

  def _credits
    @_credits ||= "#{record.xpath('.//literature/text()')}" +
      " S. #{record.xpath('.//page/text()')}, ".gsub(/ S\. ,/, '') +
    " Abb. #{record.xpath('.//figure/text()')}.".gsub(/ Abb\. \./, '')
  end

  def credits
    _credits.blank? ? "Dia-Lehrsammlung Wella" : _credits
  end

  def rights_reproduction
    "unbekannt" if _credits.blank?
  end
end
