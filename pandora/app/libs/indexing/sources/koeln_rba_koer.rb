class Indexing::Sources::KoelnRbaKoer < Indexing::SourceSuper
  def records
    document.xpath('//Field[@Type="8450"]')
  end

  def record_id
    record.xpath('.//Field[@Type="8540"]/@Value')
  end

  def path
    "#{record.at_xpath('.//Field[@Type="8540"]/@Value')}.jpg"
  end

  def s_credits
    [record.xpath('.//Field[@Type="8460"]/@Value'), record.xpath('.//Field[@Type="8490"]/@Value'), record.xpath('.//ancestor::Block[@Type="obj"]/Field[@Type="9266"]/@Value'), record.xpath('.//ancestor::Block[@Type="obj"]/Field[@Type="8350"]/@Value')]
  end

  # künstler
  def artist
    number = record.xpath('count(ancestor::Block[@Type="obj"]/Field[@Type="ob30"])')
    (1..(number.to_i)).map{ |index|
      "#{record.xpath(".//ancestor::Block[@Type='obj']/Field[@Type='ob30'][#{index}]/Field[@Type='3100']/@Value")} (#{record.xpath(".//ancestor::Block[@Type='obj']/Field[@Type='ob30'][#{index}]/Field[@Type='3475']/@Value")})".gsub(/\(\)/, "")
    }
  end

  def artist_normalized
    an = record.xpath('.//ancestor::Block[@Type="obj"]/Field[@Type="ob30"]/Field[@Type="3100"]/@Value').map { |a|
      a.to_s.split(', ').reverse.join(' ')
    }
    super(an)
  end

  # titel
  def title
    record.xpath('.//ancestor::Block[@Type="obj"]/Field[@Type="5200"]/@Value')
  end

  # datierung
  def date
    record.xpath('.//ancestor::Block[@Type="obj"]/Field[@Type="5060"]/Field[@Type="5064"]/@Value')
  end

  def location
    "#{record.xpath('.//ancestor::Block[@Type="obj"]/Field[@Type="ob26"]/Field[@Type="2664"]/@Value')}, #{record.xpath('.//ancestor::Block[@Type="obj"]/Field[@Type="ob26"]/Field[@Type="2662"]/@Value')}, #{record.xpath('.//ancestor::Block[@Type="obj"]/Field[@Type="ob26"]/Field[@Type="2660"]/@Value')}, #{record.xpath('.//ancestor::Block[@Type="obj"]/Field[@Type="ob26"]/Field[@Type="2661"]/@Value')} (#{record.xpath('.//ancestor::Block[@Type="obj"]/Field[@Type="ob26"]/Field[@Type="266f"]/@Value')} #{record.xpath('.//ancestor::Block[@Type="obj"]/Field[@Type="ob26"]/Field[@Type="266h"]/@Value')})".gsub(/, , /, '').gsub(/\A, /, '').gsub(/\(\)/, "")
  end

  # Format
  def size
    number = record.xpath('count(ancestor::Block[@Type="obj"]/Field[@Type="5364"])')
    (1..(number.to_i)).map{ |index|
      "#{record.xpath(".//ancestor::Block[@Type='obj']/Field[@Type='5364'][#{index}]/@Value")}: #{record.xpath(".//ancestor::Block[@Type='obj']/Field[@Type='5364'][#{index}]/Field[@Type='5365']/@Value")}"
    }
  end

  # material
  def material
    "#{record.xpath('.//ancestor::Block[@Type="obj"]/Field[@Type="5260"]/@Value')}; #{record.xpath('.//ancestor::Block[@Type="obj"]/Field[@Type="5300"]/@Value')}".gsub(/\A; /, '').gsub(/; \z/, '')
  end

  # Gattung
  def genre
    "#{record.xpath('.//ancestor::Block[@Type="obj"]/Field[@Type="5220"]/@Value')}; #{record.xpath('.//ancestor::Block[@Type="obj"]/Field[@Type="5226"]/@Value')}; #{record.xpath('.//ancestor::Block[@Type="obj"]/Field[@Type="5230"]/@Value')}".gsub(/\A; /, '').gsub(/; \z/, '')
  end

  def comment
    record.xpath('.//ancestor::Block[@Type="obj"]/Field[@Type="599a"]/Field[@Type="599e"]/@Value')
  end

  def provenance
    "#{record.xpath('.//ancestor::Block[@Type="obj"]/Field[@Type="ob28"][@Value="erster Vorbesitzer"]/Field[@Type="2864"]/@Value')}; #{record.xpath('.//ancestor::Block[@Type="obj"]/Field[@Type="ob28"][@Value="erster Vorbesitzer"]/Field[@Type="2890"]/@Value')}; #{record.xpath('.//ancestor::Block[@Type="obj"]/Field[@Type="ob28"][@Value="erster Vorbesitzer"]/Field[@Type="2910"]/@Value')}".gsub(/\A; /, '').gsub(/; \z/, '')
  end

  def owner
    "#{record.xpath('.//ancestor::Block[@Type="obj"]/Field[@Type="ob28"]/Field[@Type="2864"]/@Value')}, #{record.xpath('.//ancestor::Block[@Type="obj"]/Field[@Type="ob28"]/Field[@Type="2900"]/@Value')}, #{record.xpath('.//ancestor::Block[@Type="obj"]/Field[@Type="ob28"]/Field[@Type="2910"]/@Value')}".gsub(/, , /, '').gsub(/\A, /, '').gsub(/, \z/, '')
  end

  def production
    "#{record.xpath('.//ancestor::Block[@Type="obj"]/Field[@Type="ob35"]/Field[@Type="3600"]/@Value')} (#{record.xpath('.//ancestor::Block[@Type="obj"]/Field[@Type="ob35"]/Field[@Type="3975"]/@Value')})".gsub(/\(\)/, "")
  end

  # bildrecht
  def rights_reproduction
    "#{record.xpath('.//Field[@Type="8460"]/@Value')}; #{record.xpath('.//Field[@Type="8490"]/@Value')}".gsub(/\A; /, '').gsub(/; \z/, '')
  end

  def rights_work
    rights_work = record.xpath('.//ancestor::Block[@Type="obj"]/Field[@Type="9266"]/@Value')

    if is_any_artist_in_vgbk_artists_list?
      rights_work.to_a + [rights_work_vgbk]
    end
  end

  # abbildungsnachweis
  def credits
    "http://www.kulturelles-erbe-koeln.de/documents/obj/#{record.xpath('.//ancestor::Block[@Type="obj"]/Field[@Type="5000"]/@Value')}"
  end

  def literature
    record.xpath('.//ancestor::Block[@Type="obj"]/Field[@Type="8350"]/@Value')
  end

  # schlagwörter
  def iconclass
    record.xpath('.//ancestor::Block[@Type="obj"]/Field[@Type="5560"]/@Value') + record.xpath('.//ancestor::Block[@Type="obj"]/Field[@Type="5500"]/@Value')
  end

  def inscription
    "#{record.xpath('.//ancestor::Block[@Type="obj"]/Field[@Type="5650"][@Value="Inschrift"]/Field[@Type="5686"]/@Value')} (#{record.xpath('.//ancestor::Block[@Type="obj"]/Field[@Type="5650"][@Value="Inschrift"]/Field[@Type="5694"]/@Value')})".gsub(/\(\)/, "")
  end

  def signature
    record.xpath('.//ancestor::Block[@Type="obj"]/Field[@Type="5650"][@Value="Signatur"]/Field[@Type="5686"]/@Value')
  end

  def inventory_no
    record.xpath('.//Field[@Type="8470"]/@Value')
  end

  # Bild in Quelldatenbank
  def source_url
    "http://www.kulturelles-erbe-koeln.de/documents/obj/#{record.xpath('.//ancestor::Block[@Type="obj"]/Field[@Type="5000"]/@Value')}"
  end
end
