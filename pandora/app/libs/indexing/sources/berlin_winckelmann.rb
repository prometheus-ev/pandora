class Indexing::Sources::BerlinWinckelmann < Indexing::SourceSuper
  def records
    document.xpath('//OBJECT')
  end

  def records_to_exclude
    %w[53468 53469 53470 53471 53472 53473 53474 53475 53476 53477 53478 53479 53480 53481 53482 53483 53484 53485 53486 53487 53488 53489 53490 53491 53492 53493 53494 53495 53496 53497 53498 53499 53500 53501 53502 53503 53504 53505 53506 53507 53508 53509 53510 53511 53512 53513 53514 53515 53665 53666 53667]
  end

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

  # titel
  def title
    "#{record.xpath('@description')}".gsub(/ ?\(..\);?\z/, "")
  end

  # datierung
  def date
    _label('DATIERUNG IN JAHRHUNDERTEN') { |label|
      label.delete('"').split(%r{ / }).reverse.join(' ')
    }.join(", ")
  end

  def date_range
    date = _label('DATIERUNG IN JAHRHUNDERTEN') { |label|
      label.delete('"').split(%r{ / }).reverse.join(' ')
    }.to_s

    super(date)
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

  # material
  def material
    _label 'MATERIAL', '_weitere Materialien'
  end

  # bildnachweis
  def credits
    "#{record.xpath('@source_title')}, #{record.xpath('@title')}"
  end
end
