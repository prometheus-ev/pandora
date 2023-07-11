class Pandora::Indexing::Parser::BerlinWinckelmannRecord < Pandora::Indexing::Parser::Record
  def record_id
    record.xpath('@object_id')
  end

  def path
    record.at_xpath('@relative_path')
  end

  def _label(*str)
    str = str.map { |s| %Q{"#{s}" / } }.join
    re  = /\A#{Regexp.escape(str)}/

    (record.xpath(".//LINK/@label[starts-with(.,'#{str}')]")).map { |label|
      label = label.to_s.sub(re, '')
      block_given? ? yield(label) : label
    }
  end

  def title
    "#{record.xpath('@description')}".gsub(/ ?\(..\);?\z/, "")
  end

  def date
    _label('DATIERUNG IN JAHRHUNDERTEN') { |label|
      label.delete('"').split(%r{ / }).reverse.join(' ')
    }.join(", ")
  end

  def date_range
    date = _label('DATIERUNG IN JAHRHUNDERTEN') { |label|
      label.delete('"').split(%r{ / }).reverse.join(' ')
    }.to_s

    @date_parser.date_range(date)
  end

  def epoch
    _label 'DATIERUNG IN EPOCHEN'
  end

  def maps
    _label 'KARTEN'
  end

  def location
    _label('TOPOGRAPHIE / INSTITUTION" / "Institution') { |label|
      label.delete('"').split(%r{ / }).values_at(-1, 0).join('; ')
    }
  end

  def classification
    _label 'OBJEKT / BILD'
  end

  def reception
    _label 'REZEPTION'
  end

  def discoveryplace
    record.xpath('@topographie')
  end

  def material
    _label 'MATERIAL', '_weitere Materialien'
  end

  def credits
    "#{record.xpath('@source_title')}, #{record.xpath('@title')}"
  end
end
