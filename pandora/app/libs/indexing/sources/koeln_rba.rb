class Indexing::Sources::KoelnRba < Indexing::SourceSuper
  def records
    document.xpath('//Block[@Type="obj"]')
  end

  def record_id
    record.xpath('.//Field[@Type="8450"]/Field[@Type="8540"]/@Value')
  end

  def path
    "#{record.at_xpath('.//Field[@Type="8450"]/Field[@Type="8540"]/@Value')}.jpg"
  end

  # künstler
  def artist
    ["#{record.xpath('.//Field[@Type="ob30"]/Field[@Type="3100"]/@Value')} (#{record.xpath('.//Field[@Type="ob30"]/Field[@Type="3475"]/@Value')})"]
  end

  def artist_normalized
    an = record.xpath('.//Field[@Type="ob30"]/Field[@Type="3100"]/@Value').map { |a|
      a.to_s.split(', ').reverse.join(' ')
    }
    super(an)
  end

  # titel
  def title
    record.xpath('.//Field[@Type="5200"]/@Value')
  end

  # datierung
  def date
    record.xpath('.//Field[@Type="5060"]/Field[@Type="5064"]/@Value')
  end

  def date_range
    d = date.to_s.strip

    if d == 'um 19151915'
      d = 'um 1915'
    end

    super(d)
  end

  # standort
  def location
    "#{record.xpath('.//Field[@Type="ob28"][@Value="Verwalter"]/Field[@Type="2864"]/@Value')}, #{record.xpath('.//Field[@Type="ob28"][@Value="Verwalter"]/Field[@Type="2900"]/@Value')}"
  end

  # Format
  def size
    record.xpath('.//Field[@Type="5360"]/@Value')
  end

  # material
  def material
    "#{record.xpath('.//Field[@Type="5260"]/@Value')}; #{record.xpath('.//Field[@Type="5300"]/@Value')}"
  end

  # Technik
  def technique
    record.xpath('.//Field[@Type="5230"]/@Value')
  end

  # Gattung
  def genre
    "#{record.xpath('.//Field[@Type="5220"]/@Value')}; #{record.xpath('.//Field[@Type="5226"]/@Value')}"
  end

  def provenance
    "#{record.xpath('.//Field[@Type="ob28"][@Value="erster Vorbesitzer"]/Field[@Type="2864"]/@Value')}; #{record.xpath('.//Field[@Type="ob28"][@Value="erster Vorbesitzer"]/Field[@Type="2890"]/@Value')}; #{record.xpath('.//Field[@Type="ob28"][@Value="erster Vorbesitzer"]/Field[@Type="2910"]/@Value')}"
  end

  # abbildungsnachweis
  def credits
    "http://www.kulturelles-erbe-koeln.de/documents/obj/#{record.xpath('.//Field[@Type="5000"]/@Value')}"
  end

  def rights_work
    if is_any_artist_in_vgbk_artists_list?
      rights_work_vgbk
    end
  end

  # bildrecht
  def rights_reproduction
    location
  end

  # schlagwörter
  def iconclass
    record.xpath('.//Field[@Type="5560"]/@Value') + record.xpath('.//Field[@Type="5500"]/@Value')
  end

  def inscription
    "#{record.xpath('.//Field[@Type="5650"]/*/@Value')} (#{record.xpath('.//Field[@Type="5650"]/@Value')})".gsub(/\(\)/, "")
  end

  def inventory_no
    record.xpath('.//Field[@Type="8450"]/Field[@Type="8470"]/@Value')
  end

  # Bild in Quelldatenbank
  def source_url
    "http://www.deutschefotothek.de/obj#{record.xpath('.//Field[@Type="5000"]/@Value')}.html"
  end
end
